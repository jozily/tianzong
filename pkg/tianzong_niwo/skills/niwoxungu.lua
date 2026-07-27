local niwoxungu = fk.CreateSkill{ name = "niwoxungu" }
local WIND_PILE = "niwoxungu_wind"

niwoxungu:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoxungu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local old = player:getPile(WIND_PILE)
    if #old > 0 then room:throwCard(old, niwoxungu.name, player, player) end

    local judged, names, duplicate = {}, {}, nil
    while not duplicate and #room.draw_pile > 0 do
      local judge = { who = player, reason = niwoxungu.name, pattern = "." }
      room:judge(judge)
      if not judge.card then break end
      local id, name = judge.card.id, judge.card.trueName
      table.insert(judged, id)
      if table.contains(names, name) then duplicate = id else table.insert(names, name) end
    end

    local gain, winds = {}, {}
    for _, id in ipairs(judged) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeEquip or id == duplicate then table.insert(gain, id) else table.insert(winds, id) end
    end
    gain = table.filter(gain, function(id) return table.contains(room.discard_pile, id) end)
    winds = table.filter(winds, function(id) return table.contains(room.discard_pile, id) end)
    if #gain > 0 then room:obtainCard(player, gain, true, fk.ReasonPrey, player, niwoxungu.name) end
    if #winds > 0 then player:addToPile(WIND_PILE, winds, true, niwoxungu.name) end
  end,
})

niwoxungu:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwoxungu",
  max_turn_use_time = 1,
  expand_pile = WIND_PILE,
  interaction = function(self, player)
    if #player:getPile(WIND_PILE) == 0 then return end
    local names = player:getViewAsCardNames(niwoxungu.name, Fk:getAllCardNames("bt"))
    if #names > 0 then return UI.CardNameBox{ choices = names, all_choices = names } end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile(WIND_PILE), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = niwoxungu.name
    card:addSubcard(cards[1])
    return card
  end,
})

Fk:loadTranslationTable{
  [WIND_PILE] = "风",
  ["#niwoxungu"] = "寻古：将一张“风”当任意牌使用或打出",
}
return niwoxungu
