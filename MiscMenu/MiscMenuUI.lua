local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")
local CYAN =  "|cff00ffff"
local LIMEGREEN = "|cFF32CD32"
--------------- Creates the main misc menu standalone button ---------------

function MM:InitializeStandaloneButton()
    self.standaloneButton = CreateFrame("Button", "MiscMenuStandaloneButton", UIParent)
    self.standaloneButton:SetSize(70, 70)
    self.standaloneButton:EnableMouse(true)
    self.standaloneButton:SetScript("OnDragStart", function() self.standaloneButton:StartMoving() end)
    self.standaloneButton:SetScript("OnDragStop", function()
        self.standaloneButton:StopMovingOrSizing()
        self.charDB.menuSettings.menuPos = { self.standaloneButton:GetPoint() }
        self.charDB.menuSettings.menuPos[2] = "UIParent"
    end)
    self.standaloneButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    self.standaloneButton.icon = self.standaloneButton:CreateTexture(nil, "ARTWORK")
    self.standaloneButton.icon:SetSize(55, 55)
    self.standaloneButton.icon:SetPoint("CENTER", self.standaloneButton, "CENTER", 0, 0)
    self.standaloneButton.icon:SetTexture(self.defaultIcon)
    self.standaloneButton.Text = self.standaloneButton:CreateFontString()
    self.standaloneButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.standaloneButton.Text:SetFontObject(GameFontNormal)
    self.standaloneButton.Text:SetText("|cffffffffMisc\nMenu")
    self.standaloneButton.Text:SetPoint("CENTER", self.standaloneButton.icon, "CENTER", 0, 0)
    self.standaloneButton.Highlight = self.standaloneButton:CreateTexture(nil, "OVERLAY")
    self.standaloneButton.Highlight:SetSize(70, 70)
    self.standaloneButton.Highlight:SetPoint("CENTER", self.standaloneButton, 0, 0)
    self.standaloneButton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    self.standaloneButton.Highlight:Hide()
    self.standaloneButton:Hide()
    self.standaloneButton:SetScript("OnClick", function(button, btnclick)
        if btnclick == "RightButton" then
            if self.unlocked then
                self:UnlockFrame()
            end
        elseif not self.unlocked then
            self:DewdropRegister(button, true)
        end
    end)
    self.standaloneButton:SetScript("OnEnter", function(button)
        if self.unlocked then
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            self:OnEnter(button, true)
            self.standaloneButton.Highlight:Show()
        end
        if self.db.EnableAutoHide then
            self.standaloneButton:SetAlpha(10)
        end
    end)
    self.standaloneButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if not self.unlocked then
            self.standaloneButton.Highlight:Hide()
            if self.db.EnableAutoHide then
                self.standaloneButton:SetAlpha(0)
            end
        end
    end)
    self:SetFramePos(self.standaloneButton, self.charDB.menuSettings.menuPos)
    self.standaloneButton:SetScale(self.db.buttonScale or 1)
    if not self.db.HideMenu then
        self.standaloneButton:Show()
    end
    self:SetFrameAlpha()
end

--------------- Frame functions for misc menu standalone button---------------

function MM:SetFrameAlpha()
    if self.db.EnableAutoHide then
        self.standaloneButton:SetAlpha(0)
    else
        self.standaloneButton:SetAlpha(10)
    end
end

-- Used to show highlight as a frame mover
function MM:UnlockFrame()
    self = MM
    if self.unlocked then
        self.standaloneButton:SetMovable(false)
        self.standaloneButton:RegisterForDrag()
        self.standaloneButton.Highlight:Hide()
        self.unlocked = false
        GameTooltip:Hide()
        if self.db.EnableAutoHide then
            self.standaloneButton:SetAlpha(0)
        end
    else
        self.standaloneButton:SetMovable(true)
        self.standaloneButton:RegisterForDrag("LeftButton")
        self.standaloneButton.Highlight:Show()
        self.unlocked = true
        if self.db.EnableAutoHide then
            self.standaloneButton:SetAlpha(10)
        end
    end
end

-- toggle the main button frame
function MM:ToggleStandaloneButton()
    if self.standaloneButton:IsVisible() then
        self.standaloneButton:Hide()
    else
        self.standaloneButton:Show()
    end
end

local worldFrameHook
--sets up the drop down menu for any menus
function MM:DewdropRegister(button, showUnlock, profile)
    profile = profile or self.charDB.menuSettings.currentProfile
    if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
    self.dewdrop:Register(button,
        'point', function(parent)
            local point1, _, point2 = self:GetTipAnchor(button)
            return point1, point2
        end,
        'children', function(level, value)
            self.dewdrop:AddLine(
                'text', "|cffffff00MiscMenu",
                'textHeight', self.db.TxtSize,
                'textWidth', self.db.TxtSize,
                'isTitle', true,
                'notCheckable', true
            )
            local setProfile = self.db.menuProfiles[profile]
            local sortProfile = {}
            if setProfile then
                for _, v in ipairs(setProfile) do
                    sortProfile[v[1]] = {v[2], v[3]}
                end
                for i = 1, #setProfile do
                    if self.reorderMenu then
                        self:ChangeEntryOrder(sortProfile[i][1], sortProfile[i][2], i, setProfile)
                    else
                        self:AddEntry(sortProfile[i][1], sortProfile[i][2])
                    end
                end
            end
            self:AddDividerLine(35)
            local text = self.reorderMenu and LIMEGREEN.."Reorder" or "Reorder"
            self.dewdrop:AddLine(
                    'text', text,
                    'textHeight', self.db.TxtSize,
                    'textWidth', self.db.TxtSize,
                    'func', function() self.reorderMenu = not self.reorderMenu end,
                    'notCheckable', true
                )
            self.dewdrop:AddLine(
                    'text', "Unlock Action Bar Frame",
                    'textHeight', self.db.TxtSize,
                    'textWidth', self.db.TxtSize,
                    'func', self.ActionBarUnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            if showUnlock then
                self.dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', self.db.TxtSize,
                    'textWidth', self.db.TxtSize,
                    'func', self.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            self.dewdrop:AddLine(
				'text', "Options",
                'textHeight', self.db.TxtSize,
                'textWidth', self.db.TxtSize,
				'func', self.OptionsToggle,
                'funcRight', function() self:OptionsToggle(true) end,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            self.dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
                'textHeight', self.db.TxtSize,
                'textWidth', self.db.TxtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    self.dewdrop:Open(button)
    
    if not worldFrameHook then
        WorldFrame:HookScript("OnEnter", function()
            if self.dewdrop:IsOpen(button) then
                self.dewdrop:Close()
            end
        end)
        worldFrameHook = true
    end

    GameTooltip:Hide()
end