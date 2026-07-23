local chiqingya = fk.CreateSkill{
  name = "chiqingya",
}

local U = require "packages.utility.utility"

local function connect_big_cards(room, who, pindian_card)
  if not who or who.dead or not pindian_card then return end
  local point = pindian_card.number or 0
  local ids = who:getCardIds("hej")
  for _, id in ipairs(ids) do
    local c = Fk:getCardById(id)
    if c and c.number > point then
      U.connectCards(room, id)
    end
  end
end

local function use_pindian_card_if_possible(room, loser, winner, pindian_card)
  if not loser or not winner or loser.dead or winner.dead or not pindian_card then return end
  local card_name = pindian_card.trueName or pindian_card.name
  if not card_name then return end
  if loser:canUseTo(Fk:cloneCard(card_name), winner) then
    room:useVirtualCard(card_name, nil, loser, winner, chiqingya.name, true)
  end
end

local function resolve_qingya(room, user, other, caused_damage)
  if not user or not other or user.dead or other.dead then return end
  if not user:canPindian(other) then return end

  local pindian = U.delayedPindian(user, { other }, chiqingya.name)

  if user.dead or other.dead then
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      U.delayedPindianCleaner(pindian)
    end)
    return
  end

  pindian = U.delayedPindianDisplay(pindian)
  U.delayedPindianCleaner(pindian)

  local result = pindian.results[other]
  if not result then return end

  local user_card = pindian.fromCard
  local other_card = result.toCard
  local winner = result.winner

  if caused_damage then
    if winner == user then
      connect_big_cards(room, other, other_card)
    elseif winner == other then
      connect_big_cards(room, user, user_card)
    else
      connect_big_cards(room, user, user_card)
      connect_big_cards(room, other, other_card)
    end
  else
    if winner == user then
      use_pindian_card_if_possible(room, other, user, other_card)
    elseif winner == other then
      use_pindian_card_if_possible(room, user, other, user_card)
    end
  end
end

-- 当你成为伤害类卡牌的目标后
chiqingya:addEffect(fk.TargetConfirming, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(chiqingya.name)
      and player:usedSkillTimes(chiqingya.name, Player.HistoryTurn) == 0
      and data.from ~= player
      and data.card
      and data.card.is_damage_card
      and not data.cancelled
      and player:canPindian(data.from)
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { data.from } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local other = event:getCostData(self).tos[1]
    if not other or other.dead then return end

    -- 此时牌尚未结算，先挂一个延迟处理到结算后
    room:setBanner("chiqingya_pending", {
      from = player.id,
      to = other.id,
      cardId = data.card and data.card:getEffectiveId() or -1,
      caused_damage = false,
    })
  end,
})

-- 当你使用伤害类卡牌后
chiqingya:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(chiqingya.name) then return false end
    if player:usedSkillTimes(chiqingya.name, Player.HistoryTurn) > 0 then return false end
    if not data.card or not data.card.is_damage_card then return false end
    if data.from ~= player then return false end

    local targets = {}
    for _, p in ipairs(data.tos or {}) do
      if player:canPindian(p) then
        table.insert(targets, p)
      end
    end
    return #targets > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(data.tos or {}) do
      if player:canPindian(p) then
        table.insert(targets, p)
      end
    end

    if #targets == 0 then return false end
    if #targets == 1 then
      event:setCostData(self, { tos = { targets[1] }, caused_damage = next(data.damageDealt or {}) ~= nil })
      return true
    end

    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#chiqingya-target",
      skill_name = chiqingya.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos, caused_damage = next(data.damageDealt or {}) ~= nil })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local other = event:getCostData(self).tos[1]
    if not other or other.dead then return end
    resolve_qingya(room, player, other, event:getCostData(self).caused_damage == true)
  end,
})

-- 被指定为目标的情况：等该牌结算结束后再处理
chiqingya:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    local pending = room:getBanner("chiqingya_pending")
    return player:hasSkill(chiqingya.name)
      and type(pending) == "table"
      and pending.from == player.id
      and pending.cardId == (data.card and data.card:getEffectiveId() or -1)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pending = room:getBanner("chiqingya_pending")
    room:setBanner("chiqingya_pending", nil)

    local other = room:getPlayerById(pending.to)
    if not other or other.dead then return end

    local caused_damage = next(data.damageDealt or {}) ~= nil
    resolve_qingya(room, player, other, caused_damage)
  end,
})

return chiqingya
