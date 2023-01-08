PinkSkull = {
    name = "PinkSkull",
    version = "1.1.1",
    author = "@Complicative",
}

PinkSkull.Settings = {}

PinkSkull.Default = {
    mainWindowX = 10,
    mainWindowY = 10,
    mainWindowWidth = 480,
    mainWindowHeight = 140,
    hidden = false,
    fontSize = 12,
    nameType = "long",
    hideMax = true,
}

local LAM2 = LibAddonMenu2
local mainFragment = ZO_SimpleSceneFragment:New(PinkSkullMainWindow)

function PinkSkull.FillLabel()
    local physicalResist = GetPlayerStat(STAT_PHYSICAL_RESIST)
    local spellResist = GetPlayerStat(STAT_SPELL_RESIST)
    local _, _, blockMitigation = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_MITIGATION)
    blockMitigation = math.floor(blockMitigation) --Floating point things I guess

    local sName = ""
    if PinkSkull.Settings.nameType == "long" then
        sName = sName .. "Physical Resistance:\n"
        sName = sName .. "Spell Resistance:\n"
        sName = sName .. "Block Mitigation:"
    elseif PinkSkull.Settings.nameType == "short" then
        sName = sName .. "P-Resist.:\n"
        sName = sName .. "S-Resist.:\n"
        sName = sName .. "B-Miti.:"
    elseif PinkSkull.Settings.nameType == "icon" then
        sName = sName ..
            string.format("|t%d:%d:esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds|t\n",
                PinkSkull.Settings.fontSize, PinkSkull.Settings.fontSize)
        sName = sName ..
            string.format("|t%d:%d:/esoui/art/icons/alchemy/crafting_alchemy_trait_increasespellresist.dds|t\n",
                PinkSkull.Settings.fontSize, PinkSkull.Settings.fontSize)
        sName = sName ..
            string.format("|t%d:%d:esoui/art/tutorial/gamepad/gp_lfg_tank.dds|t",
                PinkSkull.Settings.fontSize, PinkSkull.Settings.fontSize)
    end

    PinkSkullMainWindow:GetNamedChild("LabelName"):SetText(sName)

    local sValue = ""
    if physicalResist >= 34000 then sValue = sValue .. "|cFF0000" elseif physicalResist > 33000 then sValue = sValue ..
            "|cFFFF00"
    end
    sValue = sValue .. ZO_CommaDelimitNumber(physicalResist) .. "|r"
    if not PinkSkull.Settings.hideMax then
        sValue = sValue .. "/" .. ZO_CommaDelimitNumber(33000)
    end
    sValue = sValue .. "\n"


    if spellResist >= 34000 then sValue = sValue .. "|cFF0000" elseif spellResist > 33000 then sValue = sValue ..
            "|cFFFF00"
    end
    sValue = sValue .. ZO_CommaDelimitNumber(spellResist) .. "|r"
    if not PinkSkull.Settings.hideMax then
        sValue = sValue .. "/" .. ZO_CommaDelimitNumber(33000)
    end
    sValue = sValue .. "\n"


    if blockMitigation >= 95 then sValue = sValue .. "|cFF0000" elseif blockMitigation > 90 then sValue = sValue ..
            "|cFFFF00"
    end
    sValue = sValue .. blockMitigation .. "|r%"
    if not PinkSkull.Settings.hideMax then
        sValue = sValue .. "/90%"
    end

    PinkSkullMainWindow:GetNamedChild("LabelValue"):SetText(sValue)
end

function PinkSkull.SaveConstraints()
    PinkSkull.Settings.mainWindowX = PinkSkullMainWindow:GetLeft()
    PinkSkull.Settings.mainWindowY = PinkSkullMainWindow:GetTop()
    PinkSkull.Settings.mainWindowWidth = PinkSkullMainWindow:GetWidth()
    PinkSkull.Settings.mainWindowHeight = PinkSkullMainWindow:GetHeight()
end

function PinkSkull.createSettings()
    local panelData = {
        type = "panel",
        name = "PinkSkull",
        author = 'Complicative',
        version = PinkSkull.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("PinkSkullOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Shows Physical and Spell Resistance and Block Mitigation in a small window.\nTurns yellow, if a bit over cap. Red if far over cap! /pinkskull to toggle on or off"
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Font Size",
        getFunc = function() return PinkSkull.Settings.fontSize end,
        setFunc = function(value)
            PinkSkull.Settings.fontSize = value
            PinkSkullMainWindowLabelName:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline", value))
            PinkSkullMainWindowLabelValue:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline", value))
            PinkSkull.FillLabel()
        end,
        min = 12,
        max = 32,
        step = 1
    }
    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Name Type",
        choices = { "long", "short", "icon" },
        getFunc = function() return PinkSkull.Settings.nameType end,
        setFunc = function(value)
            PinkSkull.Settings.nameType = value
            PinkSkull.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Max Values",
        getFunc = function() return PinkSkull.Settings.hideMax end,
        setFunc = function(value)
            PinkSkull.Settings.hideMax = value
            PinkSkull.FillLabel()
        end
    }

    LAM2:RegisterOptionControls("PinkSkullOptions", optionsData)
end

function PinkSkull.SetHidden(hidden)
    if hidden then
        HUD_SCENE:RemoveFragment(mainFragment)
        HUD_UI_SCENE:RemoveFragment(mainFragment)
        SCENE_MANAGER:GetScene("inventory"):RemoveFragment(mainFragment)
    end
    if not hidden then
        HUD_SCENE:AddFragment(mainFragment)
        HUD_UI_SCENE:AddFragment(mainFragment)
        SCENE_MANAGER:GetScene("inventory"):AddFragment(mainFragment)
    end
end

function PinkSkull.OnAddOnLoaded(event, addonName)
    if addonName ~= PinkSkull.name then
        return
    end
    -- SavedSettings
    PinkSkull.Settings = ZO_SavedVars:NewAccountWide("PinkSkullSettings", 1, nil, PinkSkull.Default)

    PinkSkullMainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PinkSkull.Settings.mainWindowX,
        PinkSkull.Settings.mainWindowY)
    PinkSkullMainWindow:SetWidth(PinkSkull.Settings.mainWindowWidth)
    PinkSkullMainWindow:SetHeight(PinkSkull.Settings.mainWindowHeight)
    PinkSkullMainWindowLabelName:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline",
        PinkSkull.Settings.fontSize))
    PinkSkullMainWindowLabelValue:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline",
        PinkSkull.Settings.fontSize))

    PinkSkull.SetHidden(PinkSkull.Settings.hidden)
    PinkSkull.createSettings()
    PinkSkull.FillLabel()
end

EVENT_MANAGER:RegisterForEvent(PinkSkull.name, EVENT_ADD_ON_LOADED, PinkSkull.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(PinkSkull.name, EVENT_EFFECT_CHANGED, PinkSkull.FillLabel)
EVENT_MANAGER:RegisterForEvent(PinkSkull.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PinkSkull.FillLabel)
EVENT_MANAGER:AddFilterForEvent(PinkSkull.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

SLASH_COMMANDS["/pinkskull"] = function()
    PinkSkull.Settings.hidden = not PinkSkull.Settings.hidden
    PinkSkull.SetHidden(PinkSkull.Settings.hidden)
end
