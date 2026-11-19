local niwochoulu = fk.CreateSkill{
  name = "niwochoulu",
}

local ONCE_MARK = "@@niwochoulu_done"

-- 此刻确实能使用【杀】：手牌里有实体杀（且未被禁用/次数允许），
-- 或有转化技能可转化出杀。cloneCard 出来的虚拟杀无子卡，
-- player:canUse 只判禁用与次数、不查手牌，故须单独确认实体杀来源。
local function can_use_slash(player)
  local slash = Fk:cloneCard("slash")
  if player:prohibitUse(slash) then return false end
  for _, id in ipairs(player:getCardIds("h")) do
    if Fk:getCardById(id).trueName == "slash" then return true end
  end
  if #player:getViewAsCardNames(niwochoulu.name, Fk:getAllCardNames("b"), nil, nil,
      { bypass_distances = true, bypass_times = true }) > 0 then return true end
  return false
end

niwochoulu:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwochoulu.name) then return false end
    if player:usedSkillTimes(niwochoulu.name, Player.HistoryRound) > 0 then return false end
    if not target or not target:isAlive() then return false end
    if not data.from or not data.from:isAlive() or data.from == player then return false end
    if player:distanceTo(target) > 1 then return false end
    return can_use_slash(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niwochoulu.name,
      prompt = "#niwochoulu-invoke::" .. data.from.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = niwochoulu.name,
      prompt = "#niwochoulu-use::" .. data.from.id,
      pattern = "slash",
      extra_data = {
        exclusive_targets = { data.from.id },
        bypass_distances = true,
        bypass_times = true,
        bypass_armors = true,
      }
    })
    
    if use then
      -- 官方限定技发动特效（InvokeUltSkill 大招动画）
      room:doAnimate("InvokeUltSkill", {
        name = niwochoulu.name,
        player = player.id,
        deputy = false,
      })
      room:delay(2000)
      player:broadcastSkillInvoke(niwochoulu.name)
      room:useCard(use)
      room:setPlayerMark(player, ONCE_MARK, 1)

      if next(use.damageDealt or {}) ~= nil then
        -- End only the current turn; shutting down the Turn event directly
        -- can propagate to the room and incorrectly end the whole game.
        room:endTurn()
      end
    end
  end,
})

niwochoulu:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(niwochoulu.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, ONCE_MARK, 0)
  end,
})

return niwochoulu
