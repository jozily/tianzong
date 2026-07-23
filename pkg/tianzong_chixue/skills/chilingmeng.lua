local chilingmeng = fk.CreateSkill{
  name = "chilingmeng",
}

chilingmeng:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chilingmeng.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chilingmeng
