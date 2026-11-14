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

-- “出牌阶段限一次”的账单独用阶段标记记：viewas 副技能与本技能名字不同，
-- usedSkillTimes 各算各的，合在一起判断会串味。
local MARK_USED = "niwotianmeng_mark-phase"

niwotianmeng:addEffect("active", {
  anim_type = "control",
  prompt = "#niwotianmeng-target",
  card_num = 0,
  target_num = 1,
  times = function(self, player)
    if player.phase ~= Player.Play then return -1 end
    return 1 - player:getMark(MARK_USED)
  end,
  can_use = function(self, player)
    return player:hasSkill(niwotianmeng.name) and player:getMark(MARK_USED) == 0 and
      not player:isNude() and #valid_mark_targets(player) > 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    room:addPlayerMark(effect.from, MARK_USED, 1)
    mark_cards(room, effect.from, effect.tos[1])
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
