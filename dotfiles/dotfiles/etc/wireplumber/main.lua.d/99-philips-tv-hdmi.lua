--[[
    This fixes the silent HDMI output of my Philips TV with wireplumber, as
    mentioned here:
    https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3016
--]]

table.insert(
    alsa_monitor.rules,
    {
        matches = {
            {
                -- Matches PHILIPS TVs with 16 bits audio.
                {"alsa.name", "matches", "PHILIPS*"},
                {"alsa.resolution_bits", "equals", 16},
                {"node.name", "matches", "alsa_output.*"}
            }
        },
        apply_properties = {
            ["audio.channels"] = 2,
            ["audio.format"] = "S16",
            ["audio.position"] = "FR,FL"
        }
    }
)
