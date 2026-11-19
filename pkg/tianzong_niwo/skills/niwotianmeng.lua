-- 殄梦（赵娥）
-- 出牌阶段限一次，或当你受到伤害后，你可以标记你与一名角色的一张牌为“殁”。
-- 你可以将你的一张“殁”当任意单体伤害牌使用或打出。
--
-- 引擎限制：一个 skill 里只能有一个 active/viewas 类效果（SkillSkeleton:addEffect
-- 会 qCritical）。所以“标记”与“当殁牌使用”必须分属两个技能：本文件是可见的
-- 【殄梦】按钮（active + 受伤触发），viewas 在 niwotianmeng_use.lua 里，名字以
-- “&” 结尾，由 addAcquireEffect 授予本人，不占武将牌技能栏。
local niwotianmeng = fk.CreateSkill{
  name = "niwotianmeng",
}

local CARD_MARK = "@@niwo_mo"
local OWNER_MARK = "niwo_mo_owner"

local function update_marks(room)
  for _, p in ipairs(room.alive_players) do
    local n = #table.filter(p:getCardIds("hej"), function(id)
      return Fk:getCardById(id):getMark(CARD_MARK) > 0
    end)
    room:setPlayerMark(p, "@niwo_mo", n)
  end
end

-- 授予“当殁牌使用”的副技能。
-- 注意不能用 attached_skill_name：那个字段是把技能发给*其他*角色（黄天那种）。
niwotianmeng:addAcquireEffect(function(self, player)
  if player.room then
    player.room:handleAddLoseSkills(player, "niwotianmeng_use&", nil, false, true)
  end
end)

niwotianmeng:addLoseEffect(function(self, player)
  if player.room then
    player.room:handleAddLoseSkills(player, "-niwotianmeng_use&", nil, false, true)
  end
end)

niwotianmeng:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(niwotianmeng.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    update_marks(player.room)
  end,
})

local function valid_mark_targets(player)
  return table.filter(player.room:getOtherPlayers(player), function(p) return not p:isNude() end)
end

local function mark_cards(room, player, target)
  local own = room:askToChooseCard(player, {
    target = player,
    flag = "hej",
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-card::" .. player.id,
  })
  local other = room:askToChooseCard(player, {
    target = target,
    flag = "hej",
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-card::" .. target.id,
  })
  if not own or not other then return end
  local own_card, other_card = Fk:getCardById(own), Fk:getCardById(other)
  room:setCardMark(own_card, CARD_MARK, 1)
  room:setCardMark(own_card, OWNER_MARK, player.id)
  room:setCardMark(other_card, CARD_MARK, 1)
  room:setCardMark(other_card, OWNER_MARK, target.id)
end

-- “出牌阶段限一次”的账单独用阶段标记记：仅“标记”动作受限，转化不限次。
local MARK_USED = "niwotianmeng_mark-phase"

-- 转化：把一张“殁”当任意单体伤害牌使用（与 niwotianmeng_use& 的 viewas 等价）
local function do_transform(room, player)
  local my_mo = table.filter(player:getCardIds("hej"), function(id)
    local c = Fk:getCardById(id)
    return c:getMark(CARD_MARK) > 0 and c:getMark(OWNER_MARK) == player.id
  end)
  if #my_mo == 0 then return false end
  local targets = {}
  for _, name in ipairs(Fk:getAllCardNames("bt")) do
    local c = Fk:cloneCard(name)
    if c and c.is_damage_card and not c.multiple_targets and
      c.skill:getMaxTargetNum(player) <= 1 then
      table.insert(targets, name)
    end
  end
  if #targets == 0 then return false end
  local name = room:askToChoice(player, {
    choices = targets,
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-use",
  })
  local use = room:askToUseVirtualCard(player, {
    name = name,
    skill_name = "niwotianmeng_use&",
    prompt = "#niwotianmeng-use",
    cancelable = false,
    extra_data = { bypass_times = true },
  })
  if use then room:useCard(use); return true end
  return false
end

niwotianmeng:addEffect("active", {
  anim_type = "control",
  prompt = "#niwotianmeng-choice",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    if not player:hasSkill(niwotianmeng.name) then return false end
    -- 注意：can_use 在客户端也会被调用，此处不能访问 player.room（否则报 field room）。
    -- 目标合法性交给 on_use 里的 valid_mark_targets 判断；这里只做无 room 依赖的粗判。
    local can_mark = player:getMark(MARK_USED) == 0 and not player:isNude()
    local can_use_mo = false
    for _, id in ipairs(player:getCardIds("hej")) do
      local c = Fk:getCardById(id)
      if c:getMark(CARD_MARK) > 0 and c:getMark(OWNER_MARK) == player.id then can_use_mo = true; break end
    end
    return can_mark or can_use_mo
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local opts = {}
    if player:getMark(MARK_USED) == 0 and not player:isNude() and #valid_mark_targets(player) > 0 then
      table.insert(opts, "niwotianmeng_mark")
    end
    if #opts == 0 and not player:isNude() then
      -- can_use 粗判放进来但没有合法目标（客户端无 room 无法预判），直接返回，避免空询问
      local has_mo = false
      for _, id in ipairs(player:getCardIds("hej")) do
        local c = Fk:getCardById(id)
        if c:getMark(CARD_MARK) > 0 and c:getMark(OWNER_MARK) == player.id then has_mo = true; break end
      end
      if not has_mo then return end
    end
    local has_mo = false
    for _, id in ipairs(player:getCardIds("hej")) do
      local c = Fk:getCardById(id)
      if c:getMark(CARD_MARK) > 0 and c:getMark(OWNER_MARK) == player.id then has_mo = true; break end
    end
    if has_mo then table.insert(opts, "niwotianmeng_transform") end
    if #opts == 0 then return end
    local opt = #opts == 1 and opts[1] or room:askToChoice(player, {
      choices = opts, skill_name = niwotianmeng.name, prompt = "#niwotianmeng-choice",
    })
    if opt == "niwotianmeng_transform" then
      do_transform(room, player)
    else
      local tos = room:askToChoosePlayers(player, {
        targets = valid_mark_targets(player), min_num = 1, max_num = 1,
        skill_name = niwotianmeng.name, prompt = "#niwotianmeng-choose", cancelable = false,
      })
      if #tos > 0 then
        room:addPlayerMark(player, MARK_USED, 1)
        mark_cards(room, player, tos[1])
      end
    end
  end,
})

niwotianmeng:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwotianmeng.name) and not player:isNude() and
      #valid_mark_targets(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = valid_mark_targets(player),
      min_num = 1,
      max_num = 1,
      skill_name = niwotianmeng.name,
      prompt = "#niwotianmeng-choose",
      cancelable = true,
    })
    if #tos > 0 then event:setCostData(self, { to = tos[1] }); return true end
  end,
  on_use = function(self, event, target, player, data)
    mark_cards(player.room, player, event:getCostData(self).to)
  end,
})

return niwotianmeng
