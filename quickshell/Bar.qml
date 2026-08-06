import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

// ─── Floating Pill Bar ────────────────────────────────────────────────────────
// Layout: [Workspaces] ··· [Clock | Date | Day] ··· [Wifi · BT · Notifs · Bat]
// ─────────────────────────────────────────────────────────────────────────────

PanelWindow {
    id: root

    // Anchor top only — no left/right so it floats freely
    anchors.top: true
    anchors.left: true
    anchors.right: true

    // Pill height + vertical gap from screen edge
    implicitHeight: barHeight + barMarginV * 2

    // No exclusion zone — windows slide under it like a real floating bar
    exclusionMode: ExclusionMode.Ignore

    // Transparent window background; pill draws its own rectangle
    color: "transparent"

    // ─── Design Tokens ──────────────────────────────────────────────────────
    readonly property int barHeight:    36
    readonly property int barMarginV:   8      // gap from screen top
    readonly property int barMarginH:   120    // shrink from screen sides
    readonly property int pillRadius:   18     // full pill = height/2
    readonly property int innerPad:     10     // padding inside pill sections
    readonly property int sectionGap:   6      // gap between the three sections
    readonly property int wsSize:       26     // workspace dot diameter

    readonly property color colBg:      "#CC1e1e2e"   // catppuccin mantle 80% opacity
    readonly property color colFg:      "#cdd6f4"     // text
    readonly property color colMuted:   "#585b70"     // inactive
    readonly property color colActive:  "#89b4fa"     // blue accent
    readonly property color colGreen:   "#a6e3a1"
    readonly property color colYellow:  "#f9e2af"
    readonly property color colRed:     "#f38ba8"
    readonly property color colPeach:   "#fab387"
    readonly property color colSurface: "#31324a"     // separator / dot bg

    readonly property string font:      "JetBrainsMono Nerd Font"
    readonly property int    fontSize:  12

    // ─── System State ───────────────────────────────────────────────────────
    property string wifiSsid:       ""
    property int    wifiStrength:   0   // 0-100
    property bool   wifiConnected:  false

    property int    batteryLevel:   100
    property bool   batteryCharging: false

    property int    notifCount:     0
    property bool   dndEnabled:     false

    // ─── Processes ──────────────────────────────────────────────────────────

    // WiFi — nmcli, fires every 10 s
    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1"]
        stdout: SplitParser {
            onRead: line => {
                if (!line.trim()) {
                    root.wifiConnected = false
                    root.wifiSsid = ""
                    root.wifiStrength = 0
                    return
                }
                var parts = line.trim().split(":")
                if (parts.length >= 3) {
                    root.wifiConnected = true
                    root.wifiSsid     = parts[1] || ""
                    root.wifiStrength = parseInt(parts[2]) || 0
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 10000
        running:  true
        repeat:   true
        onTriggered: wifiProc.running = true
    }

    // Battery — reads sysfs
    Process {
        id: batProc
        command: ["sh", "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 100"]
        stdout: SplitParser {
            onRead: line => {
                var n = parseInt(line.trim())
                if (!isNaN(n)) root.batteryLevel = n
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: batStatusProc
        command: ["sh", "-c",
            "cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Discharging"]
        stdout: SplitParser {
            onRead: line => {
                root.batteryCharging = line.trim() === "Charging" || line.trim() === "Full"
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 30000
        running:  true
        repeat:   true
        onTriggered: {
            batProc.running       = true
            batStatusProc.running = true
        }
    }

    // swaync notification count + DND state
    Process {
        id: swayncProc
        command: ["sh", "-c", "swaync-client -s 2>/dev/null || echo '0\nfalse'"]
        stdout: SplitParser {
            property int lineNum: 0
            onRead: line => {
                // swaync-client -s outputs: count on line1, dnd on line2
                if (lineNum === 0) {
                    var n = parseInt(line.trim())
                    if (!isNaN(n)) root.notifCount = n
                } else if (lineNum === 1) {
                    root.dndEnabled = line.trim() === "true"
                }
                lineNum++
            }
        }
        onRunningChanged: if (!running) {
            // reset line counter for next poll
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running:  true
        repeat:   true
        onTriggered: swayncProc.running = true
    }

    // ─── Pill Container ─────────────────────────────────────────────────────
    Item {
        id: pillContainer

        anchors {
            top:        parent.top
            left:       parent.left
            right:      parent.right
            topMargin:  root.barMarginV
            leftMargin: root.barMarginH
            rightMargin:root.barMarginH
        }
        height: root.barHeight

        // Pill background
        Rectangle {
            anchors.fill: parent
            radius:       root.pillRadius
            color:        root.colBg

            // Subtle inner glow border
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1

            layer.enabled: true
            layer.effect: null   // drop-shadow via MultiEffect if available
        }

        // Three-section layout
        RowLayout {
            anchors {
                fill:           parent
                leftMargin:     root.innerPad
                rightMargin:    root.innerPad
                topMargin:      0
                bottomMargin:   0
            }
            spacing: root.sectionGap

            // ── LEFT: Workspaces ────────────────────────────────────────────
            WorkspacesModule {
                id: workspaces
                Layout.alignment: Qt.AlignVCenter
            }

            // Flex spacer
            Item { Layout.fillWidth: true }

            // ── CENTRE: Clock / Date / Day ──────────────────────────────────
            ClockModule {
                id: clockWidget
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            }

            // Flex spacer
            Item { Layout.fillWidth: true }

            // ── RIGHT: Status Icons ─────────────────────────────────────────
            StatusModule {
                id: statusRight
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
