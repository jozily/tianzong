local chitiaofeng = fk.CreateSkill{
  name = "chitiaofeng",
}

chitiaofeng:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chitiaofeng.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chitiaofeng
