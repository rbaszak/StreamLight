#include <QtTest>
#include <QJSEngine>
#include <QSettings>
#include <QTemporaryDir>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQmlEngine>
#include <cmath>
#include <SDL.h>
#include "menusettings.h"

class MenuTests : public QObject
{
    Q_OBJECT
private slots:
    void init() { QSettings().clear(); }
    void preferencesPersist() {
        {
            MenuSettings settings;
            QCOMPARE(settings.soundVolume(), 25);
            QVERIFY(settings.soundsEnabled());
            QVERIFY(settings.defaultHost().isEmpty());
            settings.setDefaultHost("stable-uuid/");
            settings.setSoundsEnabled(false);
            settings.setSoundVolume(50);
        }
        MenuSettings settings;
        QCOMPARE(settings.defaultHost(), QString("stable-uuid/"));
        QVERIFY(!settings.soundsEnabled());
        QCOMPARE(settings.soundVolume(), 50);
        settings.setDefaultHost("");
        settings.setSoundVolume(500);
        QCOMPARE(settings.soundVolume(), 100);
        MenuSettings reloaded;
        QVERIFY(reloaded.defaultHost().isEmpty());
    }
    void tonesAreSoftAndBounded() {
        for (auto tone : {MenuAudio::Navigate, MenuAudio::Confirm, MenuAudio::Back}) {
            const auto pcm = MenuAudio::samples(tone, 100);
            QVERIFY(pcm.size() >= 2000 && pcm.size() <= 5100);
            QVERIFY(qAbs(pcm.front()) < 0.00001f);
            QVERIFY(qAbs(pcm.back()) < 0.00001f);
            double energy = 0;
            for (float value : pcm) {
                QVERIFY(std::isfinite(value));
                QVERIFY(qAbs(value) <= 0.18f);
                energy += value * value;
            }
            QVERIFY(energy > 0.1);
            for (float value : MenuAudio::samples(tone, 0)) QCOMPARE(value, 0.0f);
        }
        QVERIFY(MenuAudio::samples(MenuAudio::Confirm, 25) != MenuAudio::samples(MenuAudio::Back, 25));
    }
    void audioLifecycle() {
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
        MenuSettings settings;
        settings.preview(); // Startup/background: no audio device at all.
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
        settings.setActive(true);
        settings.preview();
        QVERIFY(SDL_WasInit(SDL_INIT_AUDIO));
        settings.setActive(false); // Entering stream releases only our audio reference.
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
        settings.setSoundsEnabled(false);
        settings.setActive(true);
        settings.preview();
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
    }
    void inputDoesNotGetConsumed() {
        MenuSettings settings;
        settings.setSoundsEnabled(false);
        settings.setActive(true);
        QQuickWindow window;
        QSignalSpy inputs(&settings, &MenuSettings::userInteraction);
        QTest::keyClick(&window, Qt::Key_Down);
        QCOMPARE(inputs.count(), 1);
        settings.setActive(false);
        QTest::keyClick(&window, Qt::Key_Return);
        QCOMPARE(inputs.count(), 1);
    }
    void mouseClicksRespectDisabledControls() {
        MenuSettings settings;
        settings.setActive(true);
        QQmlEngine engine;
        QQmlComponent component(&engine);
        component.setData(R"(
            import QtQuick
            import QtQuick.Window
            Window {
                id: testWindow
                width: 100; height: 100; visible: true
                property bool available: true
                property int clicks: 0
                MouseArea {
                    anchors.fill: parent
                    enabled: testWindow.available
                    onClicked: testWindow.clicks++
                }
            }
        )", QUrl());
        QScopedPointer<QObject> root(component.create());
        QVERIFY2(root, qPrintable(component.errorString()));
        auto window = qobject_cast<QQuickWindow*>(root.data());
        QVERIFY(window);
        QVERIFY(QTest::qWaitForWindowExposed(window));
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, QPoint(50, 50));
        QCOMPARE(window->property("clicks").toInt(), 1);
        QVERIFY(SDL_WasInit(SDL_INIT_AUDIO));
        settings.setActive(false);
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
        settings.setActive(true);
        window->setProperty("available", false);
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, QPoint(50, 50));
        QCOMPARE(window->property("clicks").toInt(), 1);
        QVERIFY(!SDL_WasInit(SDL_INIT_AUDIO));
    }
    void startupHostPolicy() {
        QFile file(QStringLiteral("/src/app/gui/StartupHost.js"));
        QVERIFY(file.open(QIODevice::ReadOnly));
        QString source = QString::fromUtf8(file.readAll());
        source.remove(0, source.indexOf('\n') + 1); // QML library pragma
        QJSEngine js;
        QVERIFY(!js.evaluate(source).isError());
        auto result = js.evaluate(R"(
            var a = {hostId:'a/',online:true,paired:true,statusUnknown:false,serverSupported:true};
            var b = {hostId:'b/',online:true,paired:true,statusUnknown:false,serverSupported:true};
            var checks = [];
            checks.push(choose([a,b], 'b/').index === 1 && choose([a,b], 'b/').open);
            checks.push(choose([b,a], 'b/').index === 0); // reordered hosts
            b.name = 'renamed'; checks.push(choose([b], 'b/').open);
            checks.push(choose([a], 'missing/').index === -1);
            checks.push(choose([a], '').index === -1);
            b.online = false; checks.push(!choose([b], 'b/').open);
            b.online = true; b.paired = false; checks.push(!choose([b], 'b/').open);
            b.paired = true; b.statusUnknown = true; checks.push(!choose([b], 'b/').open);
            b.statusUnknown = false; b.serverSupported = false; checks.push(!choose([b], 'b/').open);
            checks.push(choose([a], 'a/tailscale').index === -1);
            checks.push(choose([null,a], 'a/').index === 1);
            checks.every(function(v) { return v; });
        )");
        QVERIFY2(!result.isError(), qPrintable(result.toString()));
        QVERIFY(result.toBool());
    }
};

int main(int argc, char** argv) {
    qputenv("SDL_AUDIODRIVER", "dummy");
    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName("StreamLightTests");
    QCoreApplication::setApplicationName("Menu");
    QTemporaryDir settingsDir;
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, settingsDir.path());
    MenuTests tests;
    return QTest::qExec(&tests, argc, argv);
}
#include "test_menu.moc"
