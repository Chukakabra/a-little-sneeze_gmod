-- HUD implementation
hook.Add("HUDPaint", "DrawHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "little_sneeze" then return end

    local clip = wep:Clip1()
    local scrW, scrH = ScrW(), ScrH()
    local x, y = scrW - 250, scrH - 97
    local w, h = 220, 70
    
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(x, y, w, h)

    if clip > 0 then
        draw.SimpleText(
            "ready",
            "basic",
            x + w/2, y + 35,
            Color(255, 255, 0, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    else
        draw.SimpleText(
            "cooldown",
            "basic",
            x + w/2, y + 35,
            Color(255, 255, 0, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
end)