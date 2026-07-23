local chifushui = fk.CreateSkill{
  name = "chifushui",
}

chifushui:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chifushui.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chifushui
