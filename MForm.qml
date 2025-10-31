import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls.Material 6.0
import QtQuick.Dialogs 6.0
import QtQuick.Window 6.0
ApplicationWindow {
    id: window
    visible: true
    title: qsTr("Щоденник — Вхід / Реєстрація")
    Material.theme: Material.Light
    width: stack.currentItem ? stack.currentItem.implicitWidth : 420
    height: 640
    property color currentThemeColor: Material.color(Material.Indigo)
    Component {
        id: messageDialog
        MessageDialog {
            id: dialog
            title: qsTr("Повідомлення")
            text: ""

            function show(message, isError) {
                dialog.text = message
                dialog.open()
            }
        }
    }
    Loader { id: dialogLoader; sourceComponent: messageDialog }

    Component {
        id: newNotePage
        Page {
            implicitWidth: 420 * 1.5
            implicitHeight: 640

            property StackView stackView: null
            property var dialog: null
            property var notesModel: null

            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    ToolButton {
                        contentItem: Label { text: qsTr("👈"); font.pixelSize: 24 }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: qsTr("Створення нового запису")
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                Frame {
                    width: parent.width
                    padding: 20
                    ColumnLayout {
                        width: parent.width - padding * 2
                        spacing: 15
                        TextField { id: titleField; placeholderText: qsTr("Заголовок"); Layout.fillWidth: true; font.pixelSize: 18 }
                        TextArea {
                            id: contentArea
                            placeholderText: qsTr("Ваші думки та події...")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            wrapMode: TextEdit.Wrap
                            font.pixelSize: 16
                            background: Rectangle { color: Material.color(Material.Grey, Material.Shade100); radius: 8; border.width: 1; border.color: Material.color(Material.Grey, Material.Shade300) }
                        }
                        Button {
                            text: qsTr("Зберегти запис")
                            Layout.fillWidth: true
                            Material.background: Material.color(Material.Green, Material.Shade500)
                            onClicked: {
                                if (titleField.text.trim() === "" || contentArea.text.trim() === "") {
                                    if (dialog) dialog.show(qsTr("Будь ласка, заповніть заголовок та текст запису."), true)
                                    return
                                }
                                if (notesModel) {
                                    notesModel.append({ "title": titleField.text, "content": contentArea.text, "date": new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd") })
                                }
                                titleField.clear(); contentArea.clear()
                                if (dialog) dialog.show(qsTr("Запис успішно збережено!"), false)
                                stackView.pop()
                            }
                        }
                        Button {
                            text: qsTr("Скасувати")
                            Layout.fillWidth: true
                            Material.background: Material.color(Material.Red)
                            onClicked: stackView.pop()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: diaryContent
        Page {
            id: diaryPage

            implicitWidth: 420 * 1.5
            implicitHeight: 640

            ListModel {
                id: notesModel
            }

            property string userName: qsTr("Користувач")

            readonly property StackView stackRef: stack
            readonly property var dialogRef: dialogLoader.item

            property bool showTutorialArrow: notesModel.count === 0

            header: ToolBar {
                id: diaryToolBar
                contentHeight: 60
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            Label { text: qsTr("Ваш щоденник"); font.pixelSize: 18; Layout.alignment: Qt.AlignVCenter }
                            TextField {
                                id: searchField
                                placeholderText: qsTr("Пошук (Назва/Дата)")
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                background: Rectangle { color: Material.color(Material.Grey, Material.Shade200); radius: 5 }
                            }
                            ToolButton {
                                Layout.alignment: Qt.AlignVCenter
                                contentItem: Label { text: "⚙️"; font.pixelSize: 24 }
                                onClicked: drawer.open()
                            }
                        }
                    }
                }
            }

            Drawer {
                id: drawer
                edge: Qt.RightEdge
                width: parent.width * 0.5
                height: parent.height

                ColumnLayout {
                    width: parent.width
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 20

                    Rectangle {
                        id: avatarWrapper
                        Layout.preferredWidth: 80; Layout.preferredHeight: 80
                        Layout.alignment: Qt.AlignHCenter
                        radius: avatarWrapper.width / 2
                        clip: true

                        Image {
                            id: avatar
                            source: "qrc:/images/1.jpg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                        }

                        MouseArea { anchors.fill: parent; onClicked: dialogRef.show(qsTr("Виберіть нове фото аватара..."), false) }
                    }

                    Label {
                        text: diaryPage.userName
                        font.pixelSize: 16;
                        font.bold: true;
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 5
                    }

                    Label { text: qsTr("Налаштування щоденника"); font.pixelSize: 18; font.bold: true; Layout.topMargin: 20 }

                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: qsTr("Колір теми:"); Layout.fillWidth: true }
                        Button {
                            text: qsTr("Змінити")
                            Material.background: window.currentThemeColor
                            onClicked: {
                                window.currentThemeColor = (window.currentThemeColor === Material.color(Material.Indigo)) ? Material.color(Material.Red) : Material.color(Material.Indigo);
                                dialogRef.show(qsTr("Колір теми змінено."), false);
                            }
                        }
                    }

                    Label { text: qsTr("Шрифт тексту (Наприклад, Times New Roman)"); Layout.fillWidth: true }

                    Label { text: qsTr("Колір тексту"); Layout.fillWidth: true }

                    Button {
                        text: qsTr("Вийти з акаунта")
                        Layout.fillWidth: true
                        Layout.topMargin: 50
                        Material.background: Material.color(Material.Red)
                        onClicked: {
                            drawer.close();
                            stackRef.replace(loginPage);
                            dialogRef.show(qsTr("Вихід успішний."), false);
                        }
                    }
                }
            }

            ColumnLayout {
                id: emptyState
                visible: showTutorialArrow
                anchors.centerIn: diaryPage.contentItem
                spacing: 10
                Label { text: qsTr("Нагадувань ще нема"); font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter }
                Label { text: qsTr("Почніть вести свій щоденник"); font.pixelSize: 14; color: Material.color(Material.Grey); Layout.alignment: Qt.AlignHCenter }
                Button {
                    text: qsTr("➕ Створити перший запис")
                    Layout.alignment: Qt.AlignHCenter
                    Material.background: Material.color(Material.Green)
                    Layout.topMargin: 20
                    onClicked: stackRef.push({
                        item: newNotePage,
                        properties: { stackView: stackRef, dialog: dialogRef, notesModel: notesModel }
                    })
                }
            }

            ListView {
                id: notesList
                visible: !showTutorialArrow
                anchors.top: diaryPage.contentItem.top
                anchors.bottom: diaryPage.contentItem.bottom
                anchors.left: diaryPage.contentItem.left
                anchors.right: diaryPage.contentItem.right
                anchors.margins: 10

                model: notesModel

                delegate: Rectangle {
                    height: 80
                    width: notesList.width
                    color: notesList.currentIndex === index ? Material.color(Material.Blue, Material.Shade100) : "white"
                    radius: 8
                    border.color: Material.color(Material.Grey, Material.Shade300)
                    border.width: 1
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            notesList.currentIndex = index
                            dialogRef.show(qsTr("Вибрано запис: ") + model.title, false)
                        }
                    }

                    RowLayout {
                        spacing: 10
                        anchors.fill: parent
                        anchors.margins: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label { text: model.title; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                            Label { text: model.date; font.pixelSize: 12; color: Material.color(Material.Grey, Material.Shade700) }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: registerPage
        Page {
            title: qsTr("Реєстрація")

            implicitWidth: 420
            implicitHeight: 640

            ScrollView {
                anchors.fill: parent
                ColumnLayout {
                    width: parent.width; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: 20; spacing: 10
                    Layout.maximumWidth: parent.width * 0.85; Layout.fillWidth: true

                    Label { text: qsTr("Створення акаунту"); font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: nameField; placeholderText: qsTr("Ім'я"); Layout.fillWidth: true }
                    TextField { id: regEmail; placeholderText: qsTr("Електронна пошта"); Layout.fillWidth: true }
                    TextField { id: regPass1; placeholderText: qsTr("Пароль"); echoMode: TextInput.Password; Layout.fillWidth: true }
                    TextField { id: regPass2; placeholderText: qsTr("Підтвердіть пароль"); echoMode: TextInput.Password; Layout.fillWidth: true }

                    Button {
                        text: qsTr("Зареєструватися")
                        Layout.fillWidth: true
                        Material.background: Material.color(Material.Green)
                        onClicked: {
                            if (regPass1.text !== regPass2.text) { dialogLoader.item.show(qsTr("Паролі не співпадають."), true); return }
                            if (nameField.text === "" || regEmail.text === "" || regPass1.text === "") { dialogLoader.item.show(qsTr("Будь ласка, заповніть усі поля."), true); return }

                            if (typeof dbManager !== 'undefined') {
                                if (dbManager.registerUser(nameField.text, regEmail.text, regPass1.text)) {
                                    dialogLoader.item.show(qsTr("Реєстрація успішна! Тепер ви можете увійти."), false)

                                    Qt.callLater(function() { stack.replace(loginPage) })
                                } else {
                                    dialogLoader.item.show(qsTr("Помилка реєстрації. Можливо, користувач з таким email вже існує."), true)
                                }
                            } else {
                                dialogLoader.item.show(qsTr("ПОМИЛКА: Об'єкт dbManager недоступний. Реєстрація неможлива."), true)
                            }
                        }
                    }
                    Button { text: qsTr("Назад до входу"); Layout.fillWidth: true; Material.background: Material.color(Material.Red); onClicked: stack.replace(loginPage) }
                }
            }
        }
    }

    Component {
        id: loginPage
        Page {

            implicitWidth: 420
            implicitHeight: 640

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                width: parent.width * 0.85

                Label { text: qsTr("Ласкаво просимо!"); font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                TextField { id: email; placeholderText: qsTr("Електронна пошта"); Layout.fillWidth: true; inputMethodHints: Qt.ImhEmailCharactersOnly }
                TextField { id: password; placeholderText: qsTr("Пароль"); Layout.fillWidth: true; echoMode: TextInput.Password }

                Button {
                    text: qsTr("Увійти")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Indigo)

                    onClicked: {
                        if (email.text === "" || password.text === "") {
                            dialogLoader.item.show(qsTr("Будь ласка, заповніть усі поля."), true); return
                        }

                        if (typeof dbManager !== 'undefined') {
                            var userData = dbManager.loginUser(email.text, password.text); // QVariantMap з name
                            if (userData && userData.name) {
                                email.clear(); password.clear()
                                var diaryInstance = diaryContent.createObject(stack, {
                                    userName: userData.name
                                });
                                if (diaryInstance) {
                                    stack.replace(diaryInstance);
                                } else {
                                    dialogLoader.item.show(qsTr("Критична помилка ініціалізації сторінки щоденника."), true);
                                }

                            } else {
                                dialogLoader.item.show(qsTr("Невірний email або пароль."), true)
                            }
                        } else {
                            dialogLoader.item.show(qsTr("ПОМИЛКА: Об'єкт dbManager недоступний. Увійти неможливо."), true)
                        }
                    }
                }

                Button {
                    text: qsTr("Реєстрація")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Grey)
                    onClicked: stack.replace(registerPage)
                }
            }
        }
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPage
    }
}
