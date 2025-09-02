local addonName = ...

PurgePvPDB = PurgePvPDB or {
    enabled = true,
    enableSound = true,
    enableWarning = true,
    enableSafeZoneDisable = true,
    enableLeaveSafeWarning = true,
    enableIntervalCheck = true,
    isPlayerPvPFlagged = false,
    enableAutoPvPDisable = true,
    enableInstanceDisable = true,
    enableAutoPvPDisableMessages = false,
    enableLeaveSafeMessages = false,
}

local frame = CreateFrame("Frame")
local blockFrame = nil
local warningFrame = nil
local playerWarningFrame = nil
local lastMessageTime = 0
local lastMouseoverCheck = 0
local inSafeZone = false
local inInstanceOrBattleground = false
local lastLeaveSafeMessageTime = 0
local intervalTicker = nil

local function IsInSafeZone()
    local pvpType = GetZonePVPInfo()
    return pvpType == "sanctuary" or pvpType == "friendly"
end

local function IsInInstanceOrBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena")
end

local function CheckPlayerPvPStatus()
    if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) or (PurgePvPDB.enableInstanceDisable and inInstanceOrBattleground) then return end
    if UnitIsPVP("player") then
        PurgePvPDB.isPlayerPvPFlagged = true
        if PurgePvPDB.enableWarning then
            CombatText_AddMessage("|cFFFF0000You are PvP-flagged!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
        end
        if playerWarningFrame then playerWarningFrame:Hide() end
        playerWarningFrame = CreateFrame("Frame", nil, UIParent)
        playerWarningFrame:SetSize(600, 120)
        playerWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        local warningText = playerWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        warningText:SetText("|cFFFF0000YOU ARE PVP FLAGGED! AVOID CASTING!|r")
        if PurgePvPDB.enableSound then
            PlaySound("RaidWarning", "Master")
        end
        if PurgePvPDB.enableAutoPvPDisable then
            RunScript("/pvp off")
            if PurgePvPDB.enableAutoPvPDisableMessages and PurgePvPDB.enableWarning then
                CombatText_AddMessage("|cFF00FF00PvP status disabled!|r", COMBAT_TEXT_SCROLL_FUNCTION, 0, 1, 0)
                local disableFrame = CreateFrame("Frame", nil, UIParent)
                disableFrame:SetSize(600, 120)
                disableFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
                local disableText = disableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
                disableText:SetText("|cFF00FF00PVP STATUS DISABLED!|r")
                C_Timer.After(3, function() disableFrame:Hide() end)
            end
        end
    else
        PurgePvPDB.isPlayerPvPFlagged = false
    end
end

local function StartIntervalCheck()
    if intervalTicker then intervalTicker:Cancel() end
    if PurgePvPDB.enableIntervalCheck and PurgePvPDB.isPlayerPvPFlagged then
        intervalTicker = C_Timer.NewTicker(60, function()
            if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) or (PurgePvPDB.enableInstanceDisable and inInstanceOrBattleground) then
                PurgePvPDB.isPlayerPvPFlagged = false
                intervalTicker:Cancel()
                return
            end
            if UnitIsPVP("player") then
                CheckPlayerPvPStatus()
            else
                PurgePvPDB.isPlayerPvPFlagged = false
                intervalTicker:Cancel()
            end
        end)
    end
end

local function createCheckbutton(parent, x_loc, y_loc, displayname, tooltip)
    local uniquealyzer = tostring(GetTime()) .. math.random(1, 1000)
    local checkbutton = CreateFrame("CheckButton", "PurgePvPCheckButton" .. uniquealyzer, parent, "ChatConfigCheckButtonTemplate")
    checkbutton:SetPoint("TOPLEFT", x_loc, y_loc)
    getglobal(checkbutton:GetName() .. "Text"):SetText(displayname)
    checkbutton.tooltip = tooltip
    return checkbutton
end

local optionUI = {}
optionUI.panel = CreateFrame("Frame", "PurgePvPOptions", UIParent)
optionUI.panel.name = "PurgePvP " .. GetAddOnMetadata(addonName, "Version")
InterfaceOptions_AddCategory(optionUI.panel)

