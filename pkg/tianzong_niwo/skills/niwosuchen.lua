local niwosuchen = fk.CreateSkill{
  name = "niwosuchen",
}

niwosuchen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwosuchen.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwosuchen
