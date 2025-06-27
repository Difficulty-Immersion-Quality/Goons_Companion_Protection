-- Table of specific companion passives and their associated boosts and statuses
local companionPassives = {
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = {
        passive = "Goon_Buff_Companion_Temporary_Jaheira",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
            "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
        }
    },
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = {
        passive = "Goon_Buff_Companion_Temporary_Minsc",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    },
    --["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = {
        --passive = "Goon_Buff_Companion_Temporary_Gale",
        --boosts = {
            --{ boost = "" }
        --},
        --statuses = {  -- Using a table for statuses
            --"GOON_BUFF_COMPANION_TEMPHP_30",
            --"GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        --}
    --},
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = {
        passive = "Goon_Buff_Companion_Temporary_Laezel",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    },
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = {
        passive = "Goon_Buff_Companion_Temporary_Wyll",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    },
    --["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = {
        --passive = "Goon_Buff_Companion_Temporary_ShadowHeart",
        --boosts = {
            --{ boost = "" }
        --},
        --statuses = {  -- Using a table for statuses
            --"GOON_BUFF_COMPANION_TEMPHP_30",
            --"GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        --}
    --},
    --["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = {
        --passive = "Goon_Buff_Companion_Temporary_Karlach",
        --boosts = {
            --{ boost = "" }
        --},
        --statuses = {  -- Using a table for statuses
            --"GOON_BUFF_COMPANION_TEMPHP_30",
            --"GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        --}
    --},
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = {
        passive = "Goon_Buff_Companion_Temporary_Minthara",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    },
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = {
        passive = "Goon_Buff_Companion_Temporary_Halsin",
        boosts = {
            { boost = "" }
        },
        statuses = {  -- Using a table for statuses
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    }
}

local function GoonProtectionApplyVars()
    local Protected = Ext.Vars.GetModVariables(ModuleUUID)
    vars.GoonProtection = vars.GoonProtection or {}
    return vars.GoonProtection
end

local function GoonProtectionRemoveVars()
    local vars = Ext.Vars.GetModVariables(ModuleUUID)
    vars.GoonNotProtection = vars.GoonNotProtection or {}
    return vars.GoonNotProtection
end

-- Function to apply the global blocking status to a character
--local function applyBlockingStatus(charID)
    --Osi.ApplyStatus(charID, "GOON_BUFF_COMPANION_BLOCKER", -1, 1, charID)
--end

-- Function to apply passives, boosts, and optional statuses
local function applyBuffs(charID)

    local assigned = Ext.Vars.GetModVariables(ModuleUUID).GoonProtection or {}
    Ext.Vars.GetModVariables(ModuleUUID).GoonProtection = assigned

    local notassigned = Ext.Vars.GetModVariables(ModuleUUID).GoonNotProtection or {}
    Ext.Vars.GetModVariables(ModuleUUID).GoonNotProtection = notassigned

    local charName = "Unknown"
    local entityObj = Ext.Entity.Get(charID)
    if entityObj and entityObj.DisplayName and entityObj.DisplayName.NameKey and entityObj.DisplayName.NameKey.Handle then
        charName = Ext.Loca.GetTranslatedString(entityObj.DisplayName.NameKey.Handle.Handle) or "Unknown"
    else
        charName = Osi.GetDisplayName(charID) or "Unknown"
    end

    local config = companionPassives[charID]
    if not config then
        Ext.Utils.PrintWarning("No config found for %s (%s).", charName, charID)
        return
    end

    -- Only process if the character is not in the party
    if Osi.IsPartyMember(charID, 0) == 0 then
        -- Apply the passive
        if config.passive then
            Osi.AddPassive(charID, config.passive)
            Ext.Utils.Print("Applying passives to %s (%s).", charName, charID)
        end

        -- Apply the boosts
        if config.boosts and #config.boosts > 0 then
            for _, boostEntry in ipairs(config.boosts) do
                Ext.Utils.Print("Applying boosts to %s (%s).", charName, charID)
                Osi.AddBoosts(charID, boostEntry.boost, charID, charID)
            end
        else
            Ext.Utils.Print("No boosts found for %s (%s).", charName, charID)
        end

        -- Apply the statuses
        if config.statuses and #config.statuses > 0 then
            for _, status in ipairs(config.statuses) do
                Ext.Utils.Print("Applying statuses to %s (%s).", charName, charID)
                Osi.ApplyStatus(charID, status, -1, 1, charID)
            end
        else
            Ext.Utils.PrintWarning("No statuses to %s (%s).", charName, charID)
        end
    else
        Ext.Utils.Print("Goon's Companion Protection not applied to %s (%s) due to recruitment.", charName, charID)
    end
    GoonProtectionApplyVars()[charID] = true
end

-- Function to remove passives, boosts, and statuses for a character
local function removeBuffs(charID)
    -- Remove any passives (replace with your actual passive names)
    -- Example: Osi.RemovePassive(charID, "SomePassiveName")
    for _, passive in ipairs(companionPassives[charID].passives or {}) do
        Osi.RemovePassive(charID, passive)
        Ext.Utils.Print("Removed passives from %s (%s) due to recruitment.", charName, charID)
    end

    -- Remove any boosts (replace with your actual boost names)
    for _, boost in ipairs(companionPassives[charID].boosts or {}) do
        Osi.RemoveBoosts(charID, boost.boost, 0, charID, charID)
        Ext.Utils.Print("Removed boosts from %s (%s) due to recruitment.", charName, charID)
    end

    -- Remove any statuses (replace with your actual status names)
    for _, status in ipairs(companionPassives[charID].statuses or {}) do
        if Osi.HasActiveStatus(charID, status) == 1 then
            Osi.RemoveStatus(charID, status)
            Ext.Utils.Print("Removed statuses from %s (%s) due to recruitment.", charName, charID)
        end
        GoonProtectionRemoveVars()[charID] = true
        GoonProtectionApplyVars()[charID] = nil
    end
end

-- Function to handle combat events
local function handleCombat(charID, combatGuid)
    if companionPassives[charID] and not tTemp[combatGuid] then
        tTemp[combatGuid] = tTemp[combatGuid] or {} -- Initialize table for this combat ID
        if not tTemp[combatGuid][charID] then
            Ext.Utils.Print("Combat started, applying buffs to %s (%s).", charName, charID)
            applyBuffs(charID)
            tTemp[combatGuid][charID] = true -- Mark character as processed
        else
            Ext.Utils.Print("Character already processed for this combat: " .. tostring(charID))
        end
    end
end

function table.find(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end


Ext.Osiris.RegisterListener("EnteredCombat", 2, "before", function(object, combatGuid)
        if companionPassives[object] then
            applyBuffs(object)
        end
    end
end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
        if companionPassives[object] then
            applyBuffs(object)
        end
    end
end)

-- Listener for when a character joins the party
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(charID)
    if companionPassives[charID] then
        -- Remove any existing passives, boosts, and statuses
        removeBuffs(charID)
    end
end)

