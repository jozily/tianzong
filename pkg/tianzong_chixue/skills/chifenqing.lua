local chifenqing = fk.CreateSkill{
  name = "chifenqing",
}

chifenqing:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chifenqing.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chifenqing
