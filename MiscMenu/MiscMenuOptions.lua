function Vanity_Menu:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("MiscMenu")
	end
end

function MiscMenu_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	MiscMenu_DropDownInitialize()
	UIDropDownMenu_SetText(MiscMenuOptions_TxtSizeMenu, Vanity_Menu.db.txtSize)
end

--Creates the options frame and all its assets

function Vanity_Menu:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	local mainframe = {}
		mainframe.panel = CreateFrame("FRAME", "MiscMenuOptionsFrame", UIParent, nil)
    	local fstring = mainframe.panel:CreateFontString(mainframe, "OVERLAY", "GameFontNormal")
		fstring:SetText("Profession Menu Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		mainframe.panel.name = "MiscMenu"
		InterfaceOptions_AddCategory(mainframe.panel)

	local hideMenu = CreateFrame("CheckButton", "MiscMenuOptions_HideMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	hideMenu:SetPoint("TOPLEFT", 15, -60)
	hideMenu.Lable = hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMenu.Lable:SetJustifyH("LEFT")
	hideMenu.Lable:SetPoint("LEFT", 30, 0)
	hideMenu.Lable:SetText("Hide Standalone Button")
	hideMenu:SetScript("OnClick", function() 
		if self.db.HideMenu then
			MiscMenuFrame:Show()
			self.db.HideMenu = false
		else
			MiscMenuFrame:Hide()
			self.db.HideMenu = true
		end
	end)

	local hideHover = CreateFrame("CheckButton", "MiscMenuOptions_ShowOnHover", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	hideHover:SetPoint("TOPLEFT", 15, -95)
	hideHover.Lable = hideHover:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideHover.Lable:SetJustifyH("LEFT")
	hideHover.Lable:SetPoint("LEFT", 30, 0)
	hideHover.Lable:SetText("Only Show Standalone Button on Hover")
	hideHover:SetScript("OnClick", function()
		if self.db.ShowMenuOnHover then
			MiscMenuFrame_Menu:Show()
            MiscMenuFrame.icon:Show()
			MiscMenuFrame.Text:Show()
			self.db.ShowMenuOnHover = false
		else
			MiscMenuFrame_Menu:Hide()
            MiscMenuFrame.icon:Hide()
			MiscMenuFrame.Text:Hide()
			self.db.ShowMenuOnHover = true
		end

	end)

	local hideMinimap = CreateFrame("CheckButton", "MiscMenuOptions_HideMinimap", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	hideMinimap:SetPoint("TOPLEFT", 15, -130)
	hideMinimap.Lable = hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMinimap.Lable:SetJustifyH("LEFT")
	hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	hideMinimap.Lable:SetText("Hide Minimap Icon")
	hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	local itemDel = CreateFrame("CheckButton", "MiscMenuOptions_DeleteMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	itemDel:SetPoint("TOPLEFT", 15, -165)
	itemDel.Lable = itemDel:CreateFontString(nil , "BORDER", "GameFontNormal")
	itemDel.Lable:SetJustifyH("LEFT")
	itemDel.Lable:SetPoint("LEFT", 30, 0)
	itemDel.Lable:SetText("Delete vanity items after summoning")
	itemDel:SetScript("OnClick", function() self.db.DeleteItem = not self.db.DeleteItem end)

	local autoMenu = CreateFrame("CheckButton", "MiscMenuOptions_AutoMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	autoMenu:SetPoint("TOPLEFT", 15, -200)
	autoMenu.Lable = autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	autoMenu.Lable:SetJustifyH("LEFT")
	autoMenu.Lable:SetPoint("LEFT", 30, 0)
	autoMenu.Lable:SetText("Show menu on hover")
	autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	local hideRank = CreateFrame("CheckButton", "MiscMenuOptions_HideRank", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	hideRank:SetPoint("TOPLEFT", 15, -235)
	hideRank.Lable = hideRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideRank.Lable:SetJustifyH("LEFT")
	hideRank.Lable:SetPoint("LEFT", 30, 0)
	hideRank.Lable:SetText("Hide profession rank")
	hideRank:SetScript("OnClick", function() self.db.hideRank = not self.db.hideRank end)

	local hideMaxRank = CreateFrame("CheckButton", "MiscMenuOptions_HideMaxRank", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	hideMaxRank:SetPoint("TOPLEFT", 15, -270)
	hideMaxRank.Lable = hideMaxRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMaxRank.Lable:SetJustifyH("LEFT")
	hideMaxRank.Lable:SetPoint("LEFT", 30, 0)
	hideMaxRank.Lable:SetText("Hide profession max rank")
	hideMaxRank:SetScript("OnClick", function() self.db.hideMaxRank = not self.db.hideMaxRank end)

	local showHerb = CreateFrame("CheckButton", "MiscMenuOptions_ShowHerb", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	showHerb:SetPoint("TOPLEFT", 15, -305)
	showHerb.Lable = showHerb:CreateFontString(nil , "BORDER", "GameFontNormal")
	showHerb.Lable:SetJustifyH("LEFT")
	showHerb.Lable:SetPoint("LEFT", 30, 0)
	showHerb.Lable:SetText("Show Herbalism")
	showHerb:SetScript("OnClick", function() self.db.showHerb = not self.db.showHerb end)

	local showOldTradeUI = CreateFrame("CheckButton", "MiscMenuOptions_ShowOldTradeSkillUI", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	showOldTradeUI:SetPoint("TOPLEFT", 15, -335)
	showOldTradeUI.Lable = showOldTradeUI:CreateFontString(nil , "BORDER", "GameFontNormal")
	showOldTradeUI.Lable:SetJustifyH("LEFT")
	showOldTradeUI.Lable:SetPoint("LEFT", 30, 0)
	showOldTradeUI.Lable:SetText("Show old Blizzard Trade Skill UI")
	showOldTradeUI:SetScript("OnClick", function()
		self.db.ShowOldTradeSkillUI = not self.db.ShowOldTradeSkillUI
		if self.db.ShowOldTradeSkillUI then
			UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
			self:RegisterEvent("TRADE_SKILL_SHOW")
		else
			self:UnregisterEvent("TRADE_SKILL_SHOW")
			UIParent:RegisterEvent("TRADE_SKILL_SHOW")
		end
	end)

	local txtSize = CreateFrame("Button", "MiscMenuOptions_TxtSizeMenu", MiscMenuOptionsFrame, "UIDropDownMenuTemplate")
	txtSize:SetPoint("TOPLEFT", 15, -370)
	txtSize.Lable = txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	txtSize.Lable:SetJustifyH("LEFT")
	txtSize.Lable:SetPoint("LEFT", txtSize, 190, 0)
	txtSize.Lable:SetText("Menu Text Size")
end

Vanity_Menu:CreateOptionsUI()

	function MiscMenu_Options_Menu_Initialize()
		local info
		for i = 10, 25 do
					info = {
						text = i;
						func = function() 
							Vanity_Menu.db.txtSize = i 
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