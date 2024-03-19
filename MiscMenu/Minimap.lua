local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")
local icon = LibStub('LibDBIcon-1.0')

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("MiscMenu", {
    type = 'data source',
    text = "MiscMenu",
    icon = MM.defaultIcon
})

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not MM.db.autoMenu then
        MM:DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
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

function MM:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register('MiscMenu', minimap, self.minimap)
    end
    minimap.icon = self.defaultIcon
end
