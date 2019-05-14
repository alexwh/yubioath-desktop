import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

ScrollView {

    readonly property int dynamicWidth: 864
    readonly property int dynamicMargin: 32

    objectName: 'newCredentialView'
    property string title: "New credential"

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical: ScrollBar {
        interactive: true
        width: 5
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    property var credential
    property bool manualEntry

    contentWidth: app.width

    function acceptableInput() {
        if (settings.otpMode) {
            return secretKeyLbl.text.length > 0
            // TODO: check maxlength of secret, 20 bytes?
        } else {
            var nameAndKey = nameLbl.text.length > 0
                    && secretKeyLbl.text.length > 0
            var okTotalLength = (nameLbl.text.length + issuerLbl.text.length) < 60
            return nameAndKey && okTotalLength
        }
    }

    function addCredential() {

        function callback(resp) {
            if (resp.success) {
                yubiKey.calculateAll(navigator.goToCredentials)
                navigator.snackBar("Credential added")
            } else {
                navigator.snackBarError(navigator.getErrorMessage(
                                            resp.error_id))
                console.log("addCredential failed:", resp.error_id)
            }
        }

        if (settings.otpMode) {
            yubiKey.otpAddCredential(otpSlotComboBox.currentText,
                                     secretKeyLbl.text,
                                     requireTouchCheckBox.checked, callback)
        } else {
            yubiKey.ccidAddCredential(nameLbl.text, secretKeyLbl.text,
                                      issuerLbl.text,
                                      oathTypeComboBox.currentText,
                                      algoComboBox.currentText,
                                      digitsComboBox.currentText,
                                      periodLbl.text,
                                      requireTouchCheckBox.checked, callback)
        }
    }

    spacing: 8
    padding: 0

    ColumnLayout {
        id: content
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
        Pane {
            id: retryPane
            visible: manualEntry
            Layout.alignment: Qt.AlignCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: dynamicWidth + dynamicMargin
            Layout.bottomMargin: 16
            background: Rectangle {
                color: isDark() ? defaultDarkLighter : defaultLightDarker
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 4
                    samples: radius * 2
                    verticalOffset: 2
                    horizontalOffset: 2
                    color: formDropShdaow
                    transparentBorder: true
                }
            }
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: app.width - dynamicMargin
                       < dynamicWidth ? app.width - dynamicMargin : dynamicWidth
                spacing: 8
                RowLayout {
                    Label {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        text: "Automatic (recommended)"
                        color: yubicoGreen
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        topPadding: 8
                        bottomPadding: 8
                        Layout.fillWidth: true
                        background: Item {
                            implicitWidth: parent.width
                            implicitHeight: 40
                            Rectangle {
                                color: formTitleUnderline
                                height: 1
                                width: parent.width
                                y: 31
                            }
                        }
                    }
                }
                Label {
                    text: "1. Make sure the QR code is fully visible on screen"
                    font.pixelSize: 13
                    font.bold: false
                    color: formText
                    Layout.fillWidth: true
                }
                Label {
                    text: "2. Click the Scan QR code button"
                    font.pixelSize: 13
                    font.bold: false
                    color: formText
                    Layout.fillWidth: true
                }
                StyledButton {
                    id: retry
                    text: "Scan"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: yubiKey.scanQr(true)
                }
            }
        }

        Pane {
            id: manualEntryPane
            Layout.alignment: Qt.AlignCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: dynamicWidth + dynamicMargin
            Layout.topMargin: 8
            Layout.bottomMargin: 8

            background: Rectangle {
                color: isDark() ? defaultDarkLighter : defaultLightDarker
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 4
                    samples: radius * 2
                    verticalOffset: 2
                    horizontalOffset: 2
                    color: formDropShdaow
                    transparentBorder: true
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: app.width - dynamicMargin
                       < dynamicWidth ? app.width - dynamicMargin : dynamicWidth
                spacing: 8

                RowLayout {
                    visible: !credential
                    Label {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        text: "Manual entry"
                        color: yubicoGreen
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        topPadding: 8
                        bottomPadding: 8
                        Layout.fillWidth: true
                        background: Item {
                            implicitWidth: parent.width
                            implicitHeight: 40
                            Rectangle {
                                color: formTitleUnderline
                                height: 1
                                width: parent.width
                                y: 31
                            }
                        }
                    }
                }

                StyledTextField {
                    id: issuerLbl
                    labelText: "Issuer"
                    Layout.fillWidth: true
                    text: credential
                          && credential.issuer ? credential.issuer : ""
                    visible: !settings.otpMode
                }
                StyledTextField {
                    id: nameLbl
                    labelText: "Account name *"
                    Layout.fillWidth: true
                    text: credential && credential.name ? credential.name : ""
                    visible: !settings.otpMode
                }
                StyledTextField {
                    id: secretKeyLbl
                    labelText: "Secret key *"
                    Layout.fillWidth: true
                    text: credential
                          && credential.secret ? credential.secret : ""
                    visible: manualEntry
                    validator: RegExpValidator {
                        regExp: /[2-7a-zA-Z ]+=*/
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    StyledComboBox {
                        label: "Slot"
                        id: otpSlotComboBox
                        model: [1, 2]
                    }
                    visible: settings.otpMode
                }

                RowLayout {
                    CheckBox {
                        id: requireTouchCheckBox
                        checked: settings.closeToTray
                        text: "Require touch"
                        padding: 0
                        indicator.width: 16
                        indicator.height: 16
                        Material.foreground: formText
                    }
                    visible: yubiKey.supportsTouchCredentials()
                             || settings.otpMode
                }

                StyledExpansionPanel {
                    id: advancedSettingsPanel
                    label: "Advanced settings"
                    description: "Normally these options should not be changed, doing so may result in the code not working as expected."
                    visible: manualEntry && !settings.otpMode

                    RowLayout {
                        visible: parent.isExpanded
                        Layout.fillWidth: true

                        StyledComboBox {
                            label: "Type"
                            id: oathTypeComboBox
                            model: ["TOTP", "HOTP"]
                        }

                        Item {
                            width: 16
                        }

                        StyledComboBox {
                            id: algoComboBox
                            label: "Algorithm"
                            // TODO: only show algorithms supported on device
                            model: ["SHA1", "SHA256", "SHA512"]
                        }
                    }

                    RowLayout {
                        visible: parent.isExpanded
                        Layout.fillWidth: true

                        StyledTextField {
                            id: periodLbl
                            labelText: "Period"
                            Layout.fillWidth: true
                            text: "30"
                            horizontalAlignment: Text.Alignleft
                            validator: IntValidator {
                                bottom: 15
                                top: 60
                            }
                        }

                        Item {
                            width: 16
                        }

                        StyledComboBox {
                            id: digitsComboBox
                            label: "Digits"
                            model: ["6", "7", "8"]
                        }
                    }
                }

                StyledButton {
                    id: addBtn
                    text: "Add"
                    enabled: acceptableInput()
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: addCredential()
                }
            }
        }
    }
}
