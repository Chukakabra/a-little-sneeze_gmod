local fontCreated = false

-- Font installation
hook.Add("InitPostEntity", "CreateFont", function()
    timer.Simple(0.5, function()
        if not fontCreated then
            surface.CreateFont("basic", {
                font = "Arial",
                size = 42,
                weight = 300,
                antialias = true,
            })
            fontCreated = true
        end
    end)
end)