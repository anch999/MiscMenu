local MM = LibStub("AceAddon-3.0"):NewAddon("MiscMenu", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreator-1.0")

MISCMENU = MM
MM.dewdrop = AceLibrary("Dewdrop-2.0")

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
MM.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    EnableAutoHide = { false },
    HideMenu        = { false, HideFrame = "MiscMenuStandaloneButton"},
    Minimap         = { false },
    hideRandomPet   = { true },
    TxtSize         = 12,
    AutoMenu        = { false },
    DeleteProflie      = { false },
    profileLists    = { { default = {} } },
    selectedProfile = "default",
    actionBarProfiles = { { default = {} } }
}

local CharDefaultSettings = {
    currentProfile = "default",
    actionBar = { {rows = 9, profile = "default" } }
}

function MM:OnInitialize()

    self.db = self:SetupDB(MiscMenuDB, DefaultSettings)
    self.charDB = self:SetupDB(MiscMenuCharDB, CharDefaultSettings)
    self:CreateOptionsUI()
    --Enable the use of /MiscMenu slash command
    SLASH_MISCMENU1 = "/miscmenu"
    SlashCmdList["MISCMENU"] = function(msg)
        MISCMENU:SlashCommand(msg)
    end
end

function MM:OnEnable()
    self:SetFramePos(self.standaloneButton, self.charDB.menuPos)
    self:InitializeMinimap()
    self:ToggleMainButton(self.db.EnableAutoHide)
    self.standaloneButton:SetScale(self.db.buttonScale or 1)
    if not self.db.hideRandomPet then self:ToggleRandomPet() end
    self:CreateActionBar()
    self:FirstLoad()
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("COMPANION_UPDATE")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("EXECUTE_CHAT_LINE")
end

function MM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
	self:RemoveItem(arg2)
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

function MM:UI_ERROR_MESSAGE(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end

function MM:EXECUTE_CHAT_LINE(event, arg1, arg2)
    self:ActionBarEvents(event, arg1, arg2)
end
--[[
MM:SlashCommand(msg):
msg - takes the argument for the /miscmenu command so that the appropriate action can be performed
If someone types /miscmenu, bring up the options box
]]
function MM:SlashCommand(msg)
    local cmd, arg = string.split(" ", msg, 2)
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
    elseif cmd == "unlockpet" then
        self:UnlockRandomPet()
    elseif cmd == "pet" then
       self.db.hideRandomPet = not self.db.hideRandomPet
       self:ToggleRandomPet()
    elseif cmd == "unlockactionbar" then
        self:ActionBarUnlockFrame()
    else
        self:ToggleStandaloneButton()
    end
end
