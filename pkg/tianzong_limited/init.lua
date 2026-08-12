local extension = Package:new("tianzong_limited")
extension.extensionName = "tianzong"

extension:loadSkillSkelsByPath("./packages/tianzong/pkg/tianzong_limited/skills")

local fengji_equips = {
  { name = "&weapon__tianzong_limited__fengji", subtype = Card.SubtypeWeapon },
  { name = "&armor__tianzong_limited__fengji", subtype = Card.SubtypeArmor },
  { name = "&offensive_horse__tianzong_limited__fengji", subtype = Card.SubtypeOffensiveRide },
  { name = "&defensive_horse__tianzong_limited__fengji", subtype = Card.SubtypeDefensiveRide },
  { name = "&treasure__tianzong_limited__fengji", subtype = Card.SubtypeTreasure },
}
for _, spec in ipairs(fengji_equips) do
  local card = fk.CreateCard {
    name = spec.name,
    type = Card.TypeEquip,
    sub_type = spec.subtype,
  }
  extension:loadCardSkels { card }
  extension:addCardSpec(spec.name:sub(2))
end

General:new(extension, "tianzong_limited__misaka", "tianzong_science", 4, 4, General.Female)
  :addSkills { "tianzong_limited__leibi", "tianzong_limited__cipao" }
General:new(extension, "tianzong_limited__shirai", "tianzong_science", 3, 3, General.Female)
  :addSkills { "tianzong_limited__shunyi", "tianzong_limited__fengji" }
General:new(extension, "tianzong_limited__uiharu", "tianzong_science", 3, 3, General.Female)
  :addSkills { "tianzong_limited__hengwen", "tianzong_limited__zonghuan" }
General:new(extension, "tianzong_limited__kungou", "tianzong_science", 4, 4, General.Female)
  :addSkills { "tianzong_limited__zhoushe" }

Fk:loadTranslationTable {
  ["tianzong_limited"] = "限时武将",
  ["tianzong_science"] = "科学",

  ["tianzong_limited__misaka"] = "御坂美琴",
  ["#tianzong_limited__misaka"] = "最强无敌的电击公主",
  ["designer:tianzong_limited__misaka"] = "公冶天纵",
  ["illustrator:tianzong_limited__misaka"] = "灰村清孝",
  ["tianzong_limited__leibi"] = "雷壁",
  [":tianzong_limited__leibi"] = "其他角色使用的技能每回合首次即将作用于你时，你可视为对其使用一张雷【杀】，若此【杀】造成伤害，此技能无效。当你即将受到雷属性伤害时，你可令其取消之，然后你恢复等量点体力值。",
  ["tianzong_limited__cipao"] = "磁炮",
  [":tianzong_limited__cipao"] = "出牌阶段限一次，你可以将任意张牌当作一张不计入次数且无视防具的雷【杀】使用，若这些牌的牌名字数均不相同，此【杀】伤害改为X（X为以此法转化的牌数）。",

  ["tianzong_limited__shirai"] = "白井黑子",
  ["#tianzong_limited__shirai"] = "正义的风纪委员",
  ["designer:tianzong_limited__shirai"] = "公冶天纵",
  ["illustrator:tianzong_limited__shirai"] = "灰村清孝",
  ["tianzong_limited__shunyi"] = "瞬移",
  [":tianzong_limited__shunyi"] = "出牌阶段限一次，你可以将与你距离不大于1的一名角色的：①一张手牌区、装备区或判定区的牌移动至另一名角色的相应区域；②座次移动至两名其他角色中间，然后移除此选项。",
  ["tianzong_limited__fengji"] = "风纪",
  [":tianzong_limited__fengji"] = "每轮限一次，当有角色受到伤害后，若伤害来源与你距离为1，你可以将一张【杀】置于其装备区；有角色装备区有除了装备牌外的牌进入时，其需选择一项：1.本回合不能使用或打出与此牌花色相同的牌且所有非锁定技失效；2.保留此牌和一张手牌，然后弃置所有牌。",
  ["weapon__tianzong_limited__fengji"] = "风纪",
  ["armor__tianzong_limited__fengji"] = "风纪",
  ["offensive_horse__tianzong_limited__fengji"] = "风纪",
  ["defensive_horse__tianzong_limited__fengji"] = "风纪",
  ["treasure__tianzong_limited__fengji"] = "风纪",

  ["tianzong_limited__uiharu"] = "初春饰利",
  ["#tianzong_limited__uiharu"] = "Lv1.定温保存",
  ["designer:tianzong_limited__uiharu"] = "公冶天纵",
  ["illustrator:tianzong_limited__uiharu"] = "幻想收束",
  ["tianzong_limited__hengwen"] = "恒温",
  [":tianzong_limited__hengwen"] = "限定技，出牌阶段，你可以令一名角色获得一枚“恒温”标记并记录其体力值。其体力值变化后，若其未进入濒死状态，你可以令其恢复或失去体力至记录体力值，然后移除其“恒温”标记并重置“纵幻”。",
  ["tianzong_limited__zonghuan"] = "纵幻",
  [":tianzong_limited__zonghuan"] = "限定技，每当你成为其他角色牌的目标时，你可重置“恒温”并令此牌对你无效，然后你选择另一名角色成为此牌目标。",

  ["tianzong_limited__kungou"] = "婚后光子",
  ["#tianzong_limited__kungou"] = "Lv.4.空力使",
  ["designer:tianzong_limited__kungou"] = "公冶天纵",
  ["illustrator:tianzong_limited__kungou"] = "幻想收束",
  ["tianzong_limited__zhoushe"] = "轴射",
  [":tianzong_limited__zhoushe"] = "每回合各限一次，①你可以视为打出一张【杀】；②你可以视为对一名角色攻击范围内的所有角色使用一张雷【杀】，若此【杀】被【闪】抵消，你令其选择一项：1.失去1点体力；2.弃置装备区所有牌。",
}

return extension
