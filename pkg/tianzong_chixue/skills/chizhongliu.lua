local chizhongliu = fk.CreateSkill{
  name = "chizhongliu",
}

chizhongliu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chizhongliu.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chizhongliu
