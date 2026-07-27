local niwoxianwang = fk.CreateSkill{ name = "niwoxianwang", tags = { Skill.Compulsory } }
local WIND_PILE = "niwoxungu_wind"
local USED_MARK = "niwoxianwang_used"

niwoxianwang:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(niwoxianwang.name) or data.card:hasSkill("niwoxungu")
      or table.contains(player:getTableMark(USED_MARK), data.card.trueName) then return false end
    return table.find(player:getPile(WIND_PILE), function(id) return Fk:getCardById(id).trueName == data.card.trueName end)
  end,
  on_use = function(self, event, target, player, data)
    local id = table.find(player:getPile(WIND_PILE), function(cid) return Fk:getCardById(cid).trueName == data.card.trueName end)
    if not id then return end
    player.room:addTableMarkIfNeed(player, USED_MARK, data.card.trueName)
    player.room:throwCard({ id }, niwoxianwang.name, player, player)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

niwoxianwang:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoxianwang.name) then return false end
    return table.find(data, function(move)
      return move.toArea == Card.DiscardPile and table.find(move.moveInfo, function(info)
        return info.fromSpecialName == WIND_PILE
      end)
    end)
  end,
  on_use = function(self, event, target, player, data)
    local suits = {}
    for _, id in ipairs(player:getPile(WIND_PILE)) do suits[Fk:getCardById(id).suit] = (suits[Fk:getCardById(id).suit] or 0) + 1 end
    local moved = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromSpecialName == WIND_PILE then
            local suit = Fk:getCardById(info.cardId).suit
            moved[suit] = (moved[suit] or 0) + 1
          end
        end
      end
    end
    local n = 0
    for suit, count in pairs(moved) do n = n + count * ((suits[suit] or 0) + count) end
    if n > 0 then player:drawCards(n, niwoxianwang.name) end
  end,
})

return niwoxianwang
