-- chikuili.lua (暌离)
local chikuili = fk.CreateSkill{
  name = "chikuili",
  tags = { Skill.Switch },
  description = ":chikuili",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local state = player:getSwitchSkillState(self.name)
    local stateStr = state == fk.SwitchYang and "◆阳·转换状态" or "◇阴·锁定状态"
    return "暌离" .. stateStr
  end,
}

Fk:loadTranslationTable{
  ["chikuili"] = "暌离",
  [":chikuili"] = "转换技，每回合限一次，当你使用一张基本牌或普通锦囊牌时，若有与此牌牌名字数或合法目标数相同的牌，你可以展示之并计算二者差X，此牌：①额外结算X次；②额外选择X个目标；若X等于体力值，你刷新本技能。",
}

chikuili:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local card = data.card
    
    local nameLength = card:getNameLength(true)
    local targetCount = #data.tos
    
    local candidateCards = {}
    for _, otherCard in ipairs(Fk.cards) do
      if otherCard.name ~= card.name then
        local otherNameLength = otherCard:getNameLength(true)
        if otherNameLength == nameLength or otherNameLength == targetCount then
          table.insert(candidateCards, otherCard)
        end
      end
    end
    
    if #candidateCards > 0 then
      local shown = candidateCards[math.random(1, #candidateCards)]
      local X = math.abs(nameLength - #data.tos)
      event:setCostData(self, { x = X, shown = shown })
      return true
    end
    
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local X = event:getCostData(self).x
    
    if X > 0 then
      data.card:addMark("chikuili_extra", X)
    end
    
    if X == player:getHp() then
      player:switchSkillState(skillName)
      player:setMark(skillName .. "_used", 0)
    end
  end,
})

return chikuili
