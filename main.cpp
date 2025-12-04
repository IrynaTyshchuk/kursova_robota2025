#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>
#include <QTranslator>
#include <QLibraryInfo>
#include "Database.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("YourOrganization");
    QCoreApplication::setApplicationName("diary");

    QGuiApplication app(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "KURS_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName, QLibraryInfo::path(QLibraryInfo::TranslationsPath))) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;

    Database dbManager;

    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("diary", "Main");

    return app.exec();
}
