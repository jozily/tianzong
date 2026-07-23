local chiquege = fk.CreateSkill{
  name = "chiquege",
}

chiquege:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiquege.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiquege
