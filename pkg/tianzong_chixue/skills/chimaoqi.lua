local chimaoqi = fk.CreateSkill{
  name = "chimaoqi",
}

chimaoqi:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chimaoqi.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chimaoqi
