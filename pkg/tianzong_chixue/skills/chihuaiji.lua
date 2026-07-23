-- chihuaiji.lua
local chihuaiji = fk.CreateSkill{
  name = "chihuaiji",
  tags = { Skill.Switch },
  description = ":chihuaiji",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chihuaiji"] = "怀赍",
  [":chihuaiji"] = "转换技，阴：当你使用一张牌后，你可以失去该牌目标数点体力上限为此牌重新指定目标。阳：当你成为一张牌的目标后，你可以增加该牌目标数点体力上限。",
}

chihuaiji:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:getSwitchSkillState(self.name) == fk.SwitchYin and
      #data.tos > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local targetCount = #data.tos
    
    if targetCount == 0 or player:getMaxHp() <= targetCount then
      return false
    end
    
    if room:askToSkillInvoke(player, skillName) then
      event:setCostData(self, { targetCount = targetCount })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targetCount = event:getCostData(self).targetCount
    room:changeMaxHp(player, -targetCount)
  end,
})

chihuaiji:addEffect(fk.TargetSpecified, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:getSwitchSkillState(self.name) == fk.SwitchYang and
      #data.tos > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, self.name) then
      event:setCostData(self, { targetCount = #data.tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targetCount = event:getCostData(self).targetCount
    room:changeMaxHp(player, targetCount)
  end,
})

return chihuaiji
