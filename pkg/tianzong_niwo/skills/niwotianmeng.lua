local niwotianmeng = fk.CreateSkill{
  name = "niwotianmeng",
}

local function update_mo_marks(room)
  for _, p in ipairs(room.alive_players) do
    local cnt = 0
    for _, area in ipairs({"h", "e", "j"}) do
      for _, id in ipairs(p:getCardIds(area)) do
        local c = Fk:getCardById(id)
        if c and c:getMark("@@niwo_mo") > 0 then
          cnt = cnt + 1
        end
      end
    end
    room:setPlayerMark(p, "@niwo_mo", cnt)
  end
end

local function mark_mo(room, owner, id)
  local c = Fk:getCardById(id)
  if c then
    room:setCardMark(c, "@@niwo_mo", 1)
    room:setCardMark(c, "niwo_mo_owner", owner.id)
  end
  update_mo_marks(room)
end

local function get_my_mo_cards(player)
  return table.filter(player:getCardIds("hej"), function(id)
    local c = Fk:getCardById(id)
    return c and c:getMark("@@niwo_mo") > 0 and c:getMark("niwo_mo_owner") == player.id
  end)
end

local function get_damage_card_names(player)
  local all_names = table.filter(Fk:getAllCardNames("bt"), function(name)
    local c = Fk:cloneCard(name)
    return c and c.is_damage_card and not c.multiple_targets and c.skill:getMaxTargetNum(player) <= 1
  end)
  return player:getViewAsCardNames(niwotianmeng.name, all_names)
end

local function choose_targets_for_virtual(room, player, card_name)
  local card = Fk:cloneCard(card_name)
  if not card then return nil end
  if player:prohibitUse(card) then return nil end

  local min_num = card.skill:getMinTargetNum(player) or 0
  local max_num = card.skill:getMaxTargetNum(player) or min_num

  local valid = table.filter(room.alive_players, function(p)
    return not player:isProhibited(p, card)
      and card.skill:modTargetFilter(player, p, {}, card, { bypass_times = true })
  end)

  if #valid == 0 then
    if min_num == 0 then
      return {}
    else
      return nil
    end
  end

  if min_num == 0 and max_num == 0 then
    return {}
  end

  local tos = room:askToChoosePlayers(player, {
    min_num = min_num,
    max_num = math.max(min_num, math.min(max_num, #valid)),
    targets = valid,
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-use",
    cancelable = (min_num == 0),
  })
  if #tos < min_num then
    return nil
  end
  return tos
end

local function do_mark_mo(room, player, target)
  if not target or target.dead then return end

  local self_card = room:askToChooseCard(player, {
    target = player,
    flag = "hej",
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-selfcard",
  })
  if not self_card then return end

  local target_card = room:askToChooseCard(player, {
    target = target,
    flag = "hej",
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-targetcard",
  })
  if not target_card then return end

  mark_mo(room, player, self_card)
  mark_mo(room, target, target_card)
end

local function do_use_mo(room, player)
  local names = get_damage_card_names(player)
  if #names == 0 then return end

  local name = room:askToChoice(player, {
    choices = names,
    skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-use",
    cancelable = true,
  })
  if name == "" then return end

  local mo_cards = get_my_mo_cards(player)
  if #mo_cards == 0 then return end

  local ids = room:askToCards(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = niwotianmeng.name,
    cancelable = true,
    pattern = tostring(Exppattern{ id = mo_cards }),
  })
  if #ids == 0 then return end
  local choice_id = ids[1]

  local tos = choose_targets_for_virtual(room, player, name)
  if tos == nil then return end

  local card = Fk:cloneCard(name)
  card:addSubcard(choice_id)
  card.skillName = niwotianmeng.name

  room:useCard{
    card = card,
    from = player,
    tos = tos,
    extraUse = true,
  }
end

niwotianmeng:addEffect("active", {
  anim_type = "offensive",
  prompt = "#niwotianmeng-choice",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,

  can_use = function(self, player)
    return player.phase == Player.Play
  end,

  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,

  on_use = function(self, room, effect)
    local player = effect.from
    local can_mark = player:usedSkillTimes(niwotianmeng.name, Player.HistoryPhase) == 0
    local has_mo = #get_my_mo_cards(player) > 0

    local choices = {}
    if can_mark then
      table.insert(choices, "niwotianmeng_mark")
    end
    if has_mo then
      table.insert(choices, "niwotianmeng_use")
    end

    if #choices == 0 then return end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = niwotianmeng.name,
      prompt = "#niwotianmeng-choice",
      cancelable = false,
    })

    if choice == "niwotianmeng_mark" then
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = niwotianmeng.name,
        prompt = "#niwotianmeng-target",
        cancelable = true,
      })
      if #tos == 0 then return end
      do_mark_mo(room, player, tos[1])
    else
      do_use_mo(room, player)
    end
  end,
})

-- 受伤后：只执行“标记殁”
niwotianmeng:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwotianmeng.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = niwotianmeng.name,
      prompt = "#niwotianmeng-target",
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    do_mark_mo(player.room, player, event:getCostData(self).tos[1])
  end,
})

niwotianmeng:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(niwotianmeng.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    update_mo_marks(player.room)
  end,
})

return niwotianmeng
