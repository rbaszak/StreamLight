#include "menusettings.h"

#include <QCoreApplication>
#include <QKeyEvent>
#include <QMouseEvent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSettings>
#include <SDL.h>
#include <cmath>
#include <algorithm>

namespace {
QQuickItem* clickableAt(QQuickItem* item, const QPointF& scenePosition)
{
    if (!item->isVisible() || !item->isEnabled()) return nullptr;
    const bool inside = item->contains(item->mapFromScene(scenePosition));
    if (item->clip() && !inside) return nullptr;
    auto children = item->childItems();
    std::stable_sort(children.begin(), children.end(),
                     [](QQuickItem* a, QQuickItem* b) { return a->z() < b->z(); });
    for (auto i = children.crbegin(); i != children.crend(); ++i)
        if (auto target = clickableAt(*i, scenePosition)) return target;
    // Qt Quick Controls and the custom controls built with MouseArea. Looking up
    // the target at press time also works with Qt 6 pointer delivery, where the
    // legacy window mouseGrabberItem() can already be null at release time.
    if (inside && (item->inherits("QQuickMouseArea") || item->inherits("QQuickAbstractButton")))
        return item;
    return nullptr;
}
}

QVector<float> MenuAudio::samples(Tone tone, int volume)
{
    // Original soft, pitched taps. Smooth attack/release avoids clicks; no samples
    // from Steam or other applications are bundled. Mono float PCM at 48 kHz.
    const double duration = tone == Navigate ? 0.045 : 0.105;
    const double frequency = tone == Navigate ? 660.0 : tone == Confirm ? 880.0 : 520.0;
    QVector<float> pcm(static_cast<int>(48000 * duration));
    const double gain = qBound(0, volume, 100) / 100.0 * 0.18;
    constexpr double pi = 3.14159265358979323846;
    for (int i = 0; i < pcm.size(); ++i) {
        double t = i / 48000.0;
        double envelope = std::sin(pi * i / (pcm.size() - 1));
        envelope *= envelope * std::exp(-t / 0.045);
        double note = std::sin(2 * pi * frequency * t);
        if (tone != Navigate)
            note = 0.7 * note + 0.3 * std::sin(2 * pi * frequency * 1.5 * t);
        pcm[i] = static_cast<float>(gain * envelope * note);
    }
    return pcm;
}

MenuSettings::MenuSettings(QObject* parent) : QObject(parent)
{
    QSettings settings;
    m_DefaultHost = settings.value("menu/defaultHost").toString();
    m_SoundsEnabled = settings.value("menu/soundsEnabled", true).toBool();
    m_Volume = qBound(0, settings.value("menu/soundVolume", 25).toInt(), 100);
    m_Clock.start();
    qApp->installEventFilter(this);
}

MenuSettings::~MenuSettings() { closeAudio(); }

void MenuSettings::setDefaultHost(const QString& uuid)
{
    if (m_DefaultHost == uuid) return;
    m_DefaultHost = uuid;
    QSettings().setValue("menu/defaultHost", uuid);
    emit changed();
}

void MenuSettings::setSoundsEnabled(bool enabled)
{
    if (m_SoundsEnabled == enabled) return;
    m_SoundsEnabled = enabled;
    if (enabled) m_LastOpenAttempt = -10000;
    QSettings().setValue("menu/soundsEnabled", enabled);
    if (!enabled) closeAudio();
    emit changed();
}

void MenuSettings::setSoundVolume(int volume)
{
    volume = qBound(0, volume, 100);
    if (m_Volume == volume) return;
    m_Volume = volume;
    QSettings().setValue("menu/soundVolume", volume);
    if (!volume) closeAudio();
    emit changed();
}

void MenuSettings::setActive(bool active)
{
    if (m_Active == active) return;
    m_Active = active;
    if (active) m_LastOpenAttempt = -10000;
    // Never hold the UI audio device during a stream or while in the background.
    if (!active) closeAudio();
    emit activeChanged();
}

void MenuSettings::closeAudio()
{
    if (m_Device) SDL_CloseAudioDevice(m_Device);
    m_Device = 0;
    if (m_AudioInitialized) SDL_QuitSubSystem(SDL_INIT_AUDIO);
    m_AudioInitialized = false;
}

void MenuSettings::play(MenuAudio::Tone tone)
{
    const qint64 now = m_Clock.elapsed();
    if (!m_Active || !m_SoundsEnabled || m_Volume == 0) return;
    // Coalesce keyboard repeats and hover/focus transitions from the same input.
    if (now - m_LastSound < (tone == MenuAudio::Navigate ? 85 : 35)) return;
    if (!m_Device) {
        if (now - m_LastOpenAttempt < 5000) return;
        m_LastOpenAttempt = now;
        if (SDL_InitSubSystem(SDL_INIT_AUDIO) != 0) return;
        m_AudioInitialized = true;
        SDL_AudioSpec requested{};
        requested.freq = 48000;
        requested.format = AUDIO_F32SYS;
        requested.channels = 1;
        requested.samples = 512;
        m_Device = SDL_OpenAudioDevice(nullptr, 0, &requested, nullptr, 0);
        if (!m_Device) { closeAudio(); return; }
        SDL_PauseAudioDevice(m_Device, 0);
    }
    auto pcm = MenuAudio::samples(tone, m_Volume);
    // Keep a bounded queue when a controller is held down. New actions take priority.
    SDL_ClearQueuedAudio(m_Device);
    SDL_QueueAudio(m_Device, pcm.constData(), pcm.size() * sizeof(float));
    m_LastSound = now;
}

void MenuSettings::navigate()
{
    // Ignore synthetic hover on initial load, resize, or returning from a stream.
    if (m_Clock.elapsed() - m_LastInput < 250) play(MenuAudio::Navigate);
}

void MenuSettings::preview()
{
    // A volume change should demonstrate the new volume, replacing the click
    // emitted just before the control handled the mouse/key event.
    m_LastSound = -1000;
    play(MenuAudio::Confirm);
}

bool MenuSettings::eventFilter(QObject* watched, QEvent* event)
{
    auto window = qobject_cast<QQuickWindow*>(watched);
    if (!window || !m_Active) return false;
    if (event->type() == QEvent::MouseMove) m_LastInput = m_Clock.elapsed();
    if (event->type() == QEvent::MouseButtonPress) {
        auto mouse = static_cast<QMouseEvent*>(event);
        if (mouse->button() == Qt::LeftButton) {
            m_PressPosition = mouse->position();
            m_PressedItem = clickableAt(window->contentItem(), m_PressPosition);
        }
    }
    if (event->type() == QEvent::KeyPress || event->type() == QEvent::MouseButtonPress
        || event->type() == QEvent::Wheel || event->type() == QEvent::TouchBegin) {
        m_LastInput = m_Clock.elapsed();
        emit userInteraction();
    }
    if (event->type() == QEvent::KeyPress) {
        auto key = static_cast<QKeyEvent*>(event);
        auto focus = window->activeFocusItem();
        if (focus && focus->flags().testFlag(QQuickItem::ItemAcceptsInputMethod)) return false;
        switch (key->key()) {
        case Qt::Key_Left: case Qt::Key_Right: case Qt::Key_Up: case Qt::Key_Down:
        case Qt::Key_Tab: case Qt::Key_Backtab: case Qt::Key_PageUp: case Qt::Key_PageDown:
        case Qt::Key_F14: case Qt::Key_F15: case Qt::Key_F16: case Qt::Key_F17:
            play(MenuAudio::Navigate); break;
        case Qt::Key_Return: case Qt::Key_Enter: case Qt::Key_Space:
            if (!key->isAutoRepeat()) play(MenuAudio::Confirm);
            break;
        case Qt::Key_Escape: case Qt::Key_Back:
            if (!key->isAutoRepeat()) play(MenuAudio::Back);
            break;
        default: break;
        }
    } else if (event->type() == QEvent::MouseButtonRelease) {
        auto mouse = static_cast<QMouseEvent*>(event);
        auto grabber = m_PressedItem.data();
        if (mouse->button() == Qt::LeftButton && grabber && grabber->isEnabled()
            && grabber->isVisible()
            && (mouse->position() - m_PressPosition).manhattanLength() < 12
            && grabber->contains(grabber->mapFromScene(mouse->position()))
            && !grabber->flags().testFlag(QQuickItem::ItemAcceptsInputMethod))
            play(MenuAudio::Confirm);
        m_PressedItem.clear();
    }
    return false; // Sound must never consume navigation or gamepad input.
}