local function loadSettings()
    local xOffset = -80
    local title = optionUI.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 15, -18)
    title:SetText("PurgePvP " .. GetAddOnMetadata(addonName, "Version"))

    local enableCheck = createCheckbutton(optionUI.panel, 40, xOffset, "Enable PurgePvP", "Enable or disable the PurgePvP addon")
    enableCheck:SetChecked(PurgePvPDB.enabled)
    enableCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enabled = self:GetChecked()
        print("|cFF00FF00PurgePvP is now " .. (PurgePvPDB.enabled and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enabled then
            inSafeZone = IsInSafeZone()
            inInstanceOrBattleground = IsInInstanceOrBattleground()
            CheckPlayerPvPStatus()
            StartIntervalCheck()
        elseif intervalTicker then
            intervalTicker:Cancel()
        end
    end)
    
    local soundCheck = createCheckbutton(optionUI.panel, 40, xOffset - 30, "Sound Alerts", "Enable or disable sound alerts for PvP warnings")
    soundCheck:SetChecked(PurgePvPDB.enableSound)
    soundCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableSound = self:GetChecked()
        print("|cFF00FF00PurgePvP sound is now " .. (PurgePvPDB.enableSound and "enabled" or "disabled") .. "!|r")
    end)
    
    local warningCheck = createCheckbutton(optionUI.panel, 40, xOffset - 60, "Warning Messages", "Enable or disable warning messages (Combat Text and UI text)")
    warningCheck:SetChecked(PurgePvPDB.enableWarning)
    warningCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableWarning = self:GetChecked()
        print("|cFF00FF00PurgePvP warnings are now " .. (PurgePvPDB.enableWarning and "enabled" or "disabled") .. "!|r")
    end)
    
    local safeZoneCheck = createCheckbutton(optionUI.panel, 40, xOffset - 90, "Disable in Safe Zones", "Disable PurgePvP features in safe zones (e.g., Dalaran, Shattrath)")
    safeZoneCheck:SetChecked(PurgePvPDB.enableSafeZoneDisable)
    safeZoneCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableSafeZoneDisable = self:GetChecked()
        print("|cFF00FF00PurgePvP safe zone disable is now " .. (PurgePvPDB.enableSafeZoneDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableSafeZoneDisable then
            inSafeZone = IsInSafeZone()
            StartIntervalCheck()
        end
    end)
    
    local leaveSafeCheck = createCheckbutton(optionUI.panel, 40, xOffset - 120, "Warn on Leaving Safe Zones", "Enable or disable safe zone leave checks")
    leaveSafeCheck:SetChecked(PurgePvPDB.enableLeaveSafeWarning)
    leaveSafeCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableLeaveSafeWarning = self:GetChecked()
        print("|cFF00FF00PurgePvP leave safe zone warning is now " .. (PurgePvPDB.enableLeaveSafeWarning and "enabled" or "disabled") .. "!|r")
    end)
    
    local leaveSafeMessagesCheck = createCheckbutton(optionUI.panel, 40, xOffset - 150, "Leave Safe Zone Messages", "Enable or disable messages when leaving a safe zone while PvP-flagged")
    leaveSafeMessagesCheck:SetChecked(PurgePvPDB.enableLeaveSafeMessages)
    leaveSafeMessagesCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableLeaveSafeMessages = self:GetChecked()
        print("|cFF00FF00PurgePvP leave safe zone messages is now " .. (PurgePvPDB.enableLeaveSafeMessages and "enabled" or "disabled") .. "!|r")
    end)
    
    local intervalCheck = createCheckbutton(optionUI.panel, 40, xOffset - 180, "60-Second PvP Check", "Enable or disable 60-second PvP status checks")
    intervalCheck:SetChecked(PurgePvPDB.enableIntervalCheck)
    intervalCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableIntervalCheck = self:GetChecked()
        print("|cFF00FF00PurgePvP interval PvP check is now " .. (PurgePvPDB.enableIntervalCheck and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableIntervalCheck then
            StartIntervalCheck()
        elseif intervalTicker then
            intervalTicker:Cancel()
        end
    end)
    
    local autoPvPCheck = createCheckbutton(optionUI.panel, 40, xOffset - 210, "Auto PvP Disable", "Automatically disable PvP status when flagged")
    autoPvPCheck:SetChecked(PurgePvPDB.enableAutoPvPDisable)
    autoPvPCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableAutoPvPDisable = self:GetChecked()
        print("|cFF00FF00PurgePvP auto PvP disable is now " .. (PurgePvPDB.enableAutoPvPDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableAutoPvPDisable then
            CheckPlayerPvPStatus()
            StartIntervalCheck()
        end
    end)
    
    local autoPvPMessagesCheck = createCheckbutton(optionUI.panel, 40, xOffset - 240, "Auto PvP Disable Messages", "Enable or disable messages for auto PvP status disable")
    autoPvPMessagesCheck:SetChecked(PurgePvPDB.enableAutoPvPDisableMessages)
    autoPvPMessagesCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableAutoPvPDisableMessages = self:GetChecked()
        print("|cFF00FF00PurgePvP auto PvP disable messages is now " .. (PurgePvPDB.enableAutoPvPDisableMessages and "enabled" or "disabled") .. "!|r")
    end)
    
    local instanceCheck = createCheckbutton(optionUI.panel, 40, xOffset - 270, "Disable in Instances/Battlegrounds", "Disable PurgePvP features in instances and Battlegrounds")
    instanceCheck:SetChecked(PurgePvPDB.enableInstanceDisable)
    instanceCheck:SetScript("OnClick", function(self)
        PurgePvPDB.enableInstanceDisable = self:GetChecked()
        print("|cFF00FF00PurgePvP instance/Battleground disable is now " .. (PurgePvPDB.enableInstanceDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableInstanceDisable then
            inInstanceOrBattleground = IsInInstanceOrBattleground()
            StartIntervalCheck()
        end
    end)
    
    local resetButton = CreateFrame("Button", nil, optionUI.panel, "UIPanelButtonTemplate")
    resetButton:SetPoint("BOTTOMLEFT", 40, 20)
    resetButton:SetSize(100, 25)
    resetButton:SetText("Reset Defaults")
    resetButton.tooltip = "Reset all PurgePvP settings to their default values"
    resetButton:SetScript("OnClick", function()
        PurgePvPDB = {
            enabled = true,
            enableSound = true,
            enableWarning = true,
            enableSafeZoneDisable = true,
            enableLeaveSafeWarning = true,
            enableIntervalCheck = true,
            isPlayerPvPFlagged = false,
            enableAutoPvPDisable = true,
            enableInstanceDisable = true,
            enableAutoPvPDisableMessages = false,
            enableLeaveSafeMessages = false,
        }
        enableCheck:SetChecked(PurgePvPDB.enabled)
        soundCheck:SetChecked(PurgePvPDB.enableSound)
        warningCheck:SetChecked(PurgePvPDB.enableWarning)
        safeZoneCheck:SetChecked(PurgePvPDB.enableSafeZoneDisable)
        leaveSafeCheck:SetChecked(PurgePvPDB.enableLeaveSafeWarning)
        leaveSafeMessagesCheck:SetChecked(PurgePvPDB.enableLeaveSafeMessages)
        intervalCheck:SetChecked(PurgePvPDB.enableIntervalCheck)
        autoPvPCheck:SetChecked(PurgePvPDB.enableAutoPvPDisable)
        autoPvPMessagesCheck:SetChecked(PurgePvPDB.enableAutoPvPDisableMessages)
        instanceCheck:SetChecked(PurgePvPDB.enableInstanceDisable)
        print("|cFF00FF00PurgePvP settings reset to defaults!|r")
        if PurgePvPDB.enabled then
            inSafeZone = IsInSafeZone()
            inInstanceOrBattleground = IsInInstanceOrBattleground()
            CheckPlayerPvPStatus()
            StartIntervalCheck()
        elseif intervalTicker then
            intervalTicker:Cancel()
        end
    end)
    
    local githubButton = CreateFrame("Button", nil, optionUI.panel, "UIPanelButtonTemplate")
    githubButton:SetPoint("BOTTOMRIGHT", -40, 20)
    githubButton:SetSize(120, 25)
    githubButton:SetText("|cff00b7ebGitHub|r")
    githubButton:SetNormalFontObject("GameFontHighlight")
    githubButton.tooltip = "Visit the PurgePvP GitHub repository"
    githubButton:SetScript("OnClick", function()
        print("|cff00b7ebVisit PurgePvP on GitHub: https://github.com/ToolzGG/PurgePvP|r")
    end)
    githubButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Visit the PurgePvP GitHub repository")
        GameTooltip:Show()
        self:SetCursor("Interface\\Cursor\\Quest.blp")
    end)
    githubButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        githubButton:SetCursor(nil)
    end)
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
        frame:RegisterEvent("ZONE_CHANGED")
        frame:RegisterEvent("ZONE_CHANGED_INDOORS")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        inSafeZone = IsInSafeZone()
        inInstanceOrBattleground = IsInInstanceOrBattleground()
        print("|cFF00FF00PurgePvP loaded! Use /purgepvp or Interface Options to configure.|r")
        C_Timer.After(2, function()
            CheckPlayerPvPStatus()
            StartIntervalCheck()
            loadSettings()
        end)
    elseif event == "PLAYER_FLAGS_CHANGED" then
        CheckPlayerPvPStatus()
        StartIntervalCheck()
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        local wasInSafeZone = inSafeZone
        inSafeZone = IsInSafeZone()
        inInstanceOrBattleground = IsInInstanceOrBattleground()
        if PurgePvPDB.enableLeaveSafeWarning and UnitIsPVP("player") and wasInSafeZone and not inSafeZone and not inInstanceOrBattleground then
            local currentTime = GetTime()
            if PurgePvPDB.enableLeaveSafeMessages and PurgePvPDB.enableWarning and currentTime - lastLeaveSafeMessageTime > 2 then
                CombatText_AddMessage("|cFFFF0000Warning: You are PvP-flagged and left a safe zone!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastLeaveSafeMessageTime = currentTime
            end
            if PurgePvPDB.enableLeaveSafeMessages and PurgePvPDB.enableSound then
                PlaySound("RaidWarning", "Master")
            end
        end
        StartIntervalCheck()
    elseif event == "PLAYER_TARGET_CHANGED" then
        if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) or (PurgePvPDB.enableInstanceDisable and inInstanceOrBattleground) then
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
            return
        end
        local unit = "target"
        if not UnitIsUnit(unit, "player") and UnitExists(unit) and UnitIsPlayer(unit) and (UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)) then
            local currentTime = GetTime()
            local isCombatSafetyActive = UnitIsPVP("player") and not IsInSafeZone()
            if PurgePvPDB.enableWarning and currentTime - lastMessageTime > 2 and not isCombatSafetyActive then
                CombatText_AddMessage("|cFFFF0000PvP Target detected! Target cleared!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastMessageTime = GetTime()
            end
            if PurgePvPDB.enableSound and not isCombatSafetyActive then
                PlaySound("RaidWarning", "Master")
            end
            if not isCombatSafetyActive then
                ClearTarget()
                SetCursor("Interface\\Cursor\\UnableCrosshair.blp")
                GameTooltip:Hide()
                if blockFrame then blockFrame:Hide() end
                blockFrame = CreateFrame("Button", nil, UIParent)
                blockFrame:SetSize(50, 50)
                local scale = UIParent:GetEffectiveScale()
                local x, y = GetCursorPosition()
                blockFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
                blockFrame:SetFrameStrata("FULLSCREEN_DIALOG")
                blockFrame:SetFrameLevel(100)
                blockFrame:EnableMouse(true)
                blockFrame:SetMouseMotionEnabled(false)
                blockFrame:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
                blockFrame:SetScript("OnClick", function(self, button)
                    if PurgePvPDB.enableWarning and GetTime() - lastMessageTime > 2 then
                        CombatText_AddMessage("|cFFFF0000Click on PvP-flagged target blocked!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                        lastMessageTime = GetTime()
                    end
                end)
                blockFrame:SetScript("OnEnter", function() GameTooltip:Hide() end)
            end
            if warningFrame then warningFrame:Hide() end
            warningFrame = CreateFrame("Frame", nil, UIParent)
            warningFrame:SetSize(600, 120)
            warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            local warningText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            warningText:SetText("|cFFFF0000PvP Target!|r")
            C_Timer.After(3, function() warningFrame:Hide() end)
            if not isCombatSafetyActive then
                blockFrame:SetScript("OnUpdate", function(self, elapsed)
                    lastMouseoverCheck = lastMouseoverCheck + elapsed
                    if lastMouseoverCheck > 0.1 then
                        if not UnitExists("mouseover") or UnitIsUnit("mouseover", "player") or not (UnitIsPlayer("mouseover") and (UnitIsPVP("mouseover") or UnitIsPVPFreeForAll("mouseover"))) then
                            blockFrame:Hide()
                            blockFrame = nil
                            SetCursor(nil)
                            GameTooltip:Hide()
                        end
                        lastMouseoverCheck = 0
                    end
                end)
            end
        else
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) or (PurgePvPDB.enableInstanceDisable and inInstanceOrBattleground) then
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
            return
        end
        local unit = "mouseover"
        if not UnitIsUnit(unit, "player") and UnitExists(unit) and UnitIsPlayer(unit) and (UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)) then
            local currentTime = GetTime()
            local isCombatSafetyActive = UnitIsPVP("player") and not IsInSafeZone()
            if PurgePvPDB.enableWarning and currentTime - lastMessageTime > 2 and not isCombatSafetyActive then
                CombatText_AddMessage("|cFFFF0000PvP Target detected! Interaction blocked!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastMessageTime = GetTime()
            end
            if PurgePvPDB.enableSound and not isCombatSafetyActive then
                PlaySound("RaidWarning", "Master")
            end
            if not isCombatSafetyActive then
                SetCursor("Interface\\Cursor\\UnableCrosshair.blp")
                GameTooltip:Hide()
                if blockFrame then blockFrame:Hide() end
                blockFrame = CreateFrame("Button", nil, UIParent)
                blockFrame:SetSize(50, 50)
                local scale = UIParent:GetEffectiveScale()
                local x, y = GetCursorPosition()
                blockFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
                blockFrame:SetFrameStrata("FULLSCREEN_DIALOG")
                blockFrame:SetFrameLevel(100)
                blockFrame:EnableMouse(true)
                blockFrame:SetMouseMotionEnabled(false)
                blockFrame:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
                blockFrame:SetScript("OnClick", function(self, button)
                    if PurgePvPDB.enableWarning and GetTime() - lastMessageTime > 2 then
                        CombatText_AddMessage("|cFFFF0000Click on PvP-flagged target blocked!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                        lastMessageTime = GetTime()
                    end
                end)
                blockFrame:SetScript("OnEnter", function() GameTooltip:Hide() end)
            end
            if warningFrame then warningFrame:Hide() end
            warningFrame = CreateFrame("Frame", nil, UIParent)
            warningFrame:SetSize(600, 120)
            warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            local warningText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            warningText:SetText("|cFFFF0000PvP Target!|r")
            C_Timer.After(3, function() warningFrame:Hide() end)
            if not isCombatSafetyActive then
                blockFrame:SetScript("OnUpdate", function(self, elapsed)
                    lastMouseoverCheck = lastMouseoverCheck + elapsed
                    if lastMouseoverCheck > 0.1 then
                        if not UnitExists("mouseover") or UnitIsUnit("mouseover", "player") or not (UnitIsPlayer("mouseover") and (UnitIsPVP("mouseover") or UnitIsPVPFreeForAll("mouseover"))) then
                            blockFrame:Hide()
                            blockFrame = nil
                            SetCursor(nil)
                            GameTooltip:Hide()
                        end
                        lastMouseoverCheck = 0
                    end
                end)
            end
        else
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
        end
    end
end

frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("PLAYER_LOGIN")

SLASH_PURGEPVP1 = "/purgepvp"
SlashCmdList["PURGEPVP"] = function(msg)
    local cmd = string.lower(msg or "")
    if cmd == "" then
        InterfaceOptionsFrame_OpenToCategory(optionUI.panel)
        InterfaceOptionsFrame_OpenToCategory(optionUI.panel)
    elseif cmd == "toggle" then
        PurgePvPDB.enabled = not PurgePvPDB.enabled
        print("|cFF00FF00PurgePvP is now " .. (PurgePvPDB.enabled and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enabled then
            inSafeZone = IsInSafeZone()
            inInstanceOrBattleground = IsInInstanceOrBattleground()
            CheckPlayerPvPStatus()
            StartIntervalCheck()
        elseif intervalTicker then
            intervalTicker:Cancel()
        end
    elseif cmd == "sound" then
        PurgePvPDB.enableSound = not PurgePvPDB.enableSound
        print("|cFF00FF00PurgePvP sound is now " .. (PurgePvPDB.enableSound and "enabled" or "disabled") .. "!|r")
    elseif cmd == "warning" then
        PurgePvPDB.enableWarning = not PurgePvPDB.enableWarning
        print("|cFF00FF00PurgePvP warnings are now " .. (PurgePvPDB.enableWarning and "enabled" or "disabled") .. "!|r")
    elseif cmd == "safezone" then
        PurgePvPDB.enableSafeZoneDisable = not PurgePvPDB.enableSafeZoneDisable
        print("|cFF00FF00PurgePvP safe zone disable is now " .. (PurgePvPDB.enableSafeZoneDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableSafeZoneDisable then
            inSafeZone = IsInSafeZone()
            StartIntervalCheck()
        end
    elseif cmd == "leavesafe" then
        PurgePvPDB.enableLeaveSafeWarning = not PurgePvPDB.enableLeaveSafeWarning
        print("|cFF00FF00PurgePvP leave safe zone warning is now " .. (PurgePvPDB.enableLeaveSafeWarning and "enabled" or "disabled") .. "!|r")
    elseif cmd == "leavesafemessages" then
        PurgePvPDB.enableLeaveSafeMessages = not PurgePvPDB.enableLeaveSafeMessages
        print("|cFF00FF00PurgePvP leave safe zone messages is now " .. (PurgePvPDB.enableLeaveSafeMessages and "enabled" or "disabled") .. "!|r")
    elseif cmd == "interval" then
        PurgePvPDB.enableIntervalCheck = not PurgePvPDB.enableIntervalCheck
        print("|cFF00FF00PurgePvP interval PvP check is now " .. (PurgePvPDB.enableIntervalCheck and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableIntervalCheck then
            StartIntervalCheck()
        elseif intervalTicker then
            intervalTicker:Cancel()
        end
    elseif cmd == "autopvp" then
        PurgePvPDB.enableAutoPvPDisable = not PurgePvPDB.enableAutoPvPDisable
        print("|cFF00FF00PurgePvP auto PvP disable is now " .. (PurgePvPDB.enableAutoPvPDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableAutoPvPDisable then
            CheckPlayerPvPStatus()
            StartIntervalCheck()
        end
    elseif cmd == "autopvpmessages" then
        PurgePvPDB.enableAutoPvPDisableMessages = not PurgePvPDB.enableAutoPvPDisableMessages
        print("|cFF00FF00PurgePvP auto PvP disable messages is now " .. (PurgePvPDB.enableAutoPvPDisableMessages and "enabled" or "disabled") .. "!|r")
    elseif cmd == "instances" then
        PurgePvPDB.enableInstanceDisable = not PurgePvPDB.enableInstanceDisable
        print("|cFF00FF00PurgePvP instance/Battleground disable is now " .. (PurgePvPDB.enableInstanceDisable and "enabled" or "disabled") .. "!|r")
        if PurgePvPDB.enableInstanceDisable then
            inInstanceOrBattleground = IsInInstanceOrBattleground()
            StartIntervalCheck()
        end
    else
        print("|cFF00FF00PurgePvP commands:|r")
        print("/purgepvp - Open the options panel")
        print("/purgepvp toggle - Toggle addon on/off")
        print("/purgepvp sound - Toggle sound alerts")
        print("/purgepvp warning - Toggle warning messages")
        print("/purgepvp safezone - Toggle auto-disable in safe zones")
        print("/purgepvp leavesafe - Toggle warning when leaving safe zones")
        print("/purgepvp leavesafemessages - Toggle messages when leaving safe zones")
        print("/purgepvp interval - Toggle 60-second PvP status check")
        print("/purgepvp autopvp - Toggle auto PvP status disable")
        print("/purgepvp autopvpmessages - Toggle auto PvP disable messages")
        print("/purgepvp instances - Toggle auto-disable in instances/Battlegrounds")
    end
end
