local chizhenjie = fk.CreateSkill{
  name = "chizhenjie",
}

chizhenjie:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chizhenjie.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chizhenjie
