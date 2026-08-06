import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// ─── StatusModule ────────────────────────────────────────────────────────────
// Right side: WiFi · Bluetooth · Notifications · Battery
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: statusRoot

    implicitWidth:  statusRow.implicitWidth
    implicitHeight: statusRow.implicitHeight

    // ── Bluetooth state via bluetoothctl ─────────────────────────────────────
    property bool btEnabled:   false
    property bool btConnected: false
    property int  _btLine:     0

    Process {
        id: btProc
        command: ["sh", "-c", "bluetoothctl show | grep -c 'Powered: yes'; bluetoothctl info 2>/dev/null | grep -c 'Connected: yes'"]
        stdout: SplitParser {
            onRead: line => {
                var n = parseInt(line.trim())
                if (statusRoot._btLine === 0)      statusRoot.btEnabled   = n > 0
                else if (statusRoot._btLine === 1)  statusRoot.btConnected = n > 0
                statusRoot._btLine++
            }
        }
        onRunningChanged: if (!running) statusRoot._btLine = 0
        Component.onCompleted: running = true
    }

    Timer {
        interval: 8000
        running:  true
        repeat:   true
        onTriggered: btProc.running = true
    }

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
                text: {
                    if (!root.wifiConnected)          return "\udb82\udce0"
                    if (root.wifiStrength >= 75)      return "\udb82\udccc"
                    if (root.wifiStrength >= 50)      return "\udb82\udccb"
                    if (root.wifiStrength >= 25)      return "\udb82\udcca"
                    return "\udb82\udcc9"
                }
                color: root.wifiConnected
                    ? (root.wifiStrength >= 50 ? root.colGreen : root.colYellow)
                    : root.colMuted
                font { family: root.font; pixelSize: root.fontSize + 2 }

                ToolTip.visible: wifiMouse.containsMouse
                ToolTip.text:    root.wifiConnected
                    ? root.wifiSsid + "  " + root.wifiStrength + "%"
                    : "Not connected"
                ToolTip.delay: 600
            }

            MouseArea {
                id: wifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    Quickshell.execDetached(["nmtui"])
            }
        }

        // ── Bluetooth ────────────────────────────────────────────────────────
        Item {
            implicitWidth:  btIcon.implicitWidth
            implicitHeight: btIcon.implicitHeight

            Text {
                id: btIcon
                text:  statusRoot.btConnected ? "\uf294"
                     : statusRoot.btEnabled   ? "\uf293"
                     :                          "\uf294"
                color: statusRoot.btConnected ? root.colActive
                     : statusRoot.btEnabled   ? root.colFg
                     :                          root.colMuted
                font { family: root.font; pixelSize: root.fontSize + 2 }

                ToolTip.visible: btMouse.containsMouse
                ToolTip.text:    statusRoot.btConnected ? "Bluetooth: connected"
                               : statusRoot.btEnabled   ? "Bluetooth: on"
                               :                          "Bluetooth: off"
                ToolTip.delay: 600
            }

            MouseArea {
                id: btMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    var cmd = statusRoot.btEnabled ? ["bluetoothctl", "power", "off"]
                                                   : ["bluetoothctl", "power", "on"]
                    Quickshell.execDetached(cmd)
                    btRefreshDelay.running = true
                }
            }

            Timer {
                id: btRefreshDelay
                interval: 1500
                repeat:   false
                onTriggered: btProc.running = true
            }
        }

        // Thin separator
        Rectangle { width: 1; height: 14; color: root.colMuted; opacity: 0.35 }

        // ── Notifications (swaync) ────────────────────────────────────────────
        Item {
            implicitWidth:  notifRow.implicitWidth
            implicitHeight: notifRow.implicitHeight

            RowLayout {
                id: notifRow
                spacing: 3

                Text {
                    text:  root.dndEnabled     ? "\udb80\udf53"
                         : root.notifCount > 0  ? "\udb80\udf50"
                         :                        "\udb80\udf55"
                    color: root.dndEnabled     ? root.colYellow
                         : root.notifCount > 0  ? root.colPeach
                         :                        root.colMuted
                    font { family: root.font; pixelSize: root.fontSize + 2 }
                }

                Text {
                    visible: root.notifCount > 0 && !root.dndEnabled
                    text:    root.notifCount > 9 ? "9+" : root.notifCount.toString()
                    color:   root.colPeach
                    font { family: root.font; pixelSize: root.fontSize - 1; bold: true }
                }
            }

            MouseArea {
                anchors.fill:    parent
                hoverEnabled:    true
                cursorShape:     Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        Quickshell.execDetached(["swaync-client", "-d"])
                    else
                        Quickshell.execDetached(["swaync-client", "-t"])
                }
                ToolTip.visible: containsMouse
                ToolTip.text:    "Left: panel · Right: DND"
                ToolTip.delay:   600
            }
        }

        // Thin separator
        Rectangle { width: 1; height: 14; color: root.colMuted; opacity: 0.35 }

        // ── Battery ──────────────────────────────────────────────────────────
        Item {
            implicitWidth:  batRow.implicitWidth
            implicitHeight: batRow.implicitHeight

            RowLayout {
                id: batRow
                spacing: 4

                Text {
                    text: {
                        if (root.batteryCharging)    return "\udb80\udc84"
                        if (root.batteryLevel >= 90) return "\udb80\udc79"
                        if (root.batteryLevel >= 70) return "\udb80\udc78"
                        if (root.batteryLevel >= 50) return "\udb80\udc77"
                        if (root.batteryLevel >= 30) return "\udb80\udc76"
                        if (root.batteryLevel >= 15) return "\udb80\udc75"
                        return "\udb80\udc74"
                    }
                    color: root.batteryCharging   ? root.colGreen
                         : root.batteryLevel > 40  ? root.colFg
                         : root.batteryLevel > 20  ? root.colYellow
                         :                           root.colRed
                    font { family: root.font; pixelSize: root.fontSize + 2 }
                }

                Text {
                    text:  root.batteryLevel + "%"
                    color: root.batteryCharging   ? root.colGreen
                         : root.batteryLevel > 40  ? root.colFg
                         : root.batteryLevel > 20  ? root.colYellow
                         :                           root.colRed
                    font { family: root.font; pixelSize: root.fontSize; bold: root.batteryLevel <= 20 }
                }
            }
        }
    }
}
