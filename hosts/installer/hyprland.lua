-- ============================================================
--  Hyprland Lua Configuration — NixOS Installer ISO
-- ============================================================


-- ----------------
--  MONITORS
-- ----------------
-- Auto-detect any connected monitor

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-- ----------------
--  PROGRAMS
-- ----------------

local terminal    = "alacritty"
local browser     = "firefox"
local launcher    = "rofi -show drun -show-icons"
local fileManager = "nautilus"


-- ----------------
--  AUTOSTART
-- ----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd(terminal)

    -- Set wallpaper once swww-daemon is ready
    hl.exec_cmd("while ! swww query 2>/dev/null; do sleep 0.2; done"
        .. " && swww img ~/.config/hypr/wallpaper.png"
        .. " --transition-type fade --transition-duration 2")
end)


-- ----------------
--  ENVIRONMENT
-- ----------------

hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")


-- ----------------
--  LOOK AND FEEL
-- ----------------
-- Electro-swing palette

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 5,
        border_size = 2,
        col = {
            active_border   = { colors = {"rgba(52e9e9ee)", "rgba(4c8cdeee)"}, angle = 45 },
            inactive_border = "rgba(5e676aaa)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 6,
        rounding_power   = 3,
        active_opacity   = 1.0,
        inactive_opacity = 0.97,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee131313,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})


-- ----------------
--  ANIMATIONS
-- ----------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })


-- ----------------
--  LAYOUTS
-- ----------------

hl.config({
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


-- ----------------
--  INPUT
-- ----------------

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },
})


-- ----------------
--  KEYBINDINGS
-- ----------------

local mod = "SUPER"

-- Core
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + F",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + space",  hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + Q",      hl.dsp.window.close())
hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" }))

-- Vim-style focus
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Vim-style window movement
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Fullscreen
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen())

-- Toggle split direction (dwindle)
hl.bind(mod .. " + T", hl.dsp.layout("togglesplit"))

-- Exit Hyprland
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

-- Mouse binds
hl.bind(mod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Volume (XF86 keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })


-- ----------------
--  WINDOW RULES
-- ----------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
