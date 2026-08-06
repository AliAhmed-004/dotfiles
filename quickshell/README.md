# Pill Bar — Quickshell config for Hyprland

A floating pill-shaped top bar with three sections:

```
[ ① ② ③ ]   ···   Mon · 10:42 AM · Aug 06   ···   [ 󰰌  󰊔  󰅕  󰂷 89% ]
  workspaces         clock / date / day              wifi bt notifs battery
```

## Dependencies

| Package             | Purpose                        |
|---------------------|-------------------------------|
| `quickshell`        | Shell framework (AUR: `quickshell-git`) |
| `nmcli`             | WiFi SSID + signal (`networkmanager`) |
| `bluez` / `bluez-utils` | Bluetooth (native QS module) |
| `swaync`            | Notification daemon + panel   |
| `swaync-client`     | Included with swaync          |
| A **Nerd Font**     | Icons (JetBrainsMono NF recommended) |

## Install

```bash
# 1. Install quickshell
yay -S quickshell-git

# 2. Backup existing config
mv ~/.config/quickshell ~/.config/quickshell.bak

# 3. Drop these files in
mkdir -p ~/.config/quickshell
cp -r . ~/.config/quickshell/

# 4. Launch
quickshell
# or add to hyprland.conf:
#   exec-once = quickshell
```

## Customisation

All colours, sizes, and fonts live at the **top of `Bar.qml`** in the
`Design Tokens` block — that's the only file you need to touch for aesthetics.

```qml
readonly property color colBg:    "#CC1e1e2e"   // pill background (with alpha)
readonly property color colActive: "#89b4fa"    // accent (workspaces, active BT)
readonly property string font:    "JetBrainsMono Nerd Font"
readonly property int barMarginH: 120           // shrink bar from screen edges
```

### Changing workspace count

Open `WorkspacesModule.qml` and change:

```qml
readonly property int wsCount: 3   // ← bump to 5, 9, etc.
```

### Battery path

If your battery is `BAT1` instead of `BAT0`, the processes in `Bar.qml`
already fall through to `BAT1` automatically via:

```sh
cat /sys/class/power_supply/BAT0/capacity || cat /sys/class/power_supply/BAT1/capacity
```

### swaync DND polling

`swaync-client -s` is polled every 5 s. Left-click the bell to toggle the
panel; right-click to toggle Do Not Disturb.

## Notes

- `exclusionMode: ExclusionMode.Ignore` makes windows slide under the bar
  (true floating). Change to `ExclusionMode.Auto` if you want it to
  reserve space like waybar does.
- Tooltips appear on hover (600 ms delay) for wifi SSID, BT state, and
  the notification click hints.
- Multi-monitor: `Variants { model: Quickshell.screens }` spawns one bar
  per connected display automatically.
