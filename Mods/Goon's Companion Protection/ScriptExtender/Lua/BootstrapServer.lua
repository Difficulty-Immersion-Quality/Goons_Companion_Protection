-- Table of potential companion UUIDs
local companionCharacters = {
    "S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a",
    "S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba",
    "S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604",
    "S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255",
    "S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12",
    "S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d",
    "S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679",
    "S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c",
    "S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b",
    "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"
}

-- Function to apply the passive
local function applyPassive(charID)
    if table.contains(companionCharacters, charID) and Osi.IsPartyMember(charID, 0) == 0 then
        Osi.AddPassive(charID, "Goon_Buff_Companion_Temporary")
    end
end

-- Function to remove the passive
local function removePassive(charID)
    if table.contains(companionCharacters, charID) and Osi.IsPartyMember(charID, 0) == 1 then
        Osi.RemovePassive(charID, "Goon_Buff_Companion_Temporary")
    end
end

-- Listener for when gameplay starts
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level_name, is_editor_mode)
    -- Apply passive to all companions who are not in the party yet
    for _, charID in ipairs(companionCharacters) do
        if Osi.IsPartyMember(charID, 0) == 0 then  -- Check if the character is not in the party
            applyPassive(charID)  -- Apply passive to companions not in the party
        end
    end
end)

-- Listener for when a character joins the party
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(charID)
    if table.contains(companionCharacters, charID) then  -- Only apply logic for companions
        removePassive(charID)  -- Remove passive when joining party
    end
end)

-- Listener for when a character leaves the party
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(charID)
    if table.contains(companionCharacters, charID) then  -- Only apply logic for companions
        applyPassive(charID)  -- Add passive when leaving party
    end
end)

-- Utility function to check if a table contains a value
function table.contains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end