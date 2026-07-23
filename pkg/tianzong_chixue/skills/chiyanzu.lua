-- chiyanzu.lua
local chiyanzu = fk.CreateSkill{
  name = "chiyanzu",
  tags = { Skill.Limited },
  description = ":chiyanzu",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chiyanzu"] = "衍族",
  [":chiyanzu"] = "每回合限一次，当你需要使用或打出一张基本牌或普通锦囊牌时，或当你受到伤害后，你可以使用本回合进入弃牌堆的一张可使用的基本牌或普通锦囊牌。若此牌牌名字数大于场上角色数，你刷新此技能且摸场上角色数张牌。",
}

return chiyanzu
