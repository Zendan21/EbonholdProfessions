local addonName = ...

local ADDON_VERSION = "1.2.0"
local PREFIX = "|cff58c6ffEbonhold Professions:|r "
local PANEL_WIDTH = 500
local PANEL_PADDING = 16
local BUTTON_WIDTH = 226
local BUTTON_HEIGHT = 52
local BUTTON_GAP = 8
local COLUMNS = 2
local LAUNCHER_ICON = "Interface\\Icons\\INV_Misc_Book_09"
local SPELL_BOOK_TYPE = BOOKTYPE_SPELL or "spell"

-- skillSpellID supplies the localized profession name. actionSpellID is the
-- spell which opens that profession (or performs its active gathering action).
-- A nil action means the profession is still listed, but has no window to open.
local professionDefinitions = {
    {
        key = "ALCHEMY", skillSpellID = 2259, actionSpellID = 2259,
        rankSpellIDs = { 2259, 3101, 3464, 11611, 28596, 51304 },
    },
    {
        key = "BLACKSMITHING", skillSpellID = 2018, actionSpellID = 2018,
        rankSpellIDs = { 2018, 3100, 3538, 9785, 29844, 51300 },
    },
    {
        key = "COOKING", skillSpellID = 2550, actionSpellID = 2550,
        rankSpellIDs = { 2550, 3102, 3413, 18260, 33359, 51296 },
        extraAbilities = {
            { spellID = 818, fallbackName = "Basic Campfire" },
        },
    },
    {
        key = "ENCHANTING", skillSpellID = 7411, actionSpellID = 7411,
        rankSpellIDs = { 7411, 7412, 7413, 13920, 28029, 51313 },
        extraAbilities = {
            { spellID = 13262, fallbackName = "Disenchant" },
        },
    },
    {
        key = "ENGINEERING", skillSpellID = 4036, actionSpellID = 4036,
        rankSpellIDs = { 4036, 4037, 4038, 12656, 30350, 51306 },
    },
    {
        key = "FIRST_AID", skillSpellID = 3273, actionSpellID = 3273,
        rankSpellIDs = { 3273, 3274, 7924, 10846, 27028, 45542 },
    },
    {
        key = "FISHING", skillSpellID = 7620, actionSpellID = 7620,
        rankSpellIDs = { 7620, 7731, 7732, 18248, 33095, 51294 },
        extraAbilities = {
            { spellID = 43308, fallbackName = "Find Fish" },
        },
    },
    {
        key = "HERBALISM", skillSpellID = 2366, actionSpellID = nil,
        rankSpellIDs = { 2366, 2368, 3570, 11993, 28695, 50300 },
        extraAbilities = {
            { spellID = 2383, fallbackName = "Find Herbs" },
        },
    },
    {
        key = "INSCRIPTION", skillSpellID = 45357, actionSpellID = 45357,
        rankSpellIDs = { 45357, 45358, 45359, 45360, 45361, 45363 },
        extraAbilities = {
            { spellID = 51005, fallbackName = "Milling" },
        },
    },
    {
        key = "JEWELCRAFTING", skillSpellID = 25229, actionSpellID = 25229,
        rankSpellIDs = { 25229, 25230, 28894, 28895, 28897, 51311 },
        extraAbilities = {
            { spellID = 31252, fallbackName = "Prospecting" },
        },
    },
    {
        key = "LEATHERWORKING", skillSpellID = 2108, actionSpellID = 2108,
        rankSpellIDs = { 2108, 3104, 3811, 10662, 32549, 51302 },
    },
    {
        key = "MINING", skillSpellID = 2575, actionSpellID = 2656,
        rankSpellIDs = { 2575, 2576, 3564, 10248, 29354, 50310 },
        extraAbilities = {
            { spellID = 2580, fallbackName = "Find Minerals" },
        },
    },
    {
        key = "SKINNING", skillSpellID = 8613, actionSpellID = nil,
        rankSpellIDs = { 8613, 8617, 8618, 10768, 32678, 50305 },
    },
    {
        key = "TAILORING", skillSpellID = 3908, actionSpellID = 3908,
        rankSpellIDs = { 3908, 3909, 3910, 12180, 26790, 51309 },
    },
    {
        key = "RUNEFORGING", skillSpellID = 53428, actionSpellID = 53428,
        rankSpellIDs = { 53428 },
    },
}

