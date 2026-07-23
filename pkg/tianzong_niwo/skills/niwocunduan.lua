local niwocunduan = fk.CreateSkill{
  name = "niwocunduan",
}

niwocunduan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwocunduan.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return niwocunduan
