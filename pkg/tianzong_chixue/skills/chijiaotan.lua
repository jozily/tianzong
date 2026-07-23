local chijiaotan = fk.CreateSkill{
  name = "chijiaotan",
}

chijiaotan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chijiaotan.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chijiaotan