local fallbackNames = {
    ALCHEMY = "Alchemy",
    BLACKSMITHING = "Blacksmithing",
    COOKING = "Cooking",
    ENCHANTING = "Enchanting",
    ENGINEERING = "Engineering",
    FIRST_AID = "First Aid",
    FISHING = "Fishing",
    HERBALISM = "Herbalism",
    INSCRIPTION = "Inscription",
    JEWELCRAFTING = "Jewelcrafting",
    LEATHERWORKING = "Leatherworking",
    MINING = "Mining",
    SKINNING = "Skinning",
    TAILORING = "Tailoring",
    RUNEFORGING = "Runeforging",
}

local eventFrame = CreateFrame("Frame")
local panel
local launcherButton
local minimapButton
local professionButtons = {}
local refreshPending
local lastScanDetails = {
    skillCount = 0,
    spellCount = 0,
    spellIDCount = 0,
    professionAPICount = 0,
    knownCount = 0,
    abilityCount = 0,
    knownNames = {},
    skillNames = {},
    errors = {},
}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. message)
end

local function Trim(value)
    return (value or ""):match("^%s*(.-)%s*$")
end

local function GetProfessionName(definition)
    local name = GetSpellInfo(definition.skillSpellID)
    return name or fallbackNames[definition.key]
end

local function RecordScanError(source, message)
    table.insert(lastScanDetails.errors, source .. ": " .. tostring(message))
end

local function BuildSpellBookIndex()
    local spells = {}
    local spellIDs = {}
    local spellCount = 0
    local spellIDCount = 0

    if type(GetNumSpellTabs) ~= "function"
        or type(GetSpellTabInfo) ~= "function"
        or type(GetSpellName) ~= "function"
    then
        RecordScanError("spellbook", "one or more spellbook APIs are unavailable")
        return spells, spellIDs
    end

    local countOK, tabCount = pcall(GetNumSpellTabs)
    if not countOK then
        RecordScanError("GetNumSpellTabs", tabCount)
        return spells, spellIDs
    end

    for tabIndex = 1, tabCount do
        local tabOK, _, _, offset, spellsInTab = pcall(GetSpellTabInfo, tabIndex)
        if tabOK and type(offset) == "number" and type(spellsInTab) == "number" then
            for spellIndex = offset + 1, offset + spellsInTab do
                local spellOK, spellName, spellRank =
                    pcall(GetSpellName, spellIndex, SPELL_BOOK_TYPE)

                if spellOK and spellName then
                    local _, _, texture = GetSpellInfo(spellName)
                    spellCount = spellCount + 1
                    spells[string.lower(spellName)] = {
                        name = spellName,
                        rank = spellRank,
                        index = spellIndex,
                        texture = texture,
                    }

                    if type(GetSpellBookItemInfo) == "function" then
                        local itemOK, _, spellID =
                            pcall(GetSpellBookItemInfo, spellIndex, SPELL_BOOK_TYPE)
                        if itemOK and type(spellID) == "number" then
                            if not spellIDs[spellID] then
                                spellIDCount = spellIDCount + 1
                            end
                            spellIDs[spellID] = true
                        elseif not itemOK then
                            RecordScanError("GetSpellBookItemInfo", spellID)
                        end
                    end
                elseif not spellOK then
                    RecordScanError("GetSpellName", spellName)
                    break
                end
            end
        elseif not tabOK then
            RecordScanError("GetSpellTabInfo", offset)
        end
    end

    lastScanDetails.spellCount = spellCount
    lastScanDetails.spellIDCount = spellIDCount
    return spells, spellIDs
end

local function BuildSkillIndex()
    local skills = {}
    local skillCount = 0

    if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then
        RecordScanError("skills", "one or more skill APIs are unavailable")
        return skills
    end

    local countOK, lineCount = pcall(GetNumSkillLines)
    if not countOK then
        RecordScanError("GetNumSkillLines", lineCount)
        return skills
    end

    for skillIndex = 1, lineCount do
        local skillOK, skillName, isHeader, _, skillRank, _, _, skillMaxRank =
            pcall(GetSkillLineInfo, skillIndex)

        if skillOK then
            if skillName and not isHeader then
                skillCount = skillCount + 1
                table.insert(
                    lastScanDetails.skillNames,
                    skillName .. " " .. (skillRank or 0) .. "/" .. (skillMaxRank or 0)
                )
                skills[string.lower(skillName)] = {
                    rank = skillRank or 0,
                    maxRank = skillMaxRank or 0,
                }
            end
        else
            RecordScanError("GetSkillLineInfo", skillName)
            break
        end
    end

    lastScanDetails.skillCount = skillCount
    return skills
end

local function IsAnyRankSpellKnown(definition)
    if type(IsSpellKnown) ~= "function" then
        return false
    end

    for _, spellID in ipairs(definition.rankSpellIDs or {}) do
        local knownOK, isKnown = pcall(IsSpellKnown, spellID)
        if knownOK and isKnown then
            return true
        elseif not knownOK then
            RecordScanError("IsSpellKnown", isKnown)
            return false
        end
    end

    return false
end

local function IsAnyRankSpellInBook(definition, spellIDs)
    for _, spellID in ipairs(definition.rankSpellIDs or {}) do
        if spellIDs[spellID] then
            return true
        end
    end

    return false
end

local function IsSpellIDKnown(spellID, spellIDs)
    if spellIDs[spellID] then
        return true
    end

    if type(IsSpellKnown) == "function" then
        local knownOK, isKnown = pcall(IsSpellKnown, spellID)
        if knownOK then
            return isKnown and true or false
        end
    end

    return false
end

local function BuildProfessionAPIIndex()
    local professions = {}

    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then
        return professions
    end

    local function Pack(...)
        return { n = select("#", ...), ... }
    end

    local results = Pack(pcall(GetProfessions))
    if not results[1] then
        RecordScanError("GetProfessions", results[2])
        return professions
    end

    for resultIndex = 2, results.n do
        local professionIndex = results[resultIndex]
        if professionIndex then
            local infoOK, name, icon, rank, maxRank =
                pcall(GetProfessionInfo, professionIndex)

            if infoOK and name then
                professions[string.lower(name)] = {
                    rank = rank or 0,
                    maxRank = maxRank or 0,
                    texture = icon,
                }
                lastScanDetails.professionAPICount =
                    lastScanDetails.professionAPICount + 1
            elseif not infoOK then
                RecordScanError("GetProfessionInfo", name)
            end
        end
    end

    return professions
end

local function FindKnownProfessions()
    local known = {}
    lastScanDetails = {
        skillCount = 0,
        spellCount = 0,
        spellIDCount = 0,
        professionAPICount = 0,
        knownCount = 0,
        abilityCount = 0,
        knownNames = {},
        skillNames = {},
        errors = {},
    }
    local spells, spellIDs = BuildSpellBookIndex()
    local skills = BuildSkillIndex()
    local professionAPI = BuildProfessionAPIIndex()

    for _, definition in ipairs(professionDefinitions) do
        local professionName = GetProfessionName(definition)
        local professionKey = string.lower(professionName)
        local fallbackKey = string.lower(fallbackNames[definition.key])
        local skill = skills[professionKey] or skills[fallbackKey]
        local professionSpell = spells[professionKey] or spells[fallbackKey]
        local apiProfession = professionAPI[professionKey] or professionAPI[fallbackKey]
        local knownBySpellID = IsAnyRankSpellKnown(definition)
        local knownByBookID = IsAnyRankSpellInBook(definition, spellIDs)
        local actionName
        local actionSpell

        if definition.actionSpellID then
            actionName = GetSpellInfo(definition.actionSpellID)
            if actionName then
                actionSpell = spells[string.lower(actionName)]
            end
        end

        -- Skill lines are the authoritative source on Ebonhold because the
        -- stock GetProfessions API only exposes two primary professions.
        if skill
            or professionSpell
            or actionSpell
            or apiProfession
            or knownBySpellID
            or knownByBookID
        then
            local texture = (actionSpell and actionSpell.texture)
                or (professionSpell and professionSpell.texture)
                or (apiProfession and apiProfession.texture)
                or (definition.actionSpellID and select(3, GetSpellInfo(definition.actionSpellID)))
                or select(3, GetSpellInfo(definition.skillSpellID))
                or "Interface\\Icons\\INV_Misc_QuestionMark"

            local knownActionName = actionSpell and actionSpell.name
            if not knownActionName and definition.actionSpellID then
                knownActionName = actionName
            end

            table.insert(known, {
                key = definition.key,
                name = professionName,
                rank = (skill and skill.rank) or (apiProfession and apiProfession.rank) or 0,
                maxRank = (skill and skill.maxRank) or (apiProfession and apiProfession.maxRank) or 0,
                actionName = knownActionName,
                texture = texture,
                sortKey = professionName .. " 0",
            })

            lastScanDetails.knownCount = lastScanDetails.knownCount + 1
            table.insert(lastScanDetails.knownNames, professionName)

            for _, ability in ipairs(definition.extraAbilities or {}) do
                local abilityName = GetSpellInfo(ability.spellID) or ability.fallbackName
                local abilitySpell = abilityName and spells[string.lower(abilityName)]
                local abilityKnown =
                    abilitySpell or IsSpellIDKnown(ability.spellID, spellIDs)

                if abilityKnown then
                    local _, _, abilityTexture = GetSpellInfo(ability.spellID)
                    table.insert(known, {
                        key = definition.key .. "_UTILITY_" .. ability.spellID,
                        name = abilityName,
                        rank = 0,
                        maxRank = 0,
                        detailText = professionName .. " ability",
                        actionName = abilitySpell and abilitySpell.name or abilityName,
                        texture = (abilitySpell and abilitySpell.texture)
                            or abilityTexture
                            or "Interface\\Icons\\INV_Misc_QuestionMark",
                        isUtility = true,
                        sortKey = professionName .. " 1 " .. abilityName,
                    })
                    lastScanDetails.abilityCount =
                        lastScanDetails.abilityCount + 1
                end
            end
        end
    end

    table.sort(known, function(left, right)
        return left.sortKey < right.sortKey
    end)

    return known
