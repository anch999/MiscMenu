local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

function MM:CreateActionBars()
    for bar = 1, self.db.NumberActionBars do
        self:CreateActionBar(bar)
    end
end

function MM:CreateActionBar(bar)
    self.actionBars = self.actionBars or {}
    self.charDB.actionBars = self.charDB.actionBars or {}
    self.charDB.actionBars[bar] = self.charDB.actionBars[bar] or {}
    self.charDB.actionBars[bar].profile = self.charDB.actionBars[bar].profile or ("Bar"..bar)
    self.charDB.actionBars[bar].numButtons = self.charDB.actionBars[bar].numButtons or 12
    self.charDB.actionBars[bar].rows = self.charDB.actionBars[bar].rows or 1

    self.actionBars[bar] = CreateFrame("FRAME", "MiscMenuActionBarFrame", UIParent )
    self.actionBars[bar]:SetMovable(true)
    self.actionBars[bar]:EnableMouse(true)
    self.actionBars[bar].FrameMover = CreateFrame("FRAME", "MiscMenuActionBarFrameMover", self.actionBars[bar])
    self.actionBars[bar].FrameMover:SetPoint("CENTER",self.actionBars[bar])
    self.actionBars[bar].FrameMover:EnableMouse(true)
    self.actionBars[bar].FrameMover:RegisterForDrag("LeftButton")
    self.actionBars[bar].FrameMover:SetScript("OnDragStart", function()
        self.actionBars[bar]:StartMoving()
    end)
    self.actionBars[bar].FrameMover:SetScript("OnDragStop", function()
        self.actionBars[bar]:StopMovingOrSizing()
        self.charDB.actionBars[bar].FramePos = { self.actionBars[bar]:GetPoint() }
        self.charDB.actionBars[bar].FramePos[2] = "UIParent"
    end)
    self.actionBars[bar].FrameMover:SetFrameStrata("FULLSCREEN")
    self.actionBars[bar].FrameMover.backTexture = self.actionBars[bar].FrameMover:CreateTexture(nil, "BACKGROUND")
    self.actionBars[bar].FrameMover.backTexture:SetTexture(0,1,0,.5)
    self.actionBars[bar].FrameMover.backTexture:SetAllPoints()
    self.actionBars[bar].FrameMover.backTexture:SetPoint("CENTER",self.actionBars[bar].FrameMover)
    self.actionBars[bar].FrameMover:Hide()

    self:SetActionBarLayout(bar)
    self:SetFramePos(self.actionBars[bar], self.charDB.actionBars[bar].FramePos)
end

function MM:RefreshActionBars(numButtons, bar)
    for num = 1, 12 do
        if num > numButtons then
            self.actionBars[bar]["button"..num]:Hide()
        else
            self.actionBars[bar]["button"..num]:Show()
        end
    end
end

local function createButtons(self, bar)
    for num = 1, 12 do
        if not self.actionBars[bar]["button"..num] then
            self.actionBars[bar]["button"..num] = CreateFrame("CheckButton", "$parent"..bar.."Button"..num, self.actionBars[bar] , "MiscMenuActionBarButtonTemplate")
            self.actionBars[bar]["button"..num].ID = num
            self.actionBars[bar]["button"..num]:RegisterForDrag("LeftButton")
            self.actionBars[bar]["button"..num]:SetScript("OnReceiveDrag", function() self:PlaceAction(self.actionBars[bar]["button"..num], bar) end)
            self.actionBars[bar]["button"..num]:SetScript("OnDragStart", function() self:PickupAction(self.actionBars[bar]["button"..num], nil, bar) end)
            self.actionBars[bar]["button"..num]:SetScript("OnMouseDown", function() self:ActionButtonOnClick(bar, self.actionBars[bar]["button"..num]) end)
            self.actionBars[bar]["button"..num]:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
            self.actionBars[bar]["button"..num]:SetScript("OnLeave", function() GameTooltip:Hide() end)
            self.actionBars[bar]["button"..num].defaultAnchor = true
        end
    end
