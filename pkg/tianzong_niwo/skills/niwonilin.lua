local niwonilin = fk.CreateSkill{
  name = "niwonilin",
}

niwonilin:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwonilin.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwonilin
