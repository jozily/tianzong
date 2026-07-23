local chishaoshan = fk.CreateSkill{
  name = "chishaoshan",
}

chishaoshan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chishaoshan.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chishaoshan
