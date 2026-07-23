-- chixunfu.lua (徇覆)
local chixunfu = fk.CreateSkill{
  name = "chixunfu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chixunfu"] = "徇覆",
  [":chixunfu"] = "锁定技，当你成为一张本轮未以此法记录过的非装备牌的目标时，来源需展示另一种颜色的一张手牌，否则此牌对你无效，然后你记录此牌牌名。",
  ["#chixunfu-show"] = "徇覆：你需要展示一张另一种颜色的手牌，否则此牌对 %dest 无效",
}

chixunfu:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card and data.card.type ~= Card.TypeEquip and
      data.from and data.from:isAlive()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local cardName = data.card.name
    local recordKey = "chixunfu_record_" .. cardName
    
    -- 检查本轮是否已记录过此牌名
    if player:getMark(recordKey) > 0 then
      return false
    end
    
    local from = data.from
    local handcards = from:getCardIds("h")
    local cardColor = data.card.color == Card.Red and "red" or "black"
    local oppositeColor = cardColor == "red" and "black" or "red"
    
    local validCards = {}
    for _, id in ipairs(handcards) do
      local card = Fk:getCardById(id)
      local handCardColor = card.color == Card.Red and "red" or "black"
      if handCardColor == oppositeColor then
        table.insert(validCards, id)
      end
    end
    
    if #validCards == 0 then
      -- 无法展示，此牌无效
      data.nullified = true
    else
      -- 要求展示一张牌
      local shown = room:askToChooseCards(
        from,
        {
          min = 1,
          max = 1,
          flag = "h",
          skill_name = skillName,
          prompt = "#chixunfu-show::" .. player.id,
        }
      )
      
      if #shown == 0 then
        data.nullified = true
      else
        from:showCards(shown)
      end
    end
    
    -- 记录此牌牌名
    player:setMark(recordKey, 1)
  end,
})

return chixunfu
