PERK.PrintName = "Shotgun Punch"
PERK.Description = "ArcCW shotguns have {amount}mm extra penetration."

PERK.Parameters = {
    ["amount"] = {type = "i", default = 20, min = 0},
}

PERK.Hooks = {}

-- RecalcAllBuffs() may be necessary for certain stats that aren't calculated all the time.
-- It is unnecessary here but can be uncommented depending on use
--[[]
local recalc = function(ply, perk)
    if perk == "arccw_shotgun_penetration" then
        for _, wep in pairs(ply:GetWeapons()) do
            if wep.ArcCW then
                wep:RecalcAllBuffs()
            end
        end
    end
end
PERK.Hooks.Horde_OnSetPerk = recalc
PERK.Hooks.Horde_OnUnsetPerk = recalc
]]

-- You can modify ArcCW weapon stats with specially named hooks.
-- Specifically: O_Hook_STAT for overrides, M_Hook_STAT for multipliers and A_Hook_STAT for addition.
-- Edit the value in data.current
PERK.Hooks.O_Hook_Override_Penetration = function(wep, data)
    local ply = wep:GetOwner()
    if IsValid(ply) and ply:IsPlayer() and wep:GetIsShotgun() and ply:Horde_GetPerk("arccw_shotgun_penetration") then
        data.current = (data.current or 0) + ply:Horde_GetPerkParam("arccw_shotgun_penetration", "amount")
    end
end