import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// ─── WorkspacesModule ────────────────────────────────────────────────────────
<<<<<<< HEAD
// Shows at least 3 workspace slots. Dynamically expands when:
//   - A workspace above 3 has windows on it
//   - You navigate to a workspace above 3
// Shrinks back when those workspaces are empty and not focused.
=======
// Shows 3 workspace slots. Active = filled accent pill, occupied = dim dot,
// empty = ghost ring. Click to switch.
>>>>>>> nvim
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: wsRoot

<<<<<<< HEAD
    implicitWidth:  wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight

    readonly property int minWs: 5

    // Build the list of workspace IDs to display:
    // - Always show 1..minWs
    // - Also show any WS above minWs that has windows OR is currently focused
    readonly property var visibleIds: {
        var ids = []
        var max = minWs

        // Find highest relevant workspace
        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            var ws = Hyprland.workspaces.values[i]
            if (ws.id > max) max = ws.id
        }
        var focused = Hyprland.focusedWorkspace?.id ?? 1
        if (focused > max) max = focused

        for (var j = 1; j <= max; j++) {
            ids.push(j)
        }
        return ids
    }
=======
    // Expose sizing so Bar.qml can align
    implicitWidth:  wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight

    // Only show 3 workspaces
    readonly property int wsCount: 3
>>>>>>> nvim

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 5

        Repeater {
<<<<<<< HEAD
            model: wsRoot.visibleIds
=======
            model: wsRoot.wsCount
>>>>>>> nvim

            Item {
                id: wsSlot

<<<<<<< HEAD
                readonly property int wsId:       wsRoot.visibleIds[index]
                readonly property var wsData:     Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isActive:  (Hyprland.focusedWorkspace?.id ?? -1) === wsId
=======
                readonly property int wsId:       index + 1
                readonly property var wsData:     Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isActive:  Hyprland.focusedWorkspace?.id === wsId
>>>>>>> nvim
                readonly property bool hasWindows: wsData !== undefined && wsData !== null

                implicitWidth:  root.wsSize
                implicitHeight: root.wsSize

<<<<<<< HEAD
                // Appear smoothly when added
                opacity: 1
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Rectangle {
                    id: dotBg
                    anchors.centerIn: parent
                    width:  wsSlot.isActive ? root.wsSize : (wsSlot.hasWindows ? root.wsSize - 4 : root.wsSize - 8)
                    height: width
                    radius: width / 2
                    color:  wsSlot.isActive    ? root.colActive
                          : wsSlot.hasWindows  ? root.colSurface
                          :                      "transparent"
                    border.color: wsSlot.isActive || wsSlot.hasWindows ? "transparent" : root.colMuted
=======
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
>>>>>>> nvim
                    border.width: wsSlot.isActive || wsSlot.hasWindows ? 0 : 1
                    opacity: wsSlot.isActive ? 1.0 : 0.7

                    Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on color  { ColorAnimation  { duration: 120 } }
                }

<<<<<<< HEAD
                Text {
                    anchors.centerIn: parent
                    text:  wsSlot.wsId.toString()
                    color: wsSlot.isActive ? "#1e1e2e" : root.colMuted
=======
                // Workspace number (visible when active)
                Text {
                    anchors.centerIn: parent
                    text:    wsSlot.wsId.toString()
                    color:   wsSlot.isActive ? "#1e1e2e" : root.colMuted
>>>>>>> nvim
                    font {
                        family:    root.font
                        pixelSize: 10
                        bold:      true
                    }
<<<<<<< HEAD
                    opacity: wsSlot.isActive ? 1.0 : (wsSlot.hasWindows ? 0.6 : 0.4)
=======
                    opacity: wsSlot.isActive ? 1.0 : 0.5
>>>>>>> nvim
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
<<<<<<< HEAD
                    onClicked:    Hyprland.dispatch("workspace " + wsSlot.wsId)
                    onEntered:    dotBg.opacity = 1.0
                    onExited:     dotBg.opacity = wsSlot.isActive ? 1.0 : 0.7
=======

                    onClicked: Hyprland.dispatch("workspace " + wsSlot.wsId)

                    onEntered: dotBg.opacity = 1.0
                    onExited:  dotBg.opacity = wsSlot.isActive ? 1.0 : 0.7
>>>>>>> nvim
                }
            }
        }
    }
}
