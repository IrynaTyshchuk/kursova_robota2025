#ifndef DATABASE_H
#define DATABASE_H
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDebug>
#include <QString>
#include <QByteArray>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);

    // Функції, доступні з QML через Q_INVOKABLE
    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE bool loginUser(const QString &email, const QString &password);

private:
    QSqlDatabase db;

    // Ініціалізація підключення до БД та створення таблиць
    void initializeDatabase();

    // Функція хешування
    QByteArray hashPassword(const QString &password);
};

#endif // DATABASE_H
