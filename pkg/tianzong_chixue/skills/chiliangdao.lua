local chiliangdao = fk.CreateSkill{
  name = "chiliangdao",
}

chiliangdao:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiliangdao.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiliangdao
