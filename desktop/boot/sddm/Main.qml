import QtQuick
import QtQuick.Controls.Basic

Pane {
    id: root
    width: 1024
    height: 768
    padding: 0
    font.family: "Noto Sans"
    font.pixelSize: 15

    readonly property color accent: "#60A5FA"
    property bool authenticating: false
    property bool failed: false
    property string statusMessage: ""

    palette.window: "#161616"
    palette.base: "#1E1E1E"
    palette.alternateBase: "#262626"
    palette.text: "#F5F5F5"
    palette.windowText: "#F5F5F5"
    palette.button: "#262626"
    palette.buttonText: "#F5F5F5"
    palette.highlight: "#60A5FA"
    palette.highlightedText: "#101010"
    palette.mid: "#808080"
    palette.placeholderText: "#B0B0B0"
    background: Rectangle { color: "#161616" }

    function login() {
        if (authenticating || user.editText.trim().length === 0 || session.count === 0)
            return;
        failed = false;
        statusMessage = qsTr("Memeriksa kredensial…");
        authenticating = true;
        sddm.login(user.editText.trim(), password.text, session.currentIndex);
    }

    component Picker: ComboBox {
        id: picker
        width: parent.width
        implicitHeight: 42
        font.pixelSize: 15
        background: Rectangle {
            color: picker.enabled ? "#1E1E1E" : "#262626"
            border.width: picker.activeFocus ? 2 : 1
            border.color: picker.activeFocus ? root.accent : "#808080"
            radius: 4
        }
    }

    component ActionButton: Button {
        id: action
        implicitHeight: 42
        background: Rectangle {
            color: action.down ? "#303030" : (action.highlighted ? root.accent : "#262626")
            border.width: action.activeFocus ? 2 : 1
            border.color: action.activeFocus ? "#F5F5F5" : (action.highlighted ? root.accent : "#808080")
            radius: 4
            opacity: action.enabled ? 1 : 0.5
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.authenticating = false;
            root.failed = true;
            root.statusMessage = qsTr("Login gagal. Periksa pengguna dan kata sandi.");
            password.clear();
            password.forceActiveFocus();
        }
        function onLoginSucceeded() {
            password.clear();
            root.statusMessage = qsTr("Membuka sesi…");
        }
        function onInformationMessage(message) {
            root.statusMessage = message;
        }
    }

    Connections {
        target: keyboard
        function onCurrentLayoutChanged() {
            layout.currentIndex = keyboard.currentLayout;
        }
    }

    ScrollView {
        id: scroll
        anchors.fill: parent
        contentWidth: availableWidth
        contentHeight: form.height + 48
        clip: true

        Column {
            id: form
            width: Math.min(400, scroll.availableWidth - 48)
            x: (scroll.availableWidth - width) / 2
            y: Math.max(24, (scroll.availableHeight - height) / 2)
            spacing: 14

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "logo.svg"
                width: 100
                height: 100
                fillMode: Image.PreserveAspectFit
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ConstOS"
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Masuk ke %1").arg(sddm.hostName)
                color: "#B0B0B0"
                elide: Text.ElideRight
            }

            Column {
                width: parent.width
                spacing: 5
                Label { text: qsTr("Pengguna") }
                Picker {
                    id: user
                    model: userModel
                    textRole: "name"
                    currentIndex: userModel.lastIndex
                    editable: true
                    enabled: !root.authenticating
                    Accessible.name: qsTr("Pengguna")
                    KeyNavigation.tab: password
                    onAccepted: password.forceActiveFocus()
                }
            }
            Column {
                width: parent.width
                spacing: 5
                Label { text: qsTr("Kata sandi") }
                TextField {
                    id: password
                    width: parent.width
                    height: 42
                    echoMode: TextInput.Password
                    selectByMouse: true
                    enabled: !root.authenticating
                    Accessible.name: qsTr("Kata sandi")
                    KeyNavigation.tab: session
                    onAccepted: root.login()
                    background: Rectangle {
                        color: "#1E1E1E"
                        border.width: password.activeFocus ? 2 : 1
                        border.color: password.activeFocus ? root.accent : "#808080"
                        radius: 4
                    }
                }
            }
            Column {
                width: parent.width
                spacing: 5
                Label { text: qsTr("Sesi") }
                Picker {
                    id: session
                    model: sessionModel
                    textRole: "name"
                    currentIndex: Math.max(0, sessionModel.lastIndex)
                    enabled: !root.authenticating
                    Accessible.name: qsTr("Sesi desktop")
                    KeyNavigation.tab: layout.visible && layout.enabled ? layout : loginButton
                }
            }
            Column {
                width: parent.width
                spacing: 5
                visible: keyboard.layouts.length > 0
                Label { text: qsTr("Tata letak keyboard") }
                Picker {
                    id: layout
                    model: keyboard.layouts
                    textRole: "shortName"
                    currentIndex: keyboard.currentLayout
                    enabled: keyboard.enabled && !root.authenticating
                    Accessible.name: qsTr("Tata letak keyboard")
                    KeyNavigation.tab: loginButton
                    onActivated: index => { keyboard.currentLayout = index; }
                }
            }
            Label {
                width: parent.width
                visible: keyboard.capsLock
                text: qsTr("Caps Lock aktif")
                color: "#FBBF24"
            }
            Label {
                width: parent.width
                height: 40
                text: session.count === 0 ? qsTr("Tidak ada sesi desktop terpasang.") : root.statusMessage
                color: root.failed || session.count === 0 ? "#F87171" : "#B0B0B0"
                wrapMode: Text.WordWrap
                Accessible.name: text
            }
            ActionButton {
                id: loginButton
                width: parent.width
                text: qsTr("Masuk")
                highlighted: true
                enabled: !root.authenticating && user.editText.trim().length > 0 && session.count > 0
                KeyNavigation.tab: powerButton
                onClicked: root.login()
            }
            ActionButton {
                id: powerButton
                width: parent.width
                text: qsTr("Daya")
                enabled: !root.authenticating
                KeyNavigation.tab: user
                onClicked: powerMenu.open()
                Menu {
                    id: powerMenu
                    y: -height
                    width: powerButton.width
                    MenuItem {
                        text: qsTr("Tidurkan")
                        enabled: sddm.canSuspend
                        onTriggered: sddm.suspend()
                    }
                    MenuItem {
                        text: qsTr("Mulai ulang")
                        enabled: sddm.canReboot
                        onTriggered: sddm.reboot()
                    }
                    MenuItem {
                        text: qsTr("Matikan")
                        enabled: sddm.canPowerOff
                        onTriggered: sddm.powerOff()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        user.editText = userModel.lastUser;
        if (user.editText.length > 0)
            password.forceActiveFocus();
        else
            user.forceActiveFocus();
    }
}
