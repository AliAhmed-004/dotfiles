import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// ─── WorkspacesModule ────────────────────────────────────────────────────────
// Shows at least 5 workspace slots. Dynamically expands when:
//   - A workspace above 5 has windows on it
//   - You navigate to a workspace above 5
// Shrinks back when those workspaces are empty and not focused.
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: wsRoot

    implicitWidth:  wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight

    readonly property int minWs: 5

    // Build the list of workspace IDs to display:
    // - Always show 1..minWs
    // - Also show any WS above minWs that has windows OR is currently focused
    readonly property var visibleIds: {
        var ids = []
        var activeWsIds = new Set()

        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            activeWsIds.add(Hyprland.workspaces.values[i].id)
        }

        var focused = Hyprland.focusedWorkspace?.id ?? 1

        for (var j = 1; j <= minWs; j++) {
            ids.push(j)
        }

        // Above minWs: only if occupied or focused
        for (var k = minWs + 1; k <= 20; k++) {
            if (activeWsIds.has(k) || focused === k) {
                ids.push(k)
            }
        }

        return ids
    }

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: wsRoot.visibleIds

            Item {
                id: wsSlot

                readonly property int  wsId:       wsRoot.visibleIds[index]
                readonly property var  wsData:     Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isActive:   (Hyprland.focusedWorkspace?.id ?? -1) === wsId
                readonly property bool hasWindows: wsData !== undefined && wsData !== null

                implicitWidth:  root.wsSize
                implicitHeight: root.wsSize

                opacity: 1
                Behavior on opacity { NumberAnimation { duration: 150 } }

                // Dot background
                Rectangle {
                    id: dotBg
                    anchors.centerIn: parent
                    width:  wsSlot.isActive ? root.wsSize : (wsSlot.hasWindows ? root.wsSize - 4 : root.wsSize - 8)
                    height: width
                    radius: width / 2
                    color:  wsSlot.isActive   ? root.colActive
                          : wsSlot.hasWindows ? root.colSurface
                          :                     "transparent"
                    border.color: wsSlot.isActive || wsSlot.hasWindows ? "transparent" : root.colMuted
                    border.width: wsSlot.isActive || wsSlot.hasWindows ? 0 : 1
                    opacity: wsSlot.isActive ? 1.0 : 0.7

                    Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on color  { ColorAnimation  { duration: 120 } }
                }

                // Workspace number
                Text {
                    anchors.centerIn: parent
                    text:  wsSlot.wsId.toString()
                    color: wsSlot.isActive ? "#1e1e2e" : root.colMuted
                    font {
                        family:    root.font
                        pixelSize: 10
                        bold:      true
                    }
                    opacity: wsSlot.isActive ? 1.0 : (wsSlot.hasWindows ? 0.6 : 0.4)
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Hyprland.dispatch("workspace " + wsSlot.wsId)
                    onEntered:    dotBg.opacity = 1.0
                    onExited:     dotBg.opacity = wsSlot.isActive ? 1.0 : 0.7
                }
            }
        }
    }
}
