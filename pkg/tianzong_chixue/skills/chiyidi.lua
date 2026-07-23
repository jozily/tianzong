local chiyidi = fk.CreateSkill{
  name = "chiyidi",
}

chiyidi:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiyidi.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiyidi
