local U = require "packages.utility.utility"
local chikuili = fk.CreateSkill{ name = "chikuili", tags = { Skill.Switch } }

local function target_num(player, card)
  if not card or player:prohibitUse(card) or not player:canUse(card, { bypass_times = true }) then return 0 end
  if card.skill:getMinTargetNum() == 0 and not card.multiple_targets then return 1 end
  local n = 0
  for _, p in ipairs(player.room.alive_players) do
    if not player:isProhibited(p, card) and card.skill:modTargetFilter(player, p, {}, card) then n = n + 1 end
  end
  return n
end

local function candidates(player, used)
  local used_length, used_targets = used:getNameLength(true), target_num(player, used)
  return table.filter(player:getCardIds("h"), function(id)
    if table.contains(used.subcards, id) then return false end
    local card = Fk:getCardById(id)
    return (card.type == Card.TypeBasic or card:isCommonTrick()) and
      (card:getNameLength(true) == used_length or target_num(player, card) == used_targets)
  end)
end

chikuili:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chikuili.name) and data.firstTarget and
      player:usedSkillTimes(chikuili.name, Player.HistoryTurn) == 0 and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #candidates(player, data.card) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local ids = candidates(player, data.card)
    local cards = player.room:askToCards(player, {
      min_num = 1, max_num = 1, skill_name = chikuili.name, cancelable = true,
      pattern = tostring(Exppattern{ id = ids }), prompt = "#chikuili-show",
    })
    if #cards > 0 then event:setCostData(self, { cards = cards }); return true end
  end,
  on_use = function(self, event, target, player, data)
    local room, shown = player.room, Fk:getCardById(event:getCostData(self).cards[1])
    player:showCards({ shown.id })
    local used_length, used_targets = data.card:getNameLength(true), target_num(player, data.card)
    local shown_length, shown_targets = shown:getNameLength(true), target_num(player, shown)
    local x
    if shown_length == used_length then x = math.abs(shown_targets - used_targets)
    else x = math.abs(shown_length - used_length) end
    local state = player:getSwitchSkillState(chikuili.name)
    U.SetSwitchSkillState(player, chikuili.name, state)
    if state == fk.SwitchYang then
      data.use.additionalEffect = (data.use.additionalEffect or 0) + x
    elseif x > 0 then
      local extra = data:getExtraTargets()
      if #extra > 0 then
        local chosen = room:askToChoosePlayers(player, {
          targets = extra, min_num = math.min(x, #extra), max_num = math.min(x, #extra),
          cancelable = false, skill_name = chikuili.name, prompt = "#chikuili-target:::" .. x,
        })
        for _, p in ipairs(chosen) do data:addTarget(p) end
      end
    end
    if x == player.hp then player:setSkillUseHistory(chikuili.name, 0, Player.HistoryTurn) end
  end,
})

return chikuili
