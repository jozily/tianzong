local chixiarong = fk.CreateSkill{
  name = "chixiarong",
}

chixiarong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixiarong.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chixiarong
