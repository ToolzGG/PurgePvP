local addonName = ...

PurgePvPDB = PurgePvPDB or {}
local defaultSettings = {
    enabled = true,
    enableSafeZoneDisable = true,
    enableInstanceDisable = true,
    enableSecurePvPDisable = true,
    enablePvPWarning = true,
    enableWarningSound = true,
    enableFlightWarningDisable = true,
}
local BLOCK_FRAME_SIZE = 10
local addon = {
    frame = CreateFrame("Frame"),
    blockFrame = nil,
    optionUI = { panel = nil },
    lastMouseoverCheck = 0,
    inSafeZone = false,
    inInstanceOrBattleground = false,
    lastWarningTime = -60,
}
if next(PurgePvPDB) == nil then
    for key, value in pairs(defaultSettings) do
        PurgePvPDB[key] = value
    end
end
local function IsInSafeZone()
    local pvpType = GetZonePVPInfo()
    return pvpType == "sanctuary" or pvpType == "friendly"
end
local function IsInInstanceOrBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena")
end
local function IsUnitPvP(unit)
    return UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)
end
local function IsPvPTarget(unit)
    return (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) and IsUnitPvP(unit)
end
local function InitializeBlockFrame()
    addon.blockFrame = CreateFrame("Button", nil, UIParent)
    addon.blockFrame:SetSize(BLOCK_FRAME_SIZE, BLOCK_FRAME_SIZE)
    addon.blockFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    addon.blockFrame:SetFrameLevel(100)
    addon.blockFrame:EnableMouse(true)
    addon.blockFrame:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    addon.blockFrame:SetScript("OnClick", function() end)
    addon.blockFrame:SetScript("OnUpdate", function(self, elapsed)
        addon.lastMouseoverCheck = addon.lastMouseoverCheck + elapsed
        if addon.lastMouseoverCheck > 0.2 then
            if not UnitExists("mouseover") or not IsPvPTarget("mouseover") then
                self:Hide()
            end
            addon.lastMouseoverCheck = 0
        end
    end)
    addon.blockFrame:Hide()
end
local function SecureDisablePvP()
    if not PurgePvPDB.enableSecurePvPDisable or not addon.inSafeZone or not UnitIsPVP("player") then
        return
    end
    if InCombatLockdown() then
        print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r")
        return
    end
    SetPVP(1)
    C_Timer.After(2, function() if not InCombatLockdown() then SetPVP(0) end end)
end
local function CheckPlayerPvPStatus()
    if not PurgePvPDB.enablePvPWarning or not PurgePvPDB.enabled or
       (PurgePvPDB.enableSafeZoneDisable and addon.inSafeZone) or
       (PurgePvPDB.enableInstanceDisable and addon.inInstanceOrBattleground) or
       (PurgePvPDB.enableFlightWarningDisable and UnitOnTaxi("player")) then
        return
    end
    if UnitIsPVP("player") and GetTime() - addon.lastWarningTime >= 60 then
        UIErrorsFrame:AddMessage("|cFFFF0000You are PvP-flagged!|r", 1, 0, 0, 1, 5)
        if PurgePvPDB.enableWarningSound then
            PlaySound("RaidWarning", "Master")
        end
        addon.lastWarningTime = GetTime()
    end
end
local function StartIntervalCheck()
    if addon.intervalTicker then
        addon.intervalTicker:Cancel()
        addon.intervalTicker = nil
    end
    if PurgePvPDB.enablePvPWarning and PurgePvPDB.enabled then
        addon.intervalTicker = C_Timer.NewTicker(60, CheckPlayerPvPStatus)
    end
end
local function InitializePvPChecks()
    StartIntervalCheck()
    CheckPlayerPvPStatus()
end
local function HandlePvPTarget(unit)
    if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and addon.inSafeZone) or
       (PurgePvPDB.enableInstanceDisable and addon.inInstanceOrBattleground) then
        if addon.blockFrame then addon.blockFrame:Hide() end
        return
    end
    if not UnitIsPVP("player") and IsPvPTarget(unit) then
        if unit == "target" then
            if not InCombatLockdown() then ClearTarget() else print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end
        end
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        addon.blockFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
        addon.blockFrame:Show()
    elseif addon.blockFrame then
        addon.blockFrame:Hide()
    end
end
local function PrintStatusMessage(option, enabled)
    print(string.format("|cFF00FF00PurgePvP %s%snow %s!|r", option, option ~= "" and " " or "", enabled and "enabled" or "disabled"))
end
local function ToggleEvents(enabled)
    if enabled then
        addon.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        addon.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        addon.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        C_Timer.After(3, InitializePvPChecks)
    else
        addon.frame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        addon.frame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
        addon.frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        if addon.intervalTicker then
            addon.intervalTicker:Cancel()
            addon.intervalTicker = nil
        end
        if addon.blockFrame then addon.blockFrame:Hide() end
    end
end
local function createCheckbutton(parent, x_loc, y_loc, displayname, tooltip)
    local checkbutton = CreateFrame("CheckButton", "PurgePvPCheckButton" .. tostring(GetTime()) .. math.random(1, 1000), parent, "ChatConfigCheckButtonTemplate")
    checkbutton:SetPoint("TOPLEFT", x_loc, y_loc)
    getglobal(checkbutton:GetName() .. "Text"):SetText(displayname)
    checkbutton.tooltip = tooltip
    return checkbutton
end
local function loadSettings()
    addon.optionUI.panel = CreateFrame("Frame", "PurgePvPOptions", UIParent)
    addon.optionUI.panel.name = "PurgePvP"
    InterfaceOptions_AddCategory(addon.optionUI.panel)
    local title = addon.optionUI.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PurgePvP Settings (v" .. GetAddOnMetadata(addonName, "Version") .. ")")
    local headers = {
        { text = "General", y = -50 },
        { text = "Automation", y = -100 },
        { text = "Warnings", y = -190 }
    }
    for _, header in ipairs(headers) do
        local h = addon.optionUI.panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        h:SetPoint("TOPLEFT", 16, header.y)
        h:SetText(header.text)
    end
    local checkboxes = {
        { y = -70, name = "Enable PurgePvP", tooltip = "Enable or disable the PurgePvP addon.", var = "enabled",
          action = function(self) ToggleEvents(self:GetChecked()) if self:GetChecked() then InitializeBlockFrame() end end },
        { y = -120, name = "Disable in Safe Zones", tooltip = "Disable PurgePvP features in safe zones (e.g., Orgrimmar, Stormwind).", var = "enableSafeZoneDisable" },
        { y = -140, name = "Disable in Instances", tooltip = "Disable PurgePvP features in instances and battlegrounds.", var = "enableInstanceDisable" },
        { y = -160, name = "Secure PvP Deactivation", tooltip = "Securely deactivates PvP status when entering safe zones (15-minute server timer).", var = "enableSecurePvPDisable",
          action = function(self) if self:GetChecked() and not InCombatLockdown() then SecureDisablePvP() elseif InCombatLockdown() then print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end end },
        { y = -210, name = "Enable PvP Warning", tooltip = "Show a warning when PvP is enabled.", var = "enablePvPWarning",
          action = function(self) if self:GetChecked() then addon.lastWarningTime = -60 C_Timer.After(3, InitializePvPChecks) elseif addon.intervalTicker then addon.intervalTicker:Cancel() addon.intervalTicker = nil end end },
        { y = -230, name = "Enable Warning Sound", tooltip = "Play a sound when PvP warning is shown.", var = "enableWarningSound" },
        { y = -250, name = "Disable Warnings During Flight", tooltip = "Prevents PvP warnings during flight paths.", var = "enableFlightWarningDisable" }
    }
    for _, cb in ipairs(checkboxes) do
        cb.frame = createCheckbutton(addon.optionUI.panel, 16, cb.y, cb.name, cb.tooltip)
        cb.frame:SetChecked(PurgePvPDB[cb.var])
        cb.frame:SetScript("OnClick", function(self)
            PurgePvPDB[cb.var] = self:GetChecked()
            PrintStatusMessage(cb.var == "enabled" and "" or cb.var:gsub("enable", ""):lower(), PurgePvPDB[cb.var])
            if cb.action then cb.action(self) end
        end)
    end
    local resetButton = CreateFrame("Button", nil, addon.optionUI.panel, "UIPanelButtonTemplate")
    resetButton:SetPoint("BOTTOMLEFT", 16, 16)
    resetButton:SetSize(120, 25)
    resetButton:SetText("Reset Defaults")
    resetButton.tooltip = "Reset all PurgePvP settings to their default values."
    resetButton:SetScript("OnClick", function()
        for key, value in pairs(defaultSettings) do
            PurgePvPDB[key] = value
        end
        for _, cb in ipairs(checkboxes) do
            cb.frame:SetChecked(PurgePvPDB[cb.var])
        end
        ToggleEvents(PurgePvPDB.enabled)
        if PurgePvPDB.enabled then InitializeBlockFrame() end
        print("|cFF00FF00PurgePvP settings reset to defaults!|r")
    end)
    resetButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP") GameTooltip:SetText(self.tooltip) GameTooltip:Show() end)
    resetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local githubButton = CreateFrame("Button", nil, addon.optionUI.panel, "UIPanelButtonTemplate")
    githubButton:SetPoint("BOTTOMRIGHT", -16, 16)
    githubButton:SetSize(120, 25)
    githubButton:SetText("|cff00b7ebGitHub|r")
    githubButton:SetNormalFontObject("GameFontHighlight")
    githubButton.tooltip = "Visit the PurgePvP GitHub repository."
    githubButton:SetScript("OnClick", function() print("|cff00b7ebVisit PurgePvP on GitHub: https://github.com/ToolzGG/PurgePvP|r") end)
    githubButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP") GameTooltip:SetText(self.tooltip) GameTooltip:Show() end)
    githubButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        addon.lastWarningTime = -60
        InitializeBlockFrame()
        if PurgePvPDB.enabled then
            addon.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
            addon.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
            addon.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            C_Timer.After(3, InitializePvPChecks)
        end
        addon.inSafeZone = IsInSafeZone()
        addon.inInstanceOrBattleground = IsInInstanceOrBattleground()
        print("|cFF00FF00PurgePvP loaded! Use /purgepvp or Interface Options to configure.|r")
        if not InCombatLockdown() then loadSettings() else print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        addon.inSafeZone = IsInSafeZone()
        addon.inInstanceOrBattleground = IsInInstanceOrBattleground()
        if not InCombatLockdown() then SecureDisablePvP() else print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end
    elseif event == "PLAYER_TARGET_CHANGED" then
        HandlePvPTarget("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        HandlePvPTarget("mouseover")
    end
end
addon.frame:SetScript("OnEvent", OnEvent)
addon.frame:RegisterEvent("PLAYER_LOGIN")
local slashCommands = {
    [""] = function() if not addon.optionUI.panel then if not InCombatLockdown() then loadSettings() else print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end end InterfaceOptionsFrame_OpenToCategory(addon.optionUI.panel) end,
    ["toggle"] = { var = "enabled", action = function() ToggleEvents(PurgePvPDB.enabled) if PurgePvPDB.enabled then InitializeBlockFrame() addon.lastWarningTime = -60 C_Timer.After(3, InitializePvPChecks) end end },
    ["safezone"] = { var = "enableSafeZoneDisable" },
    ["securepvp"] = { var = "enableSecurePvPDisable", action = function() if PurgePvPDB.enableSecurePvPDisable and not InCombatLockdown() then SecureDisablePvP() elseif InCombatLockdown() then print("|cFFFF0000PurgePvP: Action blocked due to combat lockdown.|r") end end },
    ["instances"] = { var = "enableInstanceDisable" },
    ["warning"] = { var = "enablePvPWarning", action = function() if PurgePvPDB.enablePvPWarning then addon.lastWarningTime = -60 C_Timer.After(3, InitializePvPChecks) elseif addon.intervalTicker then addon.intervalTicker:Cancel() addon.intervalTicker = nil end end },
    ["warningsound"] = { var = "enableWarningSound" },
    ["flight"] = { var = "enableFlightWarningDisable" }
}
SLASH_PURGEPVP1 = "/purgepvp"
SlashCmdList["PURGEPVP"] = function(msg)
    local cmd = string.lower(msg or "")
    local cmdInfo = slashCommands[cmd]
    if cmdInfo then
        if cmdInfo.var then
            PurgePvPDB[cmdInfo.var] = not PurgePvPDB[cmdInfo.var]
            PrintStatusMessage(cmdInfo.var == "enabled" and "" or cmdInfo.var:gsub("enable", ""):lower(), PurgePvPDB[cmdInfo.var])
            if cmdInfo.action then cmdInfo.action() end
        else
            cmdInfo()
        end
    else
        print("|cFF00FF00PurgePvP commands:|r")
        for cmd, _ in pairs(slashCommands) do
            if cmd ~= "" then
                print(string.format("/purgepvp %s - Toggle %s", cmd, cmd:gsub("^%l", string.upper)))
            else
                print("/purgepvp - Open the options panel")
            end
        end
    end
end
