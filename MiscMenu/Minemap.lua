local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

local defIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
local icon = LibStub('LibDBIcon-1.0')

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("MiscMenu", {
    type = 'data source',
    text = "MiscMenu",
    icon = defIcon,
  })

local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not MM.db.autoMenu then
        MM:DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function MM:OnEnter(button, show)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("MiscMenu")
        GameTooltip:Show()
    end
end

function minimap.OnEnter(button)
    MM:OnEnter(button)
end

function MM:ToggleMinimap()
    local hide = not self.db.minimap
    self.db.minimap = hide
    if hide then
      icon:Hide('MiscMenu')
    else
      icon:Show('MiscMenu')
    end
end