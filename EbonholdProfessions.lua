local addonName = ...

local ADDON_VERSION = "1.10.1"
local PREFIX = "|cff58c6ffEbonhold Professions:|r "
local PANEL_WIDTH = 500
local MIN_PANEL_WIDTH = 380
local MIN_PANEL_HEIGHT = 260
local BUTTON_HEIGHT = 52
local BUTTON_GAP = 8
local SECTION_HEADER_HEIGHT = 20
local SECTION_HEADER_GAP = 6
local SECTION_GAP = 10
local SECTION_COLUMN_GAP = 12
local WIDE_SECTION_THRESHOLD = 760
local TWO_BUTTON_COLUMN_WIDTH = 460
local LAUNCHER_ICON = "Interface\\Icons\\INV_Misc_Book_09"
local SPELL_BOOK_TYPE = BOOKTYPE_SPELL or "spell"

-- Shared visual language with Ravioli Family Activity Finder.
local COLORS = {
    background = { 0.035, 0.043, 0.055, 0.98 },
    panel = { 0.065, 0.075, 0.095, 0.98 },
    panelLight = { 0.090, 0.102, 0.125, 1 },
    border = { 0.22, 0.25, 0.30, 1 },
    gold = { 0.86, 0.64, 0.25, 1 },
    text = { 0.92, 0.92, 0.92, 1 },
    muted = { 0.58, 0.62, 0.68, 1 },
    green = { 0.35, 0.78, 0.48, 1 },
    red = { 0.88, 0.32, 0.30, 1 },
}

local sectionDefinitions = {
    { key = "MAIN", label = "Main Professions" },
    { key = "SUB", label = "Sub Professions" },
    { key = "TRACKING", label = "Tracking" },
    { key = "ABILITY", label = "Ability Types" },
}

local sectionOrder = {
    MAIN = 1,
    SUB = 2,
    TRACKING = 3,
    ABILITY = 4,
}

local subProfessionKeys = {
    COOKING = true,
    FISHING = true,
    FIRST_AID = true,
}

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
            {
                spellID = 818,
                fallbackName = "Basic Campfire",
                section = "ABILITY",
            },
        },
    },
    {
        key = "ENCHANTING", skillSpellID = 7411, actionSpellID = 7411,
        rankSpellIDs = { 7411, 7412, 7413, 13920, 28029, 51313 },
        extraAbilities = {
            {
                spellID = 13262,
                fallbackName = "Disenchant",
                section = "ABILITY",
                itemProcessor = true,
                processorType = "DISENCHANT",
                minimumCount = 1,
            },
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
            {
                spellID = 43308,
                fallbackName = "Find Fish",
                section = "TRACKING",
            },
        },
    },
    {
        key = "HERBALISM", skillSpellID = 2366, actionSpellID = nil,
        rankSpellIDs = { 2366, 2368, 3570, 11993, 28695, 50300 },
        extraAbilities = {
            {
                spellID = 2383,
                fallbackName = "Find Herbs",
                section = "TRACKING",
            },
        },
    },
    {
        key = "INSCRIPTION", skillSpellID = 45357, actionSpellID = 45357,
        rankSpellIDs = { 45357, 45358, 45359, 45360, 45361, 45363 },
        extraAbilities = {
            {
                spellID = 51005,
                fallbackName = "Milling",
                section = "ABILITY",
                itemProcessor = true,
                processorType = "MILLING",
                minimumCount = 5,
            },
        },
    },
    {
        key = "JEWELCRAFTING", skillSpellID = 25229, actionSpellID = 25229,
        rankSpellIDs = { 25229, 25230, 28894, 28895, 28897, 51311 },
        extraAbilities = {
            {
                spellID = 31252,
                fallbackName = "Prospecting",
                section = "ABILITY",
                itemProcessor = true,
                processorType = "PROSPECTING",
                minimumCount = 5,
            },
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
            {
                spellID = 2580,
                fallbackName = "Find Minerals",
                section = "TRACKING",
            },
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
local contextMenuFrame
local itemListPanel
local settingsFrame
local itemListRows = {}
local itemScanTooltip
local processabilityCache = {}
local professionButtons = {}
local sectionHeaders = {}
local hotkeyButtons = {}
local hotkeyTargets = {}
local refreshPending
local hotkeyBindingsPending
local processingRefreshPending
local hotkeyCaptureButton
local OpenProfessionMenu
local EndHotkeyCapture
local OpenItemListEditor
local OpenSettingsFrame
local RefreshProcessingActions
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

local function AddBackground(frame, color, borderColor)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(color[1], color[2], color[3], color[4] or 1)
    borderColor = borderColor or COLORS.border
    frame:SetBackdropBorderColor(
        borderColor[1],
        borderColor[2],
        borderColor[3],
        borderColor[4] or 1
    )
end

local function CreateText(parent, text, size, color, justify)
    local label = parent:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", size or 12)
    label:SetText(text or "")
    color = color or COLORS.text
    label:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    label:SetJustifyH(justify or "LEFT")
    label:SetJustifyV("MIDDLE")
    return label
end

local function CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    AddBackground(button, COLORS.panelLight, COLORS.border)
    button.label = CreateText(button, text, 11, COLORS.text, "CENTER")
    button.label:SetAllPoints()
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.14, 0.16, 0.20, 1)
        self:SetBackdropBorderColor(
            COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 0.8
        )
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(
            COLORS.panelLight[1],
            COLORS.panelLight[2],
            COLORS.panelLight[3],
            COLORS.panelLight[4]
        )
        self:SetBackdropBorderColor(
            COLORS.border[1], COLORS.border[2], COLORS.border[3], COLORS.border[4]
        )
    end)
    button:SetScript("OnMouseDown", function(self)
        self.label:ClearAllPoints()
        self.label:SetPoint("CENTER", 1, -1)
    end)
    button:SetScript("OnMouseUp", function(self)
        self.label:ClearAllPoints()
        self.label:SetAllPoints()
    end)
    return button
end

local function IsAutomaticProcessingEnabled()
    return EbonholdProfessionsDB
        and EbonholdProfessionsDB.settings
        and EbonholdProfessionsDB.settings.autoProcessItems ~= false
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
                section = subProfessionKeys[definition.key] and "SUB" or "MAIN",
                sortKey = professionName,
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
                        section = ability.section or "ABILITY",
                        itemProcessor = ability.itemProcessor,
                        processorType = ability.processorType,
                        minimumCount = ability.minimumCount,
                        sortKey = abilityName,
                    })
                    lastScanDetails.abilityCount =
                        lastScanDetails.abilityCount + 1
                end
            end
        end
    end

    table.sort(known, function(left, right)
        local leftSection = sectionOrder[left.section] or 99
        local rightSection = sectionOrder[right.section] or 99
        if leftSection ~= rightSection then
            return leftSection < rightSection
        end
        return left.sortKey < right.sortKey
    end)

    return known
end

local function SetButtonBackdrop(button, red, green, blue, alpha)
    button.baseBackdropColor = { red, green, blue, alpha }
    button:SetBackdropColor(red, green, blue, alpha)
    button:SetBackdropBorderColor(
        COLORS.border[1], COLORS.border[2], COLORS.border[3], COLORS.border[4]
    )
end

local function ProfessionButton_OnEnter(self)
    self:SetBackdropColor(0.14, 0.16, 0.20, 1)
    self:SetBackdropBorderColor(
        COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 0.8
    )
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        self.professionName or "",
        COLORS.gold[1], COLORS.gold[2], COLORS.gold[3]
    )

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

    if self.actionName then
        if self.hotkey then
            GameTooltip:AddLine("Hotkey: " .. self.hotkey, 1, 0.82, 0)
        end
        if self.itemProcessor then
            if IsAutomaticProcessingEnabled() then
                GameTooltip:AddLine(
                    "Automatic bag targeting: Enabled",
                    COLORS.green[1], COLORS.green[2], COLORS.green[3],
                    true
                )
                GameTooltip:AddLine(
                    "Processes the first eligible non-blacklisted bag item.",
                    COLORS.muted[1], COLORS.muted[2], COLORS.muted[3],
                    true
                )
            else
                GameTooltip:AddLine(
                    "Automatic bag targeting: Disabled",
                    COLORS.muted[1], COLORS.muted[2], COLORS.muted[3],
                    true
                )
                GameTooltip:AddLine(
                    "Click to activate the ability, then choose an item manually.",
                    COLORS.muted[1], COLORS.muted[2], COLORS.muted[3],
                    true
                )
            end
            GameTooltip:AddLine("Right-click: hotkey and blacklist options", 0.65, 0.7, 0.78)
        else
            GameTooltip:AddLine("Right-click: hotkey options", 0.65, 0.7, 0.78)
        end
    end

    GameTooltip:Show()
