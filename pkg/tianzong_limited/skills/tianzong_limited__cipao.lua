local cipao = fk.CreateSkill { name = "tianzong_limited__cipao" }

cipao:addEffect("viewas", {
  pattern = "slash",
  prompt = "#tianzong_limited__cipao",
  filter_pattern = { min_num = 1, max_num = math.huge, pattern = "." },
  view_as = function(self, player, cards)
    if #cards == 0 then return end
    local card = Fk:cloneCard("thunder__slash")
    card:addSubcards(cards)
    card.skillName = cipao.name
    return card
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    local lengths, distinct = {}, true
    for _, id in ipairs(use.card.subcards) do
      local n = Fk:getCardById(id):getNameLength(true)
      if lengths[n] then distinct = false break end
      lengths[n] = true
    end
    use.extra_data = use.extra_data or {}
    use.extra_data.tianzong_limited__cipao_damage = distinct and #use.card.subcards or nil
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(cipao.name, Player.HistoryPhase) == 0
  end,
})

cipao:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == cipao.name
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

cipao:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == cipao.name
  end,
  on_refresh = function(self, event, target, player, data)
    local use = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    local x = use and use.data.extra_data and use.data.extra_data.tianzong_limited__cipao_damage
    if x then data.damage = x end
  end,
})

return cipao
