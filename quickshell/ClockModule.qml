import QtQuick
import QtQuick.Layouts

// ─── ClockModule ─────────────────────────────────────────────────────────────
// Centre piece: time in 12-hr AM/PM | date | day
// Format: 10:42 AM  ·  Mon, Aug 06
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: clockRoot

    implicitWidth:  clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight

    // Update every second
    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: clockRoot.refresh()
    }

    property string timeStr: ""
    property string dateStr: ""
    property string dayStr:  ""

    function refresh() {
        var now  = new Date()
        timeStr  = Qt.formatTime(now, "h:mm AP")     // e.g. "10:42 AM"
        dateStr  = Qt.formatDate(now, "MMM dd")       // e.g. "Aug 06"
        dayStr   = Qt.formatDate(now, "ddd")          // e.g. "Mon"
    }

    Component.onCompleted: refresh()

    RowLayout {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        // Day
        Text {
            text:  clockRoot.dayStr
            color: root.colMuted
            font {
                family:    root.font
                pixelSize: root.fontSize
                bold:      false
            }
        }

        // Thin separator
        Rectangle {
            width:  1
            height: 12
            color:  root.colMuted
            opacity: 0.4
        }

        // Time — slightly larger and brighter
        Text {
            text:  clockRoot.timeStr
            color: root.colFg
            font {
                family:    root.font
                pixelSize: root.fontSize + 2
                bold:      true
            }
        }

        // Thin separator
        Rectangle {
            width:  1
            height: 12
            color:  root.colMuted
            opacity: 0.4
        }

        // Date
        Text {
            text:  clockRoot.dateStr
            color: root.colMuted
            font {
                family:    root.font
                pixelSize: root.fontSize
                bold:      false
            }
        }
    }
}
