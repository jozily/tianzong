-- chizhichen.lua (炙尘)
local chizhichen = fk.CreateSkill{
  name = "chizhichen",
  tags = { Skill.Compulsory },
  description = ":chizhichen",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local dustCount = player:getMark("chizhichen_dust") or 0
    return "炙尘：" .. dustCount .. "个尘"
  end,
}

Fk:loadTranslationTable{
  ["chizhichen"] = "炙尘",
  [":chizhichen"] = "锁定技，每轮开始时，你的上家和下家获得“尘”标记。当你受到/造成伤害后，你令伤害来源/目标横置并获得“尘”标记，若当前回合角色横置或翻面，你重铸手牌中花色最多的所有牌。",
}

chizhichen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and target.phase == Player.PrepareStage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local prev = player:getPreviousPlayer()
    local next = player:getNextPlayer()
    
    if prev:isAlive() then
      prev:setMark("chizhichen_dust", (prev:getMark("chizhichen_dust") or 0) + 1)
    end
    
    if next:isAlive() then
      next:setMark("chizhichen_dust", (next:getMark("chizhichen_dust") or 0) + 1)
    end
  end,
})

chizhichen:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and data.from:isAlive()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local from = data.from
    
    from:setFlipped(true)
    from:setMark("chizhichen_dust", (from:getMark("chizhichen_dust") or 0) + 1)
    
    if room.current.player:isFlipped() then
      local handcards = player:getCardIds("h")
      if #handcards > 0 then
        local suits = {}
        for _, id in ipairs(handcards) do
          local card = Fk:getCardById(id)
          local suit = card.suit
          if not suits[suit] then
            suits[suit] = {}
          end
          table.insert(suits[suit], id)
        end
        
        local maxSuit = nil
        local maxCount = 0
        for suit, cards in pairs(suits) do
          if #cards > maxCount then
            maxCount = #cards
            maxSuit = suit
          end
        end
        
        if maxSuit and suits[maxSuit] then
          room:throwCard(suits[maxSuit], skillName, player, player)
          player:drawCards(#suits[maxSuit], skillName)
        end
      end
    end
  end,
})

chizhichen:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.tos and #data.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    for _, toId in ipairs(data.tos) do
      local toPlayer = room:getPlayerById(toId)
      if toPlayer and toPlayer:isAlive() then
        toPlayer:setFlipped(true)
        toPlayer:setMark("chizhichen_dust", (toPlayer:getMark("chizhichen_dust") or 0) + 1)
      end
    end
    
    if room.current.player:isFlipped() then
      local handcards = player:getCardIds("h")
      if #handcards > 0 then
        local suits = {}
        for _, id in ipairs(handcards) do
          local card = Fk:getCardById(id)
          local suit = card.suit
          if not suits[suit] then
            suits[suit] = {}
          end
          table.insert(suits[suit], id)
        end
        
        local maxSuit = nil
        local maxCount = 0
        for suit, cards in pairs(suits) do
          if #cards > maxCount then
            maxCount = #cards
            maxSuit = suit
          end
        end
        
        if maxSuit and suits[maxSuit] then
          room:throwCard(suits[maxSuit], skillName, player, player)
          player:drawCards(#suits[maxSuit], skillName)
        end
      end
    end
  end,
})

return chizhichen
