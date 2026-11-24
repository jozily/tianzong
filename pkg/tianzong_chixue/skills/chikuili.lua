local chikuili = fk.CreateSkill{ name = "chikuili" }

-- 符合条件的手牌：与 used 牌名字数和类别均相同（且不在 used 的子牌里）
local function candidates(player, used)
  local used_length = used:getNameLength(true)
  local used_type = used.type
  local used_common = used:isCommonTrick()
  return table.filter(player:getCardIds("h"), function(id)
    if table.contains(used.subcards, id) then return false end
    local card = Fk:getCardById(id)
    if card.type ~= used_type then return false end
    if used_common and not card:isCommonTrick() then return false end
    return card:getNameLength(true) == used_length
  end)
end

chikuili:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chikuili.name) and data.firstTarget and
      player:usedSkillTimes(chikuili.name, Player.HistoryTurn) == 0 and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and
      #candidates(player, data.card) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    -- 展示所有手牌
    player:showCards(player:getCardIds("h"))
    local choice = room:askToChoice(player, {
      choices = { "chikuili_extra_target", "chikuili_extra_effect" },
      skill_name = chikuili.name,
      prompt = "#chikuili-choice",
    })
    event:setCostData(self, { choice = choice })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "chikuili_extra_effect" then
      data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
    else
      local extra = data:getExtraTargets()
      if #extra > 0 then
        local chosen = room:askToChoosePlayers(player, {
          targets = extra, min_num = 1, max_num = 1,
          cancelable = false, skill_name = chikuili.name, prompt = "#chikuili-target",
        })
        for _, p in ipairs(chosen) do data:addTarget(p) end
      end
    end
    -- 然后你可以弃置所有符合条件的展示牌并令此技能视为未发动过
    local refreshed = false
    local ids = candidates(player, data.card)
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
