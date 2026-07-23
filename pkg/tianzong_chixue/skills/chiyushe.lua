-- chiyushe.lua
local chiyushe = fk.CreateSkill{
  name = "chiyushe",
  tags = { Skill.Contract },
  description = ":chiyushe",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chiyushe"] = "逾慑",
  [":chiyushe"] = "契定技，当你使用一张牌后，若不为你本回合使用的第一张牌，你可以摸X张牌。",
}

chiyushe:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    -- placeholder
  end,
})

return chiyushe
