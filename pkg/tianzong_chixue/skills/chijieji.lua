-- chijieji.lua
local chijieji = fk.CreateSkill{
  name = "chijieji",
  description = ":chijieji",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chijieji"] = "借笈",
  [":chijieji"] = "出牌阶段限一次，你可以观看一名手牌数或技能数不小于你的角色的手牌，并将其中一张牌当做一张合法目标数相同的基本牌或普通锦囊牌使用，然后其摸X张牌。",
}

return chijieji
