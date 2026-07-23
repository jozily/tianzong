-- chiyilvRemake.lua (绎律)
local chiyilvRemake = fk.CreateSkill{
  name = "chiyilvRemake",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chiyilvRemake"] = "绎律",
  [":chiyilvRemake"] = "锁定技，当你的体力值发生变化时，或一号位的准备阶段开始时，你选择一种颜色并依次展示牌堆顶X张牌，使用其中另一种颜色的牌，并获得其余的牌（X为“徇覆”已记录的锦囊牌牌名数且至少为1）。",
  ["#chiyilvRemake-color"] = "绎律：选择一种颜色",
}

-- 辅助函数：获取徇覆记录的锦囊牌牌名数
local function getChixunfuRecordCount(player)
  local count = 0
  for k, v in pairs(player.marks) do
    if string.find(k, "chixunfu_record_") and v > 0 then
      count = count + 1
    end
  end
  return math.max(count, 1)
end

chiyilvRemake:addEffect(fk.HpChanged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local colors = { "red", "black" }
    local choice = room:askToChoose(player, colors, skillName, "#chiyilvRemake-color")
    local selectedColor = colors[tonumber(choice)]
    
    local deckCount = getChixunfuRecordCount(player)
    local revealed = {}
    
    for i = 1, deckCount do
      local deck = room.deck
      if #deck > 0 then
        table.insert(revealed, table.remove(deck))
      end
    end
    
    room:broadcastProperty(player, "revealed")
    
    for _, card in ipairs(revealed) do
      local cardColor = card.color == Card.Red and "red" or "black"
      
      if cardColor ~= selectedColor then
        -- 使用此牌
        room:useCard({
          from = player,
          card = card,
          skillName = skillName,
        })
      else
        -- 获得此牌
        room:obtainCard(player, card.id, false, fk.ReasonJustMove, player, skillName)
      end
    end
  end,
})

chiyilvRemake:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and
      target == player and
      target.phase == Player.PrepareStage and
      target == player.room.players[1]
  end,
  on_use = function(self, event, target, player, data)
    -- 同上逻辑
    local room = player.room
    local skillName = self.name
    
    local colors = { "red", "black" }
    local choice = room:askToChoose(player, colors, skillName, "#chiyilvRemake-color")
    local selectedColor = colors[tonumber(choice)]
    
    local deckCount = getChixunfuRecordCount(player)
    local revealed = {}
    
    for i = 1, deckCount do
      local deck = room.deck
      if #deck > 0 then
        table.insert(revealed, table.remove(deck))
      end
    end
    
    for _, card in ipairs(revealed) do
      local cardColor = card.color == Card.Red and "red" or "black"
      
      if cardColor ~= selectedColor then
        room:useCard({
          from = player,
          card = card,
          skillName = skillName,
        })
      else
        room:obtainCard(player, card.id, false, fk.ReasonJustMove, player, skillName)
      end
    end
  end,
})

return chiyilvRemake
