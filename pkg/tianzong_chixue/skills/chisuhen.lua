local chisuhen = fk.CreateSkill{
  name = "chisuhen",
}

chisuhen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chisuhen.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chisuhen
