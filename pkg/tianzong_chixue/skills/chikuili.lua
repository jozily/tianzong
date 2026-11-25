local chikuili = fk.CreateSkill{ name = "chikuili" }

-- 触发候选：与 used「牌名字数或类别相同」的手牌（排除 used 自身子牌）
local function triggerCandidates(player, used)
  local used_length = used:getNameLength(true)
  local used_type = used.type
  return table.filter(player:getCardIds("h"), function(id)
    if table.contains(used.subcards, id) then return false end
    local card = Fk:getCardById(id)
    return card.type == used_type or card:getNameLength(true) == used_length
  end)
end

-- 刷新候选（「均符合」）：从展示出来的牌里筛出牌名字数「且」类别均相同的
local function refreshCandidates(shownIds, used)
  local used_length = used:getNameLength(true)
  local used_type = used.type
  return table.filter(shownIds, function(id)
    if table.contains(used.subcards, id) then return false end
    local card = Fk:getCardById(id)
    return card.type == used_type and card:getNameLength(true) == used_length
  end)
end

chikuili:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chikuili.name) and data.firstTarget and
      player:usedSkillTimes(chikuili.name, Player.HistoryTurn) == 0 and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and
      #triggerCandidates(player, data.card) > 0
  end,
  on_cost = function(self, event, target, player, data)
    -- 先让玩家自选是否发动；点取消则技能不发动、不消耗次数
    if not player.room:askToSkillInvoke(player, {
      skill_name = chikuili.name,
      prompt = "#chikuili-invoke",
    }) then return false end
    -- 展示所有手牌，并把展示的牌固定下来供刷新判定
    local shown = player:getCardIds("h")
    player:showCards(shown)
    event:setCostData(self, { shown = shown })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 额外结算 1 次
    data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
    -- 额外指定 1 个目标
    local extra = data:getExtraTargets()
    if #extra > 0 then
      local chosen = room:askToChoosePlayers(player, {
        targets = extra, min_num = 1, max_num = 1,
        cancelable = false, skill_name = chikuili.name, prompt = "#chikuili-target",
      })
      for _, p in ipairs(chosen) do data:addTarget(p) end
    end
    -- 若展示牌中有「均符合」（字数且类别均相同）的牌，可弃置所有这样的牌并刷新
    local refreshed = false
    local shown = event:getCostData(self).shown
    local ids = refreshCandidates(shown, data.card)
    if #ids > 0 and room:askToSkillInvoke(player, {
      skill_name = chikuili.name,
      prompt = "#chikuili-refresh",
    }) then
      room:throwCard(ids, chikuili.name, player, player)
      -- addSkillUseHistory 已在 on_use 之前写入，此处清零即可视为未发动过
      player:setSkillUseHistory(chikuili.name, 0, Player.HistoryTurn)
      refreshed = true
    end
    -- 次数用尽则加锁置灰（限定技特效）；刷新后保持可用
    if not refreshed and player:usedSkillTimes(chikuili.name, Player.HistoryTurn) > 0 then
      room:invalidateSkill(player, chikuili.name)
    end
  end,
})

-- 每个回合开始解锁（每回合限一次）
chikuili:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Start
      and player:hasSkill(chikuili.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:validateSkill(player, chikuili.name)
  end,
})

return chikuili
