import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: wifiWindow 
    
    anchors {
        top:true
        
        bottom:true
    }

    implicitHeight: 30

    Text {
        id: clock

        anchors.centerIn: parent
        text: "hello world"

        Process {
            command: ["date"]

            running: true
    
            stdout: StdioCollector {
                onStreamFinished:clock.text=this.text
            }
        }

    }
}
