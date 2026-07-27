local niwotianmeng_mark = fk.CreateSkill{
  name = "niwotianmeng_mark",
  max_phase_use_time = 1,
}

local CARD_MARK = "@@niwotianmeng"

local function valid_targets(player)
  return table.filter(player.room:getOtherPlayers(player, false), function(p)
    return not p:isNude()
  end)
end

local function mark_cards(room, player, target)
  local own = room:askToChooseCard(player, {
    target = player,
    flag = "he",
    skill_name = "niwotianmeng",
    prompt = "#niwotianmeng-card::" .. player.id,
  })
  local other = room:askToChooseCard(player, {
    target = target,
    flag = "he",
    skill_name = "niwotianmeng",
    prompt = "#niwotianmeng-card::" .. target.id,
  })
  room:setCardMark(Fk:getCardById(own), CARD_MARK, player.id)
  room:setCardMark(Fk:getCardById(other), CARD_MARK, target.id)
end

niwotianmeng_mark:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:hasSkill("niwotianmeng") and not player:isNude() and #valid_targets(player) > 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    mark_cards(room, effect.from, effect.tos[1])
  end,
})

niwotianmeng_mark:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("niwotianmeng") and not player:isNude()
      and #valid_targets(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = valid_targets(player),
      min_num = 1,
      max_num = 1,
      skill_name = "niwotianmeng",
      prompt = "#niwotianmeng-choose",
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    mark_cards(player.room, player, event:getCostData(self).tos[1])
  end,
})

Fk:loadTranslationTable{
  ["niwotianmeng_mark"] = "殄梦",
}

return niwotianmeng_mark