end

local function ProfessionButton_OnLeave(self)
    if self and self.baseBackdropColor then
        self:SetBackdropColor(unpack(self.baseBackdropColor))
        self:SetBackdropBorderColor(
            COLORS.border[1], COLORS.border[2], COLORS.border[3], COLORS.border[4]
        )
    end
    GameTooltip:Hide()
end

local function CreateProfessionButton(index)
    local button = CreateFrame(
        "Button",
        addonName .. "ProfessionButton" .. index,
        panel.content,
        "SecureActionButtonTemplate"
    )
    button:SetWidth(226)
    button:SetHeight(BUTTON_HEIGHT)
    AddBackground(button, COLORS.panel, COLORS.border)
    SetButtonBackdrop(
        button,
        COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], COLORS.panel[4]
    )
    -- Only left-click is registered as a secure action. Right-click is
    -- handled separately below so older 3.3.5 clients cannot confuse the
    -- context-menu click with the profession action.
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

    button.nameText = CreateText(button, "", 12, COLORS.text)
    button.nameText:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 10, -4)
    button.nameText:SetPoint("RIGHT", button, "RIGHT", -66, 0)
    button.nameText:SetJustifyH("LEFT")

    button.rankLabel = CreateText(button, "", 10, COLORS.muted)
    button.rankLabel:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 10, 4)
    button.rankLabel:SetPoint("RIGHT", button, "RIGHT", -8, 0)
    button.rankLabel:SetJustifyH("LEFT")
    button.rankLabel:SetTextColor(
        COLORS.muted[1], COLORS.muted[2], COLORS.muted[3]
    )

    button.hotkeyLabel = CreateText(button, "", 9, COLORS.gold, "RIGHT")
    button.hotkeyLabel:SetPoint("TOPRIGHT", button, "TOPRIGHT", -9, -9)
    button.hotkeyLabel:SetWidth(58)
    button.hotkeyLabel:SetJustifyH("RIGHT")
    button.hotkeyLabel:SetTextColor(
        COLORS.gold[1], COLORS.gold[2], COLORS.gold[3]
    )

    button:SetScript("OnEnter", ProfessionButton_OnEnter)
    button:SetScript("OnLeave", ProfessionButton_OnLeave)
    button:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "RightButton" and OpenProfessionMenu then
            OpenProfessionMenu(self)
        end
    end)

    return button
end

local function CreatePanel()
    panel = CreateFrame("Frame", addonName .. "Panel", UIParent)
    panel:SetWidth(tonumber(EbonholdProfessionsDB.panelWidth) or PANEL_WIDTH)
    panel:SetHeight(tonumber(EbonholdProfessionsDB.panelHeight) or 150)
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
    panel:SetResizable(true)
    if panel.SetMinResize then
        panel:SetMinResize(MIN_PANEL_WIDTH, MIN_PANEL_HEIGHT)
    end
    if panel.SetMaxResize then
        panel:SetMaxResize(
            math.max(MIN_PANEL_WIDTH, (UIParent:GetWidth() or 1024) - 40),
            math.max(MIN_PANEL_HEIGHT, (UIParent:GetHeight() or 768) - 40)
        )
    end
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
    AddBackground(panel, COLORS.background, COLORS.border)
    table.insert(UISpecialFrames, panel:GetName())
    panel:Hide()

    panel.header = CreateFrame("Frame", nil, panel)
    panel.header:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
    panel.header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -1, -1)
    panel.header:SetHeight(60)
    panel.header.texture = panel.header:CreateTexture(nil, "BACKGROUND")
    panel.header.texture:SetAllPoints()
    panel.header.texture:SetTexture("Interface\\Buttons\\WHITE8X8")
    panel.header.texture:SetVertexColor(0.055, 0.062, 0.078, 1)

    panel.title = CreateText(panel.header, "Ebonhold Professions", 19, COLORS.text)
    panel.title:SetPoint("TOPLEFT", panel.header, "TOPLEFT", 18, -13)
    panel.title:SetText("Ebonhold Professions")

    panel.subtitle = CreateText(panel.header, "", 10, COLORS.muted)
    panel.subtitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -4)
    panel.subtitle:SetText(
        "Every profession learned by this character  |cff7c828cv"
            .. ADDON_VERSION
            .. "|r"
    )

    panel.settingsButton = CreateButton(panel.header, "Settings", 76, 28)
    panel.settingsButton:SetPoint("TOPRIGHT", panel.header, "TOPRIGHT", -48, -12)
    panel.settingsButton:SetScript("OnClick", function()
        if OpenSettingsFrame then
            OpenSettingsFrame()
        end
    end)

    panel.closeButton = CreateButton(panel.header, "X", 28, 28)
    panel.closeButton:SetPoint("TOPRIGHT", panel.header, "TOPRIGHT", -12, -12)
    panel.closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)

    panel.resizeButton = CreateFrame("Button", nil, panel)
    panel.resizeButton:SetWidth(18)
    panel.resizeButton:SetHeight(18)
    panel.resizeButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -5, 5)
    panel.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    panel.resizeButton:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight"
    )
    panel.resizeButton:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
    )
    panel.resizeButton:RegisterForDrag("LeftButton")
    panel.resizeButton:RegisterForClicks("RightButtonUp")
    panel.resizeButton:SetScript("OnDragStart", function()
        if not InCombatLockdown() then
            panel:StartSizing("BOTTOMRIGHT")
        end
    end)
    panel.resizeButton:SetScript("OnDragStop", function()
        panel:StopMovingOrSizing()
        EbonholdProfessionsDB.panelWidth = math.floor(panel:GetWidth() + 0.5)
        EbonholdProfessionsDB.panelHeight = math.floor(panel:GetHeight() + 0.5)
        EbonholdProfessionsDB.panelSizeUserSet = true
        EbonholdProfessions_SafeRefresh(false)
    end)
    panel.resizeButton:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" and not InCombatLockdown() then
            EbonholdProfessionsDB.panelWidth = nil
            EbonholdProfessionsDB.panelHeight = nil
            EbonholdProfessionsDB.panelSizeUserSet = nil
            panel:SetWidth(PANEL_WIDTH)
            EbonholdProfessions_SafeRefresh(false)
            Print("profession window size reset.")
        end
    end)
    panel.resizeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText("Resize profession window", 1, 0.82, 0)
        GameTooltip:AddLine("Left-drag: resize", 1, 1, 1)
        GameTooltip:AddLine("Right-click: reset size", 0.7, 0.75, 0.82)
        GameTooltip:Show()
    end)
    panel.resizeButton:SetScript("OnLeave", ProfessionButton_OnLeave)

    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel)
    panel.scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -70)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -12, 40)
    AddBackground(panel.scrollFrame, { 0.045, 0.052, 0.066, 1 }, { 0.10, 0.11, 0.14, 1 })
    panel.scrollFrame:EnableMouseWheel(true)

    panel.content = CreateFrame("Frame", nil, panel.scrollFrame)
    panel.content:SetWidth(PANEL_WIDTH - 24)
    panel.content:SetHeight(1)
    panel.scrollFrame:SetScrollChild(panel.content)
    panel.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local maximum = math.max(0, panel.content:GetHeight() - self:GetHeight())
        local newValue = self:GetVerticalScroll() - delta * (BUTTON_HEIGHT + BUTTON_GAP)
        self:SetVerticalScroll(math.max(0, math.min(maximum, newValue)))
    end)

    panel.emptyText = CreateText(panel, "No learned professions were found.", 12, COLORS.muted, "CENTER")
    panel.emptyText:SetPoint("CENTER", panel, "CENTER", 0, -18)
    panel.emptyText:Hide()

    panel.hint = CreateText(panel, "", 9, COLORS.muted, "CENTER")
    panel.hint:SetPoint("BOTTOM", panel, "BOTTOM", 0, 15)
    panel.hint:SetText("Drag background  -  scroll list  -  resize bottom-right")

    panel:SetScript("OnShow", function()
        if not InCombatLockdown() then
            EbonholdProfessions_SafeRefresh(false)
        end
    end)
    panel:SetScript("OnHide", function()
        if EndHotkeyCapture then
            EndHotkeyCapture()
        end
    end)
