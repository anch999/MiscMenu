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

local spellList = {
    [406] = "Summon Mystic Altar", -- Felforged Enchanting Altar
	[1903513] = "Summon Mystic Altar", -- Normal Altar
	[2903513] = "Summon Mystic Altar", -- Mechanical Mystic Altar
	[8210192] = "Summon Mystic Altar", -- Build Master's Mystic Enchanting Altar
	[8210195] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Druid)
	[8210196] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Hunter)
	[8210197] = "Summon Mystic Altar", -- Destined Mystic Enchanting Altar
	[8210198] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Paladin)
	[8210199] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Priest)
	[8210200] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Rogue)
	[8210201] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Shaman)
	[8210202] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Warlock)
	[8210203] = "Summon Mystic Altar", -- Mystic Enchating Altar (League 4 - Warrior)
    [1777028] = "Summon Thermal Anvil", -- thermal anvil
    [1904514] = "Summon Sanguine Workbench", -- sanguine workbench vanity
    [1913515] = "Calling the Board", -- Portable call board
    [1913516] = "Calling the Board", -- Portable call board
    [1913517] = "Calling the Board" -- Portable call board
}

function MM:GetItemSpellCastName(itemID)
    if not itemID then return end
    if spellList[itemID] then return spellList[itemID] end
    return self:GetItemInfo(self.deleteItem)
end

-- deletes item from players inventory if value 2 in the items table is set
function MM:RemoveItem(arg2)
	if not self.db.AutoDeleteItems or not self.deleteItem then return end
    local itemCast = self:GetItemSpellCastName(self.deleteItem)
        if itemCast then
            if strfind(arg2, itemCast) then
                local found, bag, slot = self:HasItem(self.deleteItem)
                if found and C_VanityCollection.IsCollectionItemOwned(self.deleteItem) and self:IsRealmbound(bag, slot) then
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                end
                self.deleteItem = nil
            end
        end
end

-- add item or spell to the dropdown menu
function MM:AddEntry(ID, infoType, macroTxt)
    if (infoType ~= "macro" and not CA_IsSpellKnown(ID)) and not self:HasItem(ID) and not C_VanityCollection.IsCollectionItemOwned(ID) and infoType ~= "macro" then return end
    local startTime, duration, name, icon, cooldown

    if infoType == "item" then
        local item = Item:CreateFromID(ID)
        name = item:GetName()
        icon = item:GetIcon()
        startTime, duration = GetItemCooldown(ID)
    elseif infoType == "spell" then
        name, _, icon = GetSpellInfo(ID)
        startTime, duration = GetSpellCooldown(ID)
    elseif macroTxt then
        name = "/reloadui"
    elseif infoType == "macro" then
        name, icon = GetMacroInfo(GetMacroIndexByName(ID))
    end
    if startTime then
	    cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
    end
	local text = name

	if cooldown and cooldown > 0 then
	text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
	end
	local secure = {
	type1 = infoType,
	[macroTxt or infoType] = name
	}

    MM.dewdrop:AddLine(
            'text', text,
            'icon', icon,
            'secure', secure,
            'func', function()
                if infoType == "item" and not self:HasItem(ID) then
                    RequestDeliverVanityCollectionItem(ID)
                else
                    if infoType == "item" and self.db.AutoDeleteItems then
                        self.deleteItem = ID
                    end
                    MM.dewdrop:Close()
                end
            end,
            'textHeight', self.db.TxtSize,
            'textWidth', self.db.TxtSize
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
function MM:ChangeEntryOrder(ID, infoType, num, profile)
    local startTime, duration, name, icon

    if infoType == "item" then
        local item = Item:CreateFromID(ID)
        name = item:GetName()
        icon = item:GetIcon()
        startTime, duration = GetItemCooldown(ID)
    elseif infoType == "spell" then
        name, _, icon = GetSpellInfo(ID)
        startTime, duration = GetSpellCooldown(ID)
    elseif infoType == "macro" then
        name, icon = GetMacroInfo(GetMacroIndexByName(ID))
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
            'textHeight', self.db.TxtSize,
            'textWidth', self.db.TxtSize
    )
end

--for a adding a divider to dew drop menus 
function MM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    MM.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.TxtSize,
        'textWidth', self.db.TxtSize,
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
    if self.db.AutoMenu and not UnitAffectingCombat("player") then
        self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(MM:GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("MiscMenu")
        GameTooltip:Show()
    end
end

function MM:ItemTemplate_OnEnter(button)
    self.shiftKeyDown = false
    if not button.itemLink then return end
    if IsShiftKeyDown() then
        self.shiftKeyDown = true
    end
    if button.defaultAnchor then
        GameTooltip_SetDefaultAnchor(GameTooltip, button)
    else
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT", -13, -50)
    end
    GameTooltip:SetHyperlink(button.itemLink)
    GameTooltip:Show()
end

function MM:ItemTemplate_OnLeave()
    self.shiftKeyDown = false
    GameTooltip:Hide()
end

function MM:SetFramePos(frame, pos)
    if pos and pos[1] then
        frame:ClearAllPoints()
        frame:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent)
    end
end

function MM:GetPetIdFromSpellID(spellID, companionType)
    for i = 1, GetNumCompanions(companionType) do
        if select(3,GetCompanionInfo(companionType, i)) == spellID then
           return i
        end
     end
end

function MM:GetItemInfo(itemID)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID)
	if not itemName then
		local item = GetItemInfoInstant(itemID)
		itemName, itemSubType, itemEquipLoc, itemTexture, itemQuality = item.name, _G["ITEM_SUBCLASS_"..item.classID.."_"..item.subclassID], itemEquipLocConversion[item.inventoryType], item.icon, item.quality
	end
	return itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice
end