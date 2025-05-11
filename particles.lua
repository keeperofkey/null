local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local capi = { client = client }

-- Screen dimensions (replace with your actual screen size or use screen geometry)
local screen_width = 1920
local screen_height = 1080

-- Particle properties
local num_particles = 80
local particles = {}

local function lerp(a, b, t) return a + (b - a) * t end

-- Initialize particles with random positions, velocities, and sizes
for i = 1, num_particles do
    local angle = math.random() * 2 * math.pi
    local speed = math.random() * 1.5 + 0.5
    particles[i] = {
        x = math.random() * screen_width,
        y = math.random() * screen_height,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        ax = 0,
        ay = 0,
        r = math.random(2, 6),
        alpha = math.random() * 0.6 + 0.4,
        col = {
            lerp(0.5, 1, math.random()),
            lerp(0.5, 1, math.random()),
            lerp(0.5, 1, math.random())
        }
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
    bg = "#00000000",
    input_passthrough = true
})

-- Draw particles
particle_overlay:connect_signal("draw", function(_, cr, width, height)
    for _, p in ipairs(particles) do
        cr:set_source_rgba(p.col[1], p.col[2], p.col[3], p.alpha)
        cr:arc(p.x, p.y, p.r, 0, 2 * math.pi)
        cr:fill()
    end
end)

-- Animate particles with smooth motion
gears.timer {
    timeout = 1/60,
    autostart = true,
    callback = function()
        for _, p in ipairs(particles) do
            -- Brownian, fluid acceleration
            p.ax = (math.random() - 0.5) * 0.15
            p.ay = (math.random() - 0.5) * 0.15

            -- Apply acceleration
            p.vx = p.vx + p.ax
            p.vy = p.vy + p.ay

            -- Drag for smoothness
            p.vx = p.vx * 0.96
            p.vy = p.vy * 0.96

            -- Update position
            p.x = p.x + p.vx
            p.y = p.y + p.vy

            -- Bounce softly off screen edges
            if p.x < 0 then p.x = 0; p.vx = -p.vx * 0.7 end
            if p.x > screen_width then p.x = screen_width; p.vx = -p.vx * 0.7 end
            if p.y < 0 then p.y = 0; p.vy = -p.vy * 0.7 end
            if p.y > screen_height then p.y = screen_height; p.vy = -p.vy * 0.7 end
        end
        particle_overlay:emit_signal("widget::redraw_needed")
    end
}

-- Helper: create a ripple burst from a given point
local function ripple_burst(cx, cy)
    for _, p in ipairs(particles) do
        local dx = p.x - cx
        local dy = p.y - cy
        local dist = math.sqrt(dx * dx + dy * dy) + 1 -- avoid div by zero
        local strength = 8 / dist -- closer particles get a bigger push
        p.vx = p.vx + dx * strength * 0.12
        p.vy = p.vy + dy * strength * 0.12
    end
end

-- Connect to window movement events
client.connect_signal("property::x", function(c)
    ripple_burst(c.x + c.width/2, c.y + c.height/2)
end)
client.connect_signal("property::y", function(c)
    ripple_burst(c.x + c.width/2, c.y + c.height/2)
end)
-- Optionally, trigger on new windows or resizing too:
client.connect_signal("manage", function(c)
    ripple_burst(c.x + c.width/2, c.y + c.height/2)
end)
client.connect_signal("property::width", function(c)
    ripple_burst(c.x + c.width/2, c.y + c.height/2)
end)
client.connect_signal("property::height", function(c)
    ripple_burst(c.x + c.width/2, c.y + c.height/2)
end)

return particle_overlay