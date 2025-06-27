--- @type RegisterVariableOptions
local opts = {
    Server = true,
    Client = false,
    WriteableOnServer = true,
    WriteableOnClient = false,
    Persistent = true,
    SyncToClient = false,
    SyncToServer = true,
    SyncOnWrite = false,
    DontCache = false
}

Ext.Vars.RegisterModVariable(ModuleUUID, "GoonProtection_On", opts)
Ext.Vars.RegisterModVariable(ModuleUUID, "GoonProtection_Off", opts)
Ext.Require("Server/_Core.lua")