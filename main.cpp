#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QTranslator>
#include <QQmlContext>
#include <QLibraryInfo> // <<<< ВИПРАВЛЕННЯ: Додано необхідний заголовок
#include "Database.h"
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Встановлення перекладача (залишаємо для можливості додавання в майбутньому)
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

    // Ініціалізація та реєстрація Database
    Database dbManager;
    engine.rootContext()->setContextProperty("dbManager", &dbManager);


    // 💡 КРИТИЧНЕ ВИПРАВЛЕННЯ: Видалено engine.addImportPath("qrc:/"), оскільки QRC не використовується.

    // 💡 КРИТИЧНЕ ВИПРАВЛЕННЯ: Завантажуємо кореневий QML-файл локальним шляхом.
    // Якщо MForm.qml лежить поруч з KURS.exe, використовуємо простий шлях.
    const QUrl url(QStringLiteral("MForm.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl) {
                             qCritical("Критична помилка: Не вдалося завантажити кореневий компонент QML! Перевірте шлях MForm.qml.");
                             QCoreApplication::exit(-1);
                         }
                     }, Qt::QueuedConnection);

    // Запускаємо завантаження QML-файлу
    engine.load(url);

    return app.exec();
}
