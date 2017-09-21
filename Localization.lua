BCS = BCS or {}

BCS["L"] = {

	["([%d.]+)%% chance to crit"] = "([%d.]+)%% chance to crit",

	["^Set: Improves your chance to hit by (%d)%%."] = "^Set: Improves your chance to hit by (%d)%%.",
	["^Set: Improves your chance to get a critical strike with spells by (%d)%%."] = "^Set: Improves your chance to get a critical strike with spells by (%d)%%.",
	["^Set: Improves your chance to hit with spells by (%d)%%."] = "^Set: Improves your chance to hit with spells by (%d)%%.",
	["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."] = "^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%.",
	["^Set: Increases healing done by spells and effects by up to (%d+)%."] = "^Set: Increases healing done by spells and effects by up to (%d+)%.",
	
	["Equip: Improves your chance to hit by (%d)%%."] = "Equip: Improves your chance to hit by (%d)%%.",
	["Equip: Improves your chance to get a critical strike with spells by (%d)%%."] = "Equip: Improves your chance to get a critical strike with spells by (%d)%%.",
	["Equip: Improves your chance to hit with spells by (%d)%%."] = "Equip: Improves your chance to hit with spells by (%d)%%.",
	
	["Increases your chance to hit with melee weapons by (%d)%%."] = "Increases your chance to hit with melee weapons by (%d)%%.",
	["Increases your critical strike chance with ranged weapons by (%d)%%."] = "Increases your critical strike chance with ranged weapons by (%d)%%.",
	["Increases spell damage and healing by up to (%d+)%% of your total Spirit."] = "Increases spell damage and healing by up to (%d+)%% of your total Spirit.",
	["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."] = "Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%.",
	["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%."] = "Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%.",
	["Reduces your target's chance to resist your Shadow spells by (%d+)%%."] = "Reduces your target's chance to resist your Shadow spells by (%d+)%%.",
	
	["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."] = "Equip: Increases damage done by Arcane spells and effects by up to (%d+).",
	["Equip: Increases damage done by Fire spells and effects by up to (%d+)."] = "Equip: Increases damage done by Fire spells and effects by up to (%d+).",
	["Equip: Increases damage done by Frost spells and effects by up to (%d+)."] = "Equip: Increases damage done by Frost spells and effects by up to (%d+).",
	["Equip: Increases damage done by Holy spells and effects by up to (%d+)."] = "Equip: Increases damage done by Holy spells and effects by up to (%d+).",
	["Equip: Increases damage done by Nature spells and effects by up to (%d+)."] = "Equip: Increases damage done by Nature spells and effects by up to (%d+).",
	["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."] = "Equip: Increases damage done by Shadow spells and effects by up to (%d+).",
	
	["Shadow Damage %+(%d+)"] = "Shadow Damage %+(%d+)",
	["Spell Damage %+(%d+)"] = "Spell Damage %+(%d+)",
	["Fire Damage %+(%d+)"] = "Fire Damage %+(%d+)",
	["Frost Damage %+(%d+)"] = "Frost Damage %+(%d+)",
	["Healing Spells %+(%d+)"] = "Healing Spells %+(%d+)",
	
	["Equip: Restores (%d+) mana per 5 sec."] = "Equip: Restores (%d+) mana per 5 sec.",
	
	-- Random Bonuses // https://wow.gamepedia.com/index.php?title=SuffixId&oldid=204406
	["^%+(%d+) Damage and Healing Spells"] = "^%+(%d+) Damage and Healing Spells",
	["^%+(%d+) Arcane Spell Damage"] = "^%+(%d+) Arcane Spell Damage",
	["^%+(%d+) Fire Spell Damage"] = "^%+(%d+) Fire Spell Damage",
	["^%+(%d+) Frost Spell Damage"] = "^%+(%d+) Frost Spell Damage",
	["^%+(%d+) Holy Spell Damage"] = "^%+(%d+) Holy Spell Damage",
	["^%+(%d+) Nature Spell Damage"] = "^%+(%d+) Nature Spell Damage",
	["^%+(%d+) Shadow Spell Damage"] = "^%+(%d+) Shadow Spell Damage",
	["^%+(%d+) mana every 5 sec."] = "^%+(%d+) mana every 5 sec.",
	
	-- snowflakes ZG enchants
	["/Hit %+(%d+)"] = "/Hit %+(%d+)",
	["/Spell Hit %+(%d+)"] = "/Spell Hit %+(%d+)",
	["^Mana Regen %+(%d+)"] = "^Mana Regen %+(%d+)",
	["^%+(%d+) Healing Spells"] = "^%+(%d+) Healing Spells",
	["^%+(%d+) Spell Damage and Healing"] = "^%+(%d+) Spell Damage and Healing",
	
	["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."] = "Equip: Increases damage and healing done by magical spells and effects by up to (%d+).",
	["Equip: Increases healing done by spells and effects by up to (%d+)."] = "Equip: Increases healing done by spells and effects by up to (%d+).",
	
	-- buffs!
	["Chance to hit increased by (%d)%%."] = "Chance to hit increased by (%d)%%.",
	["Magical damage dealt is increased by up to (%d+)."] = "Magical damage dealt is increased by up to (%d+).",
	["Healing done by magical spells is increased by up to (%d+)."] = "Healing done by magical spells is increased by up to (%d+).",
	
	["MELEE_HIT_TOOLTIP"] = [[|cffffffffHit|r
	Result of an attack made with 
	melee or ranged weapons.]],
	
	["SPELL_HIT_TOOLTIP"] = [[|cffffffffHit|r
	Result of an attack made with 
	spells.]],
	
	["SPELL_HIT_SECONDARY_TOOLTIP"] = [[|cffffffffHit %d%% (%d%%|cff20ff20+%d%% %s|r|cffffffff)|r
	Result of an attack made with 
	spells.]],
	
	["SPELL_POWER_TOOLTIP"] = [[|cffffffffSpell Power %d|r
	Increases damage done by spells and effects.]],
	
	["SPELL_POWER_SECONDARY_TOOLTIP"] = [[|cffffffffSpell Power %d (%d|cff20ff20+%d %s|r|cffffffff)|r
	Increases damage done by spells and effects.]],
	
	["SPELL_HEALING_POWER_TOOLTIP"] = [[|cffffffffHealing Power %d (%d|cff20ff20+%d|r|cffffffff)|r
	Increases healing done by spells and effects.]],	
	
	["SPELL_MANA_REGEN_TOOLTIP"] = [[|cffffffffMana regen %d (%d|cff20ff20+%d|r|cffffffff)|r
	Regenerating points of mana every 5 seconds.]],
	
	["ROGUE_MELEE_HIT_TOOLTIP"] = [[
+5% hit to always hit enemy players.
+8% hit to always hit with your special abilities against a raid boss.
+24.6% hit to always hit a raid boss.]],

	PLAYERSTAT_BASE_STATS = "Base Stats",
	PLAYERSTAT_DEFENSES = "Defenses",
	PLAYERSTAT_MELEE_COMBAT = "Melee",
	PLAYERSTAT_RANGED_COMBAT = "Ranged",
	PLAYERSTAT_SPELL_COMBAT = "Spell",
	PLAYERSTAT_SPELL_SCHOOLS = "Schools",
	
	MELEE_HIT_RATING_COLON = "Hit Rating:",
	RANGED_HIT_RATING_COLON = "Hit Rating:",
	SPELL_HIT_RATING_COLON = "Hit Rating:",
	MELEE_CRIT_COLON = "Crit Chance:",
	RANGED_CRIT_COLON = "Crit Chance:",
	SPELL_CRIT_COLON = "Crit Chance:",
	MANA_REGEN_COLON = "Mana regen:",
	HEAL_POWER_COLON = "Healing:",
	DODGE_COLON = DODGE .. ":",
	PARRY_COLON = PARRY .. ":",
	BLOCK_COLON = BLOCK .. ":",
	
	SPELL_POWER_COLON = "Power:",
	
	SPELL_SCHOOL_ARCANE = "Arcane",
	SPELL_SCHOOL_FIRE = "Fire",
	SPELL_SCHOOL_FROST = "Frost",
	SPELL_SCHOOL_HOLY = "Holy",
	SPELL_SCHOOL_NATURE = "Nature",
	SPELL_SCHOOL_SHADOW = "Shadow",
	
}