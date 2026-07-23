local chisusu = fk.CreateSkill{
  name = "chisusu",
}

chisusu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chisusu.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chisusu
