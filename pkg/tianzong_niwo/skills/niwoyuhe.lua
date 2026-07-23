local niwoyuhe = fk.CreateSkill{
  name = "niwoyuhe",
}

niwoyuhe:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyuhe.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwoyuhe
