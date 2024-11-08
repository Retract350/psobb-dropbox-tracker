local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_unitxt = require("solylib.unitxt")
local lib_items = require("solylib.items.items")
local lib_menu = require("solylib.menu")
local lib_items_list = require("solylib.items.items_list")
local lib_items_cfg = require("solylib.items.items_configuration")
local clairesDealLoaded, lib_claires_deal = pcall(require, "solylib.items.claires_deal")
local cfg = require("Dropbox Tracker.configuration")
local optionsLoaded, options = pcall(require, "Dropbox Tracker.options")

local optionsFileName = "addons/Dropbox Tracker/options.lua"
local ConfigurationWindow

local origPackagePath = package.path
package.path = './addons/Dropbox Tracker/lua-xtype/src/?.lua;' .. package.path
package.path = './addons/Dropbox Tracker/MGL/src/?.lua;' .. package.path
local xtype = require("xtype")
local mgl = require("MGL")
package.path = origPackagePath

local function SetDefaultValue(Table, Index, Value)
    Table[Index] = lib_helpers.NotNilOrDefault(Table[Index], Value)
end
local function SetValue(Table, Index, Value)
    Table[Index] = Value
end
local function convertColorToInt(Alpha,R,G,B)
    return bit.lshift(Alpha, 24) +
    bit.lshift(R, 16) +
    bit.lshift(G, 8) +
    bit.lshift(B, 0)
end

local function LoadOptions()
    if options == nil or type(options) ~= "table" then
        options = {}
    end
    -- If options loaded, make sure we have all those we need
    SetDefaultValue( options, "configurationEnableWindow", true )
    SetDefaultValue( options, "enable", true )
    SetDefaultValue( options, "ignoreMeseta", false )
    SetDefaultValue( options, "maxNumTrackers", 100 )
    SetDefaultValue( options, "numTrackers", 25 )
    SetDefaultValue( options, "updateThrottle", 0 )
    SetDefaultValue( options, "server", 1 )

    SetDefaultValue( options, "customScreenResEnabled", false )
    SetDefaultValue( options, "customScreenResX", lib_helpers.GetResolutionWidth() )
    SetDefaultValue( options, "customScreenResY", lib_helpers.GetResolutionHeight() )
    SetDefaultValue( options, "customFoVEnabled", false )
    SetDefaultValue( options, "customFoV0", 86 )
    SetDefaultValue( options, "customFoV1", 87 )
    SetDefaultValue( options, "customFoV2", 88 )
    SetDefaultValue( options, "customFoV3", 89 )
    SetDefaultValue( options, "customFoV4", 90 )

    for i=1, 1 do
        local trkIdx = "tracker" .. i
        if options[trkIdx] == nil or type(options[trkIdx]) ~= "table" then
            options[trkIdx] = {}
        end
        SetDefaultValue( options[trkIdx], "EnableWindow", true )
        SetDefaultValue( options[trkIdx], "HideWhenMenu", true )
        SetDefaultValue( options[trkIdx], "HideWhenSymbolChat", true )
        SetDefaultValue( options[trkIdx], "HideWhenMenuUnavailable", true )
        SetDefaultValue( options[trkIdx], "changed", true )
        SetDefaultValue( options[trkIdx], "boxOffsetX", 0 )
        SetDefaultValue( options[trkIdx], "boxOffsetY", 0 )
        SetDefaultValue( options[trkIdx], "boxSizeX", 40 )
        SetDefaultValue( options[trkIdx], "boxSizeY", 40 )
        SetDefaultValue( options[trkIdx], "W", 271 )
        SetDefaultValue( options[trkIdx], "H", 91 )
        SetDefaultValue( options[trkIdx], "AlwaysAutoResize", true )
        SetDefaultValue( options[trkIdx], "customFontScaleEnabled", false )
        SetDefaultValue( options[trkIdx], "fontScale", 1.4 )
        SetDefaultValue( options[trkIdx], "TransparentWindow", false )
        SetDefaultValue( options[trkIdx], "customTrackerColorEnable", true )
        SetDefaultValue( options[trkIdx], "customTrackerColorMarker", 0xFFFF9900 )
        SetDefaultValue( options[trkIdx], "customTrackerColorBackground", 0x00CCCCCC )
        SetDefaultValue( options[trkIdx], "customTrackerColorWindow", 0x00000000 )

        SetDefaultValue( options[trkIdx], "showNameOverride", false )
        SetDefaultValue( options[trkIdx], "showNameClosestItemsNum", 5 )
        SetDefaultValue( options[trkIdx], "showNameClosestDist", 130 )
        SetDefaultValue( options[trkIdx], "clampItemView", true )
        SetDefaultValue( options[trkIdx], "ignoreItemMaxDist", 450 )

        if options[trkIdx].category == nil or type(options[trkIdx].category) ~= "table" then
            options[trkIdx].category = {}
        end

        local categories = {
            "LowHitCommonWeapon",
            "HighHitCommonWeapon",
            "CommonArmor",
            "MaxSocketCommonArmor",
            "CommonBarrier",
            "CommonUnit",
            "CommonTech",
            "Meseta",
            "RareWeapon",
            "ESWeapon",
            "RareArmor",
            "RareBarrier",
            "RareUnit",
            "RareMag",
            "RareConsumables",
            "TechReverser",
            "TechRyuker",
            "TechMegid",
            "TechGrants",
            "TechAnti5",
            "TechAnti7",
            "TechSupport15",
            "TechSupport20",
            "TechSupportHigh",
            "TechAttack15",
            "TechAttack20",
            "TechAttackHigh",
            "Monomate",
            "Dimate",
            "Trimate",
            "Monofluid",
            "Difluid",
            "Trifluid",
            "SolAtomizer",
            "MoonAtomizer",
            "StarAtomizer",
            "Antidote",
            "Antiparalysis",
            "TrapVision",
            "Telepipe",
            "ScapeDoll",
            "Monogrinder",
            "Digrinder",
            "Trigrinder",
            "HPMat",
            "TPMat",
            "PowerMat",
            "LuckMat",
            "MindMat",
            "EvadeMat",
            "DefenseMat",
            "ClairesDeal",
        }
        for _,cate in pairs(categories) do
            if options[trkIdx][cate] == nil or type(options[trkIdx][cate]) ~= "table" then
                options[trkIdx][cate] = {}
            end
        end

        SetDefaultValue(options[trkIdx]["LowHitCommonWeapon"], "enabled", false)
        SetDefaultValue(options[trkIdx]["CommonArmor"], "enabled", false)
        SetDefaultValue(options[trkIdx]["CommonBarrier"], "enabled", false)
        SetDefaultValue(options[trkIdx]["CommonUnit"], "enabled", false)
        SetDefaultValue(options[trkIdx]["CommonTech"], "enabled", false)

        local cate = "HighHitCommonWeapon"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "HitMin", 40)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeAtrributes", true)
        SetDefaultValue(options[trkIdx][cate], "includeHit", true)
        SetDefaultValue(options[trkIdx][cate], "includeSpecial", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)

        cate = "MaxSocketCommonArmor"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeStats", true)
        SetDefaultValue(options[trkIdx][cate], "includeSlots", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)

        cate = "Meseta"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "MinAmount", 650)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -795092)
        
        cate = "RareWeapon"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeAtrributes", true)
        SetDefaultValue(options[trkIdx][cate], "includeHit", true)
        SetDefaultValue(options[trkIdx][cate], "includeSpecial", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -62966)
        
        cate = "ESWeapon"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeAtrributes", true)
        SetDefaultValue(options[trkIdx][cate], "includeHit", true)
        SetDefaultValue(options[trkIdx][cate], "includeSpecial", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 6)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -62966)
        
        cate = "RareArmor"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeStats", true)
        SetDefaultValue(options[trkIdx][cate], "includeSlots", true)
        SetDefaultValue(options[trkIdx][cate], "highlightMaxStats", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -65466)
        
        cate = "RareBarrier"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "includeStats", true)
        SetDefaultValue(options[trkIdx][cate], "highlightMaxStats", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -3787520)
        
        cate = "RareUnit"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -52222)

        cate = "RareMag"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -49153)

        cate = "RareConsumables"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -62966)
        
        cate = "TechReverser"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TechRyuker"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)

        cate = "TechMegid"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "MinLvl", 27)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 4)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -8243766)
        
        cate = "TechGrants"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "MinLvl", 27)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 4)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -4422)

        cate = "TechAnti5"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -3252225)
        cate = "TechAnti7"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -5142273)

        cate = "TechSupport15"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TechSupport20"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TechSupportHigh"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "MinLvl", 29)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)

        cate = "TechAttack15"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TechAttack20"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TechAttackHigh"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "MinLvl", 28)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 4)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)


        cate = "Monomate"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -16747676)
        cate = "Dimate"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -16737931)
        cate = "Trimate"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -9778804)

        cate = "Monofluid"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -16742997)
        cate = "Difluid"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -16729931)
        cate = "Trifluid"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -10038789)

        cate = "SolAtomizer"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "MoonAtomizer"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -2701629)
        cate = "StarAtomizer"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "Antidote"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "Antiparalysis"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "TrapVision"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
        cate = "Telepipe"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowWhenOneOrMoreInInv", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)

        cate = "ScapeDoll"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", false)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -43629)

        cate = "Monogrinder"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -10997750)
        cate = "Digrinder"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -8040909)
        cate = "Trigrinder"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -5674936)

        cate = "HPMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -13107376)
        cate = "TPMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 4)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -13469475)

        cate = "PowerMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -48063)
        cate = "LuckMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 3)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -2506)

        cate = "MindMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -14973512)

        cate = "EvadeMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -4776780)
        cate = "DefenseMat"
        SetDefaultValue(options[trkIdx][cate], "enabled", true)
        SetDefaultValue(options[trkIdx][cate], "onlyShowIfInvNotMaxStack", true)
        SetDefaultValue(options[trkIdx][cate], "showName", true)
        SetDefaultValue(options[trkIdx][cate], "showBox", true)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 2)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -1345495)

        cate = "ClairesDeal"
        SetDefaultValue(options[trkIdx][cate], "enabled", false)
        SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
        SetDefaultValue(options[trkIdx][cate], "useCustomColor", true)
        SetDefaultValue(options[trkIdx][cate], "customBorderColor", -38656)

        -- fill in any missing values
        for _,cate in pairs(categories) do
            SetDefaultValue(options[trkIdx][cate], "enabled", false)
            SetDefaultValue(options[trkIdx][cate], "showName", true)
            SetDefaultValue(options[trkIdx][cate], "showBox", true)
            SetDefaultValue(options[trkIdx][cate], "borderSize", 1)
            SetDefaultValue(options[trkIdx][cate], "useCustomColor", false)
            SetDefaultValue(options[trkIdx][cate], "customBorderColor", -38656)
        end

    end
