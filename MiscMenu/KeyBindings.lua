local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

for header = 1, 4 do
_G["BINDING_HEADER_MISCMENUB"..header] = "MiscMenu - Action Bar"..header
end

for bar = 1, 4 do
    for button = 1, 12 do
        _G["BINDING_NAME_CLICK MiscMenuActionBarFrame"..bar.."Button"..button..":LeftButton"] = "Button "..button
    end
end