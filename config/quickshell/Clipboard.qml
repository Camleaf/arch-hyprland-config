import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

PanelWindow {
    id: clipboardWindow

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    signal requestClose()

    function close() {
        clipboardWindow.requestClose()
    }

    

    function open() {
        searchField.text = ""
        clipboardWindow.search = ""
        itemsList.currentIndex = 0
        focusTimer.restart()
        clipScanner.running = true
    }

    // Click outside backdrop to close
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)

        MouseArea {
            anchors.fill: parent
            onClicked: clipboardWindow.close()
        }
    }

    property string search: ""


    // Clipboard state
    property var clipHistory: []
    property var filteredClips: {
        let q = search.trim().toLowerCase()
        if (!q) return clipHistory
        return clipHistory.filter(c => c.preview.toLowerCase().includes(q))
    }


    // Process to scan clipboard
    Process {
        id: clipScanner
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/get-clipboard.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    clipboardWindow.clipHistory = JSON.parse(data)
                } catch (e) {
                    console.warn("Failed to parse clip json:", e)
                }
            }
        }
    }

    // Process to execute chosen app or paste clip
    Process {
        id: actionRunner
        property var cmd: []
        command: cmd
    }


    function pasteClip(idVal) {
        clipboardWindow.close()
        actionRunner.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/paste-clip.sh", String(idVal)]
        actionRunner.running = true
    }


    Timer {
        id: focusTimer
        interval: 20
        onTriggered: searchField.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            clipboardWindow.search = ""
            itemsList.currentIndex = 0
            focusTimer.restart()
            clipScanner.running = true     
        }
    }


    // Central Spotlight Window
    Rectangle {
        id: card
        width: 520
        height: 540
        anchors.centerIn: parent
        radius: 12
        color: Qt.rgba(Theme.bg0.r, Theme.bg0.g, Theme.bg0.b, 0.98)
        border.color: Theme.accent
        border.width: 2
        clip: true

        opacity: clipboardWindow.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 50 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12


            // Search Header Box
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 6
                color: Theme.bg1
                border.color: searchField.activeFocus ? Theme.accent : Theme.bg3
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: "󰅍"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: searchField.activeFocus ? Theme.accent : Theme.gray
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        color: Theme.fg0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        selectByMouse: true
                        clip: true

                        Text {
                            text: "Search copied text snippet..."
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: Theme.gray
                            visible: !searchField.text && !searchField.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }


                        Keys.onPressed: event => {
                            let count = clipboardWindow.filteredClips.length

                            if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                                if (itemsList.currentIndex < count - 1) {
                                    itemsList.currentIndex++
                                    itemsList.positionViewAtIndex(itemsList.currentIndex, ListView.Contain)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                                if (itemsList.currentIndex > 0) {
                                    itemsList.currentIndex--
                                    itemsList.positionViewAtIndex(itemsList.currentIndex, ListView.Contain)
                                }
                                event.accepted = true
                            }  else if (event.key === Qt.Key_Backtab) {
                                if (itemsList.currentIndex > 0) itemsList.currentIndex--
                                else itemsList.currentIndex = count - 1
                                itemsList.positionViewAtIndex(itemsList.currentIndex, ListView.Contain)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                clipboardWindow.close()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key===Qt.Key_Enter) {
                                if (clipboardWindow.filteredClips.length > 0 && itemsList.currentIndex >= 0 && itemsList.currentIndex < clipboardWindow.filteredClips.length){
                                    clipboardWindow.pasteClip(clipboardWindow.filteredClips[itemsList.currentIndex].id)
                                }
                                event.accepted = true;
                                
                            }
                        }
                    }

                    // Clear search button
                    Rectangle {
                        visible: searchField.text.length > 0
                        width: 20
                        height: 20
                        radius: 10
                        color: Theme.bg2
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            color: Theme.silver
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = ""
                                searchField.forceActiveFocus()
                            }
                        }
                    }
                }
            }


            // Results List
            ListView {
                id: itemsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: clipboardWindow.filteredClips

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    property bool isSelected: index === itemsList.currentIndex

                    width: itemsList.width
                    height: 44
                    radius: 6
                    color: isSelected ? Theme.bg2 : (itemMouse.containsMouse ? Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.45) : "transparent")
                    border.color: isSelected ? Theme.accent : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12


                        // Clipboard Item Icon
                        Text {
                            visible: true
                            text: "󰅍"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 15
                            color: isSelected ? Theme.accent : Theme.silver
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Text Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: modelData.preview
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.bold: isSelected
                                    color: isSelected ? Theme.fg0 : Theme.fg1
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                            }

                            Text {
                                text: "Clip #" + modelData.id
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                color: isSelected ? Theme.silver : Theme.gray
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // Selection Return Hint
                        Rectangle {
                            visible: isSelected
                            width: 22
                            height: 22
                            radius: 4
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            border.color: Theme.accent
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "↵"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.accent
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clipboardWindow.pasteClip(modelData.id)
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 4
                }
            }

            // Footer hint
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "↑↓ nav • ↵ copy • Esc exit"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    color: Theme.gray
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Cliphist"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    color: Theme.silver
                }
            }
        }
    }
}
