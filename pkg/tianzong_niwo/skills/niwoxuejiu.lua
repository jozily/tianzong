local niwoxuejiu = fk.CreateSkill{
  name = "niwoxuejiu",
}

niwoxuejiu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoxuejiu.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwoxuejiu
