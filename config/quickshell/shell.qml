import QtQuick
import Quickshell
import Quickshell.Io
import "bar_widgets"

ShellRoot {
    id: root

    
    property bool launcherVisible: false
    property bool wallpaperPickerVisible: false
    property bool calendarVisible: false
    property bool sessionVisible: false
    property bool themePickerVisible: false
    property bool cheatsheetVisible: false
    property bool clipboardVisible: false
    property bool wifiWidgetVisisble: false
    
    function closeAll() {
        /* In progress shortening all of this, gotta separate a bunch of the apps which were bundled for some reason
         */

        launcherVisible = false
        wallpaperPickerVisible = false
        calendarVisible = false
        sessionVisible = false
        themePickerVisible = false
        cheatsheetVisible = false
        clipboardVisible = false
        wifiWidgetVisisble = false
    }

    function toggleCheatsheet() {
        if (cheatsheetVisible) {
            cheatsheetVisible = false
        } else {
            closeAll()
            cheatsheetVisible = true
        }
    }



    function toggleThemePicker() {
        if (themePickerVisible) {
            themePickerVisible = false
        } else {
            closeAll()
            themePickerVisible = true
        }
    }

    function toggleSession() {
        if (sessionVisible) {
            sessionVisible = false
        } else {
            closeAll()
            sessionVisible = true
        }
    }


    function toggleLauncher() {
        if (launcherVisible) {
            launcherVisible = false
        } else {
            closeAll()
            launcher.open()
            launcherVisible = true
        }
    }

    function toggleClipboard() {
        if (clipboardVisible) {
            clipboardVisible = false
        } else {
            closeAll()
            clipboard.open()
            clipboardVisible= true
        }
    }

    function toggleWallpaperPicker(wallOnly) {
        let isWallOnly = (wallOnly === true)
        if (wallpaperPickerVisible && wallpaperPicker.wallOnlyMode === isWallOnly) {
            wallpaperPickerVisible = false
        } else {
            closeAll()
            wallpaperPicker.wallOnlyMode = isWallOnly
            wallpaperPickerVisible = true
        }
    }

    function toggleCalendar() {
        if (calendarVisible) {
            calendarVisible = false
        } else {
            closeAll()
            calendarVisible = true
        }
    }


    IpcHandler {
        target: "launcher"
        function toggle() { root.toggleLauncher() }
    }

    IpcHandler {
        target: "clipboard"
        function toggle() { root.toggleClipboard() }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle() { root.toggleWallpaperPicker(false) }
        function wallOnly() { root.toggleWallpaperPicker(true) }
    }

    IpcHandler {
        target: "calendar"
        function toggle() { root.toggleCalendar() }
    }

    IpcHandler {
        target: "session"
        function toggle() { root.toggleSession() }
    }



    IpcHandler {
        target: "theme_picker"
        function toggle() { root.toggleThemePicker() }
    }

    IpcHandler {
        target: "cheatsheet"
        function toggle() { root.toggleCheatsheet() }
    }

    IpcHandler {
        target: "theme"
        function reload() { Theme.reload() }
    }

    // Top Bar (Always visible)
    Bar {
        id: topBar
        onLauncherToggleRequested: root.toggleLauncher()
        onWallpaperToggleRequested: root.toggleWallpaperPicker()
        onCalendarToggleRequested: root.toggleCalendar()
    }


    WiFiWidget{
        id:wifiwidget
        visible: root.wifiWidgetVisisble
        onRequestClose: root.wifiWidgetVisisble = false
    }

    Launcher {
        id: launcher
        visible: root.launcherVisible
        onRequestClose: root.launcherVisible = false
    }

    Clipboard {
        id: clipboard 
        visible: root.clipboardVisible
        onRequestClose: root.clipboardVisible = false
    }
    
    WallpaperPicker {
        id: wallpaperPicker
        visible: root.wallpaperPickerVisible
        onRequestClose: root.wallpaperPickerVisible = false
    }

    CalendarDropdown {
        id: calendarDropdown
        visible: root.calendarVisible
        onRequestClose: root.calendarVisible = false
    }

    SessionMenu {
        id: sessionMenu
        visible: root.sessionVisible
        onRequestClose: root.sessionVisible = false
    }



    ThemePicker {
        id: themePicker
        visible: root.themePickerVisible
        onRequestClose: root.themePickerVisible = false
    }

    Cheatsheet {
        id: cheatsheet
        visible: root.cheatsheetVisible
        onRequestClose: root.cheatsheetVisible = false
    }

}
