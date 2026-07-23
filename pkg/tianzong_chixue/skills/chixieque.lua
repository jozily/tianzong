local chixieque = fk.CreateSkill{
  name = "chixieque",
}

chixieque:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixieque.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chixieque
