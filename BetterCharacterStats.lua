-- to-do, make it faster, get more stats for casters, tooltips
BCS = BCS or {}
BCSConfig = BCSConfig or {}


local L, IndexLeft, IndexRight
L = BCS.L

BCS.PLAYERSTAT_DROPDOWN_OPTIONS = {
	"PLAYERSTAT_BASE_STATS",
	"PLAYERSTAT_MELEE_COMBAT",
	"PLAYERSTAT_RANGED_COMBAT",
	"PLAYERSTAT_SPELL_COMBAT",
	"PLAYERSTAT_DEFENSES",
}

BCS.PaperDollFrame = PaperDollFrame

BCS.Debug = false
BCS.DebugStack = {}

function BCS:DebugTrace(start, limit)
	BCS.Debug = nil
	local length = getn(BCS.DebugStack)
	if not start then start = 1 end
	if start > length then start = length end
	if not limit then limit = start + 30 end
	
	BCS:Print("length: " .. length)
	BCS:Print("start: " .. start)
	BCS:Print("limit: " .. limit)
	
	for i = start, length, 1 do
		BCS:Print("[" .. i .. "]" .. BCS.DebugStack[i])
		if i >= limit then i = length end
	end
	
end

function BCS:Print(message)
	ChatFrame2:AddMessage("[BCS] " .. message, 0.63, 0.86, 1.0)
end

function BCS:OnLoad()
	CharacterAttributesFrame:Hide()
	
	self.Frame = BCSFrame
	self.needUpdate = nil

	self.Frame:RegisterEvent("ADDON_LOADED")
	self.Frame:RegisterEvent("UNIT_INVENTORY_CHANGED") -- fires when equipment changes
	self.Frame:RegisterEvent("SPELLS_CHANGED") -- fires when learning talent
	self.Frame:RegisterEvent("CHARACTER_POINTS_CHANGED") -- fires when learning talent
	self.Frame:RegisterEvent("PLAYER_AURAS_CHANGED")
	self.Frame:RegisterEvent("UNIT_DAMAGE")
	self.Frame:RegisterEvent("UNIT_RANGEDDAMAGE")
	self.Frame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
	self.Frame:RegisterEvent("UNIT_ATTACK_SPEED")
	self.Frame:RegisterEvent("UNIT_ATTACK_POWER")
	self.Frame:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
	self.Frame:RegisterEvent("SKILL_LINES_CHANGED")
	
end

function BCS:OnEvent()
	if BCS.Debug then tinsert(BCS.DebugStack, event) end
	
	if
		event == "SKILL_LINES_CHANGED" or 
		event == "CHARACTER_POINTS_CHANGED" or
		event == "SPELLS_CHANGED" or
		event == "UNIT_DAMAGE" or 
		event == "PLAYER_DAMAGE_DONE_MODS" or 
		event == "UNIT_ATTACK_SPEED" or 
		event == "UNIT_RANGED_ATTACK_POWER" or
		event == "UNIT_RANGEDDAMAGE" or
		event == "PLAYER_AURAS_CHANGED"
	then
		if BCS.PaperDollFrame:IsVisible() then
			BCS:UpdateStats()
		else
			BCS.needUpdate = true
		end
	elseif event == "ADDON_LOADED" and arg1 == "BetterCharacterStats" then
		IndexLeft = BCSConfig["DropdownLeft"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[1]
		IndexRight = BCSConfig["DropdownRight"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[2]

		UIDropDownMenu_SetSelectedValue(PlayerStatFrameLeftDropDown, IndexLeft)
		UIDropDownMenu_SetSelectedValue(PlayerStatFrameRightDropDown, IndexRight)
		
	elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		if BCS.PaperDollFrame:IsVisible() then
			BCS:UpdateStats()
		else
			BCS.needUpdate = true
		end
	end
end

function BCS:OnShow()
	if BCS.needUpdate then
		BCS.needUpdate = nil
		BCS:UpdateStats()
	end
end

function BCS:UpdateStats()
	--local beginTime = debugprofilestop()
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", IndexLeft)
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", IndexRight)
	--local timeUsed = debugprofilestop()-beginTime
	--BCS:Print("I used "..timeUsed.." cpu time!")
end

--
-- durrr need to get all that info
-- from somewhere
--
function BCS:PaperDollFrame_SetStat(statFrame, statIndex)
	local label = getglobal(statFrame:GetName().."Label")
	local text = getglobal(statFrame:GetName().."StatText")
	local stat
	local effectiveStat
	local posBuff
	local negBuff
	local statIndexTable = {
		"STRENGTH",
		"AGILITY",
		"STAMINA",
		"INTELLECT",
		"SPIRIT",
	}
	
	statFrame:SetScript("OnEnter", function()
		PaperDollStatTooltip("player", statIndexTable[statIndex])
	end)
	
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	label:SetText(TEXT(getglobal("SPELL_STAT"..(statIndex-1).."_NAME"))..":")
	stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex)
	
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..(statIndex-1).."_NAME").." "

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStat)
		statFrame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE
	else 
		tooltipText = tooltipText..effectiveStat
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE
		end
		statFrame.tooltip = tooltipText

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		end
	end
end

function BCS:PaperDollFrame_SetArmor(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	end

	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit)
	local totalBufs = posBuff + negBuff
	local frame = statFrame
	local label = getglobal(frame:GetName() .. "Label")
	local text = getglobal(frame:GetName() .. "StatText")

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, frame, text)
	label:SetText(TEXT(ARMOR_COLON))
	
	local playerLevel = UnitLevel(unit)
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400)
	armorReduction = 100 * (armorReduction/(armorReduction + 1))
	
	frame.tooltipSubtext = format(ARMOR_TOOLTIP, playerLevel, armorReduction)
	
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
end

local function PaperDollFrame_SetDamage(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	end

	local label = getglobal(statFrame:GetName() .. "Label")
	label:SetText(TEXT(DAMAGE_COLON))
	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	damageFrame:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local speed, offhandSpeed = UnitAttackSpeed(unit)
	
	local minDamage
	local maxDamage 
	local minOffHandDamage
	local maxOffHandDamage 
	local physicalBonusPos
	local physicalBonusNeg
	local percent
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit)
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / speed)
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)
	
	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		
	end
	damageFrame.damage = damageTooltip
	damageFrame.attackSpeed = speed
	damageFrame.dps = damagePerSecond
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed)
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1)
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.offhandDamage = offhandDamageTooltip
		damageFrame.offhandAttackSpeed = offhandSpeed
		damageFrame.offhandDps = offhandDamagePerSecond
	else
		damageFrame.offhandAttackSpeed = nil
	end
	
end

local function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	end
	local speed, offhandSpeed = UnitAttackSpeed(unit)
	speed = format("%.2f", speed)
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed)
	end
	local text	
	if ( offhandSpeed ) then
		text = speed.." / "..offhandSpeed
	else
		text = speed
	end
	
	local label = getglobal(statFrame:GetName() .. "Label")
	local value = getglobal(statFrame:GetName() .. "StatText")
	
	label:SetText(TEXT(SPEED)..":")
	value:SetText(text)

	--[[statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..text..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));]]
	
	statFrame:Show()
end

local function PaperDollFrame_SetAttackPower(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	end
	
	local base, posBuff, negBuff = UnitAttackPower(unit)

	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(TEXT(ATTACK_POWER_COLON))

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER)
end

local function PaperDollFrame_SetRating(statFrame, ratingType)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.MELEE_HIT_RATING_COLON)
	
	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	
	if ratingType == "MELEE" then
		local rating = BCS:GetHitRating()
		if rating < 5 then
			rating = colorNeg .. rating .. "%|r"
		elseif rating >= 8 then
			rating = colorPos .. rating .. "%|r"
		else
			rating = rating .. "%"
		end
		text:SetText(rating)
	elseif ratingType == "RANGED" then
		local rating = BCS:GetHitRating()
		if rating < 5 then
			rating = colorNeg .. rating .. "%|r"
		elseif rating >= 8 then
			rating = colorPos .. rating .. "%|r"
		else
			rating = rating .. "%"
		end
		text:SetText(rating)
	elseif ratingType == "SPELL" then
		local rating = BCS:GetSpellHitRating()
		if rating < 5 then
			rating = colorNeg .. rating .. "%|r"
		elseif rating >= 8 then
			rating = colorPos .. rating .. "%|r"
		else
			rating = rating .. "%"
		end
		text:SetText(rating)
	end
end

local function PaperDollFrame_SetMeleeCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.MELEE_CRIT_COLON)
	text:SetText(format("%.2f%%", BCS:GetCritChance()))
end

local function PaperDollFrame_SetSpellCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.SPELL_CRIT_COLON)
	text:SetText(format("%.2f%%", BCS:GetSpellCritChance()))
end

local function PaperDollFrame_SetRangedCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.RANGED_CRIT_COLON)
	text:SetText(format("%.2f%%", BCS:GetRangedCritChance()))
end

local function PaperDollFrame_SetManaRegen(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.MANA_REGEN_COLON)
	text:SetText(format("%d", BCS:GetManaRegen()))
end

local function PaperDollFrame_SetDodge(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.DODGE_COLON)
	text:SetText(format("%.2f%%", GetDodgeChance()))
end

local function PaperDollFrame_SetParry(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.PARRY_COLON)
	text:SetText(format("%.2f%%", GetParryChance()))
end

local function PaperDollFrame_SetBlock(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.BLOCK_COLON)
	text:SetText(format("%.2f%%", GetBlockChance()))
end

local function PaperDollFrame_SetDefense(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	end
	local base, modifier = UnitDefense(unit)

	local frame = statFrame
	local label = getglobal(statFrame:GetName() .. "Label")
	local text = getglobal(statFrame:GetName() .. "StatText")
	
	label:SetText(TEXT(DEFENSE_COLON))
	
	local posBuff = 0
	local negBuff = 0
	if ( modifier > 0 ) then
		posBuff = modifier
	elseif ( modifier < 0 ) then
		negBuff = modifier
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, frame, text)
end

