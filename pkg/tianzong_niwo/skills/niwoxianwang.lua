local niwoxianwang = fk.CreateSkill{
  name = "niwoxianwang",
  tags = { Skill.Compulsory },
}

local WIND = "niwoxungu_wind&"
local USED = "niwoxianwang_names-turn"

local function matching_wind(player, card)
  if not card or card.skillName == "niwoxungu" or #Card:getIdList(card) == 0 then return end
  return table.find(player:getPile(WIND), function(id)
    local wind = Fk:getCardById(id)
    return wind and wind.trueName == card.trueName
  end)
end

-- 弃置对应的“风”，并摸取与其花色相同的“风”数张牌
local function consume_wind(player, id)
  local room = player.room
  local suit = Fk:getCardById(id).suit
  -- 打标记：本次弃置的摸牌在这里完成，避免 AfterCardsMove 监听重复摸
  room:setCardMark(Fk:getCardById(id), "@@niwoxianwang_consumed", 1)
  room:throwCard(id, niwoxianwang.name, player, player)
  -- 弃置后该“风”已离开私人牌堆，统计剩余同花色“风”数
  local n = #table.filter(player:getPile(WIND), function(wind_id)
    return Fk:getCardById(wind_id).suit == suit
  end)
  if n > 0 and player:isAlive() then player:drawCards(n, niwoxianwang.name) end
end

local function on_trigger(player, card)
  local id = matching_wind(player, card)
  if not id then return end
  player.room:addTableMarkIfNeed(player, USED, card.trueName)
  consume_wind(player, id)
end

niwoxianwang:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoxianwang.name) and
      matching_wind(player, data.card) ~= nil and
      not table.contains(player:getTableMark(USED), data.card.trueName)
  end,
  on_use = function(self, event, target, player, data)
    on_trigger(player, data.card)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

niwoxianwang:addEffect(fk.CardResponding, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoxianwang.name) and
      matching_wind(player, data.card) ~= nil and
      not table.contains(player:getTableMark(USED), data.card.trueName)
  end,
  on_use = function(self, event, target, player, data)
    on_trigger(player, data.card)
  end,
})

-- “风”进入弃牌堆后摸牌：覆盖非主动消耗途径（如寻古回合开始弃置全部“风”、被外力弃置）。
-- 主动 consume_wind 弃置的牌已打 @@niwoxianwang_consumed 标记，这里跳过，避免重复摸。
niwoxianwang:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoxianwang.name) or player.dead then return false end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId, true)
          if card and card:getMark("@@niwo_wind") > 0 and
            card:getMark("@@niwoxianwang_consumed") == 0 then
            return true
          end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 统计本次进入弃牌堆的“风”，按各自花色摸牌
    local entered = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId, true)
          if card and card:getMark("@@niwo_wind") > 0 and
            card:getMark("@@niwoxianwang_consumed") == 0 then
            table.insertIfNeed(entered, info.cardId)
          end
        end
      end
    end
    for _, id in ipairs(entered) do
      local suit = Fk:getCardById(id).suit
      local n = #table.filter(player:getPile(WIND), function(wind_id)
        return Fk:getCardById(wind_id).suit == suit
      end)
      if n > 0 then player:drawCards(n, niwoxianwang.name) end
    end
  end,
})

return niwoxianwang
