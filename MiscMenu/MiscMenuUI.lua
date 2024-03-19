local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

function MM:CreateUI()
    self.UI = {}
    --Creates the main interface
    self.UI.button = CreateFrame("Button", "MiscMenuFrame", UIParent)
    self.UI.button:SetSize(70, 70)
    self.UI.button:EnableMouse(true)
    self.UI.button:SetScript("OnDragStart", function() self.UI.button:StartMoving() end)
    self.UI.button:SetScript("OnDragStop", function()
        self.UI.button:StopMovingOrSizing()
        self.db.menuPos = { self.UI.button:GetPoint() }
        self.db.menuPos[2] = "UIParent"
    end)
    self.UI.button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    self.UI.button:SetScript("OnClick", function()  end)
    self.UI.button.icon = self.UI.button:CreateTexture(nil, "ARTWORK")
    self.UI.button.icon:SetSize(55, 55)
    self.UI.button.icon:SetPoint("CENTER", self.UI.button, "CENTER", 0, 0)
    self.UI.button.icon:SetTexture(self.defaultIcon)
    self.UI.button.Text = self.UI.button:CreateFontString()
    self.UI.button.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.UI.button.Text:SetFontObject(GameFontNormal)
    self.UI.button.Text:SetText("|cffffffffMisc\nMenu")
    self.UI.button.Text:SetPoint("CENTER", self.UI.button.icon, "CENTER", 0, 0)
    self.UI.button.Highlight = self.UI.button:CreateTexture(nil, "OVERLAY")
    self.UI.button.Highlight:SetSize(70, 70)
    self.UI.button.Highlight:SetPoint("CENTER", self.UI.button, 0, 0)
    self.UI.button.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    self.UI.button.Highlight:Hide()
    self.UI.button:Hide()
    self.UI.button:SetScript("OnClick", function(button, btnclick)
        if btnclick == "RightButton" then
            if self.unlocked then
                self:UnlockFrame()
            end
        else
            self:DewdropRegister(button, true)
        end
    end)
    self.UI.button:SetScript("OnEnter", function(button)
        if self.unlocked then
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            self:OnEnter(button, true)
            self.UI.button.Highlight:Show()
            self:ToggleMainButton("show")
        end

    end)
    self.UI.button:SetScript("OnLeave", function()
        self.UI.button.Highlight:Hide()
        GameTooltip:Hide()
        self:ToggleMainButton("hide")
    end)

    --Creates the randomPet button
    self.randomPet = CreateFrame("Button", "MiscMenuRandomPet", UIParent, "SecureActionButtonTemplate")
    self.randomPet:SetSize(70, 70)
    self.randomPet:Show()
    self.randomPet:EnableMouse(true)
    self.randomPet:SetScript("OnDragStart", function() self.randomPet:StartMoving() end)
    self.randomPet:SetScript("OnDragStop", function()
        self.randomPet:StopMovingOrSizing()
        self.db.randomPetPos = { self.randomPet:GetPoint() }
        self.db.randomPetPos[2] = "UIParent"
    end)
    self.randomPet.icon = self.randomPet:CreateTexture(nil, "ARTWORK")
    self.randomPet.icon:SetSize(55, 55)
    self.randomPet.icon:SetPoint("CENTER", self.randomPet, "CENTER", 0, 0)
    self.randomPet.Text = self.randomPet:CreateFontString()
    self.randomPet.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.randomPet.Text:SetFontObject(GameFontNormal)
    self.randomPet.Text:SetText("|cffffffffRandom\nPet")
    self.randomPet.Text:SetPoint("CENTER", self.randomPet.icon, "CENTER", 0, 0)
    self.randomPet.Highlight = self.randomPet:CreateTexture(nil, "OVERLAY")
    self.randomPet.Highlight:SetSize(70, 70)
    self.randomPet.Highlight:SetPoint("CENTER", self.randomPet, 0, 0)
    self.randomPet.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    self.randomPet.Highlight:Hide()
    self.randomPet:SetScript("OnMouseDown", function(button, btnclick)
        if btnclick == "RightButton" then
            if self.randomPet.unlocked then
                self:UnlockRandomPet()
            end
        end
    end)
    self.randomPet:SetScript("OnEnter", function(button)
        self.randomPet.Highlight:Show()
        if self.randomPet.unlocked then
            self.randomPet.spell = nil
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            local spell, icon = select(3, GetCompanionInfo("CRITTER", math.random(1, GetNumCompanions("CRITTER"))))
            self.randomPet.spell = GetSpellInfo(spell)
            self.randomPet.icon:SetTexture(icon)
            self.randomPet:SetAttribute("type1", "spell")
            self.randomPet:SetAttribute("spell", self.randomPet.spell)
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Summons Random Pet")
            GameTooltip:Show()
        end

    end)
    self.randomPet:SetScript("OnLeave", function()
        self.randomPet.Highlight:Hide()
        GameTooltip:Hide()
    end)
end

MM:CreateUI()

------------frame functions for Misc Menu random pet button---------------

function MM:SetRandomPetPos()
    if self.db.randomPetPos then
        local pos = self.db.randomPetPos
        self.randomPet:ClearAllPoints()
        self.randomPet:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        self.randomPet:ClearAllPoints()
        self.randomPet:SetPoint("CENTER", UIParent)
    end
end

function MM:ToggleRandomPet(toggle)
    if toggle == "show" then
        self.randomPet.icon:SetTexture(select(4, GetCompanionInfo("CRITTER", math.random(1, GetNumCompanions("CRITTER")))))
        self.randomPet:Show()
    else
        self.randomPet:Hide()
    end
end

-- Used to show highlight as a frame mover
function MM:UnlockRandomPet()
    self = MM
    if self.randomPet.unlocked then
        self.randomPet:SetMovable(true)
        self.randomPet:RegisterForDrag()
        self.randomPet.Highlight:Hide()
        self.randomPet.unlocked = false
        GameTooltip:Hide()
    else
        self.randomPet:SetMovable(false)
        self.randomPet:RegisterForDrag("LeftButton")
        self.randomPet.Highlight:Show()
        self.randomPet.unlocked = true
    end
end

------------frame functions for Misc Menu main button---------------

function MM:SetMenuPos()
    if self.db.menuPos then
        local pos = self.db.menuPos
        self.UI.button:ClearAllPoints()
        self.UI.button:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        self.UI.button:ClearAllPoints()
        self.UI.button:SetPoint("CENTER", UIParent)
    end
end

function MM:ToggleMainButton(toggle)
    if self.db.hideNoMouseOver then
        if toggle == "show" then
            self.UI.button.icon:Show()
            self.UI.button.Text:Show()
        else
            self.UI.button.icon:Hide()
            self.UI.button.Text:Hide()
        end
    end
end

-- Used to show highlight as a frame mover
function MM:UnlockFrame()
    self = MM
    if self.unlocked then
        self.UI.button:SetMovable(false)
        self.UI.button:RegisterForDrag()
        self.UI.button.Highlight:Hide()
        self.unlocked = false
        GameTooltip:Hide()
    else
        self.UI.button:SetMovable(true)
        self.UI.button:RegisterForDrag("LeftButton")
        self.UI.button.Highlight:Show()
        self.unlocked = true
    end
end

-- toggle the main button frame
function MM:ToggleMiscMenuFrame()
    if self.UI.button:IsVisible() then
        self.UI.button:Hide()
    else
        self.UI.button:Show()
    end
end