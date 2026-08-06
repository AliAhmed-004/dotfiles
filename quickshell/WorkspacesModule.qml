import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// ─── WorkspacesModule ────────────────────────────────────────────────────────
// Shows 3 workspace slots. Active = filled accent pill, occupied = dim dot,
// empty = ghost ring. Click to switch.
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: wsRoot

    // Expose sizing so Bar.qml can align
    implicitWidth:  wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight

    // Only show 3 workspaces
    readonly property int wsCount: 3

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: wsRoot.wsCount

            Item {
                id: wsSlot

                readonly property int wsId:       index + 1
                readonly property var wsData:     Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isActive:  Hyprland.focusedWorkspace?.id === wsId
                readonly property bool hasWindows: wsData !== undefined && wsData !== null

                implicitWidth:  root.wsSize
                implicitHeight: root.wsSize

                // Dot background
                Rectangle {
                    id: dotBg
                    anchors.centerIn: parent
                    width:   wsSlot.isActive ? root.wsSize      : (wsSlot.hasWindows ? root.wsSize - 4 : root.wsSize - 8)
                    height:  width
                    radius:  width / 2
                    color:   wsSlot.isActive   ? root.colActive
                           : wsSlot.hasWindows ? root.colSurface
                           :                     "transparent"
                    border.color: wsSlot.isActive   ? "transparent"
                                : wsSlot.hasWindows ? root.colMuted
                                :                     root.colMuted
                    border.width: wsSlot.isActive || wsSlot.hasWindows ? 0 : 1
                    opacity: wsSlot.isActive ? 1.0 : 0.7

                    Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on color  { ColorAnimation  { duration: 120 } }
                }

                // Workspace number (visible when active)
                Text {
                    anchors.centerIn: parent
                    text:    wsSlot.wsId.toString()
                    color:   wsSlot.isActive ? "#1e1e2e" : root.colMuted
                    font {
                        family:    root.font
                        pixelSize: 10
                        bold:      true
                    }
                    opacity: wsSlot.isActive ? 1.0 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor

                    onClicked: Hyprland.dispatch("workspace " + wsSlot.wsId)

                    onEntered: dotBg.opacity = 1.0
                    onExited:  dotBg.opacity = wsSlot.isActive ? 1.0 : 0.7
                }
            }
        }
    }
}
