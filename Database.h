#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    static int getFixedFontId();
    static QString getFixedFontName();
    Q_INVOKABLE int getDayOfWeekId(const QString &dateString);
    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE QVariant loginUser(const QString &email, const QString &password);
    Q_INVOKABLE bool saveUserSettings(int userId, int accentColorId, int backgroundColorId, int textColorId);
    Q_INVOKABLE QVariantList getAccentColors();
    Q_INVOKABLE QVariantList getBackgroundColors();
    Q_INVOKABLE QVariantList getTextColors();
    Q_INVOKABLE QVariantList getTaskTypes();
    Q_INVOKABLE QVariantList getPriorities();
    Q_INVOKABLE QVariantList getActivities();
    Q_INVOKABLE QVariantList getRepeatOptions();
    Q_INVOKABLE QVariant addNote(int userId, const QVariantMap &noteData);
    Q_INVOKABLE QVariantList getNotesForUser(int userId);
    Q_INVOKABLE bool deleteNote(int noteId);
    Q_INVOKABLE int getColorIdByHex(const QString &tableName, const QString &hex);
private:
    QSqlDatabase db;
    void initializeDatabase();
    QByteArray hashPassword(const QString &password);
    QString hashPasswordToHex(const QString &password);
    int getUserIdByEmail(const QString &email);
    int getIdOrCreate(const QString &tableName, const QString &columnName, const QString &value);
    int getOrCreateActivity(int userId, const QString &activityName);
    QString getColorHexById(const QString &tableName, int colorId);
};

#endif // DATABASE_H
