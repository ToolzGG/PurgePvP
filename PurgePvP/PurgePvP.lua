local addonName = ...

PurgePvPDB = PurgePvPDB or {
    enabled = true,
    enableSound = true,
    enableWarning = true,
    enableSafeZoneDisable = true,
    enableLeaveSafeWarning = true,
}

local frame = CreateFrame("Frame")
local blockFrame = nil
local warningFrame = nil
local playerWarningFrame = nil
local lastMessageTime = 0
local lastMouseoverCheck = 0
local inSafeZone = false
local lastLeaveSafeMessageTime = 0

local function IsInSafeZone()
    local pvpType = GetZonePVPInfo()
    return pvpType == "sanctuary" or pvpType == "friendly"
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
        print("|cFF00FF00PurgePvP loaded! Use /purgepvp for options.|r")
    elseif event == "PLAYER_FLAGS_CHANGED" then
        if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) then return end
        if UnitIsPVP("player") then
            if PurgePvPDB.enableWarning then
                CombatText_AddMessage("|cFFFF0000You are PvP-flagged! Avoid combat for 15 minutes!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
            end
            if PurgePvPDB.enableSound then
                PlaySound("RaidWarning", "Master")
            end
            if playerWarningFrame then playerWarningFrame:Hide() end
            playerWarningFrame = CreateFrame("Frame", nil, UIParent)
            playerWarningFrame:SetSize(600, 120)
            playerWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
            local warningText = playerWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            warningText:SetText("|cFFFF0000YOU ARE PVP FLAGGED! AVOID CASTING!|r")
            if PurgePvPDB.enableSound then
                C_Timer.NewTicker(2, function() PlaySound("RaidWarning", "Master") end, 5)
            end
            C_Timer.After(10, function() playerWarningFrame:Hide() end)
        end
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        local wasInSafeZone = inSafeZone
        inSafeZone = IsInSafeZone()
        if PurgePvPDB.enableLeaveSafeWarning and UnitIsPVP("player") and wasInSafeZone and not inSafeZone then
            local currentTime = GetTime()
            if PurgePvPDB.enableWarning and currentTime - lastLeaveSafeMessageTime > 2 then
                CombatText_AddMessage("|cFFFF0000Warning: You are PvP-flagged and left a safe zone!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastLeaveSafeMessageTime = currentTime
            end
            if PurgePvPDB.enableSound then
                PlaySound("RaidWarning", "Master")
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) then
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
            return
        end
        local unit = "target"
        if not UnitIsUnit(unit, "player") and UnitExists(unit) and UnitIsPlayer(unit) and (UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)) then
            ClearTarget()
            local currentTime = GetTime()
            if PurgePvPDB.enableWarning and currentTime - lastMessageTime > 2 then
                CombatText_AddMessage("|cFFFF0000PvP Target detected! Target cleared!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastMessageTime = currentTime
            end
            if PurgePvPDB.enableSound then
                PlaySound("RaidWarning", "Master")
            end
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
            if warningFrame then warningFrame:Hide() end
            warningFrame = CreateFrame("Frame", nil, UIParent)
            warningFrame:SetSize(600, 120)
            warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            local warningText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            warningText:SetText("|cFFFF0000PvP Target!|r")
            C_Timer.After(5, function() warningFrame:Hide() end)
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
        else
            if blockFrame then
                blockFrame:Hide()
                blockFrame = nil
            end
            SetCursor(nil)
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if not PurgePvPDB.enabled or (PurgePvPDB.enableSafeZoneDisable and inSafeZone) then
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
            if PurgePvPDB.enableWarning and currentTime - lastMessageTime > 2 then
                CombatText_AddMessage("|cFFFF0000PvP Target detected! Interaction blocked!|r", COMBAT_TEXT_SCROLL_FUNCTION, 1, 0, 0)
                lastMessageTime = currentTime
            end
            if PurgePvPDB.enableSound then
                PlaySound("RaidWarning", "Master")
            end
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
            if warningFrame then warningFrame:Hide() end
            warningFrame = CreateFrame("Frame", nil, UIParent)
            warningFrame:SetSize(600, 120)
            warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            local warningText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            warningText:SetText("|cFFFF0000PvP Target!|r")
            C_Timer.After(5, function() warningFrame:Hide() end)
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
    local cmd = string.lower(msg)
    if cmd == "toggle" then
        PurgePvPDB.enabled = not PurgePvPDB.enabled
        print("|cFF00FF00PurgePvP is now " .. (PurgePvPDB.enabled and "enabled" or "disabled") .. "!|r")
    elseif cmd == "sound" then
        PurgePvPDB.enableSound = not PurgePvPDB.enableSound
        print("|cFF00FF00PurgePvP sound is now " .. (PurgePvPDB.enableSound and "enabled" or "disabled") .. "!|r")
    elseif cmd == "warning" then
        PurgePvPDB.enableWarning = not PurgePvPDB.enableWarning
        print("|cFF00FF00PurgePvP warnings are now " .. (PurgePvPDB.enableWarning and "enabled" or "disabled") .. "!|r")
    elseif cmd == "safezone" then
        PurgePvPDB.enableSafeZoneDisable = not PurgePvPDB.enableSafeZoneDisable
        print("|cFF00FF00PurgePvP safe zone disable is now " .. (PurgePvPDB.enableSafeZoneDisable and "enabled" or "disabled") .. "!|r")
    elseif cmd == "leavesafe" then
        PurgePvPDB.enableLeaveSafeWarning = not PurgePvPDB.enableLeaveSafeWarning
        print("|cFF00FF00PurgePvP leave safe zone warning is now " .. (PurgePvPDB.enableLeaveSafeWarning and "enabled" or "disabled") .. "!|r")
    else
        print("|cFF00FF00PurgePvP commands:|r")
        print("/purgepvp toggle - Toggle addon on/off")
        print("/purgepvp sound - Toggle sound alerts")
        print("/purgepvp warning - Toggle warning messages")
        print("/purgepvp safezone - Toggle auto-disable in safe zones")
        print("/purgepvp leavesafe - Toggle warning when leaving safe zones")
    end
end