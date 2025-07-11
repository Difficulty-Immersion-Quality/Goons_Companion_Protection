-- Table of specific companion passives and their associated boosts and statuses
local companionPassives = {
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = {
        passive = "Goon_Buff_Companion_Temporary_Jaheira",
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
            "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
        },
        boosts = {}
    },
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = {
        passive = "Goon_Buff_Companion_Temporary_Minsc",
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        },
        boosts = {}
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
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        },
        boosts = {}
    },
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = {
        passive = "Goon_Buff_Companion_Temporary_Wyll",
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        },
        boosts = {}
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
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        },
        boosts = {}
    },
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = {
        passive = "Goon_Buff_Companion_Temporary_Halsin",
        statuses = {
            "GOON_BUFF_COMPANION_TEMPHP_30",
            "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        }
    }
}

-- Helpers
local function GoonProtection_On_Vars()
    local vars = Ext.Vars.GetModVariables(ModuleUUID)
    vars.GoonProtection_On = vars.GoonProtection_On or {}
    return vars.GoonProtection_On
end

local function GoonProtection_Off_Vars()
    local vars = Ext.Vars.GetModVariables(ModuleUUID)
    vars.GoonProtection_Off = vars.GoonProtection_Off or {}
    return vars.GoonProtection_Off
end

local function GetCharName(charID)
    local name = "Unknown"
    local entity = Ext.Entity.Get(charID)
    if entity and entity.DisplayName and entity.DisplayName.NameKey and entity.DisplayName.NameKey.Handle then
        name = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle) or name
    else
        name = Osi.GetDisplayName(charID) or name
    end
    return name
end

local function FindCompanionKeyByGUID(guid)
    for key, _ in pairs(companionPassives) do
        if key:find(guid, 1, true) then
            return key
        end
    end
    return nil
end

local function applyBuffs(charID)
    local applied = GoonProtection_On_Vars()
    local blocked = GoonProtection_Off_Vars()
    if applied[charID] or blocked[charID] then return end

    local charName = GetCharName(charID)
    local config = companionPassives[charID]

    if not config then
        --Ext.Utils.PrintWarning("No config found for %s (%s).", charName, charID)
        return
    end

    if Osi.IsPartyMember(charID, 0) == 0 then
        -- If this is a player-controlled character, block buffs and mark as blocked
        if Osi.IsPlayer(charID) == 1 then
            blocked[charID] = true
            --Ext.Utils.Print("%s (%s) is a player, blocking buffs.", charName, charID)
            return
        end
        if config.passive then
            Osi.AddPassive(charID, config.passive)
            --Ext.Utils.Print("Applied passive to %s (%s).", charName, charID)
        end
        if config.statuses then
            for _, status in ipairs(config.statuses) do
                Osi.ApplyStatus(charID, status, -1, 1, charID)
                --Ext.Utils.Print("Applied status %s to %s.", status, charName)
            end
        end
        applied[charID] = true
    else
        --Ext.Utils.Print("%s (%s) is already recruited, skipping buffs.", charName, charID)
    end
end

local function removeBuffs(charID)
    local applied = GoonProtection_On_Vars()
    local blocked = GoonProtection_Off_Vars()

    -- Try to find the correct key if not found directly
    local config = companionPassives[charID]
    local charName = GetCharName(charID)
    local key = charID

    if not config then
        key = FindCompanionKeyByGUID(charID)
        config = companionPassives[key]
    end

    if not config then
        --Ext.Utils.PrintWarning("No config found for %s (%s)", charName, charID)
        return
    end

    if config.passive then
        Osi.RemovePassive(charID, config.passive)
        --Ext.Utils.Print("Removed passive from %s (%s).", charName, charID)
    end
    if config.statuses then
        for _, status in ipairs(config.statuses) do
            Osi.RemoveStatus(charID, status)
            --Ext.Utils.Print("Removed status %s from %s.", status, charName)
        end
    end

    blocked[key] = true
    applied[key] = nil
    --Ext.Utils.Print("Marked %s (%s) as recruited — no future buffs will be applied.", charName, charID)
end

-- Register listeners
Ext.Osiris.RegisterListener("EnteredCombat", 2, "before", function(charID)
    applyBuffs(charID)
end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditor)
    -- Exception: skip buff logic if in character creation level
    if Osi.IsCharacterCreationLevel(levelName) == 1 then
        --Ext.Utils.Print("[GoonCompanionProtection] Skipping buff application during character creation.")
        return
    end
    for charID, _ in pairs(companionPassives) do
        applyBuffs(charID)
    end
end)

-- Called when a character becomes a companion
Ext.Osiris.RegisterListener("RegisterAsCompanion", 2, "after", function(character, recruiter)
    removeBuffs(character)
end)

Ext.Osiris.RegisterListener("UnregisterAsCompanion", 1, "after", function(character)
    local blocked = GoonProtection_Off_Vars()
    local applied = GoonProtection_On_Vars()

    blocked[character] = nil -- ✅ Remove the block
    applied[character] = nil -- ✅ Optional: clear prior record in case re-buffing is needed

    --Ext.Utils.Print("Unregistered companion %s — now eligible for buffs again.", GetCharName(character))
    applyBuffs(character)
end)
