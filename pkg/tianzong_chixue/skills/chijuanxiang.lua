local chijuanxiang = fk.CreateSkill{
  name = "chijuanxiang",
}

local NAME_MARK = "@$chijuanxiang_names-turn"
local BLOCK_MARK = "chijuanxiang_block-turn"
local FIRED_MARK = "chijuanxiang_fired"
local COUNT_MARK = "chishuowen_count-turn"
local USED_MARK = "chishuowen_used-turn"

local function get_used_name_count(player)
  return #player:getTableMark(NAME_MARK)
end

local function reset_shuowen(player)
  local room = player.room
  room:setPlayerMark(player, USED_MARK, 0)
end

-- 动态监控：手牌数与本回合使用过的牌名数相等即待触发。
-- FIRED 做边沿检测：一次相等只触发一次，变回不等后重新待命。
local function can_chijuanxiang(player)
  if not player:hasSkill(chijuanxiang.name) or player.dead then return false end
  local x = player:getMark(COUNT_MARK)
  if type(x) ~= "number" or x <= 0 then return false end

  local equal = player:getHandcardNum() == get_used_name_count(player)
  if not equal then
    if player:getMark(FIRED_MARK) ~= 0 then
      player.room:setPlayerMark(player, FIRED_MARK, 0)
    end
    return false
  end
  return player:getMark(FIRED_MARK) == 0 and player:getMark(BLOCK_MARK) == 0
end

local function resolve_chijuanxiang(player)
  local room = player.room
  local x = player:getMark(COUNT_MARK)
  if type(x) ~= "number" or x <= 0 then return end

  room:setPlayerMark(player, BLOCK_MARK, 1)
  room:setPlayerMark(player, FIRED_MARK, 1)

  -- 重置朔闻“每回合限一次”
  reset_shuowen(player)

  local choice = room:askToChoice(player, {
    choices = { "chijuanxiang_draw", "chijuanxiang_gain" },
    skill_name = chijuanxiang.name,
  })

  if choice == "chijuanxiang_draw" then
    player:drawCards(x, chijuanxiang.name)
    if player.dead then
      room:setPlayerMark(player, BLOCK_MARK, 0)
      return
    end

    local ids = room:askToCards(player, {
      min_num = x,
      max_num = x,
      include_equip = false,
      skill_name = chijuanxiang.name,
      cancelable = false,
      pattern = ".|.|.|hand",
    })
    if #ids > 0 then
      room:moveCards({
        ids = ids,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = chijuanxiang.name,
        drawPilePosition = -1,
      })
    end
  else
    local ids = room:getNCards(x, "bottom")
    if #ids > 0 then
      room:obtainCard(player, ids, false, fk.ReasonPrey, player, chijuanxiang.name)
    end
    if player.dead then
      room:setPlayerMark(player, BLOCK_MARK, 0)
      return
    end

    local put = room:askToCards(player, {
      min_num = x,
      max_num = x,
      include_equip = false,
      skill_name = chijuanxiang.name,
      cancelable = false,
      pattern = ".|.|.|hand",
    })
    if #put > 0 then
      room:moveCards({
        ids = put,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = chijuanxiang.name,
        drawPilePosition = 1,
      })
    end
  end

  room:setPlayerMark(player, BLOCK_MARK, 0)
end

local function juanxiang_cost(self, event, target, player, data)
  -- 防止同一次事件的两个监控点重复结算
  if player:getMark(BLOCK_MARK) ~= 0 or player:getMark(FIRED_MARK) == 1 then return false end
  return player.room:askToSkillInvoke(player, {
    skill_name = chijuanxiang.name,
    prompt = "#chijuanxiang-invoke",
  })
end

-- 每个回合结束都清除“本回合”记录并重新待命
chijuanxiang:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chijuanxiang.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, NAME_MARK, 0)
    room:setPlayerMark(player, COUNT_MARK, 0)
    room:setPlayerMark(player, BLOCK_MARK, 0)
    room:setPlayerMark(player, FIRED_MARK, 0)
    room:setPlayerMark(player, USED_MARK, 0)
  end,
})

-- 记录“本回合使用过的牌名”
chijuanxiang:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(chijuanxiang.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, NAME_MARK, data.card.trueName)
  end,
})

-- 动态监控一：牌移动后（手牌数变化，或朔闻把牌堆牌移入处理区）
chijuanxiang:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return can_chijuanxiang(player)
  end,
  on_cost = juanxiang_cost,
  on_use = function(self, event, target, player, data)
    resolve_chijuanxiang(player)
  end,
})

-- 动态监控二：用牌完成后（覆盖朔闻用牌堆牌、手牌数不变但记录数增加的情形）
chijuanxiang:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and can_chijuanxiang(player)
  end,
  on_cost = juanxiang_cost,
  on_use = function(self, event, target, player, data)
    resolve_chijuanxiang(player)
  end,
})

return chijuanxiang
