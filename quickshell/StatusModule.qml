import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

// ─── StatusModule ────────────────────────────────────────────────────────────
// Right side: WiFi · Bluetooth · Notifications · Battery
// Uses Nerd Font icons — requires JetBrainsMono Nerd Font (or any Nerd Font)
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: statusRoot

    implicitWidth:  statusRow.implicitWidth
    implicitHeight: statusRow.implicitHeight

    // ── Bluetooth state from native QS module ────────────────────────────────
    // Show connected if any device is connected across all adapters
    readonly property bool btConnected: {
        for (var i = 0; i < Bluetooth.connectedDevices.length; i++) {
            if (Bluetooth.connectedDevices[i].connected) return true
        }
        return false
    }

    readonly property bool btEnabled: Bluetooth.adapters.length > 0
        && Bluetooth.adapters[0].powered

    RowLayout {
        id: statusRow
        anchors.centerIn: parent
        spacing: 12

        // ── WiFi ─────────────────────────────────────────────────────────────
        Item {
            implicitWidth:  wifiIcon.implicitWidth
            implicitHeight: wifiIcon.implicitHeight

            Text {
                id: wifiIcon
                // Nerd Font wifi icons by signal strength
                text: {
                    if (!root.wifiConnected) return "\udb82\udce0"  // 󰰠 no wifi
                    if (root.wifiStrength >= 75) return "\udb82\udccc"  // 󰰌 full
                    if (root.wifiStrength >= 50) return "\udb82\udccb"  // 󰰋 med-high
                    if (root.wifiStrength >= 25) return "\udb82\udcca"  // 󰰊 med-low
                    return "\udb82\udcc9"                               // 󰰉 low
                }
                color: root.wifiConnected
                    ? (root.wifiStrength >= 50 ? root.colGreen : root.colYellow)
                    : root.colMuted
                font {
                    family:    root.font
                    pixelSize: root.fontSize + 2
                }
                ToolTip.visible: wifiMouse.containsMouse
                ToolTip.text:    root.wifiConnected
                    ? root.wifiSsid + "  " + root.wifiStrength + "%"
                    : "Not connected"
                ToolTip.delay:   600
            }

            MouseArea {
                id: wifiMouse
                anchors.fill:  parent
                hoverEnabled:  true
                cursorShape:   Qt.PointingHandCursor
                onClicked:     Quickshell.execDetached(["nmtui"])
            }
        }

        // ── Bluetooth ────────────────────────────────────────────────────────
        Item {
            implicitWidth:  btIcon.implicitWidth
            implicitHeight: btIcon.implicitHeight

            Text {
                id: btIcon
                text:  statusRoot.btConnected  ? "\uf294"   // 󰊔 connected
                     : statusRoot.btEnabled    ? "\uf293"   //  enabled
                     :                           "\uf294"   //  disabled (same icon, dim)
                color: statusRoot.btConnected ? root.colActive
                     : statusRoot.btEnabled   ? root.colFg
                     :                          root.colMuted
                font {
                    family:    root.font
                    pixelSize: root.fontSize + 2
                }
                ToolTip.visible: btMouse.containsMouse
                ToolTip.text:    statusRoot.btConnected  ? "Bluetooth: connected"
                               : statusRoot.btEnabled    ? "Bluetooth: on"
                               :                           "Bluetooth: off"
                ToolTip.delay:   600
            }

            MouseArea {
                id: btMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                // Toggle power on first adapter
                onClicked: {
                    if (Bluetooth.adapters.length > 0) {
                        Bluetooth.adapters[0].powered = !Bluetooth.adapters[0].powered
                    }
                }
            }
        }

        // Thin separator
        Rectangle {
            width:   1
            height:  14
            color:   root.colMuted
            opacity: 0.35
        }

        // ── Notifications (swaync) ────────────────────────────────────────────
        Item {
            implicitWidth:  notifRow.implicitWidth
            implicitHeight: notifRow.implicitHeight

            RowLayout {
                id: notifRow
                spacing: 3

                Text {
                    id: notifIcon
                    // Bell / Bell-off / Bell with badge
                    text:  root.dndEnabled    ? "\udb80\udf53"   // 󰅓 DND bell
                         : root.notifCount > 0 ? "\udb80\udf50"  // 󰅐 bell with dot
                         :                       "\udb80\udf55"  // 󰅕 bell clear
                    color: root.dndEnabled     ? root.colYellow
                         : root.notifCount > 0 ? root.colPeach
                         :                       root.colMuted
                    font {
                        family:    root.font
                        pixelSize: root.fontSize + 2
                    }
                }

                // Badge count — only show when > 0 and not in DND
                Text {
                    visible: root.notifCount > 0 && !root.dndEnabled
                    text:    root.notifCount > 9 ? "9+" : root.notifCount.toString()
                    color:   root.colPeach
                    font {
                        family:    root.font
                        pixelSize: root.fontSize - 1
                        bold:      true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                // Left click: open swaync panel; right click: toggle DND
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        Quickshell.execDetached(["swaync-client", "-d"])
                    } else {
                        Quickshell.execDetached(["swaync-client", "-t"])
                    }
                }
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                ToolTip.visible: containsMouse
                ToolTip.text:   "Left: toggle panel · Right: toggle DND"
                ToolTip.delay:  600
            }
        }

        // Thin separator
        Rectangle {
            width:   1
            height:  14
            color:   root.colMuted
            opacity: 0.35
        }

        // ── Battery ──────────────────────────────────────────────────────────
        Item {
            implicitWidth:  batRow.implicitWidth
            implicitHeight: batRow.implicitHeight

            RowLayout {
                id: batRow
                spacing: 4

                Text {
                    id: batIcon
                    text: {
                        if (root.batteryCharging) return "\udb80\udc84"  // 󰂄 charging
                        if (root.batteryLevel >= 90) return "\udb80\udc79"  // 󰂹 full
                        if (root.batteryLevel >= 70) return "\udb80\udc78"  // 󰂸
                        if (root.batteryLevel >= 50) return "\udb80\udc77"  // 󰂷
                        if (root.batteryLevel >= 30) return "\udb80\udc76"  // 󰂶
                        if (root.batteryLevel >= 15) return "\udb80\udc75"  // 󰂵 low
                        return "\udb80\udc74"                               // 󰂴 critical
                    }
                    color: root.batteryCharging  ? root.colGreen
                         : root.batteryLevel > 40 ? root.colFg
                         : root.batteryLevel > 20 ? root.colYellow
                         :                          root.colRed
                    font {
                        family:    root.font
                        pixelSize: root.fontSize + 2
                    }
                }

                Text {
                    text:  root.batteryLevel + "%"
                    color: root.batteryCharging  ? root.colGreen
                         : root.batteryLevel > 40 ? root.colFg
                         : root.batteryLevel > 20 ? root.colYellow
                         :                          root.colRed
                    font {
                        family:    root.font
                        pixelSize: root.fontSize
                        bold:      root.batteryLevel <= 20
                    }
                }
            }
        }
    }
}
