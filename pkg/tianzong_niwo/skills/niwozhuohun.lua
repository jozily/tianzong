local niwozhuohun = fk.CreateSkill{
  name = "niwozhuohun",
}

niwozhuohun:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwozhuohun.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwozhuohun
