local zhoushe = fk.CreateSkill {
  name = "tianzong_limited__zhoushe",
  related_skills = { "#tianzong_limited__zhoushe_use" },
}

local zhoushe_use = fk.CreateSkill { name = "#tianzong_limited__zhoushe_use" }

zhoushe:addEffect("viewas", {
  pattern = "slash",
  prompt = "#tianzong_limited__zhoushe-response",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("slash")
    card.skillName = zhoushe.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "tianzong_limited__zhoushe_response-turn", 1)
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return response and player:getMark("tianzong_limited__zhoushe_response-turn") == 0 and
      Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("slash"))
  end,
})

zhoushe_use:addEffect("active", {
  prompt = "#tianzong_limited__zhoushe-use",
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local slash = Fk:cloneCard("thunder__slash")
    return table.find(player.room.alive_players, function(p)
      return p ~= player and to_select:inMyAttackRange(p) and
        player:canUseTo(slash, p, { bypass_times = true })
    end)
  end,
  can_use = function(self, player)
    return player:hasSkill(zhoushe.name) and player:getMark("tianzong_limited__zhoushe_use-turn") == 0
  end,
  on_use = function(self, room, effect)
    local player, anchor = effect.from, effect.tos[1]
    local slash = Fk:cloneCard("thunder__slash")
    slash.skillName = zhoushe.name
    local tos = table.filter(room.alive_players, function(p)
      return p ~= player and anchor:inMyAttackRange(p) and
        player:canUseTo(slash, p, { bypass_times = true })
    end)
    if #tos == 0 then return end
    room:setPlayerMark(player, "tianzong_limited__zhoushe_use-turn", 1)
    room:useCard { from = player, tos = tos, card = slash, extraUse = true }
  end,
})

zhoushe:addEffect(fk.CardEffectCancelledOut, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == zhoushe.name and
      data.card.trueName == "slash" and data.to and data.to:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local choices = { "tianzong_limited__zhoushe_losehp" }
    if #data.to:getCardIds("e") > 0 then table.insert(choices, "tianzong_limited__zhoushe_discard") end
    local choice = #choices == 1 and choices[1] or player.room:askToChoice(data.to, {
      choices = choices, skill_name = zhoushe.name,
      prompt = "#tianzong_limited__zhoushe-choice::" .. player.id,
    })
    if choice == "tianzong_limited__zhoushe_discard" then
      player.room:throwCard(data.to:getCardIds("e"), zhoushe.name, data.to, data.to)
    else
      player.room:loseHp(data.to, 1, zhoushe.name)
    end
  end,
})

Fk:loadTranslationTable {
  ["#tianzong_limited__zhoushe-response"] = "轴射：视为打出一张【杀】",
  ["#tianzong_limited__zhoushe-use"] = "轴射：选择一名角色，视为对其攻击范围内的所有角色使用雷【杀】",
  ["#tianzong_limited__zhoushe-choice"] = "轴射：此雷【杀】被抵消，请选择一项",
  ["tianzong_limited__zhoushe_losehp"] = "失去1点体力",
  ["tianzong_limited__zhoushe_discard"] = "弃置装备区所有牌",
}

return zhoushe