end

local function CreateSettingToggle(parent, label, description, key, y, callback)
    local button = CreateFrame("Button", nil, parent)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    button:SetWidth(390)
    button:SetHeight(48)
    button.box = CreateFrame("Frame", nil, button)
    button.box:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -2)
    button.box:SetWidth(20)
    button.box:SetHeight(20)
    AddBackground(button.box, COLORS.panelLight, COLORS.border)
    button.mark = CreateText(button.box, "", 12, COLORS.gold, "CENTER")
    button.mark:SetAllPoints()
    button.label = CreateText(button, label, 11, COLORS.text)
    button.label:SetPoint("TOPLEFT", button, "TOPLEFT", 30, -1)
    button.description = CreateText(button, description, 9, COLORS.muted)
    button.description:SetPoint("TOPLEFT", button, "TOPLEFT", 30, -22)
    button.description:SetWidth(350)
    button.description:SetJustifyV("TOP")
    button.key = key

    function button:Refresh()
        local enabled = EbonholdProfessionsDB.settings[self.key] == true
        self.mark:SetText(enabled and "X" or "")
        if enabled then
            self.box:SetBackdropBorderColor(
                COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1
            )
        else
            self.box:SetBackdropBorderColor(
                COLORS.border[1], COLORS.border[2], COLORS.border[3], 1
            )
        end
    end

    button:SetScript("OnEnter", function(self)
        self.label:SetTextColor(
            COLORS.gold[1], COLORS.gold[2], COLORS.gold[3]
        )
    end)
    button:SetScript("OnLeave", function(self)
        self.label:SetTextColor(
            COLORS.text[1], COLORS.text[2], COLORS.text[3]
        )
    end)
    button:SetScript("OnClick", function(self)
        EbonholdProfessionsDB.settings[self.key] =
            not EbonholdProfessionsDB.settings[self.key]
        self:Refresh()
        if callback then
            callback(EbonholdProfessionsDB.settings[self.key])
        end
    end)
    return button
end

local function CreateSettingsFrame()
    settingsFrame = CreateFrame(
        "Frame",
        addonName .. "SettingsFrame",
        UIParent
    )
    settingsFrame:SetWidth(440)
    settingsFrame:SetHeight(255)
    settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 250, 35)
    settingsFrame:SetFrameStrata("DIALOG")
    settingsFrame:SetClampedToScreen(true)
    settingsFrame:SetMovable(true)
    settingsFrame:EnableMouse(true)
    settingsFrame:RegisterForDrag("LeftButton")
    settingsFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    settingsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    AddBackground(settingsFrame, COLORS.background, COLORS.gold)
    table.insert(UISpecialFrames, settingsFrame:GetName())
    settingsFrame:Hide()

    settingsFrame.title = CreateText(
        settingsFrame,
        "Ebonhold Professions Settings",
        18,
        COLORS.text
    )
    settingsFrame.title:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 20, -18)
    settingsFrame.subtitle = CreateText(
        settingsFrame,
        "Choose how profession abilities interact with bag items.",
        10,
        COLORS.muted
    )
    settingsFrame.subtitle:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 20, -44)

    settingsFrame.closeButton = CreateButton(settingsFrame, "X", 28, 28)
    settingsFrame.closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -12, -12)
    settingsFrame.closeButton:SetScript("OnClick", function()
        settingsFrame:Hide()
    end)

    settingsFrame.sectionLabel = CreateText(
        settingsFrame,
        "ITEM PROCESSING",
        9,
        COLORS.gold
    )
    settingsFrame.sectionLabel:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 20, -78)

    settingsFrame.autoProcessToggle = CreateSettingToggle(
        settingsFrame,
        "Automatically find viable bag items",
        "Prospecting, Milling, and Disenchant target the first eligible non-blacklisted item.",
        "autoProcessItems",
        -98,
        function()
            RefreshProcessingActions()
        end
    )

    settingsFrame.manualNote = CreateText(
        settingsFrame,
        "When disabled, these abilities use normal manual targeting. Blacklists are kept and can still be edited.",
        10,
        COLORS.muted
    )
    settingsFrame.manualNote:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 20, -168)
    settingsFrame.manualNote:SetWidth(400)
    settingsFrame.manualNote:SetJustifyV("TOP")

    settingsFrame:SetScript("OnShow", function(self)
        self.autoProcessToggle:Refresh()
    end)
end

OpenSettingsFrame = function()
    if not settingsFrame then
        CreateSettingsFrame()
    end

    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
    end
end

