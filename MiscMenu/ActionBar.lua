local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"


function MM:CreateActionBar()

    self.actionBar = CreateFrame("FRAME", "MiscMenuActionBarFrame", UIParent )
    self.actionBar:SetMovable(true)
    self.actionBar:EnableMouse(true)
    self.actionBar.FrameMover = CreateFrame("FRAME", "MiscMenuActionBarFrameMover", self.actionBar)
    self.actionBar.FrameMover:SetPoint("CENTER",self.actionBar)
    self.actionBar.FrameMover:EnableMouse(true)
    self.actionBar.FrameMover:RegisterForDrag("LeftButton")
    self.actionBar.FrameMover:SetScript("OnDragStart", function()
        self.actionBar:StartMoving()
    end)
    self.actionBar.FrameMover:SetScript("OnDragStop", function()
        self.actionBar:StopMovingOrSizing()
        self.db.actionBarProfiles[self.charDB.actionBar.profile].FramePos = { self.actionBar:GetPoint() }
        self.db.actionBarProfiles[self.charDB.actionBar.profile].FramePos[2] = "UIParent"
    end)
    self.actionBar.FrameMover:SetFrameStrata("FULLSCREEN")
    self.actionBar.FrameMover.backTexture = self.actionBar.FrameMover:CreateTexture(nil, "BACKGROUND")
    self.actionBar.FrameMover.backTexture:SetTexture(0,1,0,.5)
    self.actionBar.FrameMover.backTexture:SetAllPoints()
    self.actionBar.FrameMover.backTexture:SetPoint("CENTER",self.actionBar.FrameMover)
    self.actionBar.FrameMover:Hide()
    self.charDB.actionBar.profile = self.charDB.actionBar.profile or "default"
    self.db.actionBarProfiles[self.charDB.actionBar.profile].numButtons = self.db.actionBarProfiles[self.charDB.actionBar.profile].numButtons or 12
    local function createButtons(numButtons)
        for i = 1, numButtons do
            if not self.actionBar["button"..i] then 
                self.actionBar["button"..i] = CreateFrame("CheckButton", "$parentButton"..i, self.actionBar , "MiscMenuActionBarButtonTemplate")
                self.actionBar["button"..i].ID = i
                self.actionBar["button"..i]:RegisterForDrag("LeftButton")
                self.actionBar["button"..i]:SetScript("OnReceiveDrag", function() self:PlaceAction(self.actionBar["button"..i]) end)
                self.actionBar["button"..i]:SetScript("OnDragStart", function() self:PickupAction(self.actionBar["button"..i]) end)
                self.actionBar["button"..i]:SetScript("OnMouseDown", function() self:ActionBarOnClick(self.actionBar["button"..i]) end)
                self.actionBar["button"..i]:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
                self.actionBar["button"..i]:SetScript("OnLeave", function() GameTooltip:Hide() end)
                self.actionBar["button"..i].defaultAnchor = true
                self.db.actionBarProfiles[self.charDB.actionBar.profile][i] = self.db.actionBarProfiles[self.charDB.actionBar.profile][i] or {}
            end
        end
    end

    function MM:SetActionBarLayout()
        local rows = self:GetNumberRows()
        local numButtons = self:GetNumberButtons()
        createButtons(numButtons)
        local width, height = ((numButtons / rows) * (self.actionBar.button1:GetWidth() + 4))-2, ((rows) * (self.actionBar.button1:GetHeight() + 4))-2
        self.actionBar:SetSize(width, height)
        self.actionBar.FrameMover:SetSize(width, height)
        local column = (numButtons/rows)
        for r = 1, rows do
            for i = ((r*column)-column+1), (r*column) do
                if i == 1 then
                    self.actionBar["button"..i]:ClearAllPoints()
                    self.actionBar["button"..i]:SetPoint("TOPLEFT", self.actionBar)
                elseif ((r*column)-column+1) == i then
                    self.actionBar["button"..i]:ClearAllPoints()
                    self.actionBar["button"..i]:SetPoint("TOP", self.actionBar["button"..(i-column)] , "BOTTOM", 0, -4)
                else
                    self.actionBar["button"..i]:ClearAllPoints()
                    self.actionBar["button"..i]:SetPoint("LEFT", self.actionBar["button"..(i-1)], "RIGHT", 4, 0)
                end
            end
        end
    end
    self:SetActionBarLayout()
    self:SetFramePos(self.actionBar, self.db.actionBarProfiles[self.charDB.actionBar.profile].FramePos)
