-- chijiantu.lua (蹇途)
local chijiantu = fk.CreateSkill{
  name = "chijiantu",
  tags = { Skill.Switch },
  description = ":chijiantu",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local state = player:getSwitchSkillState(self.name)
    local suitMarks = {}
    local suitsUsed = {}
    for k, v in pairs(player.marks) do
      if string.find(k, "chijiantu_suit_") and v > 0 then
        local suit = string.sub(k, #"chijiantu_suit_" + 1)
        table.insert(suitsUsed, suit)
      end
    end
    
    local suitStr = ""
    for _, suit in ipairs(suitsUsed) do
      suitStr = suitStr .. suit .. ","
    end
    if suitStr ~= "" then
      suitStr = string.sub(suitStr, 1, -2)
    end
    
    if state == fk.SwitchYang then
      return "蹇途◆阳·闪电 花色:" .. (suitStr == "" and "无" or suitStr)
    else
      return "蹇途◇阴·过河拆桥 花色:" .. (suitStr == "" and "无" or suitStr)
    end
  end,
}

Fk:loadTranslationTable{
  ["chijiantu"] = "蹇途",
  [":chijiantu"] = "转换技，锁定技，当你于回合内首次使用一种花色的单体目标牌指定手牌数不大于你的角色时，此牌视为：①闪电；②过河拆桥；对其使用。",
}

chijiantu:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      #data.tos == 1 and data.card.type == Card.TypeTrick
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local toId = data.tos[1]
    local toPlayer = room:getPlayerById(toId)
    
    if not toPlayer then return end
    
    local handCount = #toPlayer:getCardIds("h")
    
    if handCount > player:getHp() then return end
    
    local suit = data.card.suit
    local markKey = "chijiantu_suit_" .. suit
    
    if player:getMark(markKey) > 0 then return end
    
    player:setMark(markKey, 1)
    
    local state = player:getSwitchSkillState(skillName)
    
    if state == fk.SwitchYang then
      local card = Fk:cloneCard("lightning")
      card.skillName = skillName
      data.card = card
    else
      local card = Fk:cloneCard("dismantlement")
      card.skillName = skillName
      data.card = card
    end
  end,
})

return chijiantu
