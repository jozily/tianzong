local chihuangli = fk.CreateSkill{
  name = "chihuangli",
}

chihuangli:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chihuangli.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chihuangli
