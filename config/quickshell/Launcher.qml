import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

PanelWindow {
    id: launcherWindow

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
        launcherWindow.requestClose()
        visible = false
    }
    

    function open() {
        searchField.text = ""
        launcherWindow.search = ""
        itemsList.currentIndex = 0
        focusTimer.restart()
        if (allApps.length === 0) appScanner.running = true
    }


    // Click outside backdrop to close
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, .3)

        MouseArea {
            anchors.fill: parent
            onClicked: launcherWindow.close()
        }
    }

    // Apps state
    property var allApps: []
    property string search: ""

    property var filteredApps: {
        let q = search.trim().toLowerCase()
        if (!q) return allApps

        let matches = []
        for (let i = 0; i < allApps.length; i++) {
            let app = allApps[i]
            let nameLower = app.name.toLowerCase()
            let score = 0
            if (nameLower === q) {
                score = 1000 + (app.score || 0)
            } else if (nameLower.startsWith(q)) {
                score = 500 + (app.score || 0)
            } else if (nameLower.includes(q)) {
                score = 200 + (app.score || 0)
            } else if (app.search && app.search.includes(q)) {
                score = 100 + (app.score || 0)
            }
            if (score > 0) {
                matches.push({ app: app, searchScore: score })
            }
        }
        matches.sort((a, b) => b.searchScore - a.searchScore)
        return matches.map(m => m.app)
    }


    // Process to scan desktop files
    Process {
        id: appScanner
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/get-apps.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    launcherWindow.allApps = JSON.parse(data)
                } catch (e) {
                    console.warn("Failed to parse apps json:", e)
                }
            }
        }
    }


    // Process to execute chosen app 
    Process {
        id: actionRunner
        property var cmd: []
        command: cmd
    }

    function launch(execCmd, appName) {
        launcherWindow.close()
        actionRunner.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/launch-app.sh", execCmd, appName ?? ""]
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
            launcherWindow.search = ""
            itemsList.currentIndex = 0
            focusTimer.restart()
            appScanner.running = true
        }
    }

    Component.onCompleted: {
        appScanner.running = true
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

        opacity: launcherWindow.visible ? 1.0 : 0.0
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
                        text: "󰍉"
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
                            text: "Search apps"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: Theme.gray
                            visible: !searchField.text && !searchField.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onTextChanged: {
                            let t = text
                            launcherWindow.search = text
                            itemsList.currentIndex = 0
                        }

                        // 100% keyboard-driven navigation
                        Keys.onPressed: event => {
                            let count = launcherWindow.filteredApps.length

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
                            } else if (event.key === Qt.Key_Tab) { // autocomplete
                                if (itemsList.currentIndex < count - 1) itemsList.currentIndex++
                                else itemsList.currentIndex = 0
                                itemsList.positionViewAtIndex(itemsList.currentIndex, ListView.Contain)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Backtab) {
                                if (itemsList.currentIndex > 0) itemsList.currentIndex--
                                else itemsList.currentIndex = count - 1
                                itemsList.positionViewAtIndex(itemsList.currentIndex, ListView.Contain)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (launcherWindow.filteredApps.length > 0 && itemsList.currentIndex >= 0 && itemsList.currentIndex < launcherWindow.filteredApps.length) {
                                    let item = launcherWindow.filteredApps[itemsList.currentIndex]
                                    launcherWindow.launch(item.exec, item.name)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                launcherWindow.close()
                                event.accepted = true
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
                model: launcherWindow.filteredApps

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    property bool isSelected: index === itemsList.currentIndex

                    width: itemsList.width
                    height: 50
                    radius: 6
                    color: isSelected ? Theme.bg2 : (itemMouse.containsMouse ? Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.45) : "transparent")
                    border.color: isSelected ? Theme.accent : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // Icon Container: High-res App Image or Letter Badge Fallback
                        Item {
                            visible: true 
                            width: 30
                            height: 30
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                sourceSize.width: 64
                                sourceSize.height: 64
                                asynchronous: true
                                id: appImg
                                anchors.fill: parent
                                source: (modelData.iconPath && modelData.iconPath.length > 0) ? ("file://" + modelData.iconPath) : ""
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                visible: status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 5
                                color: isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Theme.bg1
                                border.color: isSelected ? Theme.accent : Theme.bg3
                                border.width: 1
                                visible: !appImg.visible

                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "󰀻"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: isSelected ? Theme.accent : Theme.fg1
                                }
                            }
                        }


                        // Text Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: modelData.name
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.bold: isSelected
                                    color: isSelected ? Theme.fg0 : Theme.fg1
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Frecency Star for top-used apps
                                Text {
                                    visible: modelData.score > 0
                                    text: "★"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    color: Theme.accent
                                }
                            }

                            Text {
                                text: modelData.subtitle ?? modelData.exec
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
                            launcherWindow.launch(modelData.exec, modelData.name)
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
                    text: "↑↓ nav • ↵ launch • Esc exit"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    color: Theme.gray
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Frecency ranking"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    color: Theme.silver
                }
            }
        }
    }
}
