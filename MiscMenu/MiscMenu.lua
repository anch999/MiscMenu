local MM = LibStub("AceAddon-3.0"):NewAddon("MiscMenu", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreator-1.0")

MISCMENU = MM
MM.dewdrop = AceLibrary("Dewdrop-2.0")

MM.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    EnableAutoHide = { false },
    HideMenu        = { false, HideFrame = "MiscMenuStandaloneButton"},
    Minimap         = { false },
    TxtSize         = 12,
    AutoMenu        = { false },
    DeleteProflie      = { false },
    menuProfiles    = { { default = {} } },
    NumberActionBars = 4,
    SelfCast = { "none" },
}

local CharDefaultSettings = {
    menuSettings = { {currentProfile = "default"} },
    syncBarPosition = true
}

function MM:OnInitialize()
    self.db = self:SetupDB("MiscMenuDB", DefaultSettings)
    self.charDB = self:SetupDB("MiscMenuCharDB", CharDefaultSettings)
    self:CreateOptionsUI()
    --Enable the use of /MiscMenu slash command
    SLASH_MISCMENU1 = "/miscmenu"
    SlashCmdList["MISCMENU"] = function(msg)
        MISCMENU:SlashCommand(msg)
    end
end

function MM:OnEnable()
    self:InitializeMinimap()
    self:InitializeActionBars()
    self:InitializeStandaloneButton()
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UPDATE_BINDINGS")
    self:RegisterEvent("COMPANION_UPDATE")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("ITEM_USED")
end

function MM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
	self:RemoveItem(arg2)
end

function MM:UNIT_SPELLCAST_CHANNEL_START(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:UNIT_SPELLCAST_START(event, arg1, arg2)
    self:ActionBarSpellCastStart(event, arg1, arg2)
end

function MM:CURRENT_SPELL_CAST_CHANGED(event, arg1, arg2)
    --self:ActionBarSpellCastStart(event, arg1, arg2)
end

function MM:ITEM_USED(event, arg1, arg2)
    self:ActionBarItemUsed(event, arg1, arg2)
end

function MM:UNIT_SPELLCAST_FAILED(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:UNIT_SPELLCAST_INTERRUPTED(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:COMPANION_UPDATE(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:UPDATE_BINDINGS(event, arg1, arg2)
    self:ActionBarUpdateBindings(event, arg1, arg2)
end

function MM:UI_ERROR_MESSAGE(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:BAG_UPDATE(event, arg1, arg2)
    self:ActionBarBagUpdateTimer(event, arg1, arg2)
end

--[[
MM:SlashCommand(msg):
msg - takes the argument for the /miscmenu command so that the appropriate action can be performed
If someone types /miscmenu, bring up the options box
]]
function MM:SlashCommand(msg)
    local cmd, arg = string.split(" ", msg, 3)
	cmd = string.lower(cmd) or nil
	arg = arg or nil
    if cmd == "reset" then
        MiscMenuDB = nil
        self:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif cmd == "options" then
        self:OptionsToggle()
    elseif cmd == "macromenu" then
        self:DewdropRegister(GetMouseFocus(), nil, arg)
    elseif cmd == "macromenuright" then
        self:MacroMenuClick(arg)
    elseif cmd == "unlockactionbar" then
        self:ActionBarUnlockFrame()
    else
        self:ToggleStandaloneButton()
    end
end

function MM:MacroMenuClick(arg)
    local button = GetMouseFocus()
    button.miscmenu = button.miscmenu or {}
    button.miscmenu.Profile =  arg
    if not button.miscmenu.Function then
    button.miscmenu.Function = function(btn, btnclick)
        if button.miscmenu.Profile and btnclick == "RightButton" then
            self:DewdropRegister(button, nil, button.miscmenu.Profile)
        end
        button.miscmenu.Profile = nil
    end
    button:HookScript("OnClick", button.miscmenu.Function)
    button.miscmenu.Function(nil, "RightButton")
    end
end