end

local function SetButtonBackdrop(button, red, green, blue, alpha)
    button:SetBackdropColor(red, green, blue, alpha)
    button:SetBackdropBorderColor(0.22, 0.25, 0.30, 1)
end

local function ProfessionButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.professionName or "", 1, 0.82, 0)

    if self.rankText and self.rankText ~= "" then
        GameTooltip:AddLine(self.rankText, 1, 1, 1)
    end

    if self.isUtility then
        GameTooltip:AddLine("Click to use this profession ability.", 0.45, 0.9, 1, true)
    elseif self.actionName then
        GameTooltip:AddLine("Click to open or use this profession.", 0.45, 0.9, 1, true)
    else
        GameTooltip:AddLine(
            "This gathering profession has no recipe window to open.",
            0.65,
            0.65,
            0.65,
            true
        )
    end

    GameTooltip:Show()
end

local function ProfessionButton_OnLeave()
    GameTooltip:Hide()
end

local function CreateProfessionButton(index)
    local button = CreateFrame(
        "Button",
        addonName .. "ProfessionButton" .. index,
        panel,
        "SecureActionButtonTemplate"
    )
    button:SetWidth(BUTTON_WIDTH)
    button:SetHeight(BUTTON_HEIGHT)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    SetButtonBackdrop(button, 0.055, 0.065, 0.085, 0.98)
    button:RegisterForClicks("LeftButtonUp")

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetWidth(38)
    button.icon:SetHeight(38)
    button.icon:SetPoint("LEFT", button, "LEFT", 8, 0)
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.iconBorder = button:CreateTexture(nil, "OVERLAY")
    button.iconBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    button.iconBorder:SetWidth(62)
    button.iconBorder:SetHeight(62)
    button.iconBorder:SetPoint("CENTER", button.icon, "CENTER", 0, 0)

    button.nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.nameText:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 10, -4)
    button.nameText:SetPoint("RIGHT", button, "RIGHT", -8, 0)
    button.nameText:SetJustifyH("LEFT")

    button.rankLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.rankLabel:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 10, 4)
    button.rankLabel:SetPoint("RIGHT", button, "RIGHT", -8, 0)
    button.rankLabel:SetJustifyH("LEFT")
    button.rankLabel:SetTextColor(0.68, 0.72, 0.78)

    button:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
    local highlight = button:GetHighlightTexture()
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.35)

    button:SetScript("OnEnter", ProfessionButton_OnEnter)
    button:SetScript("OnLeave", ProfessionButton_OnLeave)

    return button
end

