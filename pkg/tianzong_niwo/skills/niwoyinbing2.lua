-- 饮冰（删去“获得仇戮”的版本）：由饮冰首次濒死转移给其他角色时获得
local niwoyinbing2 = fk.CreateSkill{
  name = "niwoyinbing2",
  tags = { Skill.Contract },
}

niwoyinbing2:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing2.name) and data.from and data.from:isAlive() and
      data.to and data.to:isAlive() and data.from ~= data.to and
      (data.from == player or data.to == player) and
      player:getMark("niwoyinbing_inuse") == 0 and
      (not data.card or data.card:getMark("niwoyinbing_slash") == 0)
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("contracted_skills"), niwoyinbing2.name) then
      return true
    end
    return player.room:askToSkillInvoke(player, {
      skill_name = niwoyinbing2.name,
      prompt = "#niwoyinbing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room, user, source = player.room, data.to, data.from
    local was_contracted = table.contains(player:getTableMark("contracted_skills"), niwoyinbing2.name)
    room:addTableMarkIfNeed(player, "contracted_skills", niwoyinbing2.name)
    local use
    if was_contracted then
      local card = Fk:cloneCard("ice__slash")
      card.skillName = niwoyinbing2.name
      card:setMark("niwoyinbing_slash", 1)
      use = { from = user, card = card, tos = { { source.id } }, skillName = niwoyinbing2.name,
        extraUse = true, bypassTimes = true, bypassDistances = true }
    else
      use = room:askToUseVirtualCard(user, {
        name = "ice__slash", skill_name = niwoyinbing2.name,
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
      user:drawCards(2, niwoyinbing2.name)
      if user:isAlive() then room:loseHp(user, 1, niwoyinbing2.name) end
    end
  end,
})


-- 是否因“饮冰”而进入濒死：冰杀伤害(带 niwoyinbing_slash 标记) 或 失血(skillName=niwoyinbing2)
local function isYinbing2Dying(data)
  if data.damage then
    if data.damage.skillName == niwoyinbing2.name then return true end
    local card = data.damage.card
    if card and card:getMark("niwoyinbing_slash") > 0 then return true end
  end
  if data.hpLost and data.hpLost.skillName == niwoyinbing2.name then return true end
  return false
end

-- 有角色因“饮冰”进入濒死：当前持有者失去饮冰（不获得仇戮），
-- 再令一名没有饮冰的其他角色获得饮冰，从而可以继续传递。
-- 用当前事件 id 去重，避免同一次濒死里因 player 遍历而连锁传多次。
niwoyinbing2:addEffect(fk.EnterDying, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if data._yinbing2_transferred then return false end
    return player:hasSkill(niwoyinbing2.name) and isYinbing2Dying(data)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 同一濒死只传一次：直接在本次事件数据上打标记，避免遍历到刚获得技能的新持有者时连锁再传
    data._yinbing2_transferred = true
    player:broadcastSkillInvoke(niwoyinbing2.name)
    -- 当前持有者失去饮冰，不获得仇戮
    room:handleAddLoseSkills(player, "-" .. niwoyinbing2.name, niwoyinbing2.name, true)
    -- 令一名没有饮冰的其他角色继续获得饮冰
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p:isAlive() and not p:hasSkill("niwoyinbing", true) and
        not p:hasSkill(niwoyinbing2.name, true)
    end)
    if #targets > 0 then
      local chosen = room:askToChoosePlayers(player, {
        targets = targets, min_num = 1, max_num = 1, skill_name = niwoyinbing2.name,
        prompt = "#niwoyinbing-acquire", cancelable = false,
      })
      if #chosen > 0 then
        room:handleAddLoseSkills(chosen[1], "niwoyinbing2", niwoyinbing2.name, true)
      end
    end
  end,
})

return niwoyinbing2
