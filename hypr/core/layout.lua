-- =============================
-- General
-- =============================

hl.config({
    general = {
        layout = "dwindle",
    },
})

-- =============================
-- Dwindle Layout
-- =============================

hl.config({
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
        special_scale_factor = 0.8,
    },
})

-- =============================
-- Master Layout
-- =============================

hl.config({
    master = {
        new_status = "master",
        mfact = 0.55,
        orientation = "left",
    },
})
