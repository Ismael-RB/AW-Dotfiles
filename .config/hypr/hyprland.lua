-- Alienware m16 R2 — Hyprland config

local mainMod  = "SUPER"
local terminal = "kitty"
local files    = "kitty --title files -e yazi"
local menu     = "fuzzel"


------------------
---- MONITORS ----
------------------

hl.monitor({
    output        = "eDP-1",
    mode          = "2560x1600@240",
    position      = "0x0",
    scale         = 1.6,
    sdrsaturation = 1.10,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/backup-configs.sh")
    hl.exec_cmd("~/.config/hypr/scripts/wal-reload.sh")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("mako")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-cycle.sh current")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("~/.config/hypr/scripts/ws1-fetch.sh")
    hl.exec_cmd("~/.config/hypr/scripts/battery-notify.sh")
    hl.exec_cmd("~/.config/hypr/scripts/bluetooth-notify.sh")
    hl.exec_cmd("[workspace special:scratch silent; float; size 920 540; center] kitty --class scratchpad")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("STEAM_FRAME_FORCE_CLOSE",       "1")
hl.env("STEAM_FORCE_DESKTOPUI_SCALING", "1.6")
hl.env("XCURSOR_THEME",                 "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE",                  "24")
hl.env("HYPRCURSOR_SIZE",               "24")
hl.env("GTK_THEME",                     "Adwaita-dark")
hl.env("QT_QPA_PLATFORMTHEME",          "qt6ct")
hl.env("QT_STYLE_OVERRIDE",             "kvantum")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 6,
        resize_on_border = true,

        col = {
            active_border   = "rgba(2a2a2aee)",
            inactive_border = "rgba(595959aa)",
        },
    },

    decoration = {
        rounding         = 8,
        active_opacity   = 0.92,
        inactive_opacity = 0.80,

        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 3,
            color        = "rgba(00000066)",
        },

        blur = {
            enabled           = true,
            size              = 10,
            passes            = 3,
            brightness        = 0.8,
            contrast          = 1.1,
            noise             = 0.02,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout     = "latam",
        follow_mouse  = 1,
        sensitivity   = 0.3,
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll       = false,
            tap_to_click         = true,
            scroll_factor        = 2.0,
            disable_while_typing = true,
            clickfinger_behavior = true,
        },
    },

    gestures = {
        workspace_swipe_distance           = 250,
        workspace_swipe_invert             = false,
        workspace_swipe_min_speed_to_force = 25,
        workspace_swipe_cancel_ratio       = 0.4,
        workspace_swipe_create_new         = false,
    },
})

-- 3 dedos horizontal → cambiar workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- 3 dedos arriba → salir de fullscreen
hl.gesture({
    fingers   = 3,
    direction = "up",
    action    = function() hl.dispatch(hl.dsp.window.fullscreen()) end,
})

-- 3 dedos abajo → fullscreen
hl.gesture({
    fingers   = 3,
    direction = "down",
    action    = function() hl.dispatch(hl.dsp.window.fullscreen()) end,
})

-- 4 dedos izquierda → mover ventana al workspace anterior
hl.gesture({
    fingers   = 4,
    direction = "left",
    action    = function() hl.dispatch(hl.dsp.window.move({ workspace = "e-1" })) end,
})

-- 4 dedos derecha → mover ventana al workspace siguiente
hl.gesture({
    fingers   = 4,
    direction = "right",
    action    = function() hl.dispatch(hl.dsp.window.move({ workspace = "e+1" })) end,
})

-- 4 dedos arriba → cerrar ventana
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function() hl.dispatch(hl.dsp.window.close()) end,
})

-- 4 dedos abajo → flotar / desFlotar ventana
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function() hl.dispatch(hl.dsp.window.float()) end,
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Power
hl.bind(mainMod .. " + ESCAPE",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mainMod .. " + ALT + ESCAPE",   hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + CTRL + ESCAPE",  hl.dsp.exec_cmd("systemctl reboot"))

-- Apps
hl.bind(mainMod .. " + Q",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",     hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))

-- Ventanas
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float())

-- Scratchpad
hl.bind(mainMod .. " + V",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Foco
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Tab",         hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next("prev"))

-- Mover ventanas
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Redimensionar
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -40, y = 0 }),  { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x =  40, y = 0 }),  { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -40 }),  { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y =  40 }),  { repeating = true })

-- Mouse
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Workspaces
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Fan control
hl.bind("F1", hl.dsp.exec_cmd("awm toggle"))

-- Bluetooth
hl.bind("F9", hl.dsp.exec_cmd("[float; size 700 450; center] kitty --class bluetui bluetui"))


-- Zen mode
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/zen-mode.sh"))

-- Wallpaper
hl.bind(mainMod .. " + braceright", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-cycle.sh next"))
hl.bind(mainMod .. " + braceleft",  hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-cycle.sh prev"))

-- Captura de pantalla
hl.bind(mainMod .. " + S",               hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + S",       hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mainMod .. " + ALT + S",         hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mainMod .. " + CTRL + S",        hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))

-- Hardware keys — Alienware m16 R2
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"),      { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                                 { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                                 { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                                   { locked = true })

-- Portapapeles
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Kitty
hl.window_rule({ name = "kitty-noborder", match = { class = "^kitty$" }, border_size = 0 })

-- Steam
hl.window_rule({ name = "steam-main",    match = { class = "^steam$", title = "^Steam$" },        float = true, size = "1000 680", center = true })
hl.window_rule({ name = "steam-friends", match = { class = "^steam$", title = "^Friends List$" }, float = true })

-- Layer rules — SystemPill
hl.layer_rule({ name = "systempill-blur",  match = { namespace = "SystemPill" }, blur = true })
hl.layer_rule({ name = "systempill-alpha", match = { namespace = "SystemPill" }, ignore_alpha = 0.3 })
hl.layer_rule({ name = "systempill-xray",  match = { namespace = "SystemPill" }, xray = true })
