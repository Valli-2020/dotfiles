-- Hyprland 0.57 (Lua) config, modelled on github.com/binnewbs/arch-hyprland
-- Colours come from matugen (~/.config/hypr/colors.lua, rewritten on every wallpaper change via SUPER+W)

local ok, c = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok or type(c) ~= "table" then
    -- fallback until matugen has run once
    c = { outline = "rgba(8a9297ff)", outline_variant = "rgba(40484cff)" }
end

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"
local scripts     = "~/.config/hypr/scripts/"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = c.outline,
            inactive_border = c.outline_variant,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.8,
        shadow = { enabled = false },
        blur = {
            enabled   = true,
            size      = 5,
            passes    = 3,
            ignore_opacity    = true,
            new_optimizations = true,
            special   = false,
            popups    = true,
            xray      = true,
            vibrancy  = 0.1696,
        },
    },
    animations = { enabled = true },
    dwindle = {
        preserve_split = true,
    },
    master = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    input = {
        kb_layout  = "de",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

--------------------
---- ANIMATIONS ----
--------------------
local function bezier(name, x1, y1, x2, y2)
    hl.curve(name, { type = "bezier", points = { {x1, y1}, {x2, y2} } })
end
bezier("been",    0.24, 0.9,  0.25, 0.91)
bezier("linear",  0.0,  0.0,  1.0,  1.0)
bezier("wind",    0.05, 0.9,  0.1,  1.05)
bezier("slow",    0,    0.85, 0.3,  1)
bezier("overshot",0.7,  0.6,  0.1,  1.1)
bezier("bounce",  1.1,  1.6,  0.1,  0.85)

hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "slow",     style = "popin" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7, bezier = "been",     style = "popin 70%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind",     style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 1, bezier = "linear" })
hl.animation({ leaf = "fade",        enabled = true, speed = 5, bezier = "overshot" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "wind" })
hl.animation({ leaf = "windows",     enabled = true, speed = 5, bezier = "bounce",   style = "popin" })

-------------------------------
---- WINDOW / LAYER RULES ----
-------------------------------
-- tags
hl.window_rule({ match = { class = "^([Mm]pv|vlc)$" }, tag = "+multimedia_video" })
hl.window_rule({ match = { class = "^(nm-applet|nm-connection-editor|blueman-manager|org.gnome.FileRoller|org.gnome.DiskUtility)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(org.gnome.SystemMonitor|org.gnome.Evince|eog|org.gnome.Loupe)$" }, tag = "+viewer" })

hl.window_rule({ match = { tag = "multimedia_video*" }, no_blur = true, opacity = "1.0", float = true, size = { 900, 506 } })
hl.window_rule({ match = { tag = "settings*" }, opacity = "0.8", float = true })
hl.window_rule({ match = { tag = "viewer*" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" }, opacity = "0.8" })
hl.window_rule({ match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, opacity = "0.9" })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, opacity = "0.9", float = true, size = { "monitor_w*0.5", "monitor_h*0.6" } })
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.9" })
hl.window_rule({ match = { class = "^(discord|vesktop|org.telegram.desktop)$" }, opacity = "0.85 override 0.7 override 1 override" })
hl.window_rule({ match = { title = "^(Save As|Save a File|Pick Files)$" }, float = true, center = true, size = { "monitor_w*0.5", "monitor_h*0.6" } })
hl.window_rule({ match = { initial_title = "(Open Files)" }, float = true, size = { "monitor_w*0.7", "monitor_h*0.6" } })

hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.5, xray = false })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5, xray = false })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal, { float = true, size = { 800, 550 } }))
hl.bind(mainMod .. " + Q",              hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.exec_cmd(scripts .. "KillActiveProcess.sh"))
hl.bind("CTRL + ALT + Delete",          hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E",      hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + Space",          hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",              hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd("xdg-open https://"))
hl.bind(mainMod .. " + L",              hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + Escape",         hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + W",              hl.dsp.exec_cmd(scripts .. "wppicker.sh"))
hl.bind(mainMod .. " + C",              hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + R",              hl.dsp.exec_cmd(scripts .. "wbrestart.sh"))
hl.bind(mainMod .. " + CTRL + B",       hl.dsp.exec_cmd(scripts .. "WaybarStyles.sh"))
hl.bind(mainMod .. " + ALT + B",        hl.dsp.exec_cmd(scripts .. "WaybarLayout.sh"))
hl.bind(mainMod .. " + H",              hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + N",              hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + W",      hl.dsp.exec_cmd("networkmanager_dmenu"))
hl.bind(mainMod .. " + SHIFT + B",      hl.dsp.exec_cmd("rofi-bluetooth"))

-- Screenshots: region / full screen, saved to ~/Pictures/Screenshots and copied
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scripts .. "screenshot.sh"))
hl.bind("Print",                   hl.dsp.exec_cmd(scripts .. "screenshot.sh"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots; f=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png; grim $f && wl-copy < $f"))

-- Focus / move / resize
for _, d in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. d,            hl.dsp.focus({ direction = d }))
    hl.bind(mainMod .. " + CTRL + " .. d,     hl.dsp.window.move({ direction = d }))
end
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { repeating = true })

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Media keys (with swaync OSD notifications)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "volume.sh --inc"),        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "volume.sh --dec"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "volume.sh --toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "brightness.sh --inc"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "brightness.sh --dec"),    { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
