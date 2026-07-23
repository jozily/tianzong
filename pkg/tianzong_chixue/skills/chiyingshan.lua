local chiyingshan = fk.CreateSkill{
  name = "chiyingshan",
}

chiyingshan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiyingshan.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiyingshan
