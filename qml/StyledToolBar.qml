import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1

ToolBar {
    id: toolBar

    background: Rectangle {
        color: defaultBackground
        opacity: 0.7
    }

    function getToolbarColor(isActive) {
        if (!isActive) {
            return "transparent"
        } else {
            if (isDark()) {
                return defaultDarkLighter
            } else {
                return "#e8e8e9"
            }
        }
    }

    property bool showSearch: shouldShowSearch()
    property bool showBackBtn: navigator.depth > 1
    property bool showTitleLbl: !!navigator.currentItem
                                && !!navigator.currentItem.title
    property alias settingsBtn: settingsBtn
    property alias addCredentialBtn: addCredentialBtn
    property alias searchField: searchField

    function shouldShowSearch() {        
        return !!(navigator.currentItem
                  && navigator.currentItem.objectName === 'credentialsView'
                  && entries.count > 0 && !settings.otpMode)
    }

    function shouldShowSettings() {
        return !!(navigator.currentItem && navigator.currentItem.objectName !== 'settingsView'
                  && navigator.currentItem.objectName !== 'newCredentialView')
    }

    function shouldShowInfo() {
        return !!(navigator.currentItem && navigator.currentItem.objectName === 'settingsView')
    }

    function shouldShowCredentialOptions() {
        return !!(app.currentCredentialCard && navigator.currentItem
                  && navigator.currentItem.objectName === 'credentialsView')
    }

    function shouldShowToolbar() {
        return !!(navigator.currentItem && navigator.currentItem.objectName !== 'loadingView')
    }

    RowLayout {
        spacing: 0
        anchors.fill: parent
        visible: shouldShowToolbar()
        Layout.alignment: Qt.AlignTop


        ToolButton {
            id: backBtn
            visible: showBackBtn
            onClicked: navigator.home()
            icon.source: "../images/back.svg"
            icon.color: hovered ? iconButtonHovered : iconButtonNormal
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }

        ToolButton {
            id: settingsBtn
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            visible: !backBtn.visible && shouldShowSettings()
            onClicked: navigator.goToSettings()

            Keys.onReturnPressed: navigator.goToSettings()
            Keys.onEnterPressed: navigator.goToSettings()

            KeyNavigation.left: navigator
            KeyNavigation.backtab: navigator
            KeyNavigation.right: searchField
            KeyNavigation.tab: searchField

            Accessible.role: Accessible.Button
            Accessible.name: "Settings"
            Accessible.description: "Go to settings"

            ToolTip {
                text: qsTr("Settings")
                delay: 1000
                parent: settingsBtn
                visible: parent.hovered
                Material.foreground: toolTipForeground
                Material.background: toolTipBackground
            }

            icon.source: "../images/more.svg"
            icon.color: hovered ? iconButtonHovered : iconButtonNormal

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }

        Label {
            id: titleLbl
            visible: showTitleLbl
            text: showTitleLbl ? navigator.currentItem.title : ""
            font.pixelSize: 16
            Layout.leftMargin: settingsBtn.visible ? -32 : 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            color: iconButtonNormal
        }

        ToolButton {
            id: searchBtn
            visible: showSearch
            Layout.minimumHeight: 30
            Layout.maximumHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            background: Rectangle {
                color: getToolbarColor(searchBtn.hovered)
                height: 30
                radius: 4
            }

            TextField {
                id: searchField
                visible: showSearch
                selectByMouse: true
                selectedTextColor: defaultBackground
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: qsTr("Quick Find")
                placeholderTextColor: iconButtonNormal
                leftPadding: 28
                rightPadding: 8
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                color: hovered || activeFocus ? iconButtonHovered : iconButtonNormal
                background: Rectangle {
                    color: getToolbarColor(searchField.focus)
                    height: 30
                    radius: 4
                    opacity: 0.8
                }

                Accessible.role: Accessible.EditableText
                Accessible.searchEdit: true
                onTextChanged: forceActiveFocus()
                onVisibleChanged: {
                    if (!visible) {
                        exitSearchMode(true)
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                    onClicked: {
                        contextMenu.open();
                    }
                    onPressAndHold: {
                        if (mouse.source === Qt.MouseEventNotSynthesized) {
                            contextMenu.open();
                        }
                    }
                }

                Menu {
                    id: contextMenu

                    MenuItem {
                        text: qsTr("Cut")
                        onTriggered: {
                            searchField.cut()
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy")
                        onTriggered: {
                            searchField.copy()
                        }
                    }
                    MenuItem {
                        text: qsTr("Paste")
                        onTriggered: {
                            searchField.paste()
                        }
                    }
                }

                function exitSearchMode(clearInput) {
                    if (clearInput) {
                        text = ""
                    }
                    focus = false
                    Keys.forwardTo = navigator
                    navigator.forceActiveFocus()
                }

                KeyNavigation.backtab: settingsBtn
                KeyNavigation.left: settingsBtn
                KeyNavigation.tab: shouldShowCredentialOptions(
                                       ) ? copyCredentialBtn : addCredentialBtn
                KeyNavigation.right: shouldShowCredentialOptions(
                                       ) ? copyCredentialBtn : addCredentialBtn
                Keys.onEscapePressed: exitSearchMode(true)
                Keys.onDownPressed: exitSearchMode(false)
                Keys.onReturnPressed: {
                    if (currentCredentialCard) {
                        currentCredentialCard.calculateCard(true)
                    }
                }
                Keys.onEnterPressed: {
                    if (currentCredentialCard) {
                        currentCredentialCard.calculateCard(true)
                    }
                }

                StyledImage {
                    id: searchIcon
                    x: 5
                    y: 6
                    iconHeight: 20
                    iconWidth: 20
                    source: "../images/search.svg"
                    color: searchField.hovered || searchField.activeFocus ? iconButtonHovered : iconButtonNormal
                }
            }
        }

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            ToolButton {
                id: copyCredentialBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: shouldShowCredentialOptions()

                onClicked: app.currentCredentialCard.calculateCard(true)
                Keys.onReturnPressed: app.currentCredentialCard.calculateCard(true)
                Keys.onEnterPressed: app.currentCredentialCard.calculateCard(true)

                KeyNavigation.left: searchField
                KeyNavigation.backtab: searchField
                KeyNavigation.right: deleteCredentialBtn
                KeyNavigation.tab: deleteCredentialBtn

                Accessible.role: Accessible.Button
                Accessible.name: "Copy"
                Accessible.description: "Copy to clipboard"

                ToolTip {
                    text: qsTr("Copy code to clipboard")
                    delay: 1000
                    parent: copyCredentialBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/copy.svg"
                icon.color: hovered ? iconButtonHovered : iconButtonNormal

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            ToolButton {
                id: deleteCredentialBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: shouldShowCredentialOptions()

                onClicked: app.currentCredentialCard.deleteCard()
                Keys.onReturnPressed: app.currentCredentialCard.deleteCard()
                Keys.onEnterPressed: app.currentCredentialCard.deleteCard()

                KeyNavigation.left: copyCredentialBtn
                KeyNavigation.right: addCredentialBtn
                KeyNavigation.tab: addCredentialBtn

                Accessible.role: Accessible.Button
                Accessible.name: "Delete"
                Accessible.description: "Delete account"

                ToolTip {
                    text: qsTr("Delete account")
                    delay: 1000
                    parent: deleteCredentialBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/delete.svg"
                icon.color: hovered ? iconButtonHovered : iconButtonNormal

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            ToolButton {
                id: infoBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: shouldShowInfo()
                onClicked: navigator.about()

                Keys.onReturnPressed: navigator.about()
                Keys.onEnterPressed: navigator.about()

                KeyNavigation.left: backBtn
                KeyNavigation.backtab: backBtn
                KeyNavigation.right: navigator
                KeyNavigation.tab: navigator

                Accessible.role: Accessible.Button
                Accessible.name: "Info"
                Accessible.description: "Information"

                ToolTip {
                    text: qsTr("Information")
                    delay: 1000
                    parent: infoBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/info.svg"
                icon.color: hovered ? iconButtonHovered : iconButtonNormal

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            ToolButton {
                id: addCredentialBtn
                visible: !!yubiKey.currentDevice
                         && yubiKey.currentDeviceValidated
                         && navigator.currentItem
                         && navigator.currentItem.objectName === 'credentialsView'

                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                onClicked: yubiKey.scanQr()
                Keys.onReturnPressed: yubiKey.scanQr()
                Keys.onEnterPressed: yubiKey.scanQr()

                KeyNavigation.left: app.currentCredentialCard ? deleteCredentialBtn : searchField
                KeyNavigation.backtab: app.currentCredentialCard ? deleteCredentialBtn : searchField
                KeyNavigation.right: navigator
                KeyNavigation.tab: navigator

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Add")
                Accessible.description: qsTr("Add account")

                ToolTip {
                    text: qsTr("Add a new account")
                    delay: 1000
                    parent: addCredentialBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/add.svg"
                icon.color: hovered ? iconButtonHovered : iconButtonNormal

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

        }
    }
}
