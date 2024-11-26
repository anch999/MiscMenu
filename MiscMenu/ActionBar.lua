local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

function MM:CreateActionBars()
    for i = 1, self.db.NumberActionBars do
        self:CreateActionBar(i)
    end
end

function MM:CreateActionBar(i)
    self.actionBars = self.actionBars or {}
    self.charDB.actionBars = self.charDB.actionBars or {}
    self.charDB.actionBars[i] = self.charDB.actionBars[i] or {}
    self.charDB.actionBars[i].profile = self.charDB.actionBars[i].profile or "default"
    self.charDB.actionBars[i].numButtons = self.charDB.actionBars[i].numButtons or 12
    self.charDB.actionBars[i].rows = self.charDB.actionBars[i].rows or 1

    self.actionBars[i] = CreateFrame("FRAME", "MiscMenuActionBarFrame", UIParent )
    self.actionBars[i]:SetMovable(true)
    self.actionBars[i]:EnableMouse(true)
    self.actionBars[i].FrameMover = CreateFrame("FRAME", "MiscMenuActionBarFrameMover", self.actionBars[i])
    self.actionBars[i].FrameMover:SetPoint("CENTER",self.actionBars[i])
    self.actionBars[i].FrameMover:EnableMouse(true)
    self.actionBars[i].FrameMover:RegisterForDrag("LeftButton")
    self.actionBars[i].FrameMover:SetScript("OnDragStart", function()
        self.actionBars[i]:StartMoving()
    end)
    self.actionBars[i].FrameMover:SetScript("OnDragStop", function()
        self.actionBars[i]:StopMovingOrSizing()
        self.charDB.actionBars[i].FramePos = { self.actionBars[i]:GetPoint() }
        self.charDB.actionBars[i].FramePos[2] = "UIParent"
    end)
    self.actionBars[i].FrameMover:SetFrameStrata("FULLSCREEN")
    self.actionBars[i].FrameMover.backTexture = self.actionBars[i].FrameMover:CreateTexture(nil, "BACKGROUND")
    self.actionBars[i].FrameMover.backTexture:SetTexture(0,1,0,.5)
    self.actionBars[i].FrameMover.backTexture:SetAllPoints()
    self.actionBars[i].FrameMover.backTexture:SetPoint("CENTER",self.actionBars[i].FrameMover)
    self.actionBars[i].FrameMover:Hide()

    local function createButtons(i)
        for num = 1, 12 do
            if not self.actionBars[i]["button"..num] then
                self.actionBars[i]["button"..num] = CreateFrame("CheckButton", "$parent"..i.."Button"..num, self.actionBars[i] , "MiscMenuActionBarButtonTemplate")
                self.actionBars[i]["button"..num].ID = num
                self.actionBars[i]["button"..num]:RegisterForDrag("LeftButton")
                self.actionBars[i]["button"..num]:SetScript("OnReceiveDrag", function() self:PlaceAction(self.actionBars[i]["button"..num], i) end)
                self.actionBars[i]["button"..num]:SetScript("OnDragStart", function() self:PickupAction(self.actionBars[i]["button"..num], nil, i) end)
                self.actionBars[i]["button"..num]:SetScript("OnMouseDown", function() self:ActionBarOnClick(self.actionBars[i]["button"..num], i) end)
                self.actionBars[i]["button"..num]:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
                self.actionBars[i]["button"..num]:SetScript("OnLeave", function() GameTooltip:Hide() end)
                self.actionBars[i]["button"..num].defaultAnchor = true
            end
        end
    end

    function self:RefreshActionBars(numButtons)
        for num = 1, 12 do
            if numButtons >= i then
                self.actionBars[i]["button"..num]:Show()
            else
                self.actionBars[i]["button"..num]:Hide()
            end
        end
    end

    function self:SetActionBarLayout(i)
        local rows = self:GetNumberRows(i)
        local numButtons = self:GetNumberButtons(i)
        createButtons(i)
        self:RefreshActionBars(numButtons)
        local width, height = ((numButtons / rows) * (self.actionBars[i].button1:GetWidth() + 4))-2, ((rows) * (self.actionBars[i].button1:GetHeight() + 4))-2
        self.actionBars[i]:SetSize(width, height)
        self.actionBars[i].FrameMover:SetSize(width, height)
        local column = (12/rows)
        for r = 1, rows do
            for num = ((r*column)-column+1), (r*column) do
                if self.actionBars[i]["button"..num] then
                    if num == 1 then
                        self.actionBars[i]["button"..num]:ClearAllPoints()
                        self.actionBars[i]["button"..num]:SetPoint("TOPLEFT", self.actionBars[i])
                    elseif ((r*column)-column+1) == num then
                        self.actionBars[i]["button"..num]:ClearAllPoints()
                        self.actionBars[i]["button"..num]:SetPoint("TOP", self.actionBars[i]["button"..(num-column)] , "BOTTOM", 0, -4)
                    else
                        self.actionBars[i]["button"..num]:ClearAllPoints()
                        self.actionBars[i]["button"..num]:SetPoint("LEFT", self.actionBars[i]["button"..(num-1)], "RIGHT", 4, 0)
                    end
                end
            end
        end
    end
    self:SetActionBarLayout(i)
    self:SetFramePos(self.actionBars[i], self.charDB.actionBars[i].FramePos)
end

function MM:ActionBarUnlockFrame()
    self = MM
    for i = 1, self.db.NumberActionBars do
        if self.actionBars[i].FrameMover:IsVisible() then
            self.actionBars[i].FrameMover:Hide()
        else
            self.actionBars[i].FrameMover:Show()
        end
    end
end

function MM:SetButtonTimer(infoType, button, ID)
    local start, duration, enable
    if infoType == "item" then
        start, duration, enable = GetItemCooldown(ID)
    elseif infoType == "spell" then
        start, duration, enable = GetSpellCooldown(ID)
    end
    if start then
        CooldownFrame_SetTimer(button.Cooldown, start, duration, enable)
    end
end

function MM:ActionBarOnClick(button, i)
    if button:IsEnabled() == 0 then return end
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID])
    if not ID then button:SetChecked(true) end
    self.activeButtonID = self.actionBars[i]["button"..button.ID]
    if  infoType == "item" then
        local start = GetItemCooldown(ID)
        if start == 0 and not self:HasItem(ID) and C_VanityCollection.IsCollectionItemOwned(ID) then
           RequestDeliverVanityCollectionItem(ID)
           self.activeButtonID:SetChecked(true)
        elseif start > 0 then
            self.activeButtonID:SetChecked(true)
        else
            self.deleteItem = ID
        end
    elseif infoType == "spell" then
        if not CA_IsSpellKnown(ID) and C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[ID] or ID) then
            RequestDeliverVanityCollectionItem(VANITY_SPELL_REFERENCE[ID] or ID)
        end
    end
    Timer.After(.5, function() MM:SetButtonTimer(infoType, button, ID) end)
    self:PlaceAction(button, i)
end

function MM:PlaceAction(button, i)
    local infoType, ID, bookType = GetCursorInfo()
    local swapInfo
    if infoType then
        if not infoType then return end
        if infoType == "spell" then
            infoType, ID = GetSpellBookItemInfo(ID, bookType)
        elseif infoType == "companion" and bookType == "CRITTER" then
            infoType = "spell"
            ID = select(3, GetCompanionInfo("CRITTER", ID))
        elseif infoType == "companion" and bookType == "MOUNT" then
            infoType = "spell"
            ID = select(3, GetCompanionInfo("MOUNT", ID))
        elseif infoType == "macro" then
            ID = GetMacroInfo(ID)
        end
        if self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID][1] then
            swapInfo = {unpack(self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID])}
        end 
        self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID] = {infoType, ID, bookType}
        ClearCursor()
        Timer.After(.2, function() self:SetAttribute(button, i) end)
    end
    if swapInfo then
        self:PickupAction(button, swapInfo, i)
    end

end

function MM:PickupAction(button, swapInfo, i)
    local infoType, ID,  info = unpack(self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID])
    if swapInfo then
        infoType, ID,  info = unpack(swapInfo)
    else
        Timer.After(.5, function() CooldownFrame_Clear(button.Cooldown) end)
        button.Icon:SetTexture("")
        button.Name:SetText("")
        button:SetAttribute("type1", nil)
        button:SetAttribute(infoType, nil)
    end
    if not ID then button:SetChecked(false) end
    if ID then
            if infoType == "inventory" then
                PickupInventoryItem(ID)
            elseif infoType == "item" then
                PickupItem(self:GetItemInfo(ID))
            elseif infoType == "macro" then
                if type(ID) == "string" then ID = GetMacroIndexByName(ID) end
                PickupMacro(ID)
            elseif info == "CRITTER" or info == "MOUNT" then
                PickupCompanion(info, self:GetPetIdFromSpellID(ID, info))
            elseif infoType == "spell" then
                PickupSpell(GetSpellInfo(ID))
            elseif infoType == "equipmentset" then
                 PickupEquipmentSet(ID)
            end
            self.actionBarLock = true
        if not swapInfo then
            self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID] = {nil, nil}
        end
    end
end

function MM:SetAttribute(button, i)
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBars[i].profile][button.ID])
    local name, icon, itemLink, text, start, duration, enable
    if not ID then
        button.Name:SetText()
        button.Icon:SetTexture()
        return
    end
    if infoType == "spell" then
        name, _, icon = GetSpellInfo(ID)
        itemLink =  GetSpellLink(ID)
        start, duration, enable = GetSpellCooldown(ID)
    elseif infoType == "item" then
        local item = Item:CreateFromID(ID)
        itemLink = item:GetLink()
        name = item:GetName()
        icon = item:GetIcon()
        start, duration, enable = GetItemCooldown(ID)
    elseif infoType == "macro" then
        name, icon = GetMacroInfo(ID)
        text = name
    end
    if start then
        CooldownFrame_SetTimer(button.Cooldown, start, duration, enable)
    end
    button.itemLink = itemLink
    button.Name:SetText(text)
    button.Icon:SetTexture(icon)
    button:SetAttribute("type", infoType)
    button:SetAttribute(infoType, name)
    if InterfaceOptionsFrame:IsVisible() then
        self.options.NumberOfActionbarButtons.UpdateSlider(self:GetNumberButtons(self:GetSelectedBar()))
        self.options.NumberOfActionbarRows.UpdateSlider(self:GetNumberRows(self:GetSelectedBar()))
    end
end

function MM:SetActionBarProfile()
    for i = 1, self.db.NumberActionBars do
        for num = 1, 12 do
            if self.actionBars[i]["button"..num] then
                self:SetAttribute(self.actionBars[i]["button"..num], i)
            end
            self:SetActionBarLayout(i)
        end
    end
end

function MM:ActionBarEvents(event, arg1, arg2)
    if self.activeButtonID then
        self.activeButtonID:SetChecked(false)
        self.activeButtonID = nil
    end
end

function MM:GetNumberRows(i)
    self.charDB.actionBars[i].rows = self.charDB.actionBars[i].rows or 1
    return self.charDB.actionBars[i].rows
end

function MM:GetNumberButtons(i)
    self.charDB.actionBars[i].numButtons = self.charDB.actionBars[i].numButtons or 12
    return self.charDB.actionBars[i].numButtons
end

function MM:GetSelectedBar()
    self.selectedBar = self.selectedBar or 1
    return self.selectedBar
end

function MM:ToggleActionBar()
    for i = 1, self.db.NumberActionBars do
        if self.charDB.actionBars[i].show then
            self.actionBars[i]:Show()
        else
            self.actionBars[i]:Hide()
        end
    end
end

function MM:InitializeActionBars()
    self:CreateActionBars()
    self:SetActionBarProfile()
    self:ToggleActionBar()
end

BINDING_HEADER_MISCMENUB1 = "MiscMenu - Action Bar 1"
BINDING_HEADER_MISCMENUB2 = "MiscMenu - Action Bar 2"
BINDING_HEADER_MISCMENUB3 = "MiscMenu - Action Bar 3"
BINDING_HEADER_MISCMENUB4 = "MiscMenu - Action Bar 4"

_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button1:LeftButton"] = "Button 1"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button2:LeftButton"] = "Button 2"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button3:LeftButton"] = "Button 3"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button4:LeftButton"] = "Button 4"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button5:LeftButton"] = "Button 5"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button6:LeftButton"] = "Button 6"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button7:LeftButton"] = "Button 7"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button8:LeftButton"] = "Button 8"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button9:LeftButton"] = "Button 9"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button10:LeftButton"] = "Button 10"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button11:LeftButton"] = "Button 11"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame1Button12:LeftButton"] = "Button 12"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button1:LeftButton"] = "Button 1"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button2:LeftButton"] = "Button 2"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button3:LeftButton"] = "Button 3"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button4:LeftButton"] = "Button 4"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button5:LeftButton"] = "Button 5"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button6:LeftButton"] = "Button 6"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button7:LeftButton"] = "Button 7"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button8:LeftButton"] = "Button 8"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button9:LeftButton"] = "Button 9"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button10:LeftButton"] = "Button 10"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button11:LeftButton"] = "Button 11"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame2Button12:LeftButton"] = "Button 12"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button1:LeftButton"] = "Button 1"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button2:LeftButton"] = "Button 2"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button3:LeftButton"] = "Button 3"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button4:LeftButton"] = "Button 4"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button5:LeftButton"] = "Button 5"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button6:LeftButton"] = "Button 6"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button7:LeftButton"] = "Button 7"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button8:LeftButton"] = "Button 8"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button9:LeftButton"] = "Button 9"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button10:LeftButton"] = "Button 10"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button11:LeftButton"] = "Button 11"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame3Button12:LeftButton"] = "Button 12"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button1:LeftButton"] = "Button 1"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button2:LeftButton"] = "Button 2"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button3:LeftButton"] = "Button 3"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button4:LeftButton"] = "Button 4"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button5:LeftButton"] = "Button 5"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button6:LeftButton"] = "Button 6"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button7:LeftButton"] = "Button 7"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button8:LeftButton"] = "Button 8"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button9:LeftButton"] = "Button 9"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button10:LeftButton"] = "Button 10"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button11:LeftButton"] = "Button 11"
_G["BINDING_NAME_CLICK MiscMenuActionBarFrame4Button12:LeftButton"] = "Button 12"