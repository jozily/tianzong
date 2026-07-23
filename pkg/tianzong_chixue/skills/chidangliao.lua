local chidangliao = fk.CreateSkill{
  name = "chidangliao",
}

chidangliao:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chidangliao.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chidangliao
