local niwoshulie = fk.CreateSkill{
  name = "niwoshulie",
}

niwoshulie:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoshulie.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwoshulie
