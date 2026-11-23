local chixiege = fk.CreateSkill{
  name = "chixiege",
}

local SLASH_MARK = "@chixiege_slash-round"
local DRAW_MARK = "@chixiege_draw-round"
local DAMAGE_MARK = "@chixiege_damage-round"
local PLUS_TIMES_MARK = "chixiege_plus-turn"  -- 每回合自动清零
local MAX_NUM = 5

local function clear_xiege_marks(room, p)
  room:setPlayerMark(p, SLASH_MARK, 0)
  room:setPlayerMark(p, DRAW_MARK, 0)
  room:setPlayerMark(p, DAMAGE_MARK, 0)
end

local function is_xiege_target(p)
  return p:getMark(SLASH_MARK) > 0
    or p:getMark(DRAW_MARK) > 0
    or p:getMark(DAMAGE_MARK) > 0
end

local function get_all_xiege_targets(room)
  return table.filter(room.alive_players, function(p)
    return is_xiege_target(p)
  end)
end

local function draw_after_damage(room, p, num)
  if num > 0 and not p.dead then
    p:drawCards(num, chixiege.name)
  end
end

local NUM_CHOICES = { "chixiege_slash", "chixiege_draw", "chixiege_damage" }
local NUM_MARKS = { SLASH_MARK, DRAW_MARK, DAMAGE_MARK }

local function ask_plus_one(room, guozhao)
  local targets = get_all_xiege_targets(room)
  if #targets == 0 then return false end

  local tos = room:askToChoosePlayers(guozhao, {
    min_num = 1,
    max_num = 1,
    targets = targets,
    skill_name = chixiege.name,
    prompt = "#chixiege-plus",
    cancelable = true,
  })
  if #tos == 0 then return false end
  local target = tos[1]

  local choices = {}
  for i, mark in ipairs(NUM_MARKS) do
    local v = target:getMark(mark)
    if type(v) ~= "number" then v = 0 end
    if v < MAX_NUM then table.insert(choices, NUM_CHOICES[i]) end
  end
  if #choices == 0 then return false end

  local choice = room:askToChoice(guozhao, {
    choices = choices,
    skill_name = chixiege.name,
    cancelable = false,
  })

  local mark_name
  if choice == "chixiege_slash" then
    mark_name = SLASH_MARK
  elseif choice == "chixiege_draw" then
    mark_name = DRAW_MARK
  else
    mark_name = DAMAGE_MARK
  end

  local value = target:getMark(mark_name)
  if type(value) ~= "number" then value = 0 end
  room:setPlayerMark(target, mark_name, value + 1)
  return true
end

-- 每轮开始时：场上每个有携阁的角色都可以发动一次
chixiege:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixiege.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = chixiege.name,
      prompt = "#chixiege-choose",
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
    local up = to:getLastAlive()

    for _, p in ipairs(room.alive_players) do
      clear_xiege_marks(room, p)
    end

    for _, p in ipairs({to, up}) do
      if p and p:isAlive() then
        room:setPlayerMark(p, SLASH_MARK, 1)
        room:setPlayerMark(p, DRAW_MARK, 1)
        room:setPlayerMark(p, DAMAGE_MARK, 1)
      end
    end
  end,
})

-- 携阁目标使用伤害类卡牌指定目标后：郭照可给任意携阁目标+1
chixiege:addEffect(fk.TargetSpecified, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixiege.name)
      and (player:getMark(PLUS_TIMES_MARK) or 0) < 2
      and target ~= nil
      and target:isAlive()
      and (target == player or is_xiege_target(target))
      and data.card ~= nil
      and data.card.is_damage_card
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chixiege.name,
      prompt = "#chixiege-plus",
    })
  end,
  on_use = function(self, event, target, player, data)
    if ask_plus_one(player.room, player) then
      player.room:addPlayerMark(player, PLUS_TIMES_MARK)
    end
  end,
})

-- 携阁目标成为伤害类卡牌目标后：郭照可给任意携阁目标+1
chixiege:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixiege.name)
      and (player:getMark(PLUS_TIMES_MARK) or 0) < 2
      and target ~= nil
      and target:isAlive()
      and (target == player or is_xiege_target(target))
      and data.card ~= nil
      and data.card.is_damage_card
      and not data.cancelled
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chixiege.name,
      prompt = "#chixiege-plus",
    })
  end,
  on_use = function(self, event, target, player, data)
    if ask_plus_one(player.room, player) then
      player.room:addPlayerMark(player, PLUS_TIMES_MARK)
    end
  end,
})

-- 杀次数
chixiege:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if card and card.trueName == "slash" then
      local n = player:getMark(SLASH_MARK)
      if type(n) == "number" and n > 0 then
        return n - 1
      end
    end
  end,
})

-- 摸牌阶段摸牌数
chixiege:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(DRAW_MARK) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = player:getMark(DRAW_MARK)
  end,
})

-- 造成伤害后摸
chixiege:addEffect(fk.Damage, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:getMark(DAMAGE_MARK) > 0
  end,
  on_use = function(self, event, target, player, data)
    draw_after_damage(player.room, player, player:getMark(DAMAGE_MARK))
  end,
})

-- 受到伤害后摸
chixiege:addEffect(fk.Damaged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(DAMAGE_MARK) > 0
  end,
  on_use = function(self, event, target, player, data)
    draw_after_damage(player.room, player, player:getMark(DAMAGE_MARK))
  end,
})

-- 每轮结束清空场上所有携阁数值
chixiege:addEffect(fk.RoundEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chixiege.name, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      clear_xiege_marks(room, p)
    end
  end,
})

return chixiege
