local niwochenghen = fk.CreateSkill{
  name = "niwochenghen",
}

-- 承痕①的转化入口原先挂在单独的 niwotianmeng_use& 技能上（多出一个按钮）。
-- 按"三效果收进一个按钮"的要求，把 viewas 效果直接并入本技能，
-- 不再用 addAcquireEffect 授予 niwotianmeng_use&。

local CARD_MARK = "@@niwo_mo"
local OWNER_MARK = "niwo_mo_owner"

local function my_mo(player)
  return table.filter(player:getCardIds("hej"), function(id)
    local card = Fk:getCardById(id)
    return card:getMark(CARD_MARK) > 0 and card:getMark(OWNER_MARK) == player.id
  end)
end

local function viewas_names(player)
  local result = table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card and card.is_damage_card and not card.multiple_targets and
      card.skill:getMaxTargetNum(player) <= 1
  end)
  return player:getViewAsCardNames(niwochenghen.name, result)
end

-- ①每回合限一次，将一张"殁"当任意单体伤害类卡牌使用
niwochenghen:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwotianmeng-use",
  max_turn_use_time = 1,
  expand_pile = function(self, player) return my_mo(player) end,
  interaction = function(self, player)
    local choices = viewas_names(player)
    if #choices > 0 then return UI.TianzongCardNameBox{ choices = choices, all_choices = choices } end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(my_mo(player), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = niwochenghen.name
    return card
  end,
  enabled_at_play = function(self, player)
    return #my_mo(player) > 0 and #viewas_names(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return #my_mo(player) > 0 and #viewas_names(player) > 0
  end,
})

local function get_all_field_mo(room)
  local ids = {}
  for _, p in ipairs(room.alive_players) do
    for _, area in ipairs({"h", "e", "j"}) do
      for _, id in ipairs(p:getCardIds(area)) do
        local c = Fk:getCardById(id)
        if c and c:getMark("@@niwo_mo") > 0 then
          table.insert(ids, id)
        end
      end
    end
  end
  return ids
end

local function choose_skill_to_give(room, player, to)
  -- 新文案：令一名角色获得你武将牌上“发动过”的一个技能
  local skillNames = player:getSkillNameList()
  local skills = {}
  for _, s in ipairs(skillNames) do
    local sk = Fk.skills[s]
    if sk and not sk:hasTag(Skill.Compulsory) and
      player:usedSkillTimes(s, Player.HistoryGame) > 0 and
      not to:hasSkill(s, true) then
      table.insertIfNeed(skills, s)
    end
  end
  if #skills == 0 then return nil end

  local choice = room:askToChoice(player, {
    choices = skills,
    skill_name = niwochenghen.name,
    cancelable = true,
  })
  if choice == "" then return nil end
  return choice
end

niwochenghen:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwochenghen.name) then return false end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from and move.from ~= player and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local c = Fk:getCardById(info.cardId, true)
          if c
            and c:getMark("@@niwo_mo") > 0
            and move.moveReason == fk.ReasonUse   -- 新文案：仅“因使用”进入弃牌堆
          then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    if #cards > 0 then event:setCostData(self, { cards = cards }); return true end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niwochenghen.name,
      prompt = "#niwochenghen-obtain:::" .. #event:getCostData(self).cards,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(event:getCostData(self).cards, function(id)
      return room:getCardArea(id) == Card.DiscardPile
    end)
    if #ids > 0 then
      room:obtainCard(player, ids, false, fk.ReasonPrey, player, niwochenghen.name)
      for _, id in ipairs(ids) do
      local c = Fk:getCardById(id)
      if c then
        room:setCardMark(c, "@@niwo_mo", 1)
      end
      end
    end
  end,
})

niwochenghen:addEffect(fk.EnterDying, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = niwochenghen.name,
      prompt = "#niwochenghen-give",
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not to or to.dead then return end

    local skill = choose_skill_to_give(room, player, to)
    if skill then
      room:handleAddLoseSkills(to, skill)
    end

    local mo_ids = get_all_field_mo(room)
    for _, id in ipairs(mo_ids) do
      if to.dead then return end
      local c = Fk:getCardById(id, true)
      if c then
        local name = c.trueName or c.name
        local card = name and Fk:cloneCard(name) or nil
        if card then
          card:addSubcard(id)
          card.skillName = niwochenghen.name
        end
        local can_use = card and player:canUse(card, { bypass_times = true }) and
          not player:isProhibited(to, card) and card.skill:modTargetFilter(player, to, {}, card)
        if can_use then
          room:useCard{ from = player, card = card, tos = { to }, extraUse = true }
        elseif room:getCardArea(id) ~= Card.DiscardPile and room:getCardArea(id) ~= Card.Void then
          room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile,
            niwochenghen.name, nil, true, player)
        end
      end
    end
  end,
})

return niwochenghen
