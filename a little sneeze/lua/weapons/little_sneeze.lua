SWEP.PrintName = "a little sneeze"
SWEP.Author = "Chukakabra"
SWEP.Category = "Other"
SWEP.IconOverride = "vgui/entities/weaponIcon_sneeze.png"
SWEP.Instructions = "Go now, press LMB be a little uncultured and sneeze and somebody."
SWEP.Spawnable = true
SWEP.Slot = 0

SWEP.Base = "weapon_base"
SWEP.HoldType = "normal"

SWEP.AutoSwitchFrom = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.UseHands = "false"
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Delay = 3.0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

if CLIENT then
    local textureID = surface.GetTextureID( "weapons/weaponIcon_sneeze" )
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
        local icon_size = 132
        local icon_x = x + (wide - icon_size) / 2
        local icon_y = y + 10
    
        surface.SetDrawColor( 255, 255, 255, alpha )
        surface.SetTexture( textureID )
        surface.DrawTexturedRect( icon_x, icon_y, icon_size, icon_size )
        return true
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "HoldType")
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    return true
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    
    if GetConVar("admin_only"):GetInt() == 1 and not owner:IsAdmin() then
        if SERVER then
            owner:ChatPrint("The server admin prohibited using this SWEP for non-admins.")
            return
        end
    end
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    
    if SERVER then
        local forceCvar = (GetConVar("sneeze_force")):GetFloat()
        local rangeCvar = (GetConVar("sneeze_range")):GetFloat()
        local npcDamageCvar = (GetConVar("sneeze_npc_damage")):GetFloat()
        local playerDamageCvar = (GetConVar("sneeze_player_damage")):GetFloat()
        
        owner:EmitSound("sneeze.wav", 75, 100, 1, CHAN_AUTO)
        timer.Simple(0.30, function()
            if not IsValid(self) and not IsValid(owner) then return end
            
            local start_pos = owner:GetShootPos()
            local direction = owner:GetAimVector()
            local entities = ents.FindInCone(start_pos, direction, rangeCvar, math.cos(math.rad(60)))
            
            owner:ViewPunch(Angle(-5, 0, 0))
            
            if entities and #entities > 0 then
                for _, ent in ipairs(entities) do
                    if IsValid(ent) and ent != owner and not ent:IsPlayer() and ent:GetClass() != "worldspawn" then
                        
                        local distance = ent:GetPos():Distance(start_pos)
                        local force = forceCvar * (300 / math.max(distance, 10))
                        
                        -- Non-prop entity physics + damage local function
                        local function ImplementPhysics(finalDamage)
                            local dmgReg = DamageInfo()
                            
                            local vertical_ratio = math.abs(direction.z)
                            if vertical_ratio > 0.86 then
                                ent:SetVelocity(direction * force)
                            else
                                local horizontal_dir = Vector(direction.x, direction.y, 0)
                                if horizontal_dir:LengthSqr() > 0.01 then
                                    horizontal_dir:Normalize()
                                else
                                    horizontal_dir = owner:GetForward()
                                    horizontal_dir.z = 0
                                    horizontal_dir:Normalize()
                                end
                                
                                local vertical_boost = force * vertical_ratio * 0.1
                                ent:SetVelocity(horizontal_dir * force + Vector(0, 0, vertical_boost))
                            end
                            
                            dmgReg:SetAttacker(owner)
                            dmgReg:SetInflictor(self)
                            dmgReg:SetDamageType(DMG_SONIC)
                            dmgReg:SetDamage(finalDamage)
                            ent:TakeDamageInfo(dmgReg)
                        end
                        
                        -- Physics for props
                        if ent:GetPhysicsObject():IsValid() then
                            local physics = ent:GetPhysicsObject()
                            physics:ApplyForceCenter(direction * force)
                            physics:ApplyForceOffset(direction * force * 0.5, ent:GetPos() + Vector(0,0,10))
                        end
                        
                        -- Physics + damage for NPC
                        if ent:IsNPC() then
                            ImplementPhysics(npcDamageCvar)
                        end
                        
                        -- Physics + damage for Player
                        if ent:IsPlayer() then
                            ImplementPhysics(playerDamageCvar)
                        end
                    end
                end
            end
        end)
    end
end

function SWEP:OnDrop()
    self:Remove()
end