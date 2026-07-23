local chilique = fk.CreateSkill{
  name = "chilique",
}

chilique:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chilique.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chilique
