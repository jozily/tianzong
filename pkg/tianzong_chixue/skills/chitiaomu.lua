local chitiaomu = fk.CreateSkill{ name = "chitiaomu" }

local function target_num(player, card)
  if player:prohibitUse(card) or not player:canUse(card, { bypass_times = true }) then return 0 end
  -- 闪、无懈可击这类牌没有合法目标，走合法目标分支时必须剔除
  if card.skill:getMinTargetNum() == 0 and not card.multiple_targets then return 0 end
  local n = 0
  for _, p in ipairs(Fk:currentRoom().alive_players) do
    if not player:isProhibited(p, card) and card.skill:modTargetFilter(player, p, {}, card) then n = n + 1 end
  end
  return n
end

local function discard_candidates(player, wanted)
  local length, targets = wanted:getNameLength(true), target_num(player, wanted)
  return table.filter(Fk:currentRoom().discard_pile, function(id)
    local card = Fk:getCardById(id)
    if not (card.type == Card.TypeBasic or card:isCommonTrick()) then return false end
    -- 牌名字数相同即可（闪/无懈这类无目标牌仍可走此分支）
    if card:getNameLength(true) == length then return true end
    -- 合法目标分支：wanted 与候选牌都须有合法目标，剔除闪/无懈这类无目标牌
    local card_targets = target_num(player, card)
    return targets > 0 and card_targets > 0 and card_targets == targets
  end)
end

local function names(player)
  return table.filter(player:getViewAsCardNames(chitiaomu.name, Fk:getAllCardNames("bt")), function(name)
    local card = Fk:cloneCard(name)
    return (card.type == Card.TypeBasic or card:isCommonTrick()) and #discard_candidates(player, card) > 0
  end)
end

chitiaomu:addEffect("viewas", {
  pattern = ".",
  prompt = "#chitiaomu",
  interaction = function(self, player)
    local choices = names(player)
    if #choices > 0 then return UI.TianzongCardNameBox{ choices = choices, all_choices = Fk:getAllCardNames("bt") } end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards == 0 and self.interaction.data then
      local card = Fk:cloneCard(self.interaction.data)
      card.skillName = chitiaomu.name
      return card
    end
  end,
  before_use = function(self, player, use)
    local room, ids = player.room, discard_candidates(player, use.card)
    if #ids == 0 then return chitiaomu.name end
    local id = room:tableRandomPick(ids, 1)[1]
    local same_name = Fk:getCardById(id).trueName == use.card.trueName
    room:obtainCard(player, id, true, fk.ReasonPrey, player, chitiaomu.name)
    -- 随机拿到的是哪张要摆出来，否则玩家只看到牌直接没了
    room:showCards({ id }, player, player)
    -- 不再 addSubcard：这张牌是"获得"进手牌并保留，而非当作虚拟牌的实体子牌被消耗
    -- 记录是否同名，真正的"刷新"放到 after_use（技能使用计数在之后才写入）
    if same_name then player.room:setPlayerMark(player, "chitiaomu_refresh_flag", 1) end
  end,
  after_use = function(self, player, use)
    if player:getMark("chitiaomu_refresh_flag") > 0 then
      player:setSkillUseHistory(chitiaomu.name, 0, Player.HistoryRound)
      player.room:setPlayerMark(player, "chitiaomu_refresh_flag", 0)
      -- 同名刷新：技能保持可用，解除可能的加锁
      player.room:validateSkill(player, chitiaomu.name)
    else
      -- 次数用尽：加锁置灰（限定技特效）
      player.room:invalidateSkill(player, chitiaomu.name)
    end
  end,
  -- 按钮左下角：本轮还剩几次
  times = function(self, player)
    local left = 1 - player:usedSkillTimes(chitiaomu.name, Player.HistoryRound)
    return left > 0 and left or -1
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(chitiaomu.name, Player.HistoryRound) < 1 and #names(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(chitiaomu.name, Player.HistoryRound) < 1 and #names(player) > 0
  end,
})

-- 每轮开始解锁（每轮限一次）
chitiaomu:addEffect(fk.RoundStart, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chitiaomu.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:validateSkill(player, chitiaomu.name)
  end,
})

return chitiaomu
