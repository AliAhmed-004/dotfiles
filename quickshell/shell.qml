import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // One bar per monitor
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
