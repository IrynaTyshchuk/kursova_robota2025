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
    width: stack.currentItem ? stack.currentItem.implicitWidth : 500
    height: 720
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
            implicitWidth: 500
            implicitHeight: 720
            property StackView stackView: null
            property var dialog: null
            property int userId: -1
            property var dbManager: null
            property var notesModel: null
            property var taskTypeModel: []
            property var priorityModel: []
            property var repeatOptionModel: []
            Component.onCompleted: {
                if (dbManager) {
                    taskTypeModel = dbManager.getTaskTypes()
                    priorityModel = dbManager.getPriorities()
                    repeatOptionModel = dbManager.getRepeatOptions()
                }
                taskTypeComboBox.currentIndex = -1
                priorityComboBox.currentIndex = -1
                repeatOptionComboBox.currentIndex = 0
            }
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
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
                        Label { text: qsTr("Заголовок:"); font.pixelSize: 16 }
                        TextField {
                            id: titleField
                            placeholderText: qsTr("Введіть заголовок запису")
                            Layout.fillWidth: true
                            font.pixelSize: 18
                        }
                        Label { text: qsTr("Дата виконання:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        TextField {
                            id: executionDateField
                            placeholderText: qsTr("дд.мм.рррр")
                            Layout.fillWidth: true
                            font.pixelSize: 18
                        }
                        Label { text: qsTr("Тип завдання:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        ComboBox {
                            id: taskTypeComboBox
                            Layout.fillWidth: true
                            model: taskTypeModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: -1
                            property string placeholderTextValue: qsTr("Оберіть тип завдання")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                        }
                        Label { text: qsTr("Повторювати:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        ComboBox {
                            id: repeatOptionComboBox
                            Layout.fillWidth: true
                            model: repeatOptionModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: 0
                            property string placeholderTextValue: qsTr("Оберіть період повтору")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                        }
                        Label { text: qsTr("Пріоритет:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        ComboBox {
                            id: priorityComboBox
                            Layout.fillWidth: true
                            model: priorityModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: -1
                            property string placeholderTextValue: qsTr("Оберіть пріоритет")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                        }

                        Label { text: qsTr("Тип діяльності:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        TextField {
                            id: activityField
                            placeholderText: qsTr("Введіть тип діяльності")
                            Layout.fillWidth: true
                            font.pixelSize: 16
                        }

                        Label { text: qsTr("Зміст запису:"); font.pixelSize: 16; Layout.topMargin: 5 }
                        TextArea {
                            id: contentArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            placeholderText: qsTr("Введіть деталі вашого запису...")
                        }

                        Button {
                            text: qsTr("Зберегти запис")
                            Layout.fillWidth: true
                            Layout.topMargin: 10
                            Material.background: Material.color(Material.Green, Material.Shade500)

                            onClicked: {
                                var activityValue = activityField.text.trim();
                                var executionDateRaw = executionDateField.text.trim();
                                var executionDateValue = "";
                                var dateRegex = /^(\d{2})\.(\d{2})\.(\d{4})$/;
                                var dateMatch = executionDateRaw.match(dateRegex);

                                if (dateMatch) {
                                    executionDateValue = dateMatch[3] + '-' + dateMatch[2] + '-' + dateMatch[1];
                                } else if (executionDateRaw !== "") {
                                    if (dialog) dialog.show(qsTr("Введіть дату у форматі ДД.ММ.РРРР."), true);
                                    return;
                                }

                                if (executionDateValue !== "") {
                                    var today = new Date();
                                    var execDate = new Date(executionDateValue);
                                    today.setHours(0, 0, 0, 0);
                                    execDate.setHours(0, 0, 0, 0);

                                    if (execDate < today) {
                                        if (dialog) dialog.show(qsTr("Введена дата виконання вже минула."), true);
                                        return;
                                    }
                                }

                                if (executionDateValue === "" && executionDateRaw !== "") {
                                    if (dialog) dialog.show(qsTr("Введіть дату виконання у форматі ДД.ММ.РРРР."), true)
                                    return
                                }


                                if (titleField.text.trim() === "" || contentArea.text.trim() === "" ||
                                    priorityComboBox.currentIndex < 0 || taskTypeComboBox.currentIndex < 0 ||
                                    activityValue === "") {
                                    if (dialog) dialog.show(qsTr("Будь ласка, заповніть усі обов'язкові поля."), true)
                                    return
                                }

                                if (userId <= 0) {
                                    if (dialog) dialog.show(qsTr("Критична помилка: Ідентифікатор користувача не знайдено."), true);
                                    return;
                                }

                                var newNote = {
                                    "title": titleField.text,
                                    "content": contentArea.text,
                                    "executionDate": executionDateValue,
                                    "taskType": taskTypeComboBox.currentText,
                                    "priority": priorityComboBox.currentText,
                                    "activityType": activityValue,
                                    "repeatOption": repeatOptionComboBox.currentText
                                };

                                var newId = 0;
                                if (dbManager) {
                                    var result = dbManager.addNote(userId, newNote);
                                    if (result !== null && result !== undefined && result !== 0) {
                                        newId = parseInt(result);
                                    }
                                }

                                if (newId > 0) {
                                    titleField.clear();
                                    contentArea.clear();
                                    executionDateField.clear();
                                    activityField.clear();
                                    priorityComboBox.currentIndex = -1;
                                    taskTypeComboBox.currentIndex = -1;
                                    repeatOptionComboBox.currentIndex = 0;

                                    stackView.pop()

                                    if (stackView.currentItem && stackView.currentItem.loadNotes) {
                                        stackView.currentItem.loadNotes();
                                    }

                                    if (dialog) dialog.show(qsTr("Запис успішно збережено!"), false)
                                } else {
                                    if (dialog) dialog.show(qsTr("Помилка збереження запису в базу даних."), true)
                                }
                            }
                        }

                        Button {
                            text: qsTr("Скасувати")
                            Layout.fillWidth: true
                            Material.background: Material.color(Material.Grey, Material.Shade500)
                            onClicked: stackView.pop()
                        }
                    }
                }
            }
        }
    }
    Component {
        id: noteDetailPage
        Page {
            implicitWidth: 500
            implicitHeight: 720
            property StackView stackView: null
            property var noteData: null

            function formatDbDate(dbDate) {
                if (!dbDate || typeof dbDate !== 'string' || dbDate.length !== 10 || dbDate.indexOf('-') === -1) return dbDate;
                var parts = dbDate.split('-');
                return parts[2] + '.' + parts[1] + '.' + parts[0];
            }

            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    ToolButton {
                        contentItem: Label { text: qsTr("👈"); font.pixelSize: 24 }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: noteData ? noteData.title : qsTr("Деталі запису")
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
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
                        spacing: 10

                        Label {
                            text: qsTr("Дата створення: ") + (noteData ? formatDbDate(noteData.created_date) : "");
                            font.pixelSize: 14;
                            color: Material.color(Material.Grey, Material.Shade700)
                        }
                        Label { text: qsTr("Час створення: ") + (noteData ? noteData.creation_time : ""); font.pixelSize: 14; color: Material.color(Material.Grey, Material.Shade700) }

                        Label {
                            text: qsTr("Виконати до: ") + (noteData && noteData.executionDate ? formatDbDate(noteData.executionDate) : qsTr("Не вказано"));
                            font.pixelSize: 14;
                            font.bold: true;
                            color: Material.color(Material.Indigo, Material.Shade700)
                        }
                        Label {
                            text: qsTr("Повторювати: ") + (noteData && noteData.repeatOption ? noteData.repeatOption : qsTr("Ніколи"));
                            font.pixelSize: 14;
                            color: Material.color(Material.Teal, Material.Shade700)
                        }

                        Label { text: qsTr("Тип завдання: ") + (noteData ? noteData.taskType : ""); font.pixelSize: 14 }
                        Label {
                            text: qsTr("Пріоритет: ") + (noteData ? noteData.priority : "");
                            font.pixelSize: 14;
                            color: noteData ? (
                                noteData.priority === qsTr("Висока") ? Material.color(Material.Red) :
                                noteData.priority === qsTr("Середня") ? Material.color(Material.Blue) :
                                noteData.priority === qsTr("Низька") ? Material.color(Material.Green) : Material.color(Material.Grey, Material.Shade800)
                            ) : Material.color(Material.Grey, Material.Shade800)
                        }
                        Label { text: qsTr("Тип діяльності: ") + (noteData ? noteData.activityType : ""); font.pixelSize: 14 }

                        Rectangle { Layout.fillWidth: true; height: 1; color: Material.color(Material.Grey, Material.Shade300); Layout.topMargin: 10; Layout.bottomMargin: 10 }

                        Label { text: qsTr("Опис:"); font.pixelSize: 16; font.bold: true }

                        Rectangle {
                            id: detailContentContainer
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300

                            color: Material.color(Material.Grey, Material.Shade100);
                            radius: 8;
                            border.width: 1;
                            border.color: Material.color(Material.Grey, Material.Shade300);

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 1
                                contentHeight: detailContentLabel.height + 20
                                clip: true

                                Label {
                                    id: detailContentLabel
                                    text: noteData ? noteData.content : ""

                                    width: parent.width - 20

                                    wrapMode: Text.WordWrap

                                    font.pixelSize: 16

                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.top: parent.top
                                    anchors.topMargin: 10
                                }
                            }
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
            implicitWidth: 500
            implicitHeight: 720
            ListModel {
                id: notesModel
            }
            property string userName: qsTr("Користувач")
            property int currentUserId: -1

            property var dbManager: null
            readonly property StackView stackRef: stack
            readonly property var loginPageRef: loginPage
            readonly property var dialogRef: dialogLoader.item

            function loadNotes() {
                if (dbManager && diaryPage.currentUserId > 0) {
                    var notes = dbManager.getNotesForUser(diaryPage.currentUserId);
                    notesModel.clear();
                    for (var i = 0; i < notes.length; i++) {
                        notesModel.append(notes[i]);
                    }
                }
            }

            Component.onCompleted: {
                if (diaryPage.currentUserId > 0) {
                    loadNotes();
                } else {
                    console.error("Помилка: diaryContent завантажено без дійсного currentUserId.")
                }
            }

            function formatDbDate(dbDate) {
                if (!dbDate || typeof dbDate !== 'string' || dbDate.length !== 10 || dbDate.indexOf('-') === -1) return dbDate;
                var parts = dbDate.split('-');
                return parts[2] + '.' + parts[1] + '.' + parts[0];
            }


            header: ToolBar {
                id: diaryToolBar
                contentHeight: 60
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
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
                width: 250
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
                    Button {
                        text: qsTr("Вийти з акаунта")
                        Layout.fillWidth: true
                        Layout.topMargin: 50
                        Material.background: Material.color(Material.Red)
                        onClicked: {
                            drawer.close();
                            notesModel.clear();
                            diaryPage.currentUserId = -1;

                            dialogRef.show(qsTr("Вихід успішний. Повернення до сторінки входу."), false);

                            Qt.callLater(function() {
                                if (stackRef && loginPageRef) {
                                    stackRef.replace(loginPageRef);
                                } else {
                                    console.error("Помилка: StackView або loginPageRef недоступні для повернення.")
                                }
                            });
                        }
                    }
                }
            }

            ColumnLayout {
                id: emptyState
                visible: notesModel.count === 0
                anchors.centerIn: parent
                spacing: 10
                Label { text: qsTr("Нагадувань ще нема"); font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter }
                Label { text: qsTr("Почніть вести свій щоденник"); font.pixelSize: 14; color: Material.color(Material.Grey); Layout.alignment: Qt.AlignHCenter }
                Button {
                    text: qsTr("➕ Створити перший запис")
                    Layout.alignment: Qt.AlignHCenter
                    Material.background: Material.color(Material.Green)
                    Layout.topMargin: 20
                    onClicked: Qt.callLater(function() {
                        var noteInstance = newNotePage.createObject(stackRef, {
                            stackView: stackRef,
                            dialog: dialogRef,
                            notesModel: notesModel,
                            userId: diaryPage.currentUserId,
                            dbManager: diaryPage.dbManager
                        });
                        if (noteInstance) {
                            stackRef.push(noteInstance);
                        }
                    })
                }
            }

            ListView {
                id: notesList
                visible: notesModel.count > 0
                anchors.top: diaryPage.contentItem.top
                anchors.bottom: fab.top
                anchors.left: diaryPage.contentItem.left
                anchors.right: diaryPage.contentItem.right
                anchors.margins: 10
                spacing: 5
                model: notesModel
                delegate: Control {
                    id: noteDelegate
                    height: 80
                    width: notesList.width
                    hoverEnabled: true
                    clip: true
                    background: Rectangle {
                        anchors.fill: parent
                        color: notesList.currentIndex === index ? Material.color(Material.Blue, Material.Shade100) : (noteDelegate.hovered ? Material.color(Material.Grey, Material.Shade50) : "white")
                        radius: 8
                        border.color: Material.color(Material.Grey, Material.Shade300)
                        border.width: 1
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: 60
                        onClicked: {
                            notesList.currentIndex = index
                            var detailInstance = noteDetailPage.createObject(stackRef, {
                                stackView: stackRef,
                                noteData: notesModel.get(index)
                            });
                            if (detailInstance) {
                                stackRef.push(detailInstance);
                            }
                        }
                    }
                    RowLayout {
                        spacing: 10
                        anchors.fill: parent
                        anchors.margins: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label { text: model.title; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                            RowLayout {
                                Label {
                                    text: formatDbDate(model.created_date);
                                    font.pixelSize: 12;
                                    color: Material.color(Material.Grey, Material.Shade700)
                                }
                                Label {
                                    text: " | " + model.priority;
                                    font.pixelSize: 12;
                                    color: model.priority === qsTr("Висока") ? Material.color(Material.Red, Material.Shade700) :
                                            model.priority === qsTr("Середня") ? Material.color(Material.Blue, Material.Shade700) :
                                            model.priority === qsTr("Низька") ? Material.color(Material.Green, Material.Shade700) : Material.color(Material.Grey, Material.Shade700)
                                }
                                Label {
                                    text: " | " + model.activityType;
                                    font.pixelSize: 12;
                                    color: Material.color(Material.Indigo, Material.Shade700)
                                }
                            }
                        }
                        ToolButton {
                            id: deleteButton
                            Layout.alignment: Qt.AlignVCenter
                            width: 40; height: 40
                            visible: noteDelegate.hovered
                            contentItem: Label {
                                text: qsTr("🗑️")
                                font.pixelSize: 24
                                color: Material.color(Material.Red, Material.Shade700)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 4;
                                color: deleteButton.pressed ? Material.color(Material.Red, Material.Shade100) : "transparent";
                            }
                            onClicked: {
                                var noteId = notesModel.get(index).id;
                                if (noteId && noteId > 0) {
                                    if (dbManager.deleteNote(noteId)) {
                                        notesModel.remove(index);
                                        dialogRef.show(qsTr("Запис успішно видалено."), false);
                                    } else {
                                        dialogRef.show(qsTr("Помилка видалення запису з бази даних!"), true);
                                    }
                                } else {
                                    dialogRef.show(qsTr("Критична помилка: ID нотатки відсутній або недійсний."), true);
                                }
                            }
                        }
                    }
                }
            }

            Button {
                id: fab
                text: "➕"
                font.pixelSize: 24
                width: 56
                height: 56
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.bottomMargin: 20
                visible: notesModel.count > 0
                background: Rectangle {
                    radius: fab.width / 2
                    color: Material.color(Material.Indigo)
                }
                Material.foreground: "white"
                onClicked: Qt.callLater(function() {
                    var noteInstance = newNotePage.createObject(stackRef, {
                        stackView: stackRef,
                        dialog: dialogRef,
                        notesModel: notesModel,
                        userId: diaryPage.currentUserId,
                        dbManager: diaryPage.dbManager
                    });
                    if (noteInstance) {
                        stackRef.push(noteInstance);
                    }
                })
            }
        }
    }
    Component {
        id: registerPage
        Page {
            title: qsTr("Реєстрація")
            implicitWidth: 500
            implicitHeight: 720

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                width: Math.min(parent.width * 0.85, 400)

                Label {
                    text: qsTr("Створення акаунту")
                    font.pixelSize: 22
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: nameField
                    placeholderText: qsTr("Ім'я")
                    Layout.fillWidth: true
                }

                TextField {
                    id: regEmail
                    placeholderText: qsTr("Електронна пошта")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                }

                TextField {
                    id: regPass1
                    placeholderText: qsTr("Пароль")
                    echoMode: passwordVisible1.checked ? TextInput.Normal : TextInput.Password
                    Layout.fillWidth: true
                    rightPadding: regPass1ShowBtn.width + regPass1ShowBtn.anchors.rightMargin * 2

                    ToolButton {
                        id: regPass1ShowBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: parent.height
                        implicitWidth: 30

                        contentItem: CheckBox {
                            id: passwordVisible1
                            checked: false
                            indicator: null
                            contentItem: Label {
                                text: passwordVisible1.checked ? "🔓" : "🔒"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: passwordVisible1.checked = !passwordVisible1.checked
                    }
                }

                TextField {
                    id: regPass2
                    placeholderText: qsTr("Підтвердіть пароль")
                    echoMode: passwordVisible2.checked ? TextInput.Normal : TextInput.Password
                    Layout.fillWidth: true
                    rightPadding: regPass2ShowBtn.width + regPass2ShowBtn.anchors.rightMargin * 2

                    ToolButton {
                        id: regPass2ShowBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: parent.height
                        implicitWidth: 30

                        contentItem: CheckBox {
                            id: passwordVisible2
                            checked: false
                            indicator: null
                            contentItem: Label {
                                text: passwordVisible2.checked ? "🔓" : "🔒"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: passwordVisible2.checked = !passwordVisible2.checked
                    }
                }

                Button {
                    text: qsTr("Зареєструватися")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Green)
                    onClicked: {
                        var dbManagerRef = typeof dbManager !== 'undefined' ? dbManager : null;

                        if (regEmail.text.indexOf("@") === -1) {
                            dialogLoader.item.show(qsTr("Некоректно введена пошта."), true);
                            return
                        }
                        if (regPass1.text !== regPass2.text) { dialogLoader.item.show(qsTr("Паролі не співпадають."), true); return }
                        if (nameField.text.trim() === "" || regEmail.text.trim() === "" || regPass1.text === "") { dialogLoader.item.show(qsTr("Будь ласка, заповніть усі поля."), true); return }

                        if (dbManagerRef) {
                            if (dbManagerRef.registerUser(nameField.text, regEmail.text, regPass1.text)) {
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

                Button {
                    text: qsTr("Назад до входу")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Red)
                    onClicked: stack.replace(loginPage)
                }
            }
        }
    }

        Component {
            id: loginPage
            Page {
                title: qsTr("Вхід")
                implicitWidth: 500
                implicitHeight: 720
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16
                    width: Math.min(parent.width * 0.85, 400)

                    Label {
                        text: qsTr("Ласкаво просимо!")
                        font.pixelSize: 22
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        id: email
                        placeholderText: qsTr("Електронна пошта")
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                    }

                    TextField {
                        id: password
                        placeholderText: qsTr("Пароль")
                        echoMode: loginPasswordVisible.checked ? TextInput.Normal : TextInput.Password
                        Layout.fillWidth: true
                        rightPadding: loginPasswordShowBtn.width + loginPasswordShowBtn.anchors.rightMargin * 2

                        ToolButton {
                            id: loginPasswordShowBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 10
                            width: 30
                            height: parent.height
                            implicitWidth: 30

                            contentItem: CheckBox {
                                id: loginPasswordVisible
                                checked: false
                                indicator: null
                                contentItem: Label {
                                    text: loginPasswordVisible.checked ? "🔓" : "🔒"
                                    font.pixelSize: 18
                                    anchors.centerIn: parent
                                }
                            }
                            onClicked: loginPasswordVisible.checked = !loginPasswordVisible.checked
                        }
                    }

                    Button {
                        text: qsTr("Увійти")
                        Layout.fillWidth: true
                        Material.background: Material.color(Material.Indigo)

                        onClicked: {
                            var dbManagerRef = typeof dbManager !== 'undefined' ? dbManager : null;

                            if (email.text.indexOf("@") === -1) {
                                dialogLoader.item.show(qsTr("Некоректно введена пошта."), true);
                                return
                            }

                            if (email.text.trim() === "" || password.text === "") {
                                dialogLoader.item.show(qsTr("Будь ласка, заповніть усі поля."), true); return
                            }

                            if (dbManagerRef) {
                                var userData = dbManagerRef.loginUser(email.text, password.text);

                                if (userData && userData.email) {
                                    email.clear(); password.clear()

                                    var diaryInstance = diaryContent.createObject(stack, {
                                        userName: userData.name,
                                        userEmail: userData.email,
                                        // ВИПРАВЛЕНО: Додано currentUserId для усунення помилки
                                        currentUserId: userData.id,
                                        dbManager: dbManagerRef
                                    });

                                    if (diaryInstance) {
                                        diaryInstance.loadNotes();
                                        Qt.callLater(function() { stack.replace(diaryInstance); })
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
                        onClicked: Qt.callLater(function() { stack.replace(registerPage) })
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