end

function MM:ActionBarUnlockFrame()
    self = MM
    if self.actionBar.FrameMover:IsVisible() then
        self.actionBar.FrameMover:Hide()
    else
        self.actionBar.FrameMover:Show()
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

function MM:ActionBarOnClick(button)
    if button:IsEnabled() == 0 then return end
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID])
    if not ID then button:SetChecked(true) end
    self.activeButtonID = button.ID
    if  infoType == "item" then
        local start = GetItemCooldown(ID)
        if start == 0 and not self:HasItem(ID) and C_VanityCollection.IsCollectionItemOwned(ID) then
           RequestDeliverVanityCollectionItem(ID)
           self.actionBar["button"..self.activeButtonID]:SetChecked(true)
           self.activeButtonID = nil
        elseif start > 0 then
            self.actionBar["button"..self.activeButtonID]:SetChecked(true)
        else
            self.deleteItem = ID
        end
    elseif infoType == "spell" then
        if not CA_IsSpellKnown(ID) and C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[ID] or ID) then
            RequestDeliverVanityCollectionItem(VANITY_SPELL_REFERENCE[ID] or ID)
        end
    end
    Timer.After(.5, function() MM:SetButtonTimer(infoType, button, ID) end)
    self:PlaceAction(button)
end

function MM:PlaceAction(button)

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
        end
        if self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID][1] then
            swapInfo = {unpack(self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID])}
        end 
        self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID] = {infoType, ID, bookType}
        ClearCursor()
        Timer.After(.2, function() self:SetAttribute(button) end)
    end
    if swapInfo then
        self:PickupAction(button, swapInfo)
    end

end

function MM:PickupAction(button, swapInfo)
    local infoType, ID,  info = unpack(self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID])
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
                PickupMacro(ID)
            elseif info == "CRITTER" or info == "MOUNT" then
                PickupCompanion(info, self:GetPetIdFromSpellID(ID, info))
            elseif infoType == "spell" then
                PickupSpell(GetSpellInfo(ID))
            elseif infoType == "equipmentset" then
                 PickupEquipmentSet(ID);
            end
            self.actionBarLock = true
        if not swapInfo then
            self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID] = {nil, nil}
        end
    end
end

function MM:SetAttribute(button)
    local infoType, ID = unpack(self.db.actionBarProfiles[self.charDB.actionBar.profile][button.ID])
    local name, icon, itemLink, text, start, duration, enable
    if not ID then return end
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
    button:SetAttribute("type1", infoType)
    button:SetAttribute(infoType, name)
end

function MM:FirstLoad()
    for i, button in ipairs(self.db.actionBarProfiles[self.charDB.actionBar.profile]) do
        if self.actionBar["button"..i] then
            if button[1] == "item" then
                local item = Item:CreateFromID(button[2])
                if button[2] then
                    item:ContinueOnLoad(function()
                        self:SetAttribute(self.actionBar["button"..i])
                    end)
                end
            else
                self:SetAttribute(self.actionBar["button"..i])
            end
        end
    end
end

function MM:ActionBarEvents(event, arg1, arg2)
    if self.activeButtonID then
        self.actionBar["button"..self.activeButtonID]:SetChecked(false)
        self.activeButtonID = nil
    end
end

function MM:GetNumberRows()
   return self.db.actionBarProfiles[self.charDB.actionBar.profile].rows or 12
end

function MM:GetNumberButtons()
    return self.db.actionBarProfiles[self.charDB.actionBar.profile].numButtons or 2
end

function MM:ToggleActionBar()
    if self.db.ShowActionBar then
        self.actionBar:Show()
    else
        self.actionBar:Hide()
    end
end