end
LoadOptions()

-- Append server specific items
lib_items_list.AddServerItems(options.server)

local optionsStringBuilder = ""
local function BuildOptionsString(table, depth)
    local tabSpacing = 4
    local maxDepth = 5
    
    if not depth or depth == nil then
        depth = 0
    end
    local spaces = string.rep(" ", tabSpacing + tabSpacing * depth)
    
    --begin statement
    if depth < 1 then
        optionsStringBuilder = "return\n{\n"
    end
    --iterate over table
    for key, value in pairs(table) do
        
        local type = type(value)
        if type == "string" then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = \"%s\",\n", key, tostring(value))
        
        elseif type == "number" then
            -- check is float/double
            if value % 1 == 0 then
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %i,\n", key, tostring(value))
            else
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %f,\n", key, tostring(value))
            end
            
        elseif type == "boolean" or value == nil then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %s,\n", key, tostring(value))
            
        --recurse
        elseif type == "table" then
            if maxDepth > 5 then
                return
            end
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = {\n", key)
            BuildOptionsString(value, depth + 1)
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("},\n", key)
        end
        
    end
    --finalize statement
    if depth < 1 then
        optionsStringBuilder = optionsStringBuilder .. "}\n"
    end
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        BuildOptionsString(options)
        
        io.output(file)
        io.write(optionsStringBuilder)
        io.close(file)
    end
end

local playerSelfAddr = nil
local playerSelfCoords = nil
local playerSelfDirs = nil
local playerSelfNormDir = nil
local pCoord = nil
local cameraCoords = nil
local cameraDirs = nil
local cameraNormDirVec2 = nil
local cameraNormDirVec3 = nil
local item_graph_data = {}
local toolLookupTable = {}
local invToolLookupTable = {}
local resolutionWidth = {}
local resolutionHeight = {}
local trackerBox = {}
local screenFov = nil
local aspectRatio = nil
local eyeWorld    = nil
local eyeDir      = nil
local determinantScr = nil
local cameraZoom = nil
local lastCameraZoom = nil
local trackerWindowLookup = {}

local _CameraPosX      = 0x00A48780
local _CameraPosY      = 0x00A48784
local _CameraPosZ      = 0x00A48788
local _CameraDirX      = 0x00A4878C
local _CameraDirY      = 0x00A48790
local _CameraDirZ      = 0x00A48794
local _CameraZoomLevel = 0x009ACEDC

local function updateToolLookupTable()
    for i=1, 1 do
        local trkIdx = "tracker" .. i
        toolLookupTable[trkIdx] = {
            [0x00] = {
                [0x00] = {options[trkIdx]["Monomate"], "Monomate"},
                [0x01] = {options[trkIdx]["Dimate"], "Dimate"},
                [0x02] = {options[trkIdx]["Trimate"], "Trimate"},
            },
            [0x01] = {
                [0x00] = {options[trkIdx]["Monofluid"], "Monofluid"},
                [0x01] = {options[trkIdx]["Difluid"], "Difluid"},
                [0x02] = {options[trkIdx]["Trifluid"], "Trifluid"},
            },
            [0x03] = { [0x00] = {options[trkIdx]["SolAtomizer"], "SolAtomizer"} },
            [0x04] = { [0x00] = {options[trkIdx]["MoonAtomizer"], "MoonAtomizer"} },
            [0x05] = { [0x00] = {options[trkIdx]["StarAtomizer"], "StarAtomizer"} },
            [0x06] = {
                [0x00] = {options[trkIdx]["Antidote"], "Antidote"},
                [0x01] = {options[trkIdx]["Antiparalysis"], "Antiparalysis"},
            },
            [0x07] = { [0x00] = {options[trkIdx]["Telepipe"], "Telepipe"} },
            [0x08] = { [0x00] = {options[trkIdx]["TrapVision"], "TrapVision"} },
            [0x09] = { [0x00] = {options[trkIdx]["ScapeDoll"], "ScapeDoll"} },
            [0x0A] = {
                [0x00] = {options[trkIdx]["Monogrinder"], "Monogrinder"},
                [0x01] = {options[trkIdx]["Digrinder"], "Digrinder"},
                [0x02] = {options[trkIdx]["Trigrinder"], "Trigrinder"},
            },
            [0x0B] = {
                [0x00] = {options[trkIdx]["PowerMat"], "PowerMat"},
                [0x01] = {options[trkIdx]["MindMat"], "MindMat"},
                [0x02] = {options[trkIdx]["EvadeMat"], "EvadeMat"},
                [0x03] = {options[trkIdx]["HPMat"], "HPMat"},
                [0x04] = {options[trkIdx]["TPMat"], "TPMat"},
                [0x05] = {options[trkIdx]["DefenseMat"], "DefenseMat"},
                [0x06] = {options[trkIdx]["LuckMat"], "LuckMat"},
            },
        }
    end
end
updateToolLookupTable()

local function newInvToolLookupTable()
    invToolLookupTable = {
        [0x00] = {
            [0x00] = {0, 10, "Monomate"},
            [0x01] = {0, 10, "Dimate"},
            [0x02] = {0, 10, "Trimate"},
        },
        [0x01] = {
            [0x00] = {0, 10, "Monofluid"},
            [0x01] = {0, 10, "Difluid"},
            [0x02] = {0, 10, "Trifluid"},
        },
        [0x03] = { [0x00] = {0, 10, "SolAtomizer"} },
        [0x04] = { [0x00] = {0, 10, "MoonAtomizer"} },
        [0x05] = { [0x00] = {0, 10, "StarAtomizer"} },
        [0x06] = {
            [0x00] = {0, 10, "Antidote"},
            [0x01] = {0, 10, "Antiparalysis"},
        },
        [0x07] = { [0x00] = {0, 10, "Telepipe"} },
        [0x08] = { [0x00] = {0, 10, "TrapVision"} },
        [0x09] = { [0x00] = {0, 1, "ScapeDoll"} },
        [0x0A] = {
            [0x00] = {0, 99, "Monogrinder"},
            [0x01] = {0, 99, "Digrinder"},
            [0x02] = {0, 99, "Trigrinder"},
        },
        [0x0B] = {
            [0x00] = {0, 99, "PowerMat"},
            [0x01] = {0, 99, "MindMat"},
            [0x02] = {0, 99, "EvadeMat"},
            [0x03] = {0, 99, "HPMat"},
            [0x04] = {0, 99, "TPMat"},
            [0x05] = {0, 99, "DefenseMat"},
            [0x06] = {0, 99, "LuckMat"},
        },
    }
end

local function GetPlayerCoordinates(player)
    local x = 0
    local y = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x38)
        y = pso.read_f32(player + 0x3C)
        z = pso.read_f32(player + 0x40)
    end

    return
    {
        x = x,
        y = y,
        z = z,
    }