local function OpenLauncherMenu(buttonType)
    GameTooltip:Hide()

    local isFloating = buttonType == "floating"
    local button = isFloating and launcherButton or minimapButton
    local lockKey = isFloating and "floatingButtonLocked" or "minimapButtonLocked"
    local shownKey = isFloating and "floatingButtonShown" or "minimapButtonShown"
    local opacityKey = isFloating and "floatingButtonOpacity" or "minimapButtonOpacity"
    local buttonLabel = isFloating and "floating button" or "minimap button"
    local isLocked = EbonholdProfessionsDB[lockKey]
    local currentOpacity = EbonholdProfessionsDB[opacityKey] or 100

    if not contextMenuFrame then
        contextMenuFrame = CreateFrame(
            "Frame",
            addonName .. "ContextMenu",
            UIParent,
            "UIDropDownMenuTemplate"
        )
    end

    local opacityMenu = {}
    for percent = 10, 100, 10 do
        local opacity = percent
        table.insert(opacityMenu, {
            text = opacity .. "%",
            checked = currentOpacity == opacity,
            func = function()
                EbonholdProfessionsDB[opacityKey] = opacity
                button:SetAlpha(opacity / 100)
            end,
        })
    end

    local menu = {
        {
            text = "Ebonhold Professions",
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Settings",
            notCheckable = true,
            func = function()
                OpenSettingsFrame()
            end,
        },
        {
            text = isLocked and "Unlock position" or "Lock position",
            notCheckable = true,
            func = function()
                EbonholdProfessionsDB[lockKey] = not isLocked
            end,
        },
        {
            text = "Opacity: " .. currentOpacity .. "%",
            hasArrow = true,
            notCheckable = true,
            menuList = opacityMenu,
        },
        {
            text = "Hide " .. buttonLabel,
            notCheckable = true,
            func = function()
                GameTooltip:Hide()
                button:Hide()
                EbonholdProfessionsDB[shownKey] = false
            end,
        },
    }

    EasyMenu(menu, contextMenuFrame, "cursor", 0, 0, "MENU")
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
    launcherButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    launcherButton:RegisterForDrag("RightButton")
    AddBackground(launcherButton, COLORS.panel, COLORS.gold)

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

    -- Keep the icon above the custom backdrop. A BACKGROUND-layer texture is
    -- hidden behind SetBackdrop's fill on Wrath-era clients.
    launcherButton.icon = launcherButton:CreateTexture(nil, "ARTWORK")
    launcherButton.icon:SetPoint("TOPLEFT", launcherButton, "TOPLEFT", 4, -4)
    launcherButton.icon:SetPoint("BOTTOMRIGHT", launcherButton, "BOTTOMRIGHT", -4, 4)
    launcherButton.icon:SetTexture(LAUNCHER_ICON)
    launcherButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    launcherButton:SetScript("OnClick", function(self, mouseButton)
        if self.ignoreClick then
            return
        end

        if mouseButton == "RightButton" then
            OpenLauncherMenu("floating")
        else
            EbonholdProfessions_Toggle()
        end
    end)
    launcherButton:SetScript("OnDragStart", function(self)
        if not EbonholdProfessionsDB.floatingButtonLocked
            and not InCombatLockdown()
        then
            self.isMoving = true
            self:StartMoving()
        end
    end)
    launcherButton:SetScript("OnDragStop", function(self)
        if self.isMoving then
            self.isMoving = nil
            self:StopMovingOrSizing()
            SaveLauncherPosition()
            self.ignoreClick = true
            self:SetScript("OnUpdate", function(button)
                button.ignoreClick = nil
                button:SetScript("OnUpdate", nil)
            end)
        end
    end)
    launcherButton:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        self:SetBackdropColor(0.14, 0.16, 0.20, 1)
        self:SetBackdropBorderColor(
            COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1
        )
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ebonhold Professions", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open professions", 1, 1, 1)
        GameTooltip:AddLine("Right-click: options", 1, 1, 1)
        if EbonholdProfessionsDB.floatingButtonLocked then
            GameTooltip:AddLine("Position locked", 0.65, 0.7, 0.78)
        else
            GameTooltip:AddLine("Right-drag: move", 0.65, 0.7, 0.78)
        end
        GameTooltip:Show()
    end)
    launcherButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetBackdropColor(
            COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], COLORS.panel[4]
        )
        self:SetAlpha((EbonholdProfessionsDB.floatingButtonOpacity or 100) / 100)
    end)
    launcherButton:SetAlpha(EbonholdProfessionsDB.floatingButtonOpacity / 100)

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
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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

    minimapButton:SetScript("OnClick", function(self, mouseButton)
        if self.ignoreClick then
            return
        end

        if mouseButton == "RightButton" then
            OpenLauncherMenu("minimap")
        else
            EbonholdProfessions_Toggle()
        end
    end)
    minimapButton:SetScript("OnDragStart", function(self)
        if not EbonholdProfessionsDB.minimapButtonLocked then
            self.isMoving = true
            self:SetScript("OnUpdate", UpdateMinimapButtonPosition)
        end
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        if self.isMoving then
            self.isMoving = nil
            self:SetScript("OnUpdate", nil)
            UpdateMinimapButtonPosition()
            self.ignoreClick = true
            self:SetScript("OnUpdate", function(button)
                button.ignoreClick = nil
                button:SetScript("OnUpdate", nil)
            end)
        end
    end)
    minimapButton:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Ebonhold Professions", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open professions", 1, 1, 1)
        GameTooltip:AddLine("Right-click: options", 1, 1, 1)
        if EbonholdProfessionsDB.minimapButtonLocked then
            GameTooltip:AddLine("Position locked", 0.65, 0.7, 0.78)
        else
            GameTooltip:AddLine("Right-drag: move around the minimap", 0.65, 0.7, 0.78)
        end
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetAlpha((EbonholdProfessionsDB.minimapButtonOpacity or 100) / 100)
    end)
    minimapButton:SetAlpha(EbonholdProfessionsDB.minimapButtonOpacity / 100)

    if EbonholdProfessionsDB.minimapButtonShown then
        minimapButton:Show()
    else
        minimapButton:Hide()
    end
end

local function GetBagItemID(bag, slot, itemLink)
    if type(GetContainerItemID) == "function" then
        local itemOK, itemID = pcall(GetContainerItemID, bag, slot)
        if itemOK and itemID then
            return itemID
        end
    end

    if itemLink then
        return tonumber(string.match(itemLink, "item:(%d+)"))
    end
end

local disenchantEquipLocations = {
    INVTYPE_HEAD = true,
    INVTYPE_NECK = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_BODY = true,
    INVTYPE_CHEST = true,
    INVTYPE_ROBE = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true,
    INVTYPE_FINGER = true,
    INVTYPE_TRINKET = true,
    INVTYPE_CLOAK = true,
    INVTYPE_WEAPON = true,
    INVTYPE_SHIELD = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_RANGED = true,
    INVTYPE_THROWN = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_RELIC = true,
}

local function LowerText(value)
    if type(value) ~= "string" then
        return ""
    end
    return string.lower(value)
end

local function TooltipContainsPhrase(tooltipText, phrase)
    phrase = LowerText(phrase)
    if phrase == "" then
        return false
    end

    local formatPosition = string.find(phrase, "%", 1, true)
    if formatPosition then
        phrase = string.sub(phrase, 1, formatPosition - 1)
        phrase = string.gsub(phrase, "%s+$", "")
    end

    return #phrase >= 4
        and string.find(tooltipText, phrase, 1, true) ~= nil
end

local function GetBagItemTooltipText(bag, slot)
    if not itemScanTooltip then
        itemScanTooltip = CreateFrame(
            "GameTooltip",
            addonName .. "ItemScanTooltip",
            UIParent,
            "GameTooltipTemplate"
        )
    end

    itemScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    itemScanTooltip:ClearLines()
    local tooltipOK = pcall(
        itemScanTooltip.SetBagItem,
        itemScanTooltip,
        bag,
        slot
    )
    if not tooltipOK then
        itemScanTooltip:Hide()
        return ""
    end

    local textLines = {}
    local tooltipName = itemScanTooltip:GetName()
    for lineIndex = 1, (itemScanTooltip:NumLines() or 0) do
        local leftLine = _G[tooltipName .. "TextLeft" .. lineIndex]
        local rightLine = _G[tooltipName .. "TextRight" .. lineIndex]
        if leftLine and leftLine:GetText() then
            table.insert(textLines, leftLine:GetText())
        end
        if rightLine and rightLine:GetText() then
            table.insert(textLines, rightLine:GetText())
        end
    end
    itemScanTooltip:Hide()
    return LowerText(table.concat(textLines, " "))
end

local function IsBagItemProcessable(processorType, bag, slot, itemID, itemLink)
    local cacheKey = tostring(processorType) .. ":" .. tostring(itemID)
    if processabilityCache[cacheKey] ~= nil then
        return processabilityCache[cacheKey]
    end

    local tooltipText = GetBagItemTooltipText(bag, slot)
    local itemName, _, quality, _, _, itemType, itemSubType, _, equipLocation =
        GetItemInfo(itemLink or itemID)
    local itemNameLower = LowerText(itemName)
    local itemTypeLower = LowerText(itemType)
    local itemSubTypeLower = LowerText(itemSubType)
    local processable = false

    if processorType == "PROSPECTING" then
        processable = TooltipContainsPhrase(tooltipText, _G.ITEM_PROSPECTABLE)
            or string.find(tooltipText, "prospectable", 1, true) ~= nil
            or string.find(itemNameLower, " ore", 1, true) ~= nil
            or string.match(itemNameLower, "^ore ") ~= nil
    elseif processorType == "MILLING" then
        processable = TooltipContainsPhrase(tooltipText, _G.ITEM_MILLABLE)
            or string.find(tooltipText, "millable", 1, true) ~= nil
            or string.find(itemSubTypeLower, "herb", 1, true) ~= nil
            or itemTypeLower == "herb"
    elseif processorType == "DISENCHANT" then
        local explicitlyBlocked =
            TooltipContainsPhrase(
                tooltipText,
                _G.ITEM_DISENCHANT_NOT_DISENCHANTABLE
            )
            or string.find(tooltipText, "cannot be disenchanted", 1, true) ~= nil
            or string.find(tooltipText, "not disenchantable", 1, true) ~= nil
        local explicitlyAllowed =
            TooltipContainsPhrase(tooltipText, _G.ITEM_DISENCHANT_ANY_SKILL)
            or TooltipContainsPhrase(tooltipText, _G.ITEM_DISENCHANT_MIN_SKILL)
            or string.find(tooltipText, "disenchanting requires", 1, true) ~= nil

        if not explicitlyBlocked then
            processable = explicitlyAllowed
                or (
                    type(quality) == "number"
                    and quality >= 2
                    and quality <= 4
                    and disenchantEquipLocations[equipLocation]
                )
        end
    end

    if itemName or processable then
        processabilityCache[cacheKey] = processable and true or false
    end
    return processable
end

local function FindProcessableBagSlot(profession)
    local blacklistedItems =
        EbonholdProfessionsDB.itemBlacklists[profession.key] or {}

    for bag = 0, (NUM_BAG_SLOTS or 4) do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, count, locked, _, _, _, itemLink =
                GetContainerItemInfo(bag, slot)
            local itemID = GetBagItemID(bag, slot, itemLink)
            local isBlacklisted = itemID
                and (
                    blacklistedItems[itemID]
                    or blacklistedItems[tostring(itemID)]
                )

            if itemID
                and not isBlacklisted
                and not locked
                and (count or 0) >= (profession.minimumCount or 1)
                and IsBagItemProcessable(
                    profession.processorType,
                    bag,
                    slot,
                    itemID,
                    itemLink
                )
            then
                return bag, slot, itemID
            end
        end
    end
end

local function ConfigureSecureAction(button, profession)
    local actionType
    local spellName
    local targetBag
    local targetSlot

    if profession.actionName then
        actionType = "spell"
        spellName = profession.actionName

        if profession.itemProcessor and IsAutomaticProcessingEnabled() then
            local bag, slot = FindProcessableBagSlot(profession)
            if bag and slot then
                targetBag = bag
                targetSlot = slot
            end
        end
    end

    -- Ebonhold's 3.3.5 client can leave a recycled secure button inert when
    -- its action is rewritten while the button is shown. Re-arm it hidden,
    -- then restore its prior shown state.
    local wasShown = button:IsShown()
    button:Hide()
    button:SetAttribute("type", nil)
    button:SetAttribute("spell", nil)
    button:SetAttribute("macrotext", nil)
    button:SetAttribute("target-bag", nil)
    button:SetAttribute("target-slot", nil)
    button:SetAttribute("target-item", nil)
    button:SetAttribute("type1", nil)
    button:SetAttribute("spell1", nil)
    button:SetAttribute("macrotext1", nil)
    button:SetAttribute("target-bag1", nil)
    button:SetAttribute("target-slot1", nil)
    button:SetAttribute("target-item1", nil)

    if actionType then
        -- The unsuffixed attributes are the original SecureActionButton
        -- contract. Keep the numbered left-button aliases as well for
        -- compatibility with both stock and custom 3.3.5 clients.
        button:SetAttribute("type", actionType)
        button:SetAttribute("spell", spellName)
        button:SetAttribute("target-bag", targetBag)
        button:SetAttribute("target-slot", targetSlot)
        button:SetAttribute("type1", actionType)
        button:SetAttribute("spell1", spellName)
        button:SetAttribute("target-bag1", targetBag)
        button:SetAttribute("target-slot1", targetSlot)
    end

    if wasShown then
        button:Show()
    end
end

RefreshProcessingActions = function()
    if InCombatLockdown() then
        processingRefreshPending = true
        return
    end

    for index, button in ipairs(professionButtons) do
        if button.professionData then
            ConfigureSecureAction(button, button.professionData)

            local hotkeyButton = hotkeyButtons[index]
            if hotkeyButton then
                ConfigureSecureAction(hotkeyButton, button.professionData)
            end
        end
    end

    processingRefreshPending = nil
end

local function RefreshHotkeyLabels()
    for _, button in ipairs(professionButtons) do
        if button == hotkeyCaptureButton then
            button.hotkeyLabel:SetText("PRESS KEY")
            button.hotkey = nil
        elseif button.entryKey then
            local hotkey = EbonholdProfessionsDB.hotkeys[button.entryKey]
            button.hotkey = hotkey
            button.hotkeyLabel:SetText(hotkey or "")
        else
            button.hotkey = nil
            button.hotkeyLabel:SetText("")
        end
    end
end

local function ApplyHotkeyBindings()
    if InCombatLockdown() then
        hotkeyBindingsPending = true
        return false
    end

    if type(ClearOverrideBindings) ~= "function"
        or type(SetOverrideBindingClick) ~= "function"
    then
        return false
    end

    local clearOK = pcall(ClearOverrideBindings, eventFrame)
    if not clearOK then
        return false
    end

    local allApplied = true
    for entryKey, hotkey in pairs(EbonholdProfessionsDB.hotkeys) do
        local target = hotkeyTargets[entryKey]
        if target and hotkey and hotkey ~= "" then
            local bindOK = pcall(
                SetOverrideBindingClick,
                eventFrame,
                true,
                hotkey,
                target:GetName(),
                "LeftButton"
            )
            if not bindOK then
                allApplied = false
            end
        end
    end

    hotkeyBindingsPending = nil
    return allApplied
end

local modifierKeys = {
    LSHIFT = true,
    RSHIFT = true,
    LCTRL = true,
    RCTRL = true,
    LALT = true,
    RALT = true,
}

local function BuildHotkey(key)
    if not key or key == "UNKNOWN" or modifierKeys[key] then
        return nil
    end

    local parts = {}
    if IsControlKeyDown() then
        table.insert(parts, "CTRL")
    end
    if IsShiftKeyDown() then
        table.insert(parts, "SHIFT")
    end
    if IsAltKeyDown() then
        table.insert(parts, "ALT")
    end
    table.insert(parts, key)
    return table.concat(parts, "-")
end

EndHotkeyCapture = function()
    if not hotkeyCaptureButton then
        return
    end

    eventFrame:EnableKeyboard(false)
    eventFrame:SetScript("OnKeyDown", nil)
    hotkeyCaptureButton = nil
    RefreshHotkeyLabels()
end

local function BeginHotkeyCapture(button)
    if InCombatLockdown() then
        Print("hotkeys cannot be changed during combat.")
        return
    end

    if type(ClearOverrideBindings) ~= "function"
        or type(SetOverrideBindingClick) ~= "function"
    then
        Print("this client does not support add-on override hotkeys.")
        return
    end

    EndHotkeyCapture()
    hotkeyCaptureButton = button
    RefreshHotkeyLabels()

    Print(
        "press a key for |cffffffff"
            .. button.professionName
            .. "|r. Escape cancels; Backspace clears."
    )

    eventFrame:EnableKeyboard(true)
    eventFrame:SetScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" then
            EndHotkeyCapture()
            Print("hotkey assignment cancelled.")
            return
        end

        if key == "BACKSPACE" or key == "DELETE" then
            EbonholdProfessionsDB.hotkeys[button.entryKey] = nil
            ApplyHotkeyBindings()
            EndHotkeyCapture()
            Print("hotkey reset for |cffffffff" .. button.professionName .. "|r.")
            return
        end

        local hotkey = BuildHotkey(key)
        if not hotkey then
            return
        end

        for entryKey, assignedKey in pairs(EbonholdProfessionsDB.hotkeys) do
            if assignedKey == hotkey then
                EbonholdProfessionsDB.hotkeys[entryKey] = nil
            end
        end

        EbonholdProfessionsDB.hotkeys[button.entryKey] = hotkey
        ApplyHotkeyBindings()
        EndHotkeyCapture()
        Print(
            "|cffffffff"
                .. hotkey
                .. "|r assigned to |cffffffff"
                .. button.professionName
                .. "|r."
        )
    end)
end

local function RefreshItemListPanel()
    if not itemListPanel or not itemListPanel.currentEntryKey then
        return
    end

    local blacklistedItems =
        EbonholdProfessionsDB.itemBlacklists[itemListPanel.currentEntryKey] or {}
    local items = {}

    for itemID, blacklisted in pairs(blacklistedItems) do
        if blacklisted then
            local itemName, itemLink, _, _, _, _, _, _, _, itemTexture =
                GetItemInfo(itemID)
            table.insert(items, {
                id = itemID,
                name = itemName or ("Item " .. itemID),
                link = itemLink,
                texture = itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark",
            })
        end
    end

    table.sort(items, function(left, right)
        return left.name < right.name
    end)

    local rowHeight = 36
    itemListPanel.content:SetHeight(
        math.max(itemListPanel.scroll:GetHeight(), #items * rowHeight)
    )

    for index, item in ipairs(items) do
        local row = itemListRows[index]
        if not row then
            row = CreateFrame("Button", nil, itemListPanel.content)
            row:SetWidth(332)
            row:SetHeight(34)
            row:RegisterForClicks("RightButtonUp")
            AddBackground(row, COLORS.panel, COLORS.border)

            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetWidth(28)
            row.icon:SetHeight(28)
            row.icon:SetPoint("LEFT", row, "LEFT", 5, 0)
            row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            row.nameText = CreateText(row, "", 11, COLORS.text)
            row.nameText:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
            row.nameText:SetPoint("RIGHT", row, "RIGHT", -58, 0)
            row.nameText:SetJustifyH("LEFT")

            row.removeText = CreateText(row, "REMOVE", 9, COLORS.red, "RIGHT")
            row.removeText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            row.removeText:SetTextColor(
                COLORS.red[1], COLORS.red[2], COLORS.red[3]
            )

            row:SetScript("OnClick", function(self)
                local list =
                    EbonholdProfessionsDB.itemBlacklists[itemListPanel.currentEntryKey]
                if list and self.itemID then
                    list[self.itemID] = nil
                    RefreshItemListPanel()
                    RefreshProcessingActions()
                end
            end)
            row:SetScript("OnEnter", function(self)
                self:SetBackdropColor(0.14, 0.16, 0.20, 1)
                self:SetBackdropBorderColor(
                    COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 0.8
                )
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.itemLink then
                    GameTooltip:SetHyperlink(self.itemLink)
                else
                    GameTooltip:SetText(self.itemName or "Item")
                end
                GameTooltip:AddLine("Right-click to remove from the blacklist.", 1, 0.35, 0.35)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                self:SetBackdropColor(
                    COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], COLORS.panel[4]
                )
                self:SetBackdropBorderColor(
                    COLORS.border[1], COLORS.border[2], COLORS.border[3], 1
                )
                GameTooltip:Hide()
            end)
            itemListRows[index] = row
        end

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", itemListPanel.content, "TOPLEFT", 0, -(index - 1) * rowHeight)
        row.itemID = item.id
        row.itemName = item.name
        row.itemLink = item.link
        row.icon:SetTexture(item.texture)
        row.nameText:SetText(item.name)
        row:Show()
    end

    for index = #items + 1, #itemListRows do
        itemListRows[index]:Hide()
    end

    itemListPanel.countText:SetText(
        #items
            .. " blacklisted item"
            .. (#items == 1 and "" or "s")
            .. "  -  mouse wheel scrolls"
    )
end

local function AddCursorItemToList()
    if not itemListPanel or not itemListPanel.currentEntryKey then
        return
    end

    local cursorType, itemID, itemLink = GetCursorInfo()
    if cursorType ~= "item" then
        Print("drag an item from your bags onto the drop area.")
        return
    end

    itemID = tonumber(itemID)
        or (itemLink and tonumber(string.match(itemLink, "item:(%d+)")))
    if not itemID then
        Print("that item could not be identified.")
        return
    end

    local entryKey = itemListPanel.currentEntryKey
    if type(EbonholdProfessionsDB.itemBlacklists[entryKey]) ~= "table" then
        EbonholdProfessionsDB.itemBlacklists[entryKey] = {}
    end

    EbonholdProfessionsDB.itemBlacklists[entryKey][itemID] = true
    ClearCursor()
    RefreshItemListPanel()
    RefreshProcessingActions()

    local itemName = GetItemInfo(itemID) or ("Item " .. itemID)
    Print(
        "|cffffffff"
            .. itemName
            .. "|r added to the "
            .. itemListPanel.currentAbilityName
            .. " blacklist."
    )
end

local function CreateItemListPanel()
    itemListPanel = CreateFrame("Frame", addonName .. "ItemListPanel", UIParent)
    itemListPanel:SetWidth(390)
    itemListPanel:SetHeight(470)
    itemListPanel:SetPoint("CENTER", UIParent, "CENTER", 270, 20)
    itemListPanel:SetFrameStrata("DIALOG")
    itemListPanel:SetClampedToScreen(true)
    itemListPanel:SetMovable(true)
    itemListPanel:EnableMouse(true)
    itemListPanel:RegisterForDrag("LeftButton")
    AddBackground(itemListPanel, COLORS.background, COLORS.gold)
    itemListPanel:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    itemListPanel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    itemListPanel.title = CreateText(itemListPanel, "", 18, COLORS.text)
    itemListPanel.title:SetPoint("TOPLEFT", itemListPanel, "TOPLEFT", 20, -18)

    itemListPanel.closeButton = CreateButton(itemListPanel, "X", 28, 28)
    itemListPanel.closeButton:SetPoint("TOPRIGHT", itemListPanel, "TOPRIGHT", -12, -12)
    itemListPanel.closeButton:SetScript("OnClick", function()
        itemListPanel:Hide()
    end)

    itemListPanel.dropZone = CreateFrame("Button", nil, itemListPanel)
    itemListPanel.dropZone:SetPoint("TOPLEFT", itemListPanel, "TOPLEFT", 20, -52)
    itemListPanel.dropZone:SetPoint("TOPRIGHT", itemListPanel, "TOPRIGHT", -20, -52)
    itemListPanel.dropZone:SetHeight(52)
    AddBackground(itemListPanel.dropZone, COLORS.panel, COLORS.gold)
    itemListPanel.dropZone.text = CreateText(
        itemListPanel.dropZone,
        "Drag a bag item here to blacklist it",
        11,
        COLORS.text,
        "CENTER"
    )
    itemListPanel.dropZone.text:SetPoint("CENTER")
    itemListPanel.dropZone:SetScript("OnReceiveDrag", AddCursorItemToList)
    itemListPanel.dropZone:SetScript("OnClick", AddCursorItemToList)

    itemListPanel.scroll = CreateFrame("ScrollFrame", nil, itemListPanel)
    itemListPanel.scroll:SetPoint("TOPLEFT", itemListPanel, "TOPLEFT", 20, -114)
    itemListPanel.scroll:SetPoint("BOTTOMRIGHT", itemListPanel, "BOTTOMRIGHT", -20, 58)
    itemListPanel.scroll:EnableMouseWheel(true)

    itemListPanel.content = CreateFrame("Frame", nil, itemListPanel.scroll)
    itemListPanel.content:SetWidth(332)
    itemListPanel.content:SetHeight(300)
    itemListPanel.scroll:SetScrollChild(itemListPanel.content)
    itemListPanel.scroll:SetScript("OnMouseWheel", function(self, delta)
        local maximum =
            math.max(0, itemListPanel.content:GetHeight() - self:GetHeight())
        local newValue = self:GetVerticalScroll() - delta * 34
        self:SetVerticalScroll(math.max(0, math.min(maximum, newValue)))
    end)

    itemListPanel.countText = CreateText(itemListPanel, "", 9, COLORS.muted)
    itemListPanel.countText:SetPoint("BOTTOMLEFT", itemListPanel, "BOTTOMLEFT", 22, 22)

    itemListPanel.clearButton = CreateButton(itemListPanel, "Clear Blacklist", 110, 24)
    itemListPanel.clearButton:SetWidth(110)
    itemListPanel.clearButton:SetHeight(22)
    itemListPanel.clearButton:SetPoint("BOTTOMRIGHT", itemListPanel, "BOTTOMRIGHT", -20, 18)
    itemListPanel.clearButton:SetScript("OnClick", function()
        EbonholdProfessionsDB.itemBlacklists[itemListPanel.currentEntryKey] = {}
        RefreshItemListPanel()
        RefreshProcessingActions()
    end)

    table.insert(UISpecialFrames, itemListPanel:GetName())
    itemListPanel:Hide()
end

OpenItemListEditor = function(button)
    if not itemListPanel then
        CreateItemListPanel()
    end

    itemListPanel.currentEntryKey = button.entryKey
    itemListPanel.currentAbilityName = button.professionName
    itemListPanel.title:SetText(button.professionName .. " Blacklist")
    itemListPanel.scroll:SetVerticalScroll(0)
    RefreshItemListPanel()
    itemListPanel:Show()
end

OpenProfessionMenu = function(button)
    GameTooltip:Hide()

    if not contextMenuFrame then
        contextMenuFrame = CreateFrame(
            "Frame",
            addonName .. "ContextMenu",
            UIParent,
            "UIDropDownMenuTemplate"
        )
    end

    local hotkey = EbonholdProfessionsDB.hotkeys[button.entryKey]
    local canAssign = button.actionName and true or false
    local menu = {
        {
            text = button.professionName,
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Current hotkey: " .. (hotkey or "None"),
            disabled = true,
            notCheckable = true,
        },
        {
            text = "Assign hotkey",
            disabled = not canAssign,
            notCheckable = true,
            func = function()
                BeginHotkeyCapture(button)
            end,
        },
        {
            text = "Reset hotkey to default",
            disabled = not hotkey,
            notCheckable = true,
            func = function()
                if InCombatLockdown() then
                    Print("hotkeys cannot be changed during combat.")
                    return
                end

                EbonholdProfessionsDB.hotkeys[button.entryKey] = nil
                ApplyHotkeyBindings()
                RefreshHotkeyLabels()
                Print("hotkey reset for |cffffffff" .. button.professionName .. "|r.")
            end,
        },
    }

    if button.itemProcessor then
        table.insert(menu, {
            text = "Automatic bag targeting: "
                .. (IsAutomaticProcessingEnabled() and "Enabled" or "Disabled"),
            notCheckable = true,
            func = function()
                EbonholdProfessionsDB.settings.autoProcessItems =
                    not IsAutomaticProcessingEnabled()
                if settingsFrame and settingsFrame.autoProcessToggle then
                    settingsFrame.autoProcessToggle:Refresh()
                end
                RefreshProcessingActions()
            end,
        })
        table.insert(menu, {
            text = "Edit blacklist",
            notCheckable = true,
            func = function()
                OpenItemListEditor(button)
            end,
        })
    end

    EasyMenu(menu, contextMenuFrame, "cursor", 0, 0, "MENU")
end

local function ConfigureHotkeyButton(index, profession)
    local button = hotkeyButtons[index]
    if not button then
        button = CreateFrame(
            "Button",
            addonName .. "HotkeyButton" .. index,
            UIParent,
            "SecureActionButtonTemplate"
        )
        button:SetWidth(1)
        button:SetHeight(1)
        button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1, 1)
        button:SetAlpha(0)
        button:EnableMouse(false)
        button:RegisterForClicks("LeftButtonUp")
        hotkeyButtons[index] = button
    end

    if profession.actionName then
        ConfigureSecureAction(button, profession)
        button:Show()
        hotkeyTargets[profession.key] = button
    else
        button:SetAttribute("type", nil)
        button:SetAttribute("spell", nil)
        button:SetAttribute("macrotext", nil)
        button:SetAttribute("target-bag", nil)
        button:SetAttribute("target-slot", nil)
        button:SetAttribute("target-item", nil)
        button:SetAttribute("type1", nil)
        button:SetAttribute("spell1", nil)
        button:SetAttribute("macrotext1", nil)
        button:SetAttribute("target-bag1", nil)
        button:SetAttribute("target-slot1", nil)
        button:SetAttribute("target-item1", nil)
        button:Hide()
    end
end

local function GetSectionHeader(index)
    local header = sectionHeaders[index]
    if not header then
        header = CreateText(panel.content, "", 11, COLORS.gold)
        header:SetWidth(PANEL_WIDTH - 40)
        header:SetHeight(SECTION_HEADER_HEIGHT)
        header:SetJustifyH("LEFT")
        header:SetTextColor(
            COLORS.gold[1], COLORS.gold[2], COLORS.gold[3]
        )
        sectionHeaders[index] = header
    end
    return header
end

function EbonholdProfessions_Refresh()
    if InCombatLockdown() then
        refreshPending = true
        return
    end

    local known = FindKnownProfessions()
    hotkeyTargets = {}
    local grouped = {}
    local layout = {}
    local visibleHeaders = 0
    local maximumPanelWidth = math.max(
        MIN_PANEL_WIDTH,
        (UIParent:GetWidth() or 1024) - 40
    )
    local panelWidth = math.max(
        MIN_PANEL_WIDTH,
        math.min(panel:GetWidth() or PANEL_WIDTH, maximumPanelWidth)
    )
    if panel:GetWidth() ~= panelWidth then
        panel:SetWidth(panelWidth)
    end

    local contentWidth = math.max(1, panelWidth - 24)
    panel.content:SetWidth(contentWidth)

    local sectionColumnCount = panelWidth >= WIDE_SECTION_THRESHOLD and 2 or 1
    local sectionWidth = (
        contentWidth - SECTION_COLUMN_GAP * (sectionColumnCount - 1)
    ) / sectionColumnCount
    local sectionInnerWidth = math.max(1, sectionWidth - 8)
    local buttonColumnCount = sectionInnerWidth >= TWO_BUTTON_COLUMN_WIDTH and 2 or 1
    local buttonWidth = (
        sectionInnerWidth - BUTTON_GAP * (buttonColumnCount - 1)
    ) / buttonColumnCount

    for _, section in ipairs(sectionDefinitions) do
        grouped[section.key] = {}
    end
    for _, profession in ipairs(known) do
        local sectionKey = profession.section or "MAIN"
        if not grouped[sectionKey] then
            grouped[sectionKey] = {}
        end
        table.insert(grouped[sectionKey], profession)
    end

    local populatedSectionCount = 0
    for _, section in ipairs(sectionDefinitions) do
        if grouped[section.key] and #grouped[section.key] > 0 then
            populatedSectionCount = populatedSectionCount + 1
        end
    end

    if populatedSectionCount < 2 and sectionColumnCount == 2 then
        sectionColumnCount = 1
        sectionWidth = contentWidth
        sectionInnerWidth = math.max(1, sectionWidth - 8)
        buttonColumnCount = sectionInnerWidth >= TWO_BUTTON_COLUMN_WIDTH and 2 or 1
        buttonWidth = (
            sectionInnerWidth - BUTTON_GAP * (buttonColumnCount - 1)
        ) / buttonColumnCount
    end

    local sectionColumnHeights = {}
    for column = 1, sectionColumnCount do
        sectionColumnHeights[column] = 2
    end

    for _, section in ipairs(sectionDefinitions) do
        local entries = grouped[section.key]
        if entries and #entries > 0 then
            local targetColumn = 1
            if sectionColumnCount == 2
                and sectionColumnHeights[2] < sectionColumnHeights[1]
            then
                targetColumn = 2
            end

            local sectionX = (targetColumn - 1)
                * (sectionWidth + SECTION_COLUMN_GAP)
            local sectionY = sectionColumnHeights[targetColumn]
            visibleHeaders = visibleHeaders + 1
            local header = GetSectionHeader(visibleHeaders)
            header:ClearAllPoints()
            header:SetPoint(
                "TOPLEFT",
                panel.content,
                "TOPLEFT",
                sectionX + 4,
                -sectionY
            )
            header:SetWidth(sectionInnerWidth)
            header:SetText(section.label .. "  |cff707780(" .. #entries .. ")|r")
            header:Show()

            local buttonStartY = sectionY
                + SECTION_HEADER_HEIGHT
                + SECTION_HEADER_GAP
            for sectionIndex, profession in ipairs(entries) do
                local column = (sectionIndex - 1) % buttonColumnCount
                local row = math.floor((sectionIndex - 1) / buttonColumnCount)
                table.insert(layout, {
                    profession = profession,
                    width = buttonWidth,
                    x = sectionX + 4 + column * (buttonWidth + BUTTON_GAP),
                    y = buttonStartY + row * (BUTTON_HEIGHT + BUTTON_GAP),
                })
            end

            local rows = math.ceil(#entries / buttonColumnCount)
            local sectionHeight = SECTION_HEADER_HEIGHT
                + SECTION_HEADER_GAP
                + rows * BUTTON_HEIGHT
                + math.max(0, rows - 1) * BUTTON_GAP
                + SECTION_GAP
            sectionColumnHeights[targetColumn] = sectionY + sectionHeight
        end
    end

    for index = visibleHeaders + 1, #sectionHeaders do
        sectionHeaders[index]:Hide()
    end

    local contentHeight = 1
    for column = 1, sectionColumnCount do
        contentHeight = math.max(contentHeight, sectionColumnHeights[column])
    end
    contentHeight = math.max(1, contentHeight - SECTION_GAP + 4)
    local maximumPanelHeight = math.max(
        MIN_PANEL_HEIGHT,
        (UIParent:GetHeight() or 768) - 40
    )
    local desiredPanelHeight = contentHeight + 110
    if EbonholdProfessionsDB.panelSizeUserSet then
        panel:SetHeight(
            math.max(
                MIN_PANEL_HEIGHT,
                math.min(panel:GetHeight() or MIN_PANEL_HEIGHT, maximumPanelHeight)
            )
        )
    else
        panel:SetHeight(math.max(150, math.min(desiredPanelHeight, maximumPanelHeight)))
    end
    panel.content:SetHeight(math.max(contentHeight, panel.scrollFrame:GetHeight()))

    local maximumScroll = math.max(
        0,
        panel.content:GetHeight() - panel.scrollFrame:GetHeight()
    )
    panel.scrollFrame:SetVerticalScroll(
        math.min(panel.scrollFrame:GetVerticalScroll(), maximumScroll)
    )

    for index, layoutEntry in ipairs(layout) do
        local profession = layoutEntry.profession
        local button = professionButtons[index]
        if not button then
            button = CreateProfessionButton(index)
            professionButtons[index] = button
        end

        button:SetWidth(layoutEntry.width)
        button:ClearAllPoints()
        button:SetPoint(
            "TOPLEFT",
            panel.content,
            "TOPLEFT",
            layoutEntry.x,
            -layoutEntry.y
        )

        local rankText = ""
        if profession.maxRank and profession.maxRank > 0 then
            rankText = profession.rank .. " / " .. profession.maxRank
        end

        button.professionName = profession.name
        button.entryKey = profession.key
        button.rankText = profession.detailText or rankText
        button.actionName = profession.actionName
        button.isUtility = profession.isUtility
        button.itemProcessor = profession.itemProcessor
        button.processorType = profession.processorType
        button.minimumCount = profession.minimumCount
        button.professionData = profession
        button.hotkey = EbonholdProfessionsDB.hotkeys[profession.key]
        button.icon:SetTexture(profession.texture)
        button.nameText:SetText(profession.name)
        button.hotkeyLabel:SetText(button.hotkey or "")
        button.rankLabel:SetText(
            profession.detailText or (rankText ~= "" and rankText or "Known")
        )

        if profession.actionName then
            ConfigureSecureAction(button, profession)
            button.icon:SetVertexColor(1, 1, 1)
            button.nameText:SetTextColor(
                COLORS.text[1], COLORS.text[2], COLORS.text[3]
            )
            SetButtonBackdrop(
                button,
                COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], COLORS.panel[4]
            )
        else
            ConfigureSecureAction(button, profession)
            button.icon:SetVertexColor(0.45, 0.45, 0.45)
            button.nameText:SetTextColor(
                COLORS.muted[1], COLORS.muted[2], COLORS.muted[3]
            )
            SetButtonBackdrop(button, 0.045, 0.052, 0.066, 1)
        end

        button:Show()
        ConfigureHotkeyButton(index, profession)
    end

    for index = #known + 1, #professionButtons do
        professionButtons[index]:Hide()
        professionButtons[index]:SetAttribute("type", nil)
        professionButtons[index]:SetAttribute("spell", nil)
        professionButtons[index]:SetAttribute("macrotext", nil)
        professionButtons[index]:SetAttribute("target-bag", nil)
        professionButtons[index]:SetAttribute("target-slot", nil)
        professionButtons[index]:SetAttribute("target-item", nil)
        professionButtons[index]:SetAttribute("type1", nil)
        professionButtons[index]:SetAttribute("spell1", nil)
        professionButtons[index]:SetAttribute("macrotext1", nil)
        professionButtons[index]:SetAttribute("target-bag1", nil)
        professionButtons[index]:SetAttribute("target-slot1", nil)
        professionButtons[index]:SetAttribute("target-item1", nil)
        professionButtons[index].entryKey = nil
        professionButtons[index].hotkey = nil
        professionButtons[index].itemProcessor = nil
        professionButtons[index].processorType = nil
        professionButtons[index].professionData = nil
        professionButtons[index].hotkeyLabel:SetText("")
    end
    for index = #known + 1, #hotkeyButtons do
        hotkeyButtons[index]:Hide()
        hotkeyButtons[index]:SetAttribute("type", nil)
        hotkeyButtons[index]:SetAttribute("spell", nil)
        hotkeyButtons[index]:SetAttribute("macrotext", nil)
        hotkeyButtons[index]:SetAttribute("target-bag", nil)
        hotkeyButtons[index]:SetAttribute("target-slot", nil)
        hotkeyButtons[index]:SetAttribute("target-item", nil)
        hotkeyButtons[index]:SetAttribute("type1", nil)
        hotkeyButtons[index]:SetAttribute("spell1", nil)
        hotkeyButtons[index]:SetAttribute("macrotext1", nil)
        hotkeyButtons[index]:SetAttribute("target-bag1", nil)
        hotkeyButtons[index]:SetAttribute("target-slot1", nil)
        hotkeyButtons[index]:SetAttribute("target-item1", nil)
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
    ApplyHotkeyBindings()
    processingRefreshPending = nil
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

    local assignedHotkeys = 0
    for _ in pairs(EbonholdProfessionsDB.hotkeys) do
        assignedHotkeys = assignedHotkeys + 1
    end
    Print(
        "hotkeys: "
            .. assignedHotkeys
            .. " assigned; override API "
            .. (
                type(SetOverrideBindingClick) == "function"
                    and type(ClearOverrideBindings) == "function"
                    and "available."
                or "unavailable."
            )
    )

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
    elseif command == "settings" then
        OpenSettingsFrame()
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
        Print("commands: /ehp, /ehp refresh, /ehp debug, /ehp settings, /ehp button, /ehp minimap")
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")
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
        if EbonholdProfessionsDB.floatingButtonLocked == nil then
            EbonholdProfessionsDB.floatingButtonLocked = false
        end
        if EbonholdProfessionsDB.minimapButtonLocked == nil then
            EbonholdProfessionsDB.minimapButtonLocked = false
        end
        if EbonholdProfessionsDB.floatingButtonOpacity == nil then
            EbonholdProfessionsDB.floatingButtonOpacity = 100
        end
        if EbonholdProfessionsDB.minimapButtonOpacity == nil then
            EbonholdProfessionsDB.minimapButtonOpacity = 100
        end
        if type(EbonholdProfessionsDB.hotkeys) ~= "table" then
            EbonholdProfessionsDB.hotkeys = {}
        end
        if type(EbonholdProfessionsDB.itemBlacklists) ~= "table" then
            EbonholdProfessionsDB.itemBlacklists = {}
        end
        if type(EbonholdProfessionsDB.settings) ~= "table" then
            EbonholdProfessionsDB.settings = {}
        end
        if EbonholdProfessionsDB.settings.autoProcessItems == nil then
            EbonholdProfessionsDB.settings.autoProcessItems = true
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
        elseif processingRefreshPending then
            RefreshProcessingActions()
        end
        if hotkeyBindingsPending then
            ApplyHotkeyBindings()
        end
    elseif event == "BAG_UPDATE" then
        if InCombatLockdown() then
            processingRefreshPending = true
        else
            RefreshProcessingActions()
        end
        if itemListPanel and itemListPanel:IsShown() then
            RefreshItemListPanel()
        end
    elseif event == "SKILL_LINES_CHANGED" or event == "SPELLS_CHANGED" then
        if InCombatLockdown() then
            refreshPending = true
        else
            EbonholdProfessions_SafeRefresh(false)
        end
    end
end)
