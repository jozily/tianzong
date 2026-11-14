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

local function my_mo(player)
  return table.filter(player:getCardIds("hej"), function(id)
    local card = Fk:getCardById(id)
    return card:getMark(CARD_MARK) > 0 and card:getMark(OWNER_MARK) == player.id
  end)
end

local function names(player)
  local result = table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card and card.is_damage_card and not card.multiple_targets and
      card.skill:getMaxTargetNum(player) <= 1
  end)
  return player:getViewAsCardNames(niwotianmeng.name, result)
end

niwotianmeng:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwotianmeng-use",
  expand_pile = function(self, player) return my_mo(player) end,
  interaction = function(self, player)
    local choices = names(player)
    if #choices > 0 then return UI.CardNameBox{ choices = choices, all_choices = choices } end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(my_mo(player), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = niwotianmeng.name
    return card
  end,
  enabled_at_play = function(self, player)
    return #my_mo(player) > 0 and #names(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return #my_mo(player) > 0 and #names(player) > 0
  end,
})

niwotianmeng:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(niwotianmeng.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    update_marks(player.room)
  end,
})

-- ============================================================
-- “殄梦·标记”原本是独立技能文件，赵娥的 addSkills 里又直接加了一遍，
-- 于是武将牌上多出一栏、出牌阶段多出一个按钮。这里并回主技能：
-- 标记与“当殁牌使用”共用同一个【殄梦】按钮。
-- ============================================================

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

-- 标记与“当殁牌使用”共用【殄梦】这个名字，usedSkillTimes 会把两者算在一起，
-- 所以“出牌阶段限一次”的账单独用阶段标记记。
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
