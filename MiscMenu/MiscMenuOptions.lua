local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

function MM:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("MiscMenu")
	end
end

function MiscMenu_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	MiscMenu_DropDownInitialize()
	UIDropDownMenu_SetText(MiscMenuOptions_TxtSizeMenu, MM.db.txtSize)
end

--Creates the options frame and all its assets

function MM:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	self.options = { frame = {} }
		self.options.frame.panel = CreateFrame("FRAME", "MiscMenuOptionsFrame", UIParent, nil)
    	local fstring = self.options.frame.panel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("MiscMenu Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		self.options.frame.panel.name = "MiscMenu"
		InterfaceOptions_AddCategory(self.options.frame.panel)

	self.options.hideMenu = CreateFrame("CheckButton", "MiscMenuOptionsHideMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMenu:SetPoint("TOPLEFT", 15, -60)
	self.options.hideMenu.Lable = self.options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMenu.Lable:SetJustifyH("LEFT")
	self.options.hideMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMenu.Lable:SetText("Hide Standalone Button")
	self.options.hideMenu:SetScript("OnClick", function() 
		if self.db.hideMenu then
			MiscMenuFrame:Show()
			self.db.hideMenu = false
		else
			MiscMenuFrame:Hide()
			self.db.hideMenu = true
		end
	end)

	self.options.hideNoMouseOver = CreateFrame("CheckButton", "MiscMenuOptionsHideNoMouseOver", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideNoMouseOver:SetPoint("TOPLEFT", 15, -95)
	self.options.hideNoMouseOver.Lable = self.options.hideNoMouseOver:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideNoMouseOver.Lable:SetJustifyH("LEFT")
	self.options.hideNoMouseOver.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideNoMouseOver.Lable:SetText("Only Show Standalone Button on Hover")
	self.options.hideNoMouseOver:SetScript("OnClick", function()
		if self.db.hideNoMouseOver then
			MiscMenuOptionsFrame:Show()
			self.db.hideNoMouseOver = false
		else
			MiscMenuOptionsFrame:Hide()
			self.db.hideNoMouseOver = true
		end
	end)

	self.options.hideMinimap = CreateFrame("CheckButton", "MiscMenuOptionsHideMinimap", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 15, -130)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide minimap icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.autoDelete = CreateFrame("CheckButton", "MiscMenuOptionsAutoDelete", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoDelete:SetPoint("TOPLEFT", 15, -165)
	self.options.autoDelete.Lable = self.options.autoDelete:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoDelete.Lable:SetJustifyH("LEFT")
	self.options.autoDelete.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoDelete.Lable:SetText("Delete vanity items after summoning")
	self.options.autoDelete:SetScript("OnClick", function() self.db.deleteItem = not self.db.deleteItem end)

	self.options.autoMenu = CreateFrame("CheckButton", "MiscMenuOptionsAutoMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoMenu:SetPoint("TOPLEFT", 15, -200)
	self.options.autoMenu.Lable = self.options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoMenu.Lable:SetJustifyH("LEFT")
	self.options.autoMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoMenu.Lable:SetText("Show menu on mouse over")
	self.options.autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	self.options.txtSize = CreateFrame("Button", "MiscMenuOptions_TxtSizeMenu", MiscMenuOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -370)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu text size")
end

MM:CreateOptionsUI()

function MiscMenu_Options_Menu_Initialize()
	local info
	for i = 10, 25 do
				info = {
					text = i;
					func = function() 
						MM.db.txtSize = i 
						local thisID = this:GetID();
						UIDropDownMenu_SetSelectedID(MiscMenuOptions_TxtSizeMenu, thisID)
					end;
				};
					UIDropDownMenu_AddButton(info);
	end
end

function MiscMenu_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(MiscMenuOptions_TxtSizeMenu, MiscMenu_Options_Menu_Initialize )
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_TxtSizeMenu)
	UIDropDownMenu_SetWidth(MiscMenuOptions_TxtSizeMenu, 150)
end

--Hook interface frame show to update options data
InterfaceOptionsFrame:HookScript("OnShow", function()
	if InterfaceOptionsFrame and MiscMenuOptionsFrame:IsVisible() then
		MiscMenu_OpenOptions()
	end
end)