end

local function GetPlayerDirection(player)
    local x = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x410)
        z = pso.read_f32(player + 0x418)
    end
    
    return
    {
        x = x,
        z = z,
    }
end

local function getCameraZoom()
    return pso.read_u32(_CameraZoomLevel)
end
local function getCameraCoordinates()
    return
    {
        x = pso.read_f32(_CameraPosX),
        y = pso.read_f32(_CameraPosY),
        z = pso.read_f32(_CameraPosZ),
    }
end
local function getCameraDirection()
    return
    {
        x = pso.read_f32(_CameraDirX), -- -1 to 1 in x direction (west to east)
        y = pso.read_f32(_CameraDirY), -- pitch
        z = pso.read_f32(_CameraDirZ), -- -1 to 1 in z direction (north to south)
    }
end

local function clampVal(clamp, min, max)
    return clamp < min and min or clamp > max and max or clamp
end

local function Norm(Val,Min,Max)
    return (Val - Min)/(Max - Min)
end
local function Lerp(Norm,Min,Max)
    return (Max - Min) * Norm + Min
end

local function shiftHexColor(color)
    return
    {
        bit.band(bit.rshift(color, 24), 0xFF),
        bit.band(bit.rshift(color, 16), 0xFF),
        bit.band(bit.rshift(color, 8), 0xFF),
        bit.band(color, 0xFF)
    }
end

local function computePixelCoordinates(pWorld, eyeWorld, eyeDir, determinant)

    local pRaster = mgl.vec2(0)
    local vis = -1

    local vDir = pWorld - eyeWorld
    vDir = mgl.normalize(vDir)
    local fdp = mgl.dot( eyeDir, vDir )

    --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
    --or we will get a divide by zero error when calculating vProj below.
    if fdp == 0 then
        return pRaster,-1
    end

    --Using linear projection, project this vector onto the plane of the slice
    local ddfp = determinant/fdp
    local vProj = mgl.vec3( ddfp,ddfp,ddfp ) * vDir
    --get the up component from the forward vector assuming world yaxis (vertical axis 0,+1,0) is up
    --https://stackoverflow.com/questions/1171849/finding-quaternion-representing-the-rotation-from-one-vector-to-another/1171995#1171995
    local eyeRight = mgl.cross( eyeDir, mgl.vec3(0,1,0) )
    local eyeLeft  = mgl.cross( eyeRight, eyeDir )

    if fdp > 0.0000001 then
        vis = 1
    end
    pRaster.x =   mgl.dot(eyeRight,vProj) --0.5 * iScreenW + mgl.dot(eyeRight,vProj)
    pRaster.y = - mgl.dot(eyeLeft,vProj) --0.5 * iScreenH - mgl.dot(eyeLeft,vProj)

    return pRaster, vis
end

local function ItemAppendPosition(item)
    if not item then return end
    item.posx = pso.read_f32(item.address + 0x38)
    item.posy = pso.read_f32(item.address + 0x3C) -- vertical axis
    item.posz = pso.read_f32(item.address + 0x40)
    item.pos3 = mgl.vec3(item.posx,item.posy,item.posz)
end

local function ItemAppendPlayerDistance(item)
    if not item then return end
    item.curPlayerDistance = mgl.length(item.pos3 - pCoord)
end

local function ItemAppendScreenPos(item)

    local pRaster,visible = computePixelCoordinates(item.pos3, eyeWorld, eyeDir, determinantScr)
    
    item.screenX = pRaster.x
    item.screenY = pRaster.y
    item.screenVisDirection = visible
end

local function ItemAppendWindow(item)
    if not item then return end
    if not item.windowName then
        if item.id then
            item.windowName = item.name .. "##" .. item.id
        elseif item.index then
            item.windowName = item.name .. "##" .. item.index
        else
            item.windowName = item.name .. "##" .. math.random(0,math.maxinteger)
        end
    end
end

