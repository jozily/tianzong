local chiyushe = fk.CreateSkill{
  name = "chiyushe",
  tags = { Skill.Contract },
}
local LAST_MARK = "chiyushe_last-turn"
local USED_MARK = "@$chiyushe"

local function target_num(player, card)
  if not card or player:prohibitUse(card) or not player:canUse(card) then return 0 end
  if card.skill:getMinTargetNum() == 0 and not card.multiple_targets then return 1 end
  local n = 0
  for _, p in ipairs(player.room.alive_players) do
    if not player:isProhibited(p, card) and card.skill:modTargetFilter(player, p, {}, card) then
      n = n + 1
    end
  end
  return n
end

local function candidates(player, wanted)
  local used = player:getTableMark(USED_MARK)
  return table.filter(Fk:getAllCardNames("bt"), function(name)
    if table.contains(used, name) then return false end
    local card = Fk:cloneCard(name)
    return (card.type == Card.TypeBasic or card:isCommonTrick()) and target_num(player, card) == wanted
  end)
end

chiyushe:addEffect(fk.CardUsing, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyushe.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local previous = player:getMark(LAST_MARK)
    data.extra_data = data.extra_data or {}
    if type(previous) == "table" then
      data.extra_data.chiyushe_previous = previous.number
    end
    player.room:setPlayerMark(player, LAST_MARK, { number = target_num(player, data.card) })
  end,
})

chiyushe:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyushe.name) and data.extra_data and
      data.extra_data.chiyushe_previous ~= nil
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chiyushe.name,
      prompt = "#chiyushe-invoke:::" .. data.extra_data.chiyushe_previous,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = data.extra_data.chiyushe_previous
    player:drawCards(x, chiyushe.name)
    if player.dead then return end

    local names = candidates(player, target_num(player, data.card))
    if #names > 0 then
      local use = room:askToUseVirtualCard(player, {
        name = names,
        skill_name = chiyushe.name,
        prompt = "#chiyushe-use",
        cancelable = false,
        skip = true,
      })
      if use then
        room:addTableMarkIfNeed(player, USED_MARK, use.card.name)
        room:useCard(use)
        return
      end
    end

    room:loseHp(player, 1, chiyushe.name)
    if player:isAlive() and x > 0 then
      local n = math.min(x, #player:getCardIds("he"))
      if n > 0 then
        room:askToDiscard(player, {
          min_num = n,
          max_num = n,
          include_equip = true,
          skill_name = chiyushe.name,
          cancelable = false,
          prompt = "#chiyushe-discard:::" .. x,
        })
      end
    end
  end,
})

return chiyushe
