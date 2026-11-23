local chirenfu = fk.CreateSkill{
  name = "chirenfu",
  tags = { Skill.Compulsory },
}

-- 荏腹使用牌数 mark：实时显示本回合已使用的基本牌数
Fk:addQmlMark{
  name = "chirenfu_used",
  how_to_show = function(_, value, p)
    if type(value) == "string" and value ~= "" then return value end
    return ""
  end,
  qml_data = function() return {} end,
  qml_path = function() return "" end,
}

local function used_basic_count(player)
  local count = 0
  player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(event)
    local use = event.data
    if use.from == player and use.card and use.card.type == Card.TypeBasic then
      count = count + 1
    end
    return false
  end, Player.HistoryTurn)
  return count
end

local function can_move_between(from, to)
  return table.find(from:getCardIds("ej"), function(id)
    return from:canMoveCardInBoardTo(to, id)
  end) or table.find(to:getCardIds("ej"), function(id)
    return to:canMoveCardInBoardTo(from, id)
  end)
end

local function transfer_hand_card(room, first, second)
  if first:getHandcardNum() == second:getHandcardNum() then return end
  local less = first:getHandcardNum() < second:getHandcardNum() and first or second
  local more = less == first and second or first
  if more:isKongcheng() then return end
  local id = room:askToChooseCard(less, {
    target = more,
    flag = "h",
    skill_name = chirenfu.name,
    prompt = "#chirenfu-prey::" .. more.id,
  })
  if id and id ~= -1 then
    room:obtainCard(less, id, false, fk.ReasonPrey, less, chirenfu.name)
  end
end

-- 每使用一张牌后刷新「荏腹 N」显示（N=本回合已用基本牌数）
chirenfu:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chirenfu.name) and data.card and data.card.type == Card.TypeBasic
  end,
  on_refresh = function(self, event, target, player, data)
    local n = used_basic_count(player)
    if n > 0 then
      -- 名字前缀由翻译键 ["@[chirenfu_used]"] 提供，此处只写数字，避免显示成 @[chirenfu_used] 原文
      player.room:setPlayerMark(player, "@[chirenfu_used]", n)
    end
  end,
})

-- 回合开始重置显示（基本牌计数按回合统计）
chirenfu:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@[chirenfu_used]") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[chirenfu_used]", 0)
  end,
})

chirenfu:addEffect(fk.CardUsing, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chirenfu.name) and
      player:usedSkillTimes(chirenfu.name, Player.HistoryTurn) == 0 and
      data.card and data.card:isCommonTrick()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = used_basic_count(player)
    if count > 0 then player:drawCards(count, chirenfu.name) end
    if count >= 2 or player.dead then return end

    local current = room.current
    room:damage{
      from = current and current:isAlive() and current or nil,
      to = player,
      damage = 1,
      damageType = fk.ThunderDamage,
      skillName = chirenfu.name,
    }
    if player.dead or not current or current.dead or current == player then return end

    if can_move_between(player, current) then
      room:askToMoveCardInBoard(player, {
        target_one = player,
        target_two = current,
        skill_name = chirenfu.name,
      })
    else
      transfer_hand_card(room, player, current)
    end
  end,
})

Fk:loadTranslationTable{
  ["chirenfu"] = "荏腹",
  ["@[chirenfu_used]"] = "荏腹",
  [":chirenfu"] = "锁定技，当你每回合首次使用普通锦囊牌时，你摸已使用基本牌数量张牌。若摸牌数小于2，你受到来自当前回合角色的一点雷属性伤害，且若不为你的回合，你移动你与其一张牌；若无法移动，则改为手牌少的一方获得手牌多的一方一张手牌。",
}

Fk:loadTranslationTable{
  ["#chirenfu-prey"] = "荏腹：获得%dest的一张手牌",
}

return chirenfu
