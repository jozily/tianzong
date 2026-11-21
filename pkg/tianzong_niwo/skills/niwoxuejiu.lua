local niwoxuejiu = fk.CreateSkill{
  name = "niwoxuejiu",
  tags = { Skill.Compulsory },
}

local PILE = "niwoxuejiu_lie"
local LIE_MARK = "@@niwoxuejiu_lie"   -- 持久牌标记：牌一旦成为“裂”，一直带着该标记

local function put_lie(player)
  local room = player.room
  if #room.draw_pile == 0 then return end
  local id = room.draw_pile[#room.draw_pile]
  player:addToPile(PILE, id, true, niwoxuejiu.name)
  room:setCardMark(Fk:getCardById(id), LIE_MARK, 1)
end

niwoxuejiu:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoxuejiu.name)
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(player.room.alive_players) do put_lie(p) end
  end,
})

niwoxuejiu:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoxuejiu.name) and data.to and data.to:isAlive()
  end,
  on_use = function(self, event, target, player, data) put_lie(data.to) end,
})

niwoxuejiu:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoxuejiu.name) and data.from and data.from:isAlive()
  end,
  on_use = function(self, event, target, player, data) put_lie(data.from) end,
})

niwoxuejiu:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoxuejiu.name) then return false end
    local names = {}
    for _, p in ipairs(player.room.players) do
      for _, id in ipairs(p:getPile(PILE)) do names[Fk:getCardById(id).trueName] = true end
    end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          -- 之前只看 fromSpecialName 和“当前还在裂区里的牌名”：使用“裂”后那一步
          -- 移动的 fromSpecialName 为空，且这张牌已经离开裂区，导致摸牌不触发。
          -- 用持久牌标记兜底：这张牌只要曾是“裂”，进弃牌堆就摸牌。
          if info.fromSpecialName == PILE
            or (card and card:getMark(LIE_MARK) > 0)
            or (card and names[card.trueName]) then return true end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data) player:drawCards(2, niwoxuejiu.name) end,
})

Fk:loadTranslationTable{ [PILE] = "裂" }
return niwoxuejiu
