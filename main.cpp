#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>
#include <QTranslator>
#include <QLibraryInfo>
#include "Database.h"
#include "NotificationManager.h"
#include "DesktopNotification.h"
#include <QApplication>
#include <QIcon> // Додано для QIcon

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("YourOrganization");
    QCoreApplication::setApplicationName("diary");

    QApplication app(argc, argv); // Використовуємо QApplication

    // --- ВСТАНОВЛЕННЯ ІКОНКИ ЗАСТОСУНКУ ---
    // Це необхідно для коректної роботи QSystemTrayIcon та усунення попередження "No Icon set".
    // Використовуємо шлях до вашої іконки з resurs.qrc:
    app.setWindowIcon(QIcon(":/icons/images.png"));

    QTranslator translator;

    // ... (Код для завантаження перекладу без змін)
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "KURS_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName, QLibraryInfo::path(QLibraryInfo::TranslationsPath))) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;

    // --- ІНІЦІАЛІЗАЦІЯ C++ ОБ'ЄКТІВ ---
    Database dbManager;
    DesktopNotification desktopNotification;
    NotificationManager notificationManager(&dbManager);

    // *** ПІДКЛЮЧЕННЯ ДО QML-КОНТЕКСТУ ***
    // (Ця частина вже була коректною і забезпечує доступ з QML)
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("desktopNotification", &desktopNotification);
    engine.rootContext()->setContextProperty("notificationManager", &notificationManager);

    // --- З'ЄДНАННЯ СИГНАЛІВ ---
    // NotificationManager (час спрацював) -> DesktopNotification (показати сповіщення)
    QObject::connect(&notificationManager, &NotificationManager::notificationTriggered,
                     &desktopNotification, &DesktopNotification::showNotification);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("diary", "Main");

    return app.exec();
}
