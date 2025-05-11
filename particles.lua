local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Screen dimensions (replace with your actual screen size or use screen geometry)
local screen_width = 1920
local screen_height = 1080

-- Particle properties
local num_particles = 80
local particles = {}

-- Initialize particles with random positions, velocities, and sizes
for i = 1, num_particles do
    particles[i] = {
        x = math.random() * screen_width,
        y = math.random() * screen_height,
        vx = (math.random() - 0.5) * 2, -- -1 to +1
        vy = (math.random() - 0.5) * 2,
        r = math.random(2, 6),
        alpha = math.random() * 0.7 + 0.3
    }
end

-- Create an always-on-top transparent wibox overlay
local particle_overlay = wibox({
    visible = true,
    ontop = true,
    type = "utility",
    x = 0,
    y = 0,
    width = screen_width,
    height = screen_height,
    bg = "#00000000", -- Transparent background
    input_passthrough = true -- Doesn't block mouse/keyboard
})

-- Draw particles
particle_overlay:connect_signal("draw", function(_, cr, width, height)
    for _, p in ipairs(particles) do
        cr:set_source_rgba(1, 1, 1, p.alpha) -- White, with particle alpha
        cr:arc(p.x, p.y, p.r, 0, 2 * math.pi)
        cr:fill()
    end
end)

-- Animate particles
gears.timer {
    timeout = 1/60, -- ~60 FPS
    autostart = true,
    callback = function()
        for _, p in ipairs(particles) do
            p.x = (p.x + p.vx)
            p.y = (p.y + p.vy)
            -- Bounce off edges
            if p.x < 0 or p.x > screen_width then p.vx = -p.vx end
            if p.y < 0 or p.y > screen_height then p.vy = -p.vy end
        end
        particle_overlay:emit_signal("widget::redraw_needed")
    end
}