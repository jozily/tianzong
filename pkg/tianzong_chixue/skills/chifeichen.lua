local chifeichen = fk.CreateSkill{
  name = "chifeichen",
}

chifeichen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chifeichen.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chifeichen
