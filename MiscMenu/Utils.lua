local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

function MM:IsRealmbound(bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")
    cTip:SetBagItem(bag, slot)
    cTip:Show()
    for i = 1,cTip:NumLines() do
        local text = _G["cTooltipTextLeft"..i]:GetText()
        if text == "Realm Bound" or text == ITEM_SOULBOUND then
            return true
        end
    end
    cTip:Hide()
    return false
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function MM:HasItem(itemID)
	local item, found, id
	-- scan bags
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag, slot)
			if item then
				found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
				if found and tonumber(id) == itemID then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- deletes item from players inventory if value 2 in the items table is set
function MM:RemoveItem(arg2)
	if not self.db.deleteItem then return end
        if strfind(arg2, (GetItemInfo(self.deleteItem))) then
            local found, bag, slot = self:HasItem(self.deleteItem)
            if found and C_VanityCollection.IsCollectionItemOwned(self.deleteItem) and self:IsRealmbound(bag, slot) then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
            self.deleteItem = nil
        end
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

-- add item or spell to the dropdown menu
function MM:AddEntry(ID, eType)
    if not CA_IsSpellKnown(ID) and not self:HasItem(ID) and not C_VanityCollection.IsCollectionItemOwned(ID) then return end
    local startTime, duration, name, icon

    if eType == "item" then
        name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
        startTime, duration = GetItemCooldown(ID)
    else
        name, _, icon = GetSpellInfo(ID)
        startTime, duration = GetSpellCooldown(ID)
    end

	local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
	local text = name

	if cooldown > 0 then
	text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
	end
	local secure = {
	type1 = eType,
	[eType] = name
	}

    MM.dewdrop:AddLine(
            'text', text,
            'icon', icon,
            'secure', secure,
            'func', function()
                if eType == "item" and not self:HasItem(ID) then
                    RequestDeliverVanityCollectionItem(ID)
                else
                    if eType == "item" and self.db.deleteItem then
                        self.deleteItem = ID
                        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
                    end
                    MM.dewdrop:Close()
                end
            end,
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize
    )
end

function MM:MoveEntry(oldNum, newNum, profile)
    for _, v in ipairs(profile) do
        if newNum >= 1 and newNum <= #profile then
            if v[1] == oldNum then
                v[1] = newNum

            elseif v[1] == newNum then
                v[1] = oldNum
            end
        end
    end
end

-- add item or spell to the dropdown menu
function MM:ChangeEntryOrder(ID, eType, num, profile)
    local startTime, duration, name, icon

    if eType == "item" then
        name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
        startTime, duration = GetItemCooldown(ID)
    else
        name, _, icon = GetSpellInfo(ID)
        startTime, duration = GetSpellCooldown(ID)
    end

	local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
	local text = name

	if cooldown > 0 then
	text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
	end

    MM.dewdrop:AddLine(
            'text', text,
            'icon', icon,
            'func', function() MM:MoveEntry(num, num - 1, profile) end,
            'funcRight', function() MM:MoveEntry(num, num + 1, profile) end,
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize
    )
end

--for a adding a divider to dew drop menus 
function MM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    MM.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

function MM:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function MM:OnEnter(button, show)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(MM:GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("MiscMenu")
        GameTooltip:Show()
    end
end
