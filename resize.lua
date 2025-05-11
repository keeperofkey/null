function resize_client_by_rms(client, context, state)
    local rms = context.rms or 0
    local spec = context.spectral_contrast or 0
    -- Normalize: assume spec is between min_spec and max_spec
    local min_spec, max_spec = 0, 1  -- Adjust if needed
    local norm = (spec - min_spec) / (max_spec - min_spec)
    norm = math.max(0, math.min(1, norm))  -- Clamp to [0, 1]

    -- Map normalized value to a corner
    local corner
    if norm < 0.25 then
        corner = "topleft"
    elseif norm < 0.5 then
        corner = "topright"
    elseif norm < 0.75 then
        corner = "bottomright"
    else
        corner = "bottomleft"
    end

    local geo = client:geometry()
    local screen_geo = client.screen.geometry or {x=0, y=0, width=1920, height=1080}

    if corner == "topleft" then
        geo.x = math.max(screen_geo.x, geo.x - rms)
        geo.y = math.max(screen_geo.y, geo.y - rms)
        geo.width = math.min(screen_geo.width - (geo.x - screen_geo.x), geo.width + rms)
        geo.height = math.min(screen_geo.height - (geo.y - screen_geo.y), geo.height + rms)
    elseif corner == "topright" then
        geo.y = math.max(screen_geo.y, geo.y - rms)
        geo.width = math.max(1, geo.width + rms)
        geo.height = math.min(screen_geo.height - (geo.y - screen_geo.y), geo.height + rms)
    elseif corner == "bottomright" then
        geo.width = math.max(1, geo.width + rms)
        geo.height = math.max(1, geo.height + rms)
    elseif corner == "bottomleft" then
        geo.x = math.max(screen_geo.x, geo.x - rms)
        geo.height = math.max(1, geo.height + rms)
        geo.width = math.min(screen_geo.width - (geo.x - screen_geo.x), geo.width + rms)
    end

    -- Constrain to screen
    geo.width = math.min(geo.width, screen_geo.width - (geo.x - screen_geo.x))
    geo.height = math.min(geo.height, screen_geo.height - (geo.y - screen_geo.y))

    client:geometry(geo)
end