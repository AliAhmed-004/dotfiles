-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 0,

		layout = "dwindle",
	},
})

hl.config({
	dwindle = {
		force_split = 2,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		-- Use round window corners.
		rounding = 8,

		-- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
		dim_inactive = true,
		dim_strength = 0.30,
	},
})