local function CreatePanel()
    panel = CreateFrame("Frame", addonName .. "Panel", UIParent)
    panel:SetWidth(PANEL_WIDTH)
    panel:SetHeight(150)
    if EbonholdProfessionsDB.position then
        local position = EbonholdProfessionsDB.position
        panel:SetPoint(
            position.point or "CENTER",
            UIParent,
            position.relativePoint or "CENTER",
            position.x or 0,
            position.y or 40
        )
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    end
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self)
        if not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint(1)
        EbonholdProfessionsDB.position = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    panel:Hide()

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -17)
    panel.title:SetText("Ebonhold Professions")
    panel.title:SetTextColor(1, 0.82, 0)

    panel.subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.subtitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -4)
    panel.subtitle:SetText("Every profession learned by this character  |cff707780v" .. ADDON_VERSION .. "|r")
    panel.subtitle:SetTextColor(0.65, 0.7, 0.78)

    panel.closeButton = CreateFrame(
        "Button",
        addonName .. "CloseButton",
        panel,
        "UIPanelCloseButton"
    )
    panel.closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)

    panel.emptyText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.emptyText:SetPoint("CENTER", panel, "CENTER", 0, -18)
    panel.emptyText:SetText("No learned professions were found.")
    panel.emptyText:SetTextColor(0.65, 0.65, 0.65)
    panel.emptyText:Hide()

    panel.hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    panel.hint:SetPoint("BOTTOM", panel, "BOTTOM", 0, 15)
    panel.hint:SetText("Drag this window by its background  -  /ehp toggles it")

    panel:SetScript("OnShow", function()
        if not InCombatLockdown() then
            EbonholdProfessions_SafeRefresh(false)
        end
    end)
end

local function SaveLauncherPosition()
    local point, _, relativePoint, x, y = launcherButton:GetPoint(1)
    EbonholdProfessionsDB.launcherPosition = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

local function CreateLauncherButton()
    launcherButton = CreateFrame("Button", addonName .. "LauncherButton", UIParent)
    launcherButton:SetWidth(36)
    launcherButton:SetHeight(36)
    launcherButton:SetFrameStrata("HIGH")
    launcherButton:SetClampedToScreen(true)
    launcherButton:SetMovable(true)
    launcherButton:RegisterForClicks("LeftButtonUp")
    launcherButton:RegisterForDrag("RightButton")

    local position = EbonholdProfessionsDB.launcherPosition
    if position then
        launcherButton:SetPoint(
            position.point or "CENTER",
            UIParent,
            position.relativePoint or "CENTER",
            position.x or 0,
            position.y or -260
        )
    else
        launcherButton:SetPoint("CENTER", UIParent, "CENTER", 0, -260)
    end

    launcherButton.icon = launcherButton:CreateTexture(nil, "BACKGROUND")
    launcherButton.icon:SetAllPoints()
    launcherButton.icon:SetTexture(LAUNCHER_ICON)
    launcherButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    launcherButton.border = launcherButton:CreateTexture(nil, "OVERLAY")
    launcherButton.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    launcherButton.border:SetWidth(60)
    launcherButton.border:SetHeight(60)
    launcherButton.border:SetPoint("CENTER")

    launcherButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    launcherButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

    launcherButton:SetScript("OnClick", function()
        EbonholdProfessions_Toggle()
    end)
    launcherButton:SetScript("OnDragStart", function(self)
        if not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    launcherButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveLauncherPosition()
    end)
    launcherButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ebonhold Professions", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open professions", 1, 1, 1)
        GameTooltip:AddLine("Right-drag: move this button", 0.65, 0.7, 0.78)
        GameTooltip:Show()
    end)
    launcherButton:SetScript("OnLeave", ProfessionButton_OnLeave)

    if EbonholdProfessionsDB.floatingButtonShown then
        launcherButton:Show()
    else
        launcherButton:Hide()
    end
end

local function SetMinimapButtonPosition(x, y)
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateMinimapButtonPosition()
    local scale = Minimap:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    local centerX, centerY = Minimap:GetCenter()

    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local deltaX = cursorX - centerX
    local deltaY = cursorY - centerY
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    if distance < 1 then
        return
    end

    local radius = 78
    local x = deltaX / distance * radius
    local y = deltaY / distance * radius
    EbonholdProfessionsDB.minimapX = x
    EbonholdProfessionsDB.minimapY = y
    SetMinimapButtonPosition(x, y)
end

local function CreateMinimapButton()
    minimapButton = CreateFrame("Button", addonName .. "MinimapButton", Minimap)
    minimapButton:SetWidth(32)
    minimapButton:SetHeight(32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    minimapButton:RegisterForClicks("LeftButtonUp")
    minimapButton:RegisterForDrag("RightButton")

    SetMinimapButtonPosition(
        EbonholdProfessionsDB.minimapX or -55,
        EbonholdProfessionsDB.minimapY or -55
    )

    minimapButton.background = minimapButton:CreateTexture(nil, "BACKGROUND")
    minimapButton.background:SetWidth(24)
    minimapButton.background:SetHeight(24)
    minimapButton.background:SetPoint("CENTER")
    minimapButton.background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    minimapButton.icon = minimapButton:CreateTexture(nil, "ARTWORK")
    minimapButton.icon:SetWidth(20)
    minimapButton.icon:SetHeight(20)
    minimapButton.icon:SetPoint("CENTER")
    minimapButton.icon:SetTexture(LAUNCHER_ICON)
    minimapButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    minimapButton.border = minimapButton:CreateTexture(nil, "OVERLAY")
    minimapButton.border:SetWidth(54)
    minimapButton.border:SetHeight(54)
    minimapButton.border:SetPoint("TOPLEFT")
    minimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    minimapButton.highlight = minimapButton:CreateTexture(nil, "HIGHLIGHT")
    minimapButton.highlight:SetWidth(32)
    minimapButton.highlight:SetHeight(32)
    minimapButton.highlight:SetPoint("CENTER")
    minimapButton.highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    minimapButton.highlight:SetBlendMode("ADD")

    minimapButton:SetScript("OnClick", function()
        EbonholdProfessions_Toggle()
    end)
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", UpdateMinimapButtonPosition)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        UpdateMinimapButtonPosition()
    end)
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Ebonhold Professions", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open professions", 1, 1, 1)
        GameTooltip:AddLine("Right-drag: move around the minimap", 0.65, 0.7, 0.78)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", ProfessionButton_OnLeave)

    if EbonholdProfessionsDB.minimapButtonShown then
        minimapButton:Show()
    else
        minimapButton:Hide()
    end
end

function EbonholdProfessions_Refresh()
    if InCombatLockdown() then
        refreshPending = true
        return
    end

    local known = FindKnownProfessions()
    local rows = math.max(1, math.ceil(#known / COLUMNS))
    local contentTop = 66
    local contentHeight = rows * BUTTON_HEIGHT + (rows - 1) * BUTTON_GAP
    panel:SetHeight(contentTop + contentHeight + 42)

    for index, profession in ipairs(known) do
        local button = professionButtons[index]
        if not button then
            button = CreateProfessionButton(index)
            professionButtons[index] = button
        end

        local column = (index - 1) % COLUMNS
        local row = math.floor((index - 1) / COLUMNS)
        button:ClearAllPoints()
        button:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            PANEL_PADDING + column * (BUTTON_WIDTH + BUTTON_GAP),
            -contentTop - row * (BUTTON_HEIGHT + BUTTON_GAP)
        )

        local rankText = ""
        if profession.maxRank and profession.maxRank > 0 then
            rankText = profession.rank .. " / " .. profession.maxRank
        end

        button.professionName = profession.name
        button.rankText = profession.detailText or rankText
        button.actionName = profession.actionName
        button.isUtility = profession.isUtility
        button.icon:SetTexture(profession.texture)
        button.nameText:SetText(profession.name)
        button.rankLabel:SetText(
            profession.detailText or (rankText ~= "" and rankText or "Known")
        )

        if profession.actionName then
            button:SetAttribute("type", "spell")
            button:SetAttribute("spell", profession.actionName)
            button.icon:SetVertexColor(1, 1, 1)
            button.nameText:SetTextColor(1, 0.82, 0)
            SetButtonBackdrop(button, 0.055, 0.065, 0.085, 0.98)
        else
            button:SetAttribute("type", nil)
            button:SetAttribute("spell", nil)
            button.icon:SetVertexColor(0.45, 0.45, 0.45)
            button.nameText:SetTextColor(0.72, 0.72, 0.72)
            SetButtonBackdrop(button, 0.045, 0.05, 0.06, 0.9)
        end

        button:Show()
    end

    for index = #known + 1, #professionButtons do
        professionButtons[index]:Hide()
    end

    if #known == 0 then
        panel.emptyText:Show()
        panel.hint:SetText("0 found  -  type /ehp debug and send the chat output")
    else
        panel.emptyText:Hide()
        panel.hint:SetText(
            lastScanDetails.knownCount
                .. " professions, "
                .. lastScanDetails.abilityCount
                .. " utilities  -  drag the background"
        )
    end
    refreshPending = nil
end

function EbonholdProfessions_SafeRefresh(reportError)
    local refreshOK, errorMessage = pcall(EbonholdProfessions_Refresh)
    if refreshOK then
        return true
    end

    RecordScanError("refresh", errorMessage)
    if reportError then
        Print("|cffff6060profession refresh failed: " .. tostring(errorMessage) .. "|r")
    end
    return false
end

function EbonholdProfessions_Toggle()
    if InCombatLockdown() then
        Print("the profession window cannot be toggled during combat.")
        return
    end

    if panel:IsShown() then
        panel:Hide()
    else
        panel:Show()
    end
end

local function PrintDiagnostics()
    Print("version " .. ADDON_VERSION .. ".")
    Print(
        "scan: "
            .. lastScanDetails.skillCount
            .. " skill lines, "
            .. lastScanDetails.spellCount
            .. " spellbook entries, "
            .. lastScanDetails.spellIDCount
            .. " raw spell IDs, "
            .. lastScanDetails.professionAPICount
            .. " stock profession entries, "
            .. lastScanDetails.knownCount
            .. " professions and "
            .. lastScanDetails.abilityCount
            .. " utilities found."
    )

    if #lastScanDetails.errors == 0 then
        Print("scan APIs completed without a reported error.")
    else
        for _, errorMessage in ipairs(lastScanDetails.errors) do
            Print("|cffff6060" .. errorMessage .. "|r")
        end
    end

    if #lastScanDetails.knownNames > 0 then
        Print("detected: " .. table.concat(lastScanDetails.knownNames, ", ") .. ".")
    end

    if lastScanDetails.knownCount == 0 and #lastScanDetails.skillNames > 0 then
        for startIndex = 1, #lastScanDetails.skillNames, 4 do
            local lines = {}
            for index = startIndex, math.min(startIndex + 3, #lastScanDetails.skillNames) do
                table.insert(lines, lastScanDetails.skillNames[index])
            end
            Print("skills: " .. table.concat(lines, ", "))
        end
    end

end

local function HandleSlashCommand(input)
    local command = string.lower(Trim(input))

    if command == "" or command == "toggle" then
        EbonholdProfessions_Toggle()
    elseif command == "show" then
        if not InCombatLockdown() then
            panel:Show()
        end
    elseif command == "hide" then
        if not InCombatLockdown() then
            panel:Hide()
        end
    elseif command == "refresh" then
        if EbonholdProfessions_SafeRefresh(true) then
            Print("profession list refreshed.")
        end
    elseif command == "debug" then
        EbonholdProfessions_SafeRefresh(true)
        PrintDiagnostics()
    elseif command == "button" then
        if launcherButton:IsShown() then
            launcherButton:Hide()
            EbonholdProfessionsDB.floatingButtonShown = false
        else
            launcherButton:Show()
            EbonholdProfessionsDB.floatingButtonShown = true
        end
    elseif command == "minimap" then
        if minimapButton:IsShown() then
            minimapButton:Hide()
            EbonholdProfessionsDB.minimapButtonShown = false
        else
            minimapButton:Show()
            EbonholdProfessionsDB.minimapButtonShown = true
        end
    else
        Print("commands: /ehp, /ehp refresh, /ehp debug, /ehp button, /ehp minimap")
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, argument)
    if event == "ADDON_LOADED" then
        if argument ~= addonName then
            return
        end

        if type(EbonholdProfessionsDB) ~= "table" then
            EbonholdProfessionsDB = {}
        end
        if EbonholdProfessionsDB.floatingButtonShown == nil then
            EbonholdProfessionsDB.floatingButtonShown = true
        end
        if EbonholdProfessionsDB.minimapButtonShown == nil then
            EbonholdProfessionsDB.minimapButtonShown = true
        end

        CreatePanel()
        CreateLauncherButton()
        CreateMinimapButton()

        SLASH_EBONHOLDPROFESSIONS1 = "/ehp"
        SLASH_EBONHOLDPROFESSIONS2 = "/professions"
        SlashCmdList.EBONHOLDPROFESSIONS = HandleSlashCommand
    elseif event == "PLAYER_LOGIN" then
        EbonholdProfessions_SafeRefresh(false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if refreshPending then
            EbonholdProfessions_SafeRefresh(false)
        end
    elseif event == "SKILL_LINES_CHANGED" or event == "SPELLS_CHANGED" then
        if panel and panel:IsShown() then
            EbonholdProfessions_SafeRefresh(false)
        else
            refreshPending = true
        end
    end
end)
