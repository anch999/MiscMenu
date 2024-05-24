local MAJOR, MINOR = "SettingsCreator-1.0", 1

if not AceLibrary then error(MAJOR .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR, MINOR) then return end

local SettingsCreator = {}

--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

--[[ DB = Name of the db you want to setup
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
function SettingsCreator:SetupDB(db, defaultList)
    db = db or {}
    for table, v in pairs(defaultList) do
        if not db[table] and db[table] ~= false then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox and _G[v.CheckBox] then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text and _G[v.Text] then
                _G[v.Text]:SetText(db[table])
            end
            if v.ShowFrame and _G[v.Frame] then
                if db[table] then _G[v.Frame]:Show() else _G[v.Frame]:Hide() end
            end
            if v.HideFrame and _G[v.HideFrame] then
                if db[table] then _G[v.HideFrame]:Hide() else _G[v.HideFrame]:Show() end
            end
        end
    end
    return db
end

local function CreateCheckButton(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("CheckButton", addonName..opTable.Name, frame, "UICheckButtonTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name].Lable = options[opTable.Name]:CreateFontString(nil , "BORDER", "GameFontNormal")
    options[opTable.Name].Lable:SetJustifyH("LEFT")
    options[opTable.Name].Lable:SetPoint("LEFT", 30, 0)
    options[opTable.Name].Lable:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
    options[opTable.Name]:SetScript("OnEnter", opTable.OnEnter)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    options[opTable.Name]:SetChecked(db[opTable.Name] or false)
end

local function CreateButton(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Button", addonName..opTable.Name, frame, "OptionsButtonTemplate")
    options[opTable.Name]:SetSize(unpack(opTable.Size))
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name]:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
    options[opTable.Name]:SetScript("OnEnter", opTable.OnEnter)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
end

local function CreateDropDownMenu(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Button", addonName.."Options"..opTable.Name.."Menu", frame, "UIDropDownMenuTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name].Lable = options[opTable.Name]:CreateFontString(nil , "BORDER", "GameFontNormal")
    options[opTable.Name].Lable:SetJustifyH("LEFT")
    options[opTable.Name].Lable:SetPoint("LEFT", options[opTable.Name], 190, 0)
    options[opTable.Name].Lable:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
    options[opTable.Name]:SetScript("OnEnter", opTable.OnEnter)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    options[opTable.Name].Menu = opTable.Menu
end

local function CreateSlider(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Slider", addonName..opTable.Name, frame, "OptionsSliderTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name]:SetSize(unpack(opTable.Size))
    options[opTable.Name]:SetMinMaxValues(opTable.MinMax[1], opTable.MinMax[2])
    _G[options[opTable.Name]:GetName().."Text"]:SetText(opTable.Lable..": ".." ("..round(options[opTable.Name]:GetValue(),2)..")")
    _G[options[opTable.Name]:GetName().."Low"]:SetText(opTable.MinMax[1])
    _G[options[opTable.Name]:GetName().."High"]:SetText(opTable.MinMax[2])
    options[opTable.Name]:SetScript("OnValueChanged", opTable.OnValueChanged)
    options[opTable.Name]:SetScript("OnShow", opTable.OnShow)
    options[opTable.Name]:SetValueStep(opTable.Step)

end

local function CreateTab(options, tabNum, data, tab)
    if tabNum == 1 then return end
	options.frame[tab.Name] = CreateFrame("FRAME", data.AddonName.."OptionsFrame"..tabNum, UIParent, nil)
		local fstring = options.frame[tab.Name]:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText(tab.TitleText)
		fstring:SetPoint("TOPLEFT", 30, -15)
		options.frame[tab.Name].name = tab.Name
		options.frame[tab.Name].parent = data.AddonName
		InterfaceOptions_AddCategory(options.frame[tab.Name])
        return options.frame[tab.Name]
end

function SettingsCreator:CreateOptionsPages(data, db)
    if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	local options = { frame = {} }
		options.frame.panel = CreateFrame("FRAME", data.AddonName.."OptionsFrame", UIParent, nil)
    	local fstring = options.frame.panel:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText(data.TitleText)
		fstring:SetPoint("TOPLEFT", 15, -15)
		options.frame.panel.name = data.AddonName
		InterfaceOptions_AddCategory(options.frame.panel)
        local frame = options.frame.panel
        for tabNum, tab in ipairs(data) do
            frame = CreateTab(options, tabNum, data, tab) or frame
            for coloum, side in pairs(tab) do
                local lastOption
                local point = -10
                if type(side) == "table" then
                    for _, option in pairs(side) do
                        if option.Type == "CheckButton" then
                            point = point -30
                            local setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 380, point}
                            CreateCheckButton(options, db, frame, data.AddonName, setPoint, option)
                        elseif option.Type == "Button" then
                            point = point -35
                            local setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 385, point}
                            CreateButton(options, db, frame, data.AddonName, setPoint, option )
                        elseif option.Type == "Menu" then
                            point = point -35
                            local setPoint = (coloum == "Left") and {"TOPLEFT", 20, point} or (coloum == "Right") and {"TOPLEFT", 368, point}
                            CreateDropDownMenu(options, db, frame, data.AddonName, setPoint, option)
                        elseif option.Type == "Slider" then
                            point = point -50
                            local setPoint = (coloum == "Left") and {"TOPLEFT", 35, point} or (coloum == "Right") and {"TOPLEFT", 385, point}
                            CreateSlider(options, db, frame, data.AddonName, setPoint, option )
                        end
                    end
                end
            end
        end
    return options
end

local mixins = {
	"SetupDB",
	"CreateOptionsPages",
}

SettingsCreator.embeds = SettingsCreator.embeds or {}

function SettingsCreator:Embed(target)
	for _, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- Update embeds
for target, _ in pairs(SettingsCreator.embeds) do
	SettingsCreator:Embed(target)
end

AceLibrary:Register(SettingsCreator, MAJOR, MINOR)