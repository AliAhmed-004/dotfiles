-- =============================
-- Autostart
-- =============================

hl.on("hyprland.start", function()
	hl.exec_cmd("quickshell")
	hl.exec_cmd("hyprpaper")

	-- Future additions:
	-- hl.exec_cmd("hyprpaper")
	-- hl.exec_cmd("swaync")
	-- hl.exec_cmd("hypridle")
	-- hl.exec_cmd("nm-applet")
end)
