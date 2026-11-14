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
  room:throwCard(id, niwoxianwang.name, player, player)
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

return niwoxianwang
