local chiyuanque = fk.CreateSkill{
  name = "chiyuanque",
   related_skills = { "ty_ex__jueqing","shangshi","jianmie","liangyan","minghui","ol__huishi","qingleng","chiejue","mini__juejue","mini__qingshiz","mini__qingjuez"},
    tags = { Skill.Quest },
}

chiyuanque:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiyuanque.name)
  end,
  on_use = function(self, event, target, player, data)
    -- TODO
  end,
})

return chiyuanque