local function PaperDollFrame_SetRangedDamage(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	elseif ( unit == "pet" ) then
		return
	end

	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	damageFrame:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit)
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed)
	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		local colorPos = "|cff20ff20"
		local colorNeg = "|cffff2020"
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond)
	end
	damageFrame.attackSpeed = rangedAttackSpeed
	damageFrame.damage = tooltip
	damageFrame.dps = damagePerSecond
end

local function PaperDollFrame_SetRangedAttackSpeed(startFrame, unit)
	if ( not unit ) then
		unit = "player"
	elseif ( unit == "pet" ) then
		return
	end

	local damageText = getglobal(startFrame:GetName() .. "StatText")
	local damageFrame = startFrame

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit)
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed)
	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		local colorPos = "|cff20ff20"
		local colorNeg = "|cffff2020"
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond)
	end
	
	damageText:SetText(format("%.2f", rangedAttackSpeed))
	
	damageFrame.attackSpeed = rangedAttackSpeed
	damageFrame.damage = tooltip
	damageFrame.dps = damagePerSecond
end

local function PaperDollFrame_SetRangedAttackPower(statFrame, unit)
	if ( not unit ) then
		unit = "player"
	elseif ( unit == "pet" ) then
		return
	end
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text:SetText(NOT_APPLICABLE)
		frame.tooltip = nil
		return
	end
	if ( HasWandEquipped() ) then
		text:SetText("--")
		frame.tooltip = nil
		return
	end

	local base, posBuff, negBuff = UnitRangedAttackPower(unit)
	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(RANGED_ATTACK_POWER_TOOLTIP, base/ATTACK_POWER_MAGIC_NUMBER)
end

function BCS:UpdatePaperdollStats(prefix, index)
	local stat1 = getglobal(prefix..1)
	local stat2 = getglobal(prefix..2)
	local stat3 = getglobal(prefix..3)
	local stat4 = getglobal(prefix..4)
	local stat5 = getglobal(prefix..5)
	local stat6 = getglobal(prefix..6)

	stat1:SetScript("OnEnter", nil)
	stat2:SetScript("OnEnter", nil)
	stat3:SetScript("OnEnter", nil)
	stat4:SetScript("OnEnter", nil)
	stat4:SetScript("OnEnter", nil)
	stat5:SetScript("OnEnter", nil)
	stat6:SetScript("OnEnter", nil)

	stat4:Show()
	stat5:Show()
	stat6:Show()

	if ( index == "PLAYERSTAT_BASE_STATS" ) then
		BCS:PaperDollFrame_SetStat(stat1, 1)
		BCS:PaperDollFrame_SetStat(stat2, 2)
		BCS:PaperDollFrame_SetStat(stat3, 3)
		BCS:PaperDollFrame_SetStat(stat4, 4)
		BCS:PaperDollFrame_SetStat(stat5, 5)
		BCS:PaperDollFrame_SetArmor(stat6)
	elseif ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
		PaperDollFrame_SetDamage(stat1)
		PaperDollFrame_SetAttackSpeed(stat2)
		PaperDollFrame_SetAttackPower(stat3)
		PaperDollFrame_SetRating(stat4, "MELEE")
		PaperDollFrame_SetMeleeCritChance(stat5)
		stat6:Hide()
	elseif ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
		PaperDollFrame_SetRangedDamage(stat1)
		PaperDollFrame_SetRangedAttackSpeed(stat2)
		PaperDollFrame_SetRangedAttackPower(stat3)
		PaperDollFrame_SetRating(stat4, "RANGED")
		PaperDollFrame_SetRangedCritChance(stat5)
		stat6:Hide()
	elseif ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
		--PaperDollFrame_SetSpellBonusDamage(stat1);
		--stat1:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
		--PaperDollFrame_SetSpellBonusHealing(stat2);
		--PaperDollFrame_SetRating(stat3, CR_HIT_SPELL);
		--PaperDollFrame_SetSpellCritChance(stat4);
		--stat4:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
		--PaperDollFrame_SetSpellHaste(stat5);
		--PaperDollFrame_SetManaRegen(stat6);
		PaperDollFrame_SetRating(stat1, "SPELL")
		PaperDollFrame_SetSpellCritChance(stat2)
		PaperDollFrame_SetManaRegen(stat3)
		stat4:Hide()
		stat5:Hide()
		stat6:Hide()
	elseif ( index == "PLAYERSTAT_DEFENSES" ) then
		BCS:PaperDollFrame_SetArmor(stat1)
		PaperDollFrame_SetDefense(stat2)
		PaperDollFrame_SetDodge(stat3)
		PaperDollFrame_SetParry(stat4)
		PaperDollFrame_SetBlock(stat5)
		stat6:Hide()
	end
end

function PlayerStatFrameLeftDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameLeftDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end

function PlayerStatFrameRightDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameRightDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end

function PlayerStatFrameLeftDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameLeftDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

function PlayerStatFrameRightDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameRightDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

function PlayerStatFrameLeftDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexLeft = this.value
	BCSConfig["DropdownLeft"] = IndexLeft
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", this.value)
end

function PlayerStatFrameRightDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexRight = this.value
	BCSConfig["DropdownRight"] = IndexRight
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", this.value)
end