local function ItemAppendVisibilityData(cate,item,trkIdx)
    if not item then return end

    if not item.screenShouldNotShow then
        if not cate.enabled or (not cate.showName and not cate.showBox) then
            item.screenShow =  false
            item.screenX = nil
            item.screenY = nil
            return
        end
    end

    -- ignore if item is too far away
    ItemAppendPosition(item)
    ItemAppendPlayerDistance(item)
    if options[trkIdx].ignoreItemMaxDist > 0 then
        if item.curPlayerDistance > options[trkIdx].ignoreItemMaxDist then
            item.screenShow = false
            item.screenX = nil
            item.screenY = nil
            return
        end
    end
    
    -- get x,y position on screen where item is
    ItemAppendScreenPos(item)
    if options[trkIdx].clampItemView then
        if item.screenVisDirection < 0 then
            local tempVec2 = mgl.normalize( mgl.vec2(-item.screenX,-item.screenY) ) * resolutionHeight.clampRescale
            item.screenX = tempVec2.x
            item.screenY = tempVec2.y
        else
            if not (item.screenX > -resolutionHeight.clampRescale and item.screenX < resolutionHeight.clampRescale and
                    item.screenY > -resolutionWidth.clampRescale  and item.screenY < resolutionWidth.clampRescale)
            then
                local tempVec2 = mgl.normalize( mgl.vec2(item.screenX, item.screenY) ) * resolutionHeight.clampRescale
                item.screenX = tempVec2.x
                item.screenY = tempVec2.y
            end
        end
        item.screenShow = true
    else
        if item.screenVisDirection < 0 then
            item.screenShow = false
        else
            item.screenShow = true
        end
    end

    if not item.screenShow then return end

    ItemAppendWindow(item)
    item.cate = cate
end

local function AddWeaponAtrributes(item,showAtribs,showHit)
    local colorGrey = {1.0, 0.4706, 0.4706, 0.4706}
    local wNameCount = 0
    local attribs = 0
    local hitItr = 5
    local attribStart = 1

    if item.wName and type(options) == "table" then
        wNameCount = table.getn(item.wName)
    else
        item.wName = {}
    end

    if showAtribs then
        table.insert(item.wName, { " [", nil })
        table.insert(item.wName, { }) -- native
        table.insert(item.wName, { "/", nil })
        table.insert(item.wName, { }) -- beast
        table.insert(item.wName, { "/", nil })
        table.insert(item.wName, { }) -- machine
        table.insert(item.wName, { "/", nil })
        table.insert(item.wName, { }) -- dark
        if showHit then
            attribs = 5
            table.insert(item.wName, { "|", nil })
            table.insert(item.wName, { }) -- hit
        else
            attribs = 4
        end
        table.insert(item.wName, { "]", nil })
    else
        if showHit then
            attribs = 1
            hitItr = 1
            attribStart = 5
            table.insert(item.wName, { " [", nil })
            table.insert(item.wName, { }) -- hit
            table.insert(item.wName, { "]", nil })
        end
    end

    for i=1, attribs, 1 do
        local attribIdx = i+attribStart
        if item.weapon.stats[attribIdx] > 0 then
            if i == hitItr then
                local clr, pL
                if item.weapon.stats[attribIdx] < 60 then
                    pL = item.weapon.stats[attribIdx] / 60
                    clr = { 1.0, Lerp(pL, 0, 1.0), 1.0, 0.0 }
                else
                    pL = (item.weapon.stats[attribIdx] - 60) / 40
                    clr = { 1.0, 1.0, Lerp(pL, 1.0, 0), 0.0 }
                end
                item.wName[i*2+wNameCount] = { item.weapon.stats[attribIdx],clr }
            else
                item.wName[i*2+wNameCount] = { item.weapon.stats[attribIdx], nil }
            end
        elseif item.weapon.stats[i+1] == 0 then
            item.wName[i*2+wNameCount] = { item.weapon.stats[attribIdx], colorGrey }
        else
            item.wName[i*2+wNameCount] = { item.weapon.stats[attribIdx], colorGrey }
        end
    end
end
local function AddWeaponSpecial(item,showSpecial)
    if not item.wName or type(options) ~= "table" then
        item.wName = {}
    end

    if showSpecial then
        local hasSpecial = false
        local rankText, clr
        if item.weapon.isSRank and item.weapon.specialSRank ~= 0 then
            hasSpecial = true
            rankText = lib_unitxt.GetSRankSpecialName(item.weapon.specialSRank)
            clr      = lib_items_cfg.weaponSRankSpecial[item.weapon.specialSRank]
        elseif item.weapon.special ~= 0 then
            hasSpecial = true
            rankText = lib_unitxt.GetSpecialName(item.weapon.special)
            clr      = lib_items_cfg.weaponSpecial[item.weapon.special + 1]
        end
            
        if hasSpecial then
            clr      = lib_helpers.GetColorAsFloats(clr)
            table.insert(item.wName, { " [", nil })
            table.insert(item.wName, { rankText, {clr.a, clr.r, clr.g, clr.b} })
            table.insert(item.wName, { "]", nil })
        end
    end

end
local function AddArmorStats(item,showStats,showSlots,highlightMaxStats)
    local colorGrey = {1.0, 0.4706, 0.4706, 0.4706}

    if not item.wName or type(options) ~= "table" then
        item.wName = {}
    end

    if showStats then
        local nClr,dfpClr,dfpMaxClr, evpClr,evpMaxClr
        if highlightMaxStats and item.armor.dfp == item.armor.dfpMax and item.armor.evp == item.armor.evpMax and (item.armor.dfpMax > 0 or item.armor.evpMax > 0) then
            nClr = {1.0, 1.0, 0.8, 0.0}
        end
        if item.armor.dfp == 0 then
            dfpClr = colorGrey
        else
            if highlightMaxStats and item.armor.dfp == item.armor.dfpMax then
                dfpClr = {1.0, 1.0, 0.8, 0.0}
            else
                dfpClr = {1.0, 0.15686, 0.8, 0.4}
            end
        end
        if item.armor.dfpMax == 0 then
            dfpMaxClr = colorGrey
        else
            dfpMaxClr = dfpClr
        end
        if item.armor.evp == 0 then
            evpClr = colorGrey
        else
            if highlightMaxStats and item.armor.evp == item.armor.evpMax then
                evpClr = {1.0, 1.0, 0.8, 0.0}
            else
                evpClr = {1.0, 0.15686, 0.8, 0.4}
            end
        end
        if item.armor.evpMax == 0 then
            evpMaxClr = colorGrey
        else
            evpMaxClr = evpClr
        end
        item.wName[1][2] = nClr
        table.insert(item.wName, { " [", nil })
        table.insert(item.wName, { item.armor.dfp, dfpClr }) -- dfp
        table.insert(item.wName, { "/", nil })
        table.insert(item.wName, { item.armor.dfpMax, dfpMaxClr }) -- dfpMax
        table.insert(item.wName, { "|", nil })
        table.insert(item.wName, { item.armor.evp, evpClr }) -- evp
        table.insert(item.wName, { "/", nil })
        table.insert(item.wName, { item.armor.evpMax, evpMaxClr }) -- evpMax
        table.insert(item.wName, { "]", nil })
    end

    if showSlots then
        table.insert(item.wName, { " [", nil })
        table.insert(item.wName, { item.armor.slots .. "S", {1.0, 1.0, 1.0, 0.0} }) -- slots
        table.insert(item.wName, { "]", nil })
    end

end

