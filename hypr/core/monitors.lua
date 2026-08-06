hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x900", -- sits below HDMI, offset by HDMI's logical height
	scale = 1.2,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@60",
	position = "0x0", -- top monitor starts at origin
	scale = 1.2,
})
