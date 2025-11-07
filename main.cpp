#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QTranslator>
#include <QQmlContext>
#include <QLibraryInfo>
#include "Database.h"
#include <QUrl>

int main(int argc, char *argv[])
{
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

    const QUrl url(QStringLiteral("MForm.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl) {
                             qCritical("Критична помилка: Не вдалося завантажити кореневий компонент QML! Перевірте шлях MForm.qml.");
                             QCoreApplication::exit(-1);
                         }
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
