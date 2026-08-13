-- Assign workspaces to monitors
for i = 1, 10 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end

for i = 11, 15 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end
