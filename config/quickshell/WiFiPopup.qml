import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: wifiWindow 

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
        wifiWindow.pendingPowerAction = ""
        wifiWindow.requestClose()
        
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

}
