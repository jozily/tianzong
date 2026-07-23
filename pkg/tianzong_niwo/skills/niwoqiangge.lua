local niwoqiangge = fk.CreateSkill{
  name = "niwoqiangge",
}

niwoqiangge:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoqiangge.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwoqiangge
