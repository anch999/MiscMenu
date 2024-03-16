local MM = LibStub("AceAddon-3.0"):NewAddon("MiscMenu", "AceTimer-3.0", "AceEvent-3.0")
local professionbutton, mainframe
local dewdrop = AceLibrary("Dewdrop-2.0")

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"



--Set Savedvariables defaults
local DefaultSettings  = {
    { TableName = "ShowMenuOnHover", false, Frame = "MiscMenuFrame",CheckBox = "MiscMenuOptions_ShowOnHover" },
    { TableName = "HideMenu", false, Frame = "MiscMenuFrame", CheckBox = "MiscMenuOptions_HideMenu"},
    { TableName = "minimap", false, CheckBox = "MiscMenuOptions_HideMinimap"},
    { TableName = "txtSize", 12},
    { TableName = "autoMenu", false, CheckBox = "MiscMenuOptions_AutoMenu"},
}

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db)
    for _,v in ipairs(DefaultSettings) do
        if db[v.TableName] == nil then
            if #v > 1 then
                db[v.TableName] = {}
                for _, n in ipairs(v) do
                    tinsert(db[v.TableName], n)
                end
            else
                db[v.TableName] = v[1]
            end
        end

        if v.CheckBox then
            _G[v.CheckBox]:SetChecked(db[v.TableName])
        end
        if v.Text then
            _G[v.Text]:SetText(db[v.TableName])
        end
        if v.Frame then
            if db[v.TableName] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
        end
    end
end

function VMENU:OnEnable()
    if icon then
        self.map = {hide = self.db.minimap}
        icon:Register('MiscMenu', minimap, self.map)
    end

    if self.db.menuPos then
        local pos = self.db.menuPos
        mainframe:ClearAllPoints()
        mainframe:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        mainframe:ClearAllPoints()
        mainframe:SetPoint("CENTER", UIParent)
    end

    self:ToggleMainButton("hide")
end

function VMENU:OnInitialize()
    if not MiscMenuDB then MiscMenuDB = {} end
    self.db = MiscMenuDB
    setupSettings(self.db)
    --Enable the use of /MiscMenu slash command
    SLASH_MiscMenu1 = "/MiscMenu"
    SlashCmdList["MiscMenu"] = function(msg)
        self.SlashCommand(msg)
    end
end

function VMENU:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	self:RemoveItem(arg2)
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function VMENU:HasItem(itemID)
	local item, found, id
	-- scan bags
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag, slot)
			if item then
				found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
				if found and tonumber(id) == itemID then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- deletes item from players inventory if value 2 in the items table is set
function VMENU:RemoveItem(arg2)
	if not self.db.DeleteItem then return end
	for _, item in ipairs(items) do
        if arg2 == item[2] then
            local found, bag, slot = self:HasItem(item[1])
            if found and C_VanityCollection.IsCollectionItemOwned(item[1]) and self:IsSoulbound(bag, slot) then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
        end
	end
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

-- add altar summon button via dewdrop secure
function VMENU:AddItem(itemID)
        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
        local startTime, duration = GetItemCooldown(itemID)
		local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
		local text = name
		if cooldown > 0 then
		text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
		end
		local secure = {
		type1 = 'item',
		item = name
		}
        dewdrop:AddLine(
                'text', text,
                'icon', icon,
                'secure', secure,
                'func', function() if not self:HasItem(itemID) then RequestDeliverVanityCollectionItem(itemID) else if self.db.DeleteItem then self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") end dewdrop:Close() end end,
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize
        )
end

--for a adding a divider to dew drop menus 
function VMENU:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

--sets up the drop down menu for specs
function VMENU:DewdropRegister(button, showUnlock)
    if dewdrop:IsOpen(button) then dewdrop:Close() return end
    dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Professions",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
                'isTitle', true,
                'notCheckable', true
            )
            local divider

            local SummonItems = self:ReturnItemIDs()

            if #SummonItems > 0 then
                if not divider then divider = self:AddDividerLine(35) end
                for _, itemID in ipairs(SummonItems) do
                    self:AddItem(itemID)
                end
            end

            if CA_IsSpellKnown(750750) then
                if not divider then divider = self:AddDividerLine(35) end
                local name, _, icon = GetSpellInfo(750750)
                local secure = { type1 = 'spell', spell = name }
                dewdrop:AddLine( 'text', name, 'icon', icon, 'secure', secure, 'closeWhenClicked', true, 'textHeight', self.db.txtSize, 'textWidth', self.db.txtSize)
            end

            local spellIDs = self:ReturnSpellIDs()
            if #spellIDs > 0 then
                self:AddDividerLine(35)
                for _, spellID in ipairs(spellIDs) do
                    local name, _, icon = GetSpellInfo(spellID)
                    local secure = { type1 = 'spell', spell = spellID }
                    dewdrop:AddLine( 'text', name, 'icon', icon,'secure', secure, 'closeWhenClicked', true, 'textHeight', self.db.txtSize, 'textWidth', self.db.txtSize)    
                end
            end
            self:AddDividerLine(35)
            if showUnlock then
                dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', self.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'func', self.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    dewdrop:Open(button)
    local hook
    if not hook then
        WorldFrame:HookScript("OnEnter", function()
            if dewdrop:IsOpen(button) then
                dewdrop:Close()
            end
        end)
        hook = true
    end

    GameTooltip:Hide()
end

function VMENU:ToggleMainButton(toggle)
    if self.db.ShowMenuOnHover then
        if toggle == "show" then
            MiscMenuFrame_Menu:Show()
            MiscMenuFrame.icon:Show()
            MiscMenuFrame.Text:Show()
        else
            MiscMenuFrame_Menu:Hide()
            MiscMenuFrame.icon:Hide()
            MiscMenuFrame.Text:Hide()
        end
    end
end

-- Used to show highlight as a frame mover
local unlocked = false
function VMENU:UnlockFrame()
    if unlocked then
        MiscMenuFrame_Menu:Show()
        MiscMenuFrame.Highlight:Hide()
        unlocked = false
        GameTooltip:Hide()
    else
        MiscMenuFrame_Menu:Hide()
        MiscMenuFrame.Highlight:Show()
        unlocked = true
    end
end



InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and MiscMenuOptionsFrame:IsVisible() then
		MiscMenu_OpenOptions()
    end
end)

-- toggle the main button frame
function VMENU:ToggleMainFrame()
    if MiscMenuFrame:IsVisible() then
        MiscMenuFrame:Hide()
    else
        MiscMenuFrame:Show()
    end
end

--[[
VMENU:SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
function VMENU:SlashCommand(msg)
    if msg == "reset" then
        MiscMenuDB = nil
        self:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        self:Options_Toggle()
    else
        self:ToggleMainFrame()
    end
end
