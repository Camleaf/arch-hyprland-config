import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io

PanelWindow {
    id: wifiDashboard

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
        wifiDashboard.pendingPowerAction = ""
        visible=false
        wifiDashboard.requestClose()
    }

    // Active View Tab: "controls" or "notifications"
    property string currentTab: "controls"

    // Telemetry & Hardware States
    property int sysVol: 50
    property bool isMuted: false
    property int sysBri: 75
    property string wifiRadio: "enabled"
    property string wifiSsid: ""
    property string caffeineState: "off"
    property string nightLightState: "off"
    property bool gameModeState: false
    property string surfaceMode: "obsidian"
    property string activeScheme: "scheme-vibrant"
    property string uptimeStr: "Online"
    property string pendingPowerAction: "" // "", "reboot", "poweroff"

    // Hardware Sensors
    property int hwCpu: 0
    property int hwRam: 0
    property string hwRamStr: "0G / 0G"
    property int hwDisk: 0
    property string hwDiskStr: "0G / 0G"
    property var topProcs: []

    // Active player accessor
    property var player: (Mpris.players && Mpris.players.values && Mpris.players.values.length > 0)
                         ? Mpris.players.values[0]
                         : null

    // Non-blocking detached launcher (exits in <1ms, never locks Quickshell)
    Process {
        id: actionProc
        property var cmd: []
        command: cmd
    }

    function launchApp(execCmd) {
        wifiDashboard.close()
        actionProc.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/launch-app.sh", execCmd]
        actionProc.running = true
    }

    function runDetached(cmdStr) {
        actionProc.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/launch-app.sh", cmdStr]
        actionProc.running = true
    }



    // Comprehensive state sync process
    Process {
        id: stateSyncProc
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-sync.sh"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let d = JSON.parse(data.trim())
                } catch(e) {}
            }
        }
    }

    // Hardware resources process
    Process {
        id: hwStatsProc
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/hw-stats.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let d = JSON.parse(data)
                } catch (e) {}
            }
        }
    }

    // Sync timer on visible
    Timer {
        interval: 2000
        running: wifiDashboard.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stateSyncProc.running = true
            hwStatsProc.running = true
        }
    }

    // Fluid backdrop dim with smooth cubic fade
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: wifiDashboard.visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: wifiDashboard.close()
        }
    }

    // Slide-out Bento Drawer from right edge (440px wide, macOS spring glide)
    Rectangle {
        id: drawer
        width: 440
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 12
        radius: 14
        color: Qt.rgba(Theme.bg0.r, Theme.bg0.g, Theme.bg0.b, 0.95)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
        border.width: 1
        clip: true

        transform: Translate {
            x: wifiDashboard.visible ? 0 : 470
            Behavior on x {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }
        }

        // Escape key handler
        Item {
            anchors.fill: parent
            focus: wifiDashboard.visible
            Keys.onEscapePressed: wifiDashboard.close()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ================= HEADER ROW =================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // OS & User pill
                Row {
                    spacing: 8
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: Theme.bg2
                        border.color: Theme.accent
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "󰣇"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 15
                            color: Theme.accent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1
                        Text {
                            text: "Arch Linux"
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                            font.pixelSize: 12
                            color: Theme.fg0
                        }
                        Text {
                            text: "󰔚 Up " + wifiDashboard.uptimeStr
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            color: Theme.silver
                        }
                    }
                }

                Item { Layout.fillWidth: true }


                // Close Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 7
                    color: closeMouse.containsMouse ? Theme.bg3 : Theme.bg1
                    border.color: closeMouse.containsMouse ? Theme.accent : Theme.bg3
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: closeMouse.containsMouse ? Theme.red : Theme.silver
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiDashboard.close()
                    }
                }
            }

            // ================= CONTROLS VIEW =================
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: controlsCol.implicitHeight
                clip: true
                visible: wifiDashboard.currentTab === "controls"
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: controlsCol
                    width: parent.width
                    spacing: 12

                    // 1. BENTO QUICK TOGGLES (2 Columns x 3 Rows)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                    }    
                }
            }
        }
    }
}