local function ProcessWeapon(item, floor, trkIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item.weapon.isSRank == false then
        if item_cfg ~= nil and item_cfg[1] ~= 0 then
            item.wName = { { item.name, nil } }
            AddWeaponSpecial(item,options[trkIdx]["RareWeapon"].includeSpecial)
            AddWeaponAtrributes(item,options[trkIdx]["RareWeapon"].includeAtrributes,options[trkIdx]["RareWeapon"].includeHit)
            ItemAppendVisibilityData( options[trkIdx]["RareWeapon"], item, trkIdx )
        elseif floor then
            -- Hide weapon drops with less then xxHit (40 default) untekked
            if item.weapon.stats[6] >= options[trkIdx].HighHitCommonWeapon.HitMin then
                item.wName = { { item.name, nil } }
                AddWeaponSpecial(item,options[trkIdx]["HighHitCommonWeapon"].includeSpecial)
                AddWeaponAtrributes(item,options[trkIdx]["HighHitCommonWeapon"].includeAtrributes,options[trkIdx]["HighHitCommonWeapon"].includeHit)
                ItemAppendVisibilityData( options[trkIdx]["HighHitCommonWeapon"], item, trkIdx )
            -- Show Claire's Deal 5 items
            elseif options[trkIdx].ClairesDeal.enabled and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendVisibilityData( options[trkIdx]["ClairesDeal"], item, trkIdx )
            elseif item.weapon.stats[6] < options[trkIdx].HighHitCommonWeapon.HitMin then
                item.wName = { { item.name, nil } }
                AddWeaponSpecial(item,options[trkIdx]["LowHitCommonWeapon"].includeSpecial)
                AddWeaponAtrributes(item,options[trkIdx]["LowHitCommonWeapon"].includeAtrributes,options[trkIdx]["LowHitCommonWeapon"].includeHit)
                ItemAppendVisibilityData( options[trkIdx]["LowHitCommonWeapon"], item, trkIdx )
            end            
        end
    else
        item.wName = { { item.name, nil } }
        AddWeaponAtrributes(item,options[trkIdx]["LowHitCommonWeapon"].includeAtrributes,options[trkIdx]["LowHitCommonWeapon"].includeHit)
        ItemAppendVisibilityData( options[trkIdx]["ESWeapon"], item, trkIdx )
    end
end
local function ProcessFrame(item, floor, trkIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        item.wName = { { item.name, nil } }
        AddArmorStats(item, options[trkIdx]["RareArmor"].includeStats,options[trkIdx]["RareArmor"].includeSlots,options[trkIdx]["RareArmor"].highlightMaxStats)
        ItemAppendVisibilityData( options[trkIdx]["RareArmor"], item, trkIdx )
    elseif floor then
        -- Show 4 socket armors
        if item.armor.slots == 4 then
            item.wName = { { item.name, nil } }
            AddArmorStats(item, options[trkIdx]["MaxSocketCommonArmor"].includeStats,options[trkIdx]["MaxSocketCommonArmor"].includeSlots,options[trkIdx]["MaxSocketCommonArmor"].highlightMaxStats)
            ItemAppendVisibilityData( options[trkIdx]["MaxSocketCommonArmor"], item, trkIdx )
            -- Show Claire's Deal 5 items
        elseif options[trkIdx].ClairesDeal.enabled and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendVisibilityData( options[trkIdx]["ClairesDeal"], item, trkIdx )
        else
            item.wName = { { item.name, nil } }
            AddArmorStats(item, options[trkIdx]["CommonArmor"].includeStats,options[trkIdx]["CommonArmor"].includeSlots,options[trkIdx]["CommonArmor"].highlightMaxStats)
            ItemAppendVisibilityData( options[trkIdx]["CommonArmor"], item, trkIdx )
        end
    end
end
local function ProcessBarrier(item, floor, trkIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        item.wName = { { item.name, nil } }
        AddArmorStats(item, options[trkIdx]["RareBarrier"].includeStats,false,options[trkIdx]["RareBarrier"].highlightMaxStats)
        ItemAppendVisibilityData( options[trkIdx]["RareBarrier"], item, trkIdx )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options[trkIdx].ClairesDeal.enabled and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendVisibilityData( options[trkIdx]["ClairesDeal"], item, trkIdx )
        else
            item.wName = { { item.name, nil } }
            AddArmorStats(item, options[trkIdx]["RareBarrier"].includeStats,false,options[trkIdx]["RareBarrier"].highlightMaxStats)
            ItemAppendVisibilityData( options[trkIdx]["CommonBarrier"], item, trkIdx )
        end
    end
end
local function ProcessUnit(item, floor, trkIdx)

    local item_cfg = lib_items_list.t[item.hex]

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        ItemAppendVisibilityData( options[trkIdx]["RareUnit"], item, trkIdx )
    elseif floor then
        -- Show Claire's Deal 5 items
        if options[trkIdx].ClairesDeal.enabled and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
            ItemAppendVisibilityData( options[trkIdx]["ClairesDeal"], item, trkIdx )
        else
            ItemAppendVisibilityData( options[trkIdx]["CommonUnit"], item, trkIdx )
        end
    end
end
local function ProcessMag(item, fromMagWindow, trkIdx)
    ItemAppendVisibilityData( options[trkIdx]["RareMag"], item, trkIdx )
end
local function ProcessTool(item, floor, trkIdx)
    local nameColor
    local item_cfg = lib_items_list.t[item.hex]
    local show_item = true

    if item.data[2] == 2 then
        nameColor = lib_items_cfg.techName
    else
        nameColor = lib_items_cfg.toolName
    end

    if item_cfg ~= nil and item_cfg[1] ~= 0 then
        nameColor = item_cfg[1]
    end

    if floor then
        -- Process Technique Disks
        if item.data[2] == 0x02 then
            item.wName = {
                { item.name, nil },
                { " Lv", nil },
                { item.tool.level, nil },
            }
            -- Is Reverser/Ryuker
            if item.data[5] == 0x11 then
                ItemAppendVisibilityData( options[trkIdx]["TechReverser"], item, trkIdx )
            elseif item.data[5] == 0x0E then
                ItemAppendVisibilityData( options[trkIdx]["TechRyuker"], item, trkIdx )
                -- Is Good Anti?
            elseif item.data[5] == 0x10 then
                if item.tool.level == 5 then
                    ItemAppendVisibilityData( options[trkIdx]["TechAnti5"], item, trkIdx )
                elseif item.tool.level >= 7 then
                    ItemAppendVisibilityData( options[trkIdx]["TechAnti7"], item, trkIdx )
                else
                    ItemAppendVisibilityData( options[trkIdx]["CommonTech"], item, trkIdx )
                end
            -- Is Good Megid/Grants
            elseif item.data[5] == 0x12 then
                if item.tool.level >= options[trkIdx].TechMegid.MinLvl then
                    ItemAppendVisibilityData( options[trkIdx]["TechMegid"], item, trkIdx )
                else
                    ItemAppendVisibilityData( options[trkIdx]["CommonTech"], item, trkIdx )
                end
            elseif item.data[5] == 0x09 then
                if item.tool.level >= options[trkIdx].TechGrants.MinLvl then
                    ItemAppendVisibilityData( options[trkIdx]["TechGrants"], item, trkIdx )
                else
                    ItemAppendVisibilityData( options[trkIdx]["CommonTech"], item, trkIdx )
                end
                -- Is good support spell
            elseif item.data[5] == 0x0A or item.data[5] == 0x0B or item.data[5] == 0x0C or item.data[5] == 0x0D or item.data[5] == 0x0F then
                if item.tool.level >= options[trkIdx].TechSupportHigh.MinLvl then
                    ItemAppendVisibilityData( options[trkIdx]["TechSupportHigh"], item, trkIdx )
                elseif item.tool.level == 15 then
                    ItemAppendVisibilityData( options[trkIdx]["TechSupport15"], item, trkIdx )
                elseif item.tool.level == 20 then
                    ItemAppendVisibilityData( options[trkIdx]["TechSupport20"], item, trkIdx )
                else
                    ItemAppendVisibilityData( options[trkIdx]["CommonTech"], item, trkIdx )
                end
            -- Is a max tier tech?
            elseif item.tool.level >= options[trkIdx].TechAttackHigh.MinLvl then
                ItemAppendVisibilityData( options[trkIdx]["TechAttackHigh"], item, trkIdx )
            elseif item.tool.level == 15 then
                ItemAppendVisibilityData( options[trkIdx]["TechAttack15"], item, trkIdx )
            elseif item.tool.level == 20 then
                ItemAppendVisibilityData( options[trkIdx]["TechAttack20"], item, trkIdx )
            else
                ItemAppendVisibilityData( options[trkIdx]["CommonTech"], item, trkIdx )
            end

        -- Hide Monomates, Dimates, Monofluids, Difluids, Antidotes, Antiparalysis, Telepipe, and Trap Visions
        elseif  toolLookupTable[trkIdx][item.data[2]] ~= nil and 
                toolLookupTable[trkIdx][item.data[2]][item.data[3]] ~= nil and 
                toolLookupTable[trkIdx][item.data[2]][item.data[3]][2] then
            -- Show Claire's Deal 5 items
            if options[trkIdx].ClairesDeal.enabled and clairesDealLoaded and lib_claires_deal.IsClairesDealItem(item) then
                ItemAppendVisibilityData( options[trkIdx]["ClairesDeal"], item, trkIdx )
            else
                local toolLookup = toolLookupTable[trkIdx][item.data[2]][item.data[3]]
                if toolLookup[1] ~= nil and toolLookup[2] ~= nil then
                    if toolLookup[1].onlyShowIfInvNotMaxStack ~= nil or toolLookup[1].onlyShowWhenOneOrMoreInInv ~= nil then

                        if  invToolLookupTable[item.data[2]] ~= nil and 
                            invToolLookupTable[item.data[2]][item.data[3]] ~= nil and 
                            invToolLookupTable[item.data[2]][item.data[3]][2]
                        then
                            local invToolTab = invToolLookupTable[item.data[2]][item.data[3]]
                            if invToolTab[2] > 0 then
                                local oneOrMore =   invToolTab[1] > 0
                                local notMaxStack = invToolTab[1] < invToolTab[2]
                                if not notMaxStack and toolLookup[1].onlyShowIfInvNotMaxStack then
                                    item.screenShouldNotShow = true
                                    ItemAppendVisibilityData( toolLookup[1], item, trkIdx )
                                    return
                                end
                                if not oneOrMore and toolLookup[1].onlyShowWhenOneOrMoreInInv then
                                    item.screenShouldNotShow = true
                                    ItemAppendVisibilityData( toolLookup[1], item, trkIdx )
                                    return
                                end
                                ItemAppendVisibilityData( toolLookup[1], item, trkIdx )
                            end
                        end

                    else
                        ItemAppendVisibilityData( toolLookup[1], item, trkIdx )
                    end
                end
            end
        else
            ItemAppendVisibilityData( options[trkIdx]["RareConsumables"], item, trkIdx )
        end
    end
end
local function ProcessMeseta(item, trkIdx)
    if options.ignoreMeseta == false then
        item.wName = {
            { item.meseta, nil },
            { " ", nil },
            { item.name, nil },
        }
        if item.meseta >= options[trkIdx].Meseta.MinAmount then
            ItemAppendVisibilityData( options[trkIdx]["Meseta"], item, trkIdx )
        end
    end
end
local function ProcessItem(item, floor, save, fromMagWindow, trkIdx)
    floor = floor or false
    save = save or false
    fromMagWindow = fromMagWindow or false

    -- Do not process disabled items when it's floor list
    -- but only when item IDs are off
    if floor == true then
        local item_cfg = lib_items_list.t[item.hex]
        if item_cfg ~= nil and item_cfg[2] == false then
            return
        end
    end

    if item.data[1] == 0 then
        ProcessWeapon(item, floor, trkIdx)
    elseif item.data[1] == 1 then
        if item.data[2] == 1 then
            ProcessFrame(item, floor, trkIdx)
        elseif item.data[2] == 2 then
            ProcessBarrier(item, floor, trkIdx)
        elseif item.data[2] == 3 then
            ProcessUnit(item, floor, trkIdx)
        end
    elseif item.data[1] == 2 then
        ProcessMag(item, fromMagWindow, trkIdx)
    elseif item.data[1] == 3 then
        ProcessTool(item, floor, trkIdx)
    elseif item.data[1] == 4 then
        ProcessMeseta(item, trkIdx)
    end

end

local update_delay = options.updateThrottle
local current_time = 0
local last_floor_time = 0
local cache_floor = nil
local itemCount = 0
local lastnumTrackers = options.numTrackers
local firstLoad = true
local last_inventory_index = -1
local last_inventory_time = 0
local lastFontScale = options["tracker1"].fontScale
local cache_inventory = nil
local invItemCount = 0
local windowTextSizes = {}

local function sortByDistanceP(a,b)
    return a.curPlayerDistance < b.curPlayerDistance
end

local function UpdateItemCache()
    if last_floor_time + update_delay < current_time or cache_floor == nil then
        local temp_floor_cache = lib_items.GetItemList(lib_items.NoOwner, options.invertItemList)
        local iCount = table.getn(temp_floor_cache)
        cache_floor = {}
        for i=1,iCount,1 do
            local item = temp_floor_cache[i]
            ProcessItem(item, true, false, false, "tracker1")
            if item.screenShow then
                table.insert(cache_floor,item)
            end
        end
        table.sort(cache_floor,sortByDistanceP)
        -- reassign a tracker window to its item
        local trackerNum = 1
        local prevTrackerWindowLookup = trackerWindowLookup
        trackerWindowLookup = {}
        local cache_floor_notracker = {}
        local usedWindowNameIdLookup = {}
        local windowNameIdCurIdx = 1
        local function nextWindowNameId()
            for i=windowNameIdCurIdx, options.numTrackers, 1 do
                if not usedWindowNameIdLookup[i] then
                    windowNameIdCurIdx = 1 + i
                    return i
                end
                windowNameIdCurIdx = i
            end
        end
        for i=1, #cache_floor, 1 do
            if trackerNum > options.numTrackers then break end
            local item = cache_floor[i]
            local windowNameId = prevTrackerWindowLookup[item.id]
            if windowNameId then
                usedWindowNameIdLookup[windowNameId] = true
                trackerWindowLookup[item.id] = windowNameId
                item.windowNameId = windowNameId
                trackerNum = trackerNum + 1
            else
                table.insert(cache_floor_notracker, item)
            end
        end
        -- assign a tracker window to an item
        for i=1, #cache_floor_notracker, 1 do
            if trackerNum > options.numTrackers then break end
            local item = cache_floor_notracker[i]
            local windowNameId = nextWindowNameId()
            if windowNameId then
                trackerWindowLookup[item.id] = windowNameId
                item.windowNameId = windowNameId
                trackerNum = trackerNum + 1
            else
                break -- no more trackers
            end
        end
        last_floor_time = current_time
    end
end

local function UpdateInventoryCache()
    local index = lib_items.Me

    if last_inventory_time + update_delay < current_time or last_inventory_index ~= index or cache_inventory == nil then
        cache_inventory = lib_items.GetInventory(index)
        last_inventory_index = index
        last_inventory_time = current_time
    end
end
local function updateInvToolLookupTable()
    for i=1,invItemCount,1 do
        local item = cache_inventory.items[i]
        if  invToolLookupTable[item.data[2]] ~= nil and 
            invToolLookupTable[item.data[2]][item.data[3]] ~= nil and 
            invToolLookupTable[item.data[2]][item.data[3]][2]
        then
            if item.tool and item.tool.count > 0 then
                invToolLookupTable[item.data[2]][item.data[3]][1] = item.tool.count
            end
        end
    end
end
local function PrintWText(wText)
    for i=1,table.getn(wText),1 do
        local clr = wText[i][2]
        if i ~= 1 then imgui.SameLine(0, 0) end
        if clr then
            imgui.TextColored(clr[2], clr[3], clr[4], clr[1], wText[i][1])
        else
            imgui.Text(wText[i][1])
        end
    end
end

local function getUnWText(wText)
    local str = ""
    for i=1,table.getn(wText),1 do
        str = str .. wText[i][1]
    end
    return str
end

local function getWText(wText,Default)
    if wText then
        return wText
    else
        return { {Default, nil} }
    end
end

local function PresentBoxTracker(item,trkIdx,curCount)
    local textC = {{"",nil}}

    if item.cate then
        local windowW,windowH = imgui.GetWindowSize()
        local padding     = 6
        local sizeX       = trackerBox.sizeX - padding
        local sizeY       = trackerBox.sizeY
        local cateTabl    = item.cate
        local windowWP    = windowW - padding

        -- if should show string "name" above item
        if options[trkIdx].showNameOverride then
            if curCount <= options[trkIdx].showNameClosestItemsNum then
                if options[trkIdx].showNameClosestDist <= 0 then
                    textC = getWText(item.wName,item.name)
                elseif item.curPlayerDistance <= options[trkIdx].showNameClosestDist then
                    textC = getWText(item.wName,item.name)
                end
            end
        else
            if curCount <= options[trkIdx].showNameClosestItemsNum then
                if options[trkIdx].showNameClosestDist <= 0 then
                    textC = getWText(item.wName,item.name)
                else
                    if item.curPlayerDistance <= options[trkIdx].showNameClosestDist and not item.screenShouldNotShow then
                        textC = getWText(item.wName,item.name)
                    elseif cateTabl.showName and not item.screenShouldNotShow then
                        textC = getWText(item.wName,item.name)
                    end
                end
            elseif cateTabl.showName and not item.screenShouldNotShow then
                textC = getWText(item.wName,item.name)
            end
        end

        local textW = imgui.CalcTextSize(getUnWText(textC)) -- get text width as simple string
        imgui.SetCursorPosX( (windowW - textW) * 0.5 ) -- center text
        PrintWText(textC)
        
        local cursorPosTY = imgui.GetCursorPosY() -- Don't change lines, need cursor pos After imgui.Text()
        local cursorPosY = clampVal( windowH * 0.5 - sizeY*0.5 + cursorPosTY*0.5, cursorPosTY, windowH )

        sizeX = clampVal( sizeX, 0,  windowWP - 2 )
        sizeY = clampVal( sizeY, 0,  windowH - cursorPosTY )

        if cateTabl.showBox and cateTabl.enabled and not item.screenShouldNotShow then
            if cateTabl.useCustomColor then
                TrackerColor = shiftHexColor(cateTabl.customBorderColor)
            else
                TrackerColor = shiftHexColor(options[trkIdx].customTrackerColorMarker)
            end

            imgui.PushStyleColor("Border", TrackerColor[2]/255, TrackerColor[3]/255, TrackerColor[4]/255, TrackerColor[1]/255)
            
            imgui.PushStyleColor("ChildWindowBg",0, 0, 0, 0)
            local borderSize = clampVal(cateTabl.borderSize, 1, math.floor(sizeX*0.5) - 2)
            borderSize       = clampVal(borderSize,          1, math.floor(sizeY*0.5) - 2)
            for border=1, borderSize-1, 1 do
                imgui.SetCursorPosX( windowW*0.5 - sizeX*0.5 + border +1 )
                imgui.SetCursorPosY( cursorPosY + border - 1 )
                imgui.BeginChild( "itembox##" .. border, sizeX - border*2 - 2, sizeY - border*2 - 2, true, {"NoInputs"} )
                imgui.EndChild()
            end
            imgui.PopStyleColor()
            
            local border = borderSize
            imgui.SetCursorPosX( windowW*0.5 - sizeX*0.5 + border +1 )
            imgui.SetCursorPosY( cursorPosY + border - 1 )
            imgui.BeginChild( "itembox##" .. border, sizeX - border*2 - 2, sizeY - border*2 - 2, true, {"NoInputs"} )
            imgui.EndChild()
            imgui.PopStyleColor()
        end
    end
end

local function calcScreenResolutions(trkIdx, forced)
    if forced or not resolutionWidth.val or not resolutionHeight.val then
        if options.customScreenResEnabled then
            resolutionWidth.val          = options.customScreenResX
            resolutionHeight.val         = options.customScreenResY
        else
            resolutionWidth.val          = lib_helpers.GetResolutionWidth()
            resolutionHeight.val         = lib_helpers.GetResolutionHeight()
        end
        aspectRatio                      = resolutionWidth.val / resolutionHeight.val
        resolutionWidth.half             = resolutionWidth.val * 0.5
        resolutionHeight.half            = resolutionHeight.val * 0.5
        resolutionWidth.clampRescale     = resolutionWidth.val  * 1
        resolutionHeight.clampRescale    = resolutionHeight.val * 1

        trackerBox.sizeX                 = options[trkIdx].boxSizeX
        trackerBox.sizeHalfX             = options[trkIdx].boxSizeX * 0.5
        trackerBox.sizeY                 = options[trkIdx].boxSizeY
        trackerBox.sizeHalfY             = options[trkIdx].boxSizeY * 0.5
        trackerBox.offsetX               = options[trkIdx].boxOffsetX
        trackerBox.offsetY               = options[trkIdx].boxOffsetY

        resolutionWidth.clampBoxLowest   = -resolutionWidth.half  + trackerBox.sizeHalfX
        resolutionWidth.clampBoxHighest  =  resolutionWidth.half  - trackerBox.sizeHalfX
        resolutionHeight.clampBoxLowest  = -resolutionHeight.half + trackerBox.sizeHalfY + 2
        resolutionHeight.clampBoxHighest =  resolutionHeight.half - trackerBox.sizeHalfY - 2
    end
end
local function calcScreenFoV(trkIdx, forced)

    if not aspectRatio or not cameraZoom or not resolutionHeight.val then
        cameraZoom        = getCameraZoom()
        calcScreenResolutions(trkIdx, forced)
    end

    if forced or cameraZoom ~= lastCameraZoom or cameraZoom == nil then
        if options.customFoVEnabled then
            if     cameraZoom == 0 then
                screenFov = math.rad( options.customFoV0 )
            elseif cameraZoom == 1 then
                screenFov = math.rad( options.customFoV1 )
            elseif cameraZoom == 2 then
                screenFov = math.rad( options.customFoV2 )
            elseif cameraZoom == 3 then
                screenFov = math.rad( options.customFoV3 )
            elseif cameraZoom == 4 then
                screenFov = math.rad( options.customFoV4 )
            else
                screenFov = 69 -- a good guess
            end
        else
            screenFov = math.rad( 
                math.deg( 
                    2*math.atan(0.56470588 * aspectRatio) -- 0.56470588 is 768/1360
                ) - (cameraZoom-1) * 0.600 - clampVal(cameraZoom,0,1) * 0.300 -- the constant here should work for most to all aspect ratios between 1.25 to 1.77, gud enuff.
            ) 
        end
        determinantScr = aspectRatio * 3 * resolutionHeight.val / ( 6 * math.tan( 0.5 * screenFov ) )
        lastCameraZoom = CameraZoom
    end
end


local function present()
    local trkIdx = "tracker1"

    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end
    ConfigurationWindow.Update()

    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        if options.numTrackers > lastnumTrackers then
            LoadOptions()
            lastnumTrackers = options.numTrackers
        end
        local curFontScale
        if options[trkIdx].customFontScaleEnabled then
            curFontScale = options[trkIdx].fontScale
        else
            curFontScale = 1.0
        end
        if lastFontScale ~= curFontScale then
            lastFontScale = curFontScale
            windowTextSizes = {}
        end
        updateToolLookupTable()
        calcScreenResolutions(trkIdx, true)
        calcScreenFoV(trkIdx, true)
        SaveOptions(options)
        -- Update the delay too
        update_delay = options.updateThrottle
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    --- Update timer for update throttle
    current_time = pso.get_tick_count()
-- --needed?
-- local myFloor = lib_characters.GetCurrentFloorSelf()
-- --needed?
    cameraZoom        = getCameraZoom()
    calcScreenResolutions(trkIdx)
    calcScreenFoV(trkIdx)
    playerSelfAddr    = lib_characters.GetSelf()
    playerSelfCoords  = GetPlayerCoordinates(playerSelfAddr)
    playerSelfDirs    = GetPlayerDirection(playerSelfAddr)
    pCoord            = mgl.vec3(playerSelfCoords.x,playerSelfCoords.y,playerSelfCoords.z)
    cameraCoords      = getCameraCoordinates()
    cameraDirs        = getCameraDirection()
    eyeWorld          = mgl.vec3(cameraCoords.x, cameraCoords.y, cameraCoords.z)
    eyeDir            = mgl.vec3(  cameraDirs.x,   cameraDirs.y,   cameraDirs.z)

    UpdateItemCache()
    UpdateInventoryCache()
    itemCount         = table.getn(cache_floor)
    invItemCount      = table.getn(cache_inventory.items)
    newInvToolLookupTable()
    updateInvToolLookupTable()
    local itemIdx = 0
    local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" }

    for i=1, options.numTrackers, 1 do
        itemIdx = itemIdx + 1
        if itemIdx > options.numTrackers or itemIdx > itemCount or itemCount < 1 then break end

        if (options[trkIdx].EnableWindow == true)
            and (options[trkIdx].HideWhenMenu == false or lib_menu.IsMenuOpen() == false)
            and (options[trkIdx].HideWhenSymbolChat == false or lib_menu.IsSymbolChatOpen() == false)
            and (options[trkIdx].HideWhenMenuUnavailable == false or lib_menu.IsMenuUnavailable() == false)
        then
            if cache_floor[itemIdx].screenShow then

                if options[trkIdx].customTrackerColorEnable == true then
                    local FrameBgColor  = shiftHexColor(options[trkIdx].customTrackerColorBackground)
                    local WindowBgColor = shiftHexColor(options[trkIdx].customTrackerColorWindow)
                    local TrackerColor  = shiftHexColor(options[trkIdx].customTrackerColorMarker)
                    imgui.PushStyleColor("ChildWindowBg", FrameBgColor[2]/255, FrameBgColor[3]/255,  FrameBgColor[4]/255,  FrameBgColor[1]/255)
                    imgui.PushStyleColor("WindowBg",     WindowBgColor[2]/255, WindowBgColor[3]/255, WindowBgColor[4]/255, WindowBgColor[1]/255)
                    imgui.PushStyleColor("Border",        TrackerColor[2]/255, TrackerColor[3]/255,  TrackerColor[4]/255,  TrackerColor[1]/255)
                end

                if options[trkIdx].TransparentWindow == true then
                    imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
                end

                local textC = getWText(cache_floor[itemIdx].wName, cache_floor[itemIdx].name)
                local textP = getUnWText(textC)
                if options[trkIdx].customFontScaleEnabled then -- get text width and height for every item name text
                    local tx, ty
                    if not windowTextSizes[textP] then
                        if imgui.Begin( "##DropBox Tracker - FontDummy",
                            nil, { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" } )
                        then
                            imgui.SetWindowFontScale(options[trkIdx].fontScale)
                            tx, ty = imgui.CalcTextSize(textP)
                            windowTextSizes[textP] = {
                                x = tx,
                                y = ty,
                            }
                        end
                        imgui.End()
                    end
                else
                    if not windowTextSizes[textP] then
                        tx, ty = imgui.CalcTextSize(textP)
                        windowTextSizes[textP] = {
                            x = tx,
                            y = ty,
                        }
                    end
                end

                local wx, wy
                local tx = windowTextSizes[textP].x
                local ty = windowTextSizes[textP].y
                local tyh = ty * 0.5
                local wPadding = 6
                local wPaddingh = wPadding * 0.5 - 2
                local wPaddingd = wPadding * 2

                if options[trkIdx].W < 1 or options[trkIdx].AlwaysAutoResize then
                    wx = clampVal(tx, trackerBox.sizeX, tx) + wPadding + 1
                else
                    wx = options[trkIdx].W
                end
                if options[trkIdx].H < 1 or options[trkIdx].AlwaysAutoResize then
                    wy = ty + trackerBox.sizeY + wPaddingd + 4
                else
                    wy = options[trkIdx].H
                end

                local sx, sy
                sx = cache_floor[itemIdx].screenX + wPaddingh
                sy = cache_floor[itemIdx].screenY - tyh
                if options[trkIdx].clampItemView then
                    sx = clampVal(  sx, 
                                    resolutionWidth.clampBoxLowest, resolutionWidth.clampBoxHighest )
                    sy = clampVal(  sy,
                                    resolutionHeight.clampBoxLowest + tyh, resolutionHeight.clampBoxHighest - tyh)
                else

                end

                local ps =  lib_helpers.GetPosBySizeAndAnchor( sx, sy, wx, wy, 5 ) -- 5 is "center" window anchor
                imgui.SetNextWindowPos( ps[1], ps[2], "Always" )
                imgui.SetNextWindowSize( wx, wy, "Always" )
                
                local windowName = "DropBox Tracker - Hud" .. cache_floor[itemIdx].windowNameId
                if imgui.Begin( windowName,
                    nil, windowParams )
                then
                    if options[trkIdx].customFontScaleEnabled then
                        imgui.SetWindowFontScale(options[trkIdx].fontScale)
                    else
                        imgui.SetWindowFontScale(1.0)
                    end
                    PresentBoxTracker(cache_floor[itemIdx],trkIdx,itemIdx)
                end
                imgui.End()

                if options[trkIdx].customTrackerColorEnable == true then
                    imgui.PopStyleColor()
                    imgui.PopStyleColor()
                    imgui.PopStyleColor()
                end
    
                if options[trkIdx].TransparentWindow == true then
                    imgui.PopStyleColor()
                end
    
                options[trkIdx].changed = false

            end
        end
        if itemIdx>=itemCount then
            break
        end
    end
    firstLoad = false
end

local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options)

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("Dropbox Tracker", mainMenuButtonHandler)

    return
    {
        name = "Dropbox Tracker",
        version = "0.2.8",
        author = "X9Z0.M2",
        description = "Onscreen Drop tracking to let you see which drops are important loot.",
        present = present,
    }
end

return
{
    __addon =
    {
        init = init
    }
}
