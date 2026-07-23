local niwotalan = fk.CreateSkill{
  name = "niwotalan",
}

niwotalan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwotalan.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwotalan
