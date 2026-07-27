local niwochenghen = fk.CreateSkill{ name = "niwochenghen" }
local CARD_MARK = "@@niwotianmeng"

niwochenghen:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwochenghen.name) then return false end
    return table.find(data, function(move)
      return move.toArea == Card.DiscardPile and table.find(move.moveInfo, function(info)
        local owner = Fk:getCardById(info.cardId):getMark(CARD_MARK)
        return info.fromArea == Card.Processing and owner ~= 0 and owner ~= player.id
      end)
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local owner = Fk:getCardById(info.cardId):getMark(CARD_MARK)
          if info.fromArea == Card.Processing and owner ~= 0 and owner ~= player.id then table.insert(ids, info.cardId) end
        end
      end
    end
    if #ids > 0 and player.room:askToSkillInvoke(player, { skill_name = niwochenghen.name, prompt = "#niwochenghen-obtain:::" .. #ids }) then
      event:setCostData(self, { cards = ids })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = table.filter(event:getCostData(self).cards, function(id) return table.contains(player.room.discard_pile, id) end)
    if #ids > 0 then player.room:obtainCard(player, ids, true, fk.ReasonPrey, player, niwochenghen.name) end
  end,
})

niwochenghen:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwochenghen.name)
      and #player:getSkillNameList() > 1 and #player.room:getOtherPlayers(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, { targets = room:getOtherPlayers(player), min_num = 1, max_num = 1, skill_name = niwochenghen.name, prompt = "#niwochenghen-choose", cancelable = true })
    if #tos > 0 then event:setCostData(self, { tos = tos }); return true end
  end,
  on_use = function(self, event, target, player, data)
    local room, to = player.room, event:getCostData(self).tos[1]
    local names = table.filter(player:getSkillNameList(), function(name) return name ~= niwochenghen.name end)
    local name = room:askToChoice(player, { choices = names, skill_name = niwochenghen.name, prompt = "#niwochenghen-skill::" .. to.id })
    room:handleAddLoseSkills(to, name)
    local ids = {}
    for _, p in ipairs(room.players) do
      for _, id in ipairs(p:getCardIds("ej")) do if Fk:getCardById(id):getMark(CARD_MARK) ~= 0 then table.insert(ids, id) end end
    end
    for _, id in ipairs(ids) do
      if to.dead then break end
      local card = Fk:getCardById(id)
      if player:canUseTo(card, to, { bypass_times = true, bypass_distances = true }) then
        room:useCard{ from = player, tos = { to }, card = card, extraUse = true }
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["#niwochenghen-obtain"] = "承恨：是否获得进入弃牌堆的%arg张其他角色的“殁”？",
  ["#niwochenghen-choose"] = "承恨：选择一名角色获得你的一个技能",
  ["#niwochenghen-skill"] = "承恨：选择令 %dest 获得的技能",
}
return niwochenghen
