local _, addon = ...

addon.name = "Activate Windows"
addon.locked = true
ActivateWindowsDB = ActivateWindowsDB or {}

function addon:Debug(...)
    print("|cffffff00[" .. self.name .. "]|r", ...)
end

function addon:UpdateLockVisual()
    if not self.frame then return end

    if addon.locked then
        self.frame:SetBackdropBorderColor(1, 0, 0, 0) -- red border hidden
    else
        self.frame:SetBackdropBorderColor(1, 0, 0, 1) -- red border visible

    end
end

function addon:CreateFrame()
    if self.frame then return end

    local f = self.frame or CreateFrame("Frame", "ActivateWindows", UIParent, "BackdropTemplate")
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint(ActivateWindowsDB.left or "CENTER", UIParent, ActivateWindowsDB.right or "CENTER", ActivateWindowsDB.x or 0, ActivateWindowsDB.y or 0)
    f:SetSize(400, 80)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)

    f:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    f:SetBackdropBorderColor(1, 0, 0, 0)

    f:SetScript("OnDragStart", function(self)
        if addon.locked then return end
        self:StartMoving()
    end)

    f:SetScript("OnDragStop", function(self)
        local l,_,r,x,y = f:GetPoint()
        ActivateWindowsDB.x = x
        ActivateWindowsDB.y = y
        ActivateWindowsDB.left = l
        ActivateWindowsDB.right = r
        self:StopMovingOrSizing()
    end)

    f:SetScript("OnMouseUp", function(self, button)
        if button ~= "RightButton" then return end
        if InCombatLockdown() then
            addon:Debug("Cannot lock/unlock frame while in combat.")
            if not addon.locked then 
                addon.locked = true
                addon:UpdateLockVisual()
            end
            return
        end

        addon.locked = not addon.locked
        addon:UpdateLockVisual()
    end)

    

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 20)
    title:SetJustifyH("LEFT")
    title:SetFont(GameFontNormal:GetFont(), 24)
    title:SetTextColor(1, 1, 1, 0.35)
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 0.6)
    title:SetText("Activate Windows")

    local subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetFont(GameFontNormal:GetFont(), 18)
    subtitle:SetTextColor(0.7, 0.7, 0.7, 0.35)
    subtitle:SetShadowOffset(1, -1)
    subtitle:SetShadowColor(0, 0, 0, 0.6)
    subtitle:SetText("Go to Settings to activate Windows.")

    self.frame = f
    self:UpdateLockVisual()

end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        addon:CreateFrame()
    end
    if event == "PLAYER_REGEN_DISABLED" then
        if not addon.locked then
            addon.locked = true
            addon:UpdateLockVisual()
            addon:Debug("Frame locked due to entering combat.")
        end
    end
end)