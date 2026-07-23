local chidulie = fk.CreateSkill{
  name = "chidulie",
}

chidulie:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chidulie.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chidulie
