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
    --},
    --["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = {
        --passive = "Goon_Buff_Companion_Temporary_Gale",
        --boosts = {
            --{ boost = "" }
        --},
        --statuses = {  -- Using a table for statuses
            --"GOON_BUFF_COMPANION_TEMPHP_30",
            --"GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3"
        --}
    },
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
    --},
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
    },
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


-- Temporary table to track characters who have received buffs in the current combat
local tTemp = {}

-- Function to apply the global blocking status to a character
local function applyBlockingStatus(charID)
    Osi.ApplyStatus(charID, "GOON_BUFF_COMPANION_BLOCKER", -1, 1, charID)
end

-- Function to apply passives, boosts, and optional statuses
local function applyBuffs(charID)
    local config = companionPassives[charID]
    if not config then
        Ext.Utils.PrintWarning("No config found for character: " .. tostring(charID))
        return
    end

    -- Check if the blocking status is active
    --if Osi.HasActiveStatus(charID, "GOON_BUFF_COMPANION_BLOCKER") == 1 then
        --Ext.Utils.Print("Blocking status active for: " .. tostring(charID) .. ". Buffs will not be applied.")
        --return
    --end

    -- Only process if the character is not in the party
    if Osi.IsPartyMember(charID, 0) == 0 then
        -- Apply the passive
        if config.passive then
            Osi.AddPassive(charID, config.passive)
            Ext.Utils.Print("Applying passive: " .. config.passive .. " to: " .. tostring(charID))
        end

        -- Apply the boosts
        if config.boosts and #config.boosts > 0 then
            for _, boostEntry in ipairs(config.boosts) do
                Ext.Utils.Print("Applying boost: " .. boostEntry.boost .. " to: " .. tostring(charID))
                Osi.AddBoosts(charID, boostEntry.boost, charID, charID)
            end
        else
            Ext.Utils.PrintWarning("No boosts found for character: " .. tostring(charID))
        end

        -- Apply the statuses
        if config.statuses and #config.statuses > 0 then
            for _, status in ipairs(config.statuses) do
                Ext.Utils.Print("Applying status: " .. status .. " to: " .. tostring(charID))
                Osi.ApplyStatus(charID, status, -1, 1, charID)
            end
        else
            Ext.Utils.PrintWarning("No statuses found for character: " .. tostring(charID))
        end
    else
        Ext.Utils.Print("Character is in the party, skipping: " .. tostring(charID))
    end
end


-- Function to handle combat events
local function handleCombat(charID, combatID)
    if companionPassives[charID] and not tTemp[combatID] then
        tTemp[combatID] = tTemp[combatID] or {} -- Initialize table for this combat ID
        if not tTemp[combatID][charID] then
            Ext.Utils.Print("Processing buffs for: " .. tostring(charID) .. " in combat: " .. tostring(combatID))
            applyBuffs(charID)
            tTemp[combatID][charID] = true -- Mark character as processed
        else
            Ext.Utils.Print("Character already processed for this combat: " .. tostring(charID))
        end
    end
end

-- Listener for combat start (apply buffs)
Ext.Osiris.RegisterListener("EnteredCombat", 2, "before", function(char, combatID)
    -- Ensure character and combatID are valid
    if char and combatID then
        -- Check if the character exists in the table
        if companionPassives[char] then
            -- Call the combat handling function
            handleCombat(char, combatID)
        end
    else
        -- Debugging in case of invalid parameters
        Ext.Utils.PrintError("EnteredCombat triggered with invalid parameters!")
        if not char then Ext.Utils.PrintError("Character is nil!") end
        if not combatID then Ext.Utils.PrintError("CombatID is nil!") end
    end
end)


-- Listener for combat end (clear temporary table for the combat ID)
--Ext.Osiris.RegisterListener("CombatEnded", 2, "after", function(combatID)
    --if tTemp[combatID] then
        --Ext.Utils.Print("Clearing temporary table for combat: " .. tostring(combatID))
        --tTemp[combatID] = nil -- Clear the table for this combat ID
    --end
--end)


-- Listener for when a character joins the party
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(charID)
    if companionPassives[charID] then
        -- Apply the blocking status to prevent the passive from being applied
        --applyBlockingStatus(charID)

        -- Remove any existing passives, boosts, and statuses
        removePassiveAndBoostsWithHealth(charID)
    end
end)

