local chiliaozhi = fk.CreateSkill{
  name = "chiliaozhi",
}

chiliaozhi:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiliaozhi.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiliaozhi
