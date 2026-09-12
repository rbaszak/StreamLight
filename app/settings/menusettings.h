#pragma once

#include <QObject>
#include <QElapsedTimer>
#include <QVector>
#include <QPointer>
#include <QPointF>
#include <SDL_audio.h>

class QQuickItem;

namespace MenuAudio {
enum Tone { Navigate, Confirm, Back };
QVector<float> samples(Tone tone, int volume);
}

class MenuSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString defaultHost READ defaultHost WRITE setDefaultHost NOTIFY changed)
    Q_PROPERTY(bool soundsEnabled READ soundsEnabled WRITE setSoundsEnabled NOTIFY changed)
    Q_PROPERTY(int soundVolume READ soundVolume WRITE setSoundVolume NOTIFY changed)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
public:
    explicit MenuSettings(QObject* parent = nullptr);
    ~MenuSettings() override;
    QString defaultHost() const { return m_DefaultHost; }
    bool soundsEnabled() const { return m_SoundsEnabled; }
    int soundVolume() const { return m_Volume; }
    bool active() const { return m_Active; }
    void setDefaultHost(const QString& uuid);
    void setSoundsEnabled(bool enabled);
    void setSoundVolume(int volume);
    void setActive(bool active);
    Q_INVOKABLE void navigate();
    Q_INVOKABLE void preview();
signals:
    void changed();
    void activeChanged();
    void userInteraction();
protected:
    bool eventFilter(QObject* watched, QEvent* event) override;
private:
    void play(MenuAudio::Tone tone);
    void closeAudio();
    QString m_DefaultHost;
    bool m_SoundsEnabled = true;
    int m_Volume = 25;
    bool m_Active = false;
    bool m_AudioInitialized = false;
    SDL_AudioDeviceID m_Device = 0;
    QElapsedTimer m_Clock;
    qint64 m_LastInput = -1000;
    qint64 m_LastSound = -1000;
    qint64 m_LastOpenAttempt = -10000;
    QPointer<QQuickItem> m_PressedItem;
    QPointF m_PressPosition;
};
