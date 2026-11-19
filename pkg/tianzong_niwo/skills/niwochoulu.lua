local niwochoulu = fk.CreateSkill{
  name = "niwochoulu",
}

local ONCE_MARK = "@@niwochoulu_done"

niwochoulu:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwochoulu.name) then return false end
    if player:usedSkillTimes(niwochoulu.name, Player.HistoryRound) > 0 then return false end
    if not target or not target:isAlive() then return false end
    if not data.from or not data.from:isAlive() or data.from == player then return false end
    if player:distanceTo(target) > 1 then return false end
    -- 需要此刻确实能使用【杀】（实体杀或转化杀技能均可）才触发
    local slash = Fk:cloneCard("slash")
    if not player:prohibitUse(slash) and player:canUse(slash, { bypass_distances = true, bypass_times = true }) then return true end
    if #player:getViewAsCardNames(niwochoulu.name, Fk:getAllCardNames("b"), nil, nil,
        { bypass_distances = true, bypass_times = true }) > 0 then return true end
    return false
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
      -- 限定技发动特效
      room:doSuperLightBox(nil, {
        text = "#niwochoulu-animate",
        bgColor = "transparent",
        contentAreaColor = "gray",
        contentAreaSize = 0.3,
      })
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
