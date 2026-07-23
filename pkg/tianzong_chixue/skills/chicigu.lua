-- chicigu.lua (刺骨)
local chicigu = fk.CreateSkill{
  name = "chicigu",
  description = ":chicigu",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local ciCount = 0
    for k, v in pairs(player.marks) do
      if string.find(k, "chicigu_ci_") and v > 0 then
        ciCount = ciCount + v
      end
    end
    return "刺骨：已有" .. ciCount .. "/" .. player:getMaxHp() .. "个刺"
  end,
}

Fk:loadTranslationTable{
  ["chicigu"] = "刺骨",
  ["#chicigu-choose-card"] = "刺骨：选择一张牌置为刺",
  ["#chicigu-choose-player"] = "刺骨：选择一名角色",
  ["#chicigu-end"] = "刺骨：选择一项",
  ["chicigu1"] = "弃置所有刺视为使用冰杀",
  ["chicigu2"] = "获得体力值张刺",
}

chicigu:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return Fk:currentRoom().players[to_select] ~= Fk:currentRoom().current.player
  end,
  can_use = function(self, player)
    return true
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    if #targets == 0 then return end
    
    local target = room:getPlayerById(targets[1])
    local ciCount = 0
    for k, v in pairs(player.marks) do
      if string.find(k, "chicigu_ci_") and v > 0 then
        ciCount = ciCount + v
      end
    end
    
    if ciCount >= player:getMaxHp() then
      room:sendLog("刺骨：已满，无法添加刺")
      return
    end
    
    local cards = target:getCardIds("he")
    if #cards == 0 then return end
    
    local choice = room:askToChooseCards(
      player,
      {
        min = 1,
        max = 1,
        target = target,
        flag = "he",
        skill_name = self.name,
        prompt = "#chicigu-choose-card::" .. target.id,
      }
    )
    
    if #choice > 0 then
      local card = Fk:getCardById(choice[1])
      player:setMark("chicigu_ci_" .. choice[1], 1)
      
      local point = card.number
      local remainder = point % player:getHp()
      if remainder > 1 then
        room:damage({
          to = player,
          from = target,
          damage = 1,
          damageType = fk.IceDamage,
          skillName = self.name,
        })
      end
    end
  end,
})

chicigu:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    if not data.from or not data.from:isAlive() then return false end
    
    local room = player.room
    local ciCount = 0
    for k, v in pairs(player.marks) do
      if string.find(k, "chicigu_ci_") and v > 0 then
        ciCount = ciCount + v
      end
    end
    
    if ciCount >= player:getMaxHp() then return false end
    
    return room:askToSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    
    local cards = from:getCardIds("he")
    if #cards == 0 then return end
    
    local choice = room:askToChooseCards(
      player,
      {
        min = 1,
        max = 1,
        target = from,
        flag = "he",
        skill_name = self.name,
        prompt = "#chicigu-choose-card::" .. from.id,
      }
    )
    
    if #choice > 0 then
      local card = Fk:getCardById(choice[1])
      player:setMark("chicigu_ci_" .. choice[1], 1)
      
      local point = card.number
      local remainder = point % player:getHp()
      if remainder > 1 then
        room:damage({
          to = player,
          from = from,
          damage = 1,
          damageType = fk.IceDamage,
          skillName = self.name,
        })
      end
    end
  end,
})

chicigu:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and target.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local ciCards = {}
    for k, v in pairs(player.marks) do
      if string.find(k, "chicigu_ci_") and v > 0 then
        local cardId = tonumber(string.sub(k, #"chicigu_ci_" + 1))
        table.insert(ciCards, cardId)
      end
    end
    
    if #ciCards == 0 then return end
    
    local choices = { "chicigu1", "chicigu2" }
    local choice = room:askToChoose(player, choices, skillName, "#chicigu-end")
    
    if choice == "chicigu1" then
      room:throwCard(ciCards, skillName, player, player)
      
      local targets = room.alive_players
      local targetList = {}
      for _, p in ipairs(targets) do
        if p ~= player then
          table.insert(targetList, p.id)
        end
      end
      
      if #targetList > 0 then
        local targetId = room:askToChoose(player, targetList, skillName, "#chicigu-choose-player")
        local targetPlayer = room:getPlayerById(tonumber(targetId))
        
        local card = Fk:cloneCard("slash")
        card.skillName = skillName
        card.damage_type = fk.IceDamage
        
        room:useCard({
          from = player,
          card = card,
          tos = { { targetPlayer.id } },
          skillName = skillName,
        })
      end
      
      for _, cardId in ipairs(ciCards) do
        player:setMark("chicigu_ci_" .. cardId, 0)
      end
    else
      local gainCount = player:getMaxHp()
      for _, cardId in ipairs(ciCards) do
        player:setMark("chicigu_ci_" .. cardId, 0)
      end
    end
  end,
})

return chicigu
