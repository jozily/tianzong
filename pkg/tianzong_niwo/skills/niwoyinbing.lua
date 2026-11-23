local niwoyinbing = fk.CreateSkill{
  name = "niwoyinbing",
  tags = { Skill.Contract },
  related_skills = { "niwochoulu", "niwoyinbing2" },
}

-- 是否因饮冰而进入濒死：冰杀伤害(带 niwoyinbing_slash 标记) 或 失血(skillName=niwoyinbing)
local function isYinbingDying(data)
  if data.damage then
    if data.damage.skillName == niwoyinbing.name then return true end
    local card = data.damage.card
    if card and card:getMark("niwoyinbing_slash") > 0 then return true end
  end
  if data.hpLost and data.hpLost.skillName == niwoyinbing.name then return true end
  return false
end

local function dyedDone(room)
  room.tag = room.tag or {}
  return room.tag["niwoyinbing_dying_done"] == true
end

niwoyinbing:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing.name) and data.from and data.from:isAlive() and
      data.to and data.to:isAlive() and data.from ~= data.to and
      (data.from == player or data.to == player) and
      player:getMark("niwoyinbing_inuse") == 0 and
      (not data.card or data.card:getMark("niwoyinbing_slash") == 0)
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("contracted_skills"), niwoyinbing.name) then
      return true
    end
    return player.room:askToSkillInvoke(player, {
      skill_name = niwoyinbing.name,
      prompt = "#niwoyinbing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room, user, source = player.room, data.to, data.from
    local was_contracted = table.contains(player:getTableMark("contracted_skills"), niwoyinbing.name)
    room:addTableMarkIfNeed(player, "contracted_skills", niwoyinbing.name)
    local use
    if was_contracted then
      local card = Fk:cloneCard("ice__slash")
      card.skillName = niwoyinbing.name
      card:setMark("niwoyinbing_slash", 1)
      use = { from = user, card = card, tos = { { source.id } }, skillName = niwoyinbing.name,
        extraUse = true, bypassTimes = true, bypassDistances = true }
    else
      use = room:askToUseVirtualCard(user, {
        name = "ice__slash", skill_name = niwoyinbing.name,
        prompt = "#niwoyinbing-ice::" .. source.id, cancelable = true, skip = true,
        extra_data = { exclusive_targets = { source.id }, bypass_times = true, bypass_distances = true },
      })
      if not use then return end
      use.card:setMark("niwoyinbing_slash", 1)
    end
    room:setPlayerMark(player, "niwoyinbing_inuse", 1)
    room:useCard(use)
    room:setPlayerMark(player, "niwoyinbing_inuse", 0)

    local dealt = false
    for _, n in pairs(use.damageDealt or {}) do
      if n > 0 then dealt = true break end
    end
    if not dealt and user:isAlive() then
      user:drawCards(2, niwoyinbing.name)
      if user:isAlive() then room:loseHp(user, 1, niwoyinbing.name) end
    end
  end,
})

-- 首次有角色因饮冰进入濒死：你失去饮冰、获得仇戮，并令一名没有饮冰的其他角色获得“删去获得仇戮”的饮冰
niwoyinbing:addEffect(fk.EnterDying, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing.name) and not dyedDone(player.room) and
      isYinbingDying(data)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room.tag["niwoyinbing_dying_done"] = true
    player:broadcastSkillInvoke(niwoyinbing.name)
    -- 你失去饮冰、获得仇戮
    room:handleAddLoseSkills(player, "-" .. niwoyinbing.name .. "|niwochoulu", niwoyinbing.name, true)
    -- 令一名没有饮冰的其他角色获得删去“获得仇戮”的饮冰（niwoyinbing2）
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p:isAlive() and not p:hasSkill(niwoyinbing.name, true) and
        not p:hasSkill("niwoyinbing2", true)
    end)
    if #targets > 0 then
      local chosen = room:askToChoosePlayers(player, {
        targets = targets, min_num = 1, max_num = 1, skill_name = niwoyinbing.name,
        prompt = "#niwoyinbing-acquire", cancelable = false,
      })
      if #chosen > 0 then
        room:handleAddLoseSkills(chosen[1], "niwoyinbing2", niwoyinbing.name, true)
      end
    end
  end,
})

return niwoyinbing
