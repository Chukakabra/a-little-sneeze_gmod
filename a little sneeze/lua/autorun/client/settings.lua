CreateConVar("sneeze_force", "10000", {FCVAR_ARCHIVE})
CreateConVar("sneeze_range", "500", {FCVAR_ARCHIVE})
CreateConVar("sneeze_npc_damage", "300", {FCVAR_ARCHIVE})
CreateConVar("sneeze_player_damage", "50", {FCVAR_ARCHIVE})
CreateConVar("admin_only", "0", {FCVAR_ARCHIVE})

-- ToolMenu adjunction
hook.Add("PopulateToolMenu", "AddSneezeSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "User", "SneezeSettings", "a little sneeze", "", "", function(panel)
        panel:ClearControls()
        panel:Help("sneeze settings")
        
        -- False if not admin when SWEP's set to admin-only
        local canEdit = LocalPlayer():IsAdmin() or GetConVar("admin_only"):GetInt() == 0
        
        if canEdit then
            panel:CheckBox("admin only", "admin_only")
        end
        
        local forceSlider = panel:NumSlider(
            "Force",
            "sneeze_force",
            100,
            100000,
            0
        )
        
        local rangeSlider = panel:NumSlider(
            "Range",
            "sneeze_range",
            100,
            700,
            0
        )
        
        local npcDamageSlider = panel:NumSlider(
            "NPC damage",
            "sneeze_npc_damage",
            0,
             1000,
            0
        )
        
        local playerDamageSlider = panel:NumSlider(
            "Player damage",
            "sneeze_player_damage",
            0,
            1000,
            0
        )
        
        local resedButton = panel:Button("reset to defaults", "sneeze_reset")
        
        -- Restriction for non-admins
        if not canEdit then
            forceSlider:SetDisabled(true)
            rangeSlider:SetDisabled(true)
            npcDamageSlider:SetDisabled(true)
            playerDamageSlider:SetDisabled(true)
        end
            
        concommand.Add("sneeze_reset", function()
            RunConsoleCommand("sneeze_force", "10000", {FCVAR_ARCHIVE})
            RunConsoleCommand("sneeze_range", "500", {FCVAR_ARCHIVE})
            RunConsoleCommand("sneeze_npc_damage", "300", {FCVAR_ARCHIVE})
            RunConsoleCommand("sneeze_player_damage", "50", {FCVAR_ARCHIVE})
            RunConsoleCommand("admin_only", "0", {FCVAR_ARCHIVE})
        end)
    end)
end)