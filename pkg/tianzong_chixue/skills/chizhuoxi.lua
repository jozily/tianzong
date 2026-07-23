local chizhuoxi = fk.CreateSkill{
  name = "chizhuoxi",
}

chizhuoxi:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chizhuoxi.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chizhuoxi