end
------------------------------------------------------------------------------------------------------
function MM:SetActionBarLayout(bar)
    local rows = self:GetNumberRows(bar)
    local numButtons = self:GetNumberButtons(bar)
    createButtons(self, bar)
    self:RefreshActionBars(numButtons, bar)
    local buttonWidth = self.actionBars[bar].button1:GetWidth() + 4
    local width = buttonWidth < ((numButtons / rows) * buttonWidth)-2 and ((numButtons / rows) * buttonWidth)-2 or buttonWidth
    local buttonHeight = self.actionBars[bar].button1:GetHeight() + 4
    local height = buttonHeight < (((rows) * (buttonHeight))-2) and (((rows) * (buttonHeight))-2) or buttonHeight
    self.actionBars[bar]:SetSize(width, height)
    self.actionBars[bar].FrameMover:SetHeight(height)
    self.actionBars[bar].FrameMover:SetWidth(width)
    local column = (12/rows)
    for r = 1, rows do
        for num = ((r*column)-column+1), (r*column) do
            if self.actionBars[bar]["button"..num] then
                if num == 1 then
                    self.actionBars[bar]["button"..num]:ClearAllPoints()
                    self.actionBars[bar]["button"..num]:SetPoint("TOPLEFT", self.actionBars[bar])
                elseif ((r*column)-column+1) == num then
                    self.actionBars[bar]["button"..num]:ClearAllPoints()
                    self.actionBars[bar]["button"..num]:SetPoint("TOP", self.actionBars[bar]["button"..(num-column)] , "BOTTOM", 0, -4)
                else
                    self.actionBars[bar]["button"..num]:ClearAllPoints()
                    self.actionBars[bar]["button"..num]:SetPoint("LEFT", self.actionBars[bar]["button"..(num-1)], "RIGHT", 4, 0)
                end
            end
        end
    end
end

function MM:ActionBarUnlockFrame()
    self = MM
    for bar = 1, self.db.NumberActionBars do
        if self.actionBars[bar].FrameMover:IsVisible() then
            self.actionBars[bar].FrameMover:Hide()
        else
            self.actionBars[bar].FrameMover:Show()
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

function MM:ActionButtonOnClick(bar, button)
    if button:IsEnabled() == 0 then return end
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID])
    self.activeButtonID = button
    self.spellCastStarted = nil
    --self.barUpdateTimer = self:ScheduleTimer("ActionBarClearButtonCheck", .5)
    self.barUpdateTimer.button = button
    if  infoType == "item" then
        local start = GetItemCooldown(ID)
        if start == 0 and not self:HasItem(ID) and C_VanityCollection.IsCollectionItemOwned(ID) then
           RequestDeliverVanityCollectionItem(VANITY_SPELL_REFERENCE[ID] or ID)
           Timer.After(.2, function() button:SetChecked(false) end)
        else
            self.deleteItem = ID
        end
    elseif infoType == "spell" then
        if not CA_IsSpellKnown(ID) and C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[ID] or ID) then
            RequestDeliverVanityCollectionItem(VANITY_SPELL_REFERENCE[ID] or ID)
            Timer.After(.2, function() button:SetChecked(false) end)
        end
    end

    Timer.After(.5, function() MM:SetButtonTimer(infoType, button, ID) end)
    self:PlaceAction(button, bar)
end

function MM:PlaceAction(button, bar)
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
        if self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID][1] then
            swapInfo = {unpack(self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID])}
        end 
        self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID] = {infoType, ID, bookType}
        ClearCursor()
        Timer.After(.2, function() self:SetAttribute(button, bar) end)
    end
    if swapInfo then
        self:PickupAction(button, swapInfo, bar)
    end
end

function MM:PickupAction(button, swapInfo, bar)
    local infoType, ID,  info = unpack(self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID])
    if swapInfo then
        infoType, ID,  info = unpack(swapInfo)
    else
        Timer.After(.5, function() CooldownFrame_Clear(button.Cooldown) end)
        button.Icon:SetTexture("")
        button.Name:SetText("")
        button.itemID = nil
        button.itemLink = nil
        button:SetAttribute("type", nil)
        SetItemButtonCount(button)
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
            self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID] = {nil, nil}
        end
    end
end

function MM:SetAttribute(button, bar)
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBars[bar].profile][button.ID])
    local name, icon, itemLink, text, start, duration, enable
    if not ID then
        button.Name:SetText()
        button.Icon:SetTexture()
        button.itemID = nil
        button.itemLink = nil
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
    ActionButton_UpdateHotkeys(button)
    button.itemLink = itemLink
    button.itemID = ID
    button.Name:SetText(text)
    button.Icon:SetTexture(icon)
    button:SetAttribute("macro", nil)
    button:SetAttribute(infoType, nil)
    if self.db.SelfCast ~= "none" and infoType ~= "macro" then
        if infoType == "item" then
            if self.db.SelfCast == "always" then
                name = "/use [@player] "..name
            else
                name = "/use [nomod:"..self.db.SelfCast.."] "..name.."; [mod:"..self.db.SelfCast..", @player] "..name
            end
        elseif infoType == "spell" then
            if self.db.SelfCast == "always" then
                name = "/cast [@player] "..name
            else
                name = "/cast [nomod:"..self.db.SelfCast.."] "..name.."; [mod:"..self.db.SelfCast..", @player] "..name
            end
        end
        button:SetAttribute("type", "macro")
        button:SetAttribute("macrotext", name)
    else
        button:SetAttribute("type", infoType)
        button:SetAttribute(infoType, name)
    end

    self:ActionBarBagUpdate()

    if InterfaceOptionsFrame:IsVisible() then
        self.options.NumberOfActionbarButtons.UpdateSlider(self:GetNumberButtons(self:GetSelectedBar()))
        self.options.NumberOfActionbarRows.UpdateSlider(self:GetNumberRows(self:GetSelectedBar()))
    end
end

function MM:SetActionBarProfile()
    for bar = 1, self.db.NumberActionBars do
        for num = 1, 12 do
            if self.actionBars[bar]["button"..num] then
                self:SetAttribute(self.actionBars[bar]["button"..num], bar)
            end
            self:SetActionBarLayout(bar)
        end
    end
end

function MM:ActionBarBagUpdate()
    for bar = 1, self.db.NumberActionBars do
        for num = 1, 12 do
            if self.actionBars[bar]["button"..num] then
                local count = GetItemCount(self.actionBars[bar]["button"..num].itemID)
                if count and count > 0 then
                    SetItemButtonCount(self.actionBars[bar]["button"..num], count)
                else
                    SetItemButtonCount(self.actionBars[bar]["button"..num])
                end
            end
        end
    end
end

function MM:ActionBarBagUpdateTimer()
    self:CancelTimer(self.barUpdateTimer)
    self.barUpdateTimer = self:ScheduleTimer("ActionBarBagUpdate", .1)
end

function MM:ActionBarEvents(event, arg1, arg2)
    if self.activeButtonID and self.activeButtonID:GetChecked() then
        self.activeButtonID:SetChecked(false)
        self.activeButtonID = nil
    end
end

function MM:ActionBarSpellCastStart(event, arg1, arg2)
    self.spellCastStarted = true
end

function MM:ActionBarClearButtonCheck()
    if not self.spellCastStarted then
        self.barUpdateTimer.button:SetChecked(false)
    end
end

function MM:ActionBarItemUsed()

end

function MM:ActionBarUpdateBindings(event, arg1, arg2)
    for _, bar in ipairs(self.actionBars) do
        for buttonNum = 1, 12 do
            ActionButton_UpdateHotkeys(bar["button"..buttonNum])
        end
    end
end

function MM:GetNumberRows(bar)
    self.charDB.actionBars[bar].rows = self.charDB.actionBars[bar].rows or 1
    return self.charDB.actionBars[bar].rows
end

function MM:GetNumberButtons(bar)
    self.charDB.actionBars[bar].numButtons = self.charDB.actionBars[bar].numButtons or 12
    return self.charDB.actionBars[bar].numButtons
end

function MM:GetSelectedBar()
    self.selectedBar = self.selectedBar or 1
    return self.selectedBar
end

function MM:ToggleActionBar()
    for bar = 1, self.db.NumberActionBars do
        if self.charDB.actionBars[bar].show then
            self.actionBars[bar]:Show()
        else
            self.actionBars[bar]:Hide()
        end
    end
end

function MM:InitializeActionBarProfiles()
    if self.db.actionBarProfiles then return end
    self.db.actionBarProfiles = self.db.actionBarProfiles or {}
    for i = 1, 4 do
        self:AddActionBarProfile("Bar"..i)
    end
end

function MM:AddActionBarProfile(profileName)
    if self.db.actionBarProfiles[profileName] then DEFAULT_CHAT_FRAME:AddMessage("A profile with this name already exists") return end
    self.db.actionBarProfiles[profileName] = {}
    for i = 1, 12 do
        tinsert(self.db.actionBarProfiles[profileName], {})
    end
end

function MM:InitializeActionBars()
    self:InitializeActionBarProfiles()
    self:CreateActionBars()
    self:SetActionBarProfile()
    self:ToggleActionBar()
    self:ActionBarBagUpdate()
end