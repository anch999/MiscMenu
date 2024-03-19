local MM = LibStub("AceAddon-3.0"):NewAddon("MiscMenu", "AceTimer-3.0", "AceEvent-3.0")
MISCMENU = MM
MM.dewdrop = AceLibrary("Dewdrop-2.0")

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
MM.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    hideNoMouseOver = { false, Frame = "MiscMenuStandaloneButton", CheckBox = "MiscMenuOptionsHideNoMouseOver" },
    hideMenu        = { false, Frame = "MiscMenuStandaloneButton", CheckBox = "MiscMenuOptionsHideMenu"},
    minimap         = { false, CheckBox = "MiscMenuOptionsHideMinimap"},
    txtSize         = 12,
    autoMenu        = { false, CheckBox = "MiscMenuOptionsAutoMenu"},
    deleteItem      = { false, CheckBox = "MiscMenuOptionsAutoDelete" },
    profileLists    = { { default = {} } },
}

local CharDefaultSettings = {
    currentProfile = "default"
}

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db, defaultList)
    for table, v in pairs(defaultList) do
        if not db[table] then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text then
                _G[v.Text]:SetText(db[table])
            end
            if v.Frame then
                if db[table] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
            end
        end
    end
end

function MM:OnEnable()
    self:SetMenuPos()
    self:SetRandomPetPos()
    self:InitializeMinimap()
    self:ToggleMainButton("hide")
    self:ToggleRandomPet("show")
end

function MM:OnInitialize()
    MiscMenuDB = MiscMenuDB or {}
    MiscMenuCharDB = MiscMenuCharDB or {}
    self.db = MiscMenuDB
    self.charDB = MiscMenuCharDB
    setupSettings(self.db, DefaultSettings)
    setupSettings(self.charDB, CharDefaultSettings)
    --Enable the use of /MiscMenu slash command
    SLASH_MISCMENU1 = "/miscmenu"
    SlashCmdList["MISCMENU"] = function(msg)
        MISCMENU:SlashCommand(msg)
    end
end

function MM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	self:RemoveItem(arg2)
end

--[[
MM:SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
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
    else
        self:ToggleStandaloneButton()
    end
end
