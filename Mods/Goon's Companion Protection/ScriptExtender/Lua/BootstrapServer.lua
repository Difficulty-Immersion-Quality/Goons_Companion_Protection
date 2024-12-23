-- Table of specific companion passives and their associated boosts and statuses
local companionPassives = {
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = {
        passive = "Goon_Buff_Companion_Temporary_Jaheira",
        boosts = {
            { boost = "DamageReduction(All,3)" },
            { boost = "Advantage(SavingThrow, Strength)" },
            { boost = "Advantage(SavingThrow, Dexterity)" },
            { boost = "Advantage(SavingThrow, Constitution)" },
            { boost = "Advantage(SavingThrow, Intelligence)" },
            { boost = "Advantage(SavingThrow, Wisdom)" },
            { boost = "Advantage(SavingThrow, Charisma)" }
        },
        status = "GOON_BUFF_COMPANION_TEMPHP_30"
    },
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = {
        passive = "Goon_Buff_Companion_Temporary_Minsc",
        boosts = {
            { boost = "DamageReduction(All,3)" }
        },
        status = "GOON_BUFF_COMPANION_TEMPHP_30"
    --},
    --["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = {
        --passive = "Goon_Buff_Companion_Temporary_Gale",
        --boosts = {
            --{ boost = "IncreaseMaxHP(10%)" },
            --{ boost = "DamageReduction(Magic,10)" }
        --}
    --},
    --["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = {
        --passive = "Goon_Buff_Companion_Temporary_Astarion",
        --boosts = {
            --{ boost = "IncreaseMaxHP(5%)" },
            --{ boost = "DamageReduction(Sneak,10)" }
        --}
    --},
    --["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = {
        --passive = "Goon_Buff_Companion_Temporary_Laezel",
        --boosts = {
            --{ boost = "IncreaseMaxHP(15%)" },
            --{ boost = "DamageReduction(Melee,10)" }
        --},
        --status = nil
    },
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = {
        passive = "Goon_Buff_Companion_Temporary_Wyll",
        boosts = {
            { boost = "DamageReduction(All,3)" }
        },
        status = "GOON_BUFF_COMPANION_TEMPHP_30"
    --},
    --["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = {
        --passive = "Goon_Buff_Companion_Temporary_ShadowHeart",
        --boosts = {
            --{ boost = "IncreaseMaxHP(10%)" },
            --{ boost = "DamageReduction(Healing,5)" }
        --},
        --status = nil
    --},
    --["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = {
        --passive = "Goon_Buff_Companion_Temporary_Karlach",
        --boosts = {
            --{ boost = "IncreaseMaxHP(25%)" },
            --{ boost = "DamageReduction(Fire,20)" }
        --},
        --status = nil
    },
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = {
        passive = "Goon_Buff_Companion_Temporary_Minthara",
        boosts = {
            { boost = "DamageReduction(All,3)" }
        },
        status = "GOON_BUFF_COMPANION_TEMPHP_30"
    },
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = {
        passive = "Goon_Buff_Companion_Temporary_Halsin",
        boosts = {
            { boost = "DamageReduction(All,3)" }
        },
        status = "GOON_BUFF_COMPANION_TEMPHP_30"
    }
}

-- Function to apply passives, boosts, and optional statuses
local function applyPassiveAndBoostsWithHealth(charID)
    local config = companionPassives[charID]
    if config and Osi.IsPartyMember(charID, 0) == 0 then
        -- Apply the specific passive
        Osi.AddPassive(charID, config.passive)

        -- Apply boosts
        for _, boost in ipairs(config.boosts) do
            Osi.AddBoosts(charID, boost.boost, charID, charID)
        end

        -- Apply status if configured
        if config.status then
            Osi.ApplyStatus(charID, config.status, -1, 1, charID)
        end

        -- Manage health to ensure consistency
        local entityHandle = Ext.Entity.UuidToHandle(charID)
        if entityHandle and entityHandle.Health then
            local currentHp = entityHandle.Health.Hp
            local subscription

            subscription = Ext.Entity.Subscribe("Health", function(health, _, _)
                health.Health.Hp = currentHp
                health:Replicate("Health")
                if subscription then
                    Ext.Entity.Unsubscribe(subscription)
                end
            end, entityHandle)
        end
    end
end

-- Function to remove passives, boosts, and optional statuses
local function removePassiveAndBoostsWithHealth(charID)
    local config = companionPassives[charID]
    if config and Osi.IsPartyMember(charID, 1) == 1 then
        -- Remove the specific passive
        Osi.RemovePassive(charID, config.passive)

        -- Remove boosts
        for _, boost in ipairs(config.boosts) do
            Osi.RemoveBoosts(charID, boost.boost, 0, charID, charID)
        end

        -- Remove status if configured
        if config.status then
            Osi.RemoveStatus(charID, config.status)
        end
    end
end

-- Function to handle combat start and end
local function handleCombat(isCombatStart)
    for charID, _ in pairs(companionPassives) do
        if Osi.IsPartyMember(charID, 0) == 0 then
            if isCombatStart then
                applyPassiveAndBoostsWithHealth(charID)
            else
                removePassiveAndBoostsWithHealth(charID)
            end
        end
    end
end

-- Listener for combat start (apply buffs)
Ext.Osiris.RegisterListener("EnteredCombat", 2, "before", function(object, combat)
    handleCombat(true)  -- Apply buffs at the start of combat
end)

-- Listener for combat end (remove buffs)
Ext.Osiris.RegisterListener("CombatEnded", 2, "after", function(combatGuid)
    handleCombat(false)  -- Remove buffs at the end of combat
end)

-- Listeners for applying and removing passives and boosts when characters join/leave the party
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(charID)
    if companionPassives[charID] then
        applyPassiveAndBoostsWithHealth(charID)
    end
end)

Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(charID)
    if companionPassives[charID] then
        removePassiveAndBoostsWithHealth(charID)
    end
end)
