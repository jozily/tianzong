local niwozhengtu = fk.CreateSkill{
  name = "niwozhengtu",
}

niwozhengtu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwozhengtu.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwozhengtu
