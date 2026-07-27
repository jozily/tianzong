local chiyanzu = fk.CreateSkill{ name = "chiyanzu" }

local function discarded_cards(player)
  local ids = player.room:getBanner(MarkEnum.ThisTurnDiscarded) or {}
  return table.filter(ids, function(id)
    if player.room:getCardArea(id) ~= Card.DiscardPile then return false end
    local card = Fk:getCardById(id)
    return card.type == Card.TypeBasic or card:isCommonTrick()
  end)
end

local function refresh(player, card)
  if card:getNameLength(true) <= #player.room.alive_players then return end
  player:setSkillUseHistory(chiyanzu.name, 0, Player.HistoryTurn)
  player:drawCards(#player.room.alive_players, chiyanzu.name)
end

chiyanzu:addEffect("viewas", {
  pattern = ".",
  prompt = "#chiyanzu_choose_use",
  expand_pile = function(self, player)
    return discarded_cards(player)
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 or not table.contains(discarded_cards(player), to_select) then return false end
    local card = Fk:getCardById(to_select)
    if Fk.currentResponsePattern then
      return Exppattern:Parse(Fk.currentResponsePattern):match(card)
    end
    return player:canUse(card) and not player:prohibitUse(card)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    return Fk:getCardById(cards[1])
  end,
  before_use = function(self, player, use)
    refresh(player, use.card)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(chiyanzu.name, Player.HistoryTurn) == 0 and #discarded_cards(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(chiyanzu.name, Player.HistoryTurn) == 0 and #discarded_cards(player) > 0
  end,
})

chiyanzu:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyanzu.name) and
      player:usedSkillTimes(chiyanzu.name, Player.HistoryTurn) == 0 and #discarded_cards(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local ids = discarded_cards(player)
    local use = player.room:askToUseRealCard(player, {
      pattern = ids,
      expand_pile = ids,
      skill_name = chiyanzu.name,
      prompt = "#chiyanzu_choose_damaged",
      cancelable = true,
      skip = true,
      extra_data = { bypass_times = true },
    })
    if use then
      event:setCostData(self, { extra_data = use })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local use = event:getCostData(self).extra_data
    player.room:useCard(use)
    if player:isAlive() then refresh(player, use.card) end
  end,
})

return chiyanzu
