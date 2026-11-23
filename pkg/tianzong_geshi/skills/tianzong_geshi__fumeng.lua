local fumeng = fk.CreateSkill{ name = "tianzong_geshi__fumeng" }

local TEMP_MARK = "tianzong_geshi__fumeng_temp"
-- 独立计数：覆梦已用过的技能（与风循的 used_skills 互不冲突）
local USED_MARK = "tianzong_geshi__fumeng_used_skills"

-- 统一的临时技能移除：读玩家身上的 TEMP_MARK，有技能名就移除并清 mark。
-- 三重保险（cleaner / TurnEnd refresh / TurnStart 兜底 refresh）都走这里，
-- 任何一个时点生效即可，绝不残留到下一回合。
local function remove_temp_skill(room, player)
  if not room or not player or player.dead then return end
  local name = player:getMark(TEMP_MARK)
  if type(name) == "string" and name ~= "" then
    -- 授予时不带 source_skill（见 gain_one），技能进 player_skills，
    -- 这里也必须不带 source_skill 才能从 player_skills 删掉。
    room:handleAddLoseSkills(player, "-" .. name, nil, false, true)
  end
  room:setPlayerMark(player, TEMP_MARK, "")
end

-- 排除国战技能
local function is_hegemony(name, skill)
  if name:find("heg__", 1, true) then return true end
  local pkg = skill.package
  if pkg then
    if pkg.extensionName and tostring(pkg.extensionName):find("heg", 1, true) then return true end
    for _, m in ipairs(pkg.game_modes_whitelist or {}) do
      if tostring(m):find("heg", 1, true) then return true end
    end
  end
  return false
end

-- 排除"神人许劭"（srxs）等 mamashengde 单人/模式专属技能
local function is_special_mode(name, skill)
  local pkg = skill.package
  if pkg then
    if pkg.name == "srxs" then return true end
    if pkg.extensionName and tostring(pkg.extensionName) == "mamashengde" then
      return true
    end
  end
  if name:find("zhushuai__", 1, true) or name:find("srxs", 1, true) then
    return true
  end
  return false
end

-- 排除"天书"类技能（OL 动态天书 tianshu1..N / tianshu_active、
-- mobile__tianshu、sxfy__tianshu）：技能名统一含 tianshu
local function is_tianshu(name, skill)
  return name:find("tianshu", 1, true) ~= nil
end

-- 描述中含"伤害"的技能候选
local function damage_skills(player)
  local names = {}
  for name, skill in pairs(Fk.skills) do
    if skill.visible and not player:hasSkill(name, true) and name ~= fumeng.name
      and name ~= "tianzong_geshi__fengxun"
      and not table.contains(player:getTableMark(USED_MARK), name)
      and not is_hegemony(name, skill) and not is_special_mode(name, skill)
      and not is_tianshu(name, skill) then
      local desc = Fk:translate(":" .. name)
      if type(desc) == "string" and desc:find("伤害", 1, true) then
        table.insert(names, name)
      end
    end
  end
  return names
end

-- 从伤害技能中选一个令 target 获得至其回合结束，并记录到 TEMP_MARK
local function gain_one(room, player, target, skill_name)
  local pool = damage_skills(target)
  if #pool == 0 then return false end
  if #pool > 3 then pool = room:tableRandomPick(pool, 3) end
  local choice = room:askToChoice(player, {
    choices = pool,
    skill_name = skill_name,
    prompt = "#tianzong_geshi__fumeng-choose",
    detailed = true,
  })
  if not choice or choice == "" then return false end
  room:addTableMark(target, USED_MARK, choice)
  -- 不带 source_skill：技能进 player_skills。这样金烬这类"主动失去本技能"
  -- 的技能，其内部 handleAddLoseSkills(player, "-jinjinx")（传 nil）才能
  -- 从 player_skills 正常删掉；若 here 带 source_skill=fumeng，技能会进
  -- derivative_skills[fumeng]，金烬内部删 player_skills 就删了个空，导致
  -- 金烬"失去本技能"失效、获得后一直能用。与风循的授予方式保持一致。
  room:handleAddLoseSkills(target, choice)
  room:setPlayerMark(target, TEMP_MARK, choice)
  -- 照官方 shuangrui/lianhua 写法：把"移除临时技能"绑定到当前回合事件的 cleaner，
  -- 引擎在该角色回合结束时必定执行，不受 hasSkill / target==player 限制。
  local turnEvent = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
  if turnEvent then
    turnEvent:addCleaner(function()
      remove_temp_skill(room, target)
    end)
  end
  return true
end

-- 临时技能的移除已改为在 gain_one 里用 turnEvent:addCleaner 绑定回合事件，
-- 这是官方 shuangrui/lianhua 等"获得技能至回合结束"的标准做法：
-- cleaner 挂在获得技能当时所在的回合事件上，回合结束由引擎保证执行，
-- 不受 hasSkill / target==player / refresh 遍历顺序影响。
-- 原 fk.TurnEnd + late_refresh + hasSkill(fumeng) 的方案会漏移除，已废弃。

-- 发动覆梦所得的临时技能造成伤害后，覆梦主获得 1 点能量
-- （任意角色用该临时技能造成伤害，都给覆梦主积攒能量）
fumeng:addEffect(fk.Damage, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(fumeng.name) then return false end
    local skill_name = data.skillName
    if not skill_name or skill_name == "" then return false end
    -- 伤害来源角色身上的临时技能 == 造成伤害的技能
    local src = data.from
    return src and not src.dead and src:getMark(TEMP_MARK) == skill_name
  end,
  on_refresh = function(self, event, target, player, data)
    TianzongEnergy.gain(player.room, player, 1)
  end,
})

-- 回合结束时强制移除覆梦赋予的临时技能。
-- refresh 通道在引擎里会遍历所有在场玩家（见 trigger_event.lua 的 repeat..until），
-- 不限技能宿主；但为稳妥仍加 global=true。
local function any_temp_mark(player)
  if player.dead then return false end
  local name = player:getMark(TEMP_MARK)
  return (type(name) == "string" and name ~= "") or type(name) == "number"
end

fumeng:addEffect(fk.TurnEnd, {
  mute = true,
  global = true,
  can_refresh = function(self, event, target, player, data)
    return any_temp_mark(player)
  end,
  on_refresh = function(self, event, target, player, data)
    remove_temp_skill(player.room, player)
  end,
})

-- 兜底：若 TurnEnd 时目标已死亡导致 cleaner/refresh 跳过，则其复活或
-- 下一个角色回合开始时仍带残留 mark，这里再清一次，确保不跨回合残留。
fumeng:addEffect(fk.TurnStart, {
  mute = true,
  global = true,
  can_refresh = function(self, event, target, player, data)
    return any_temp_mark(player)
  end,
  on_refresh = function(self, event, target, player, data)
    remove_temp_skill(player.room, player)
  end,
})

-- ① 出牌阶段限一次，三选一获得技能至回合结束
fumeng:addEffect("active", {
  anim_type = "special",
  prompt = "#tianzong_geshi__fumeng-active",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(fumeng.name, Player.HistoryPhase) == 0 and #damage_skills(player) > 0
  end,
  on_use = function(self, room, effect)
    gain_one(room, effect.from, effect.from, fumeng.name)
  end,
})

-- ② 其他角色回合开始时，可消耗任意点能量令其交给你等量的牌，
--    然后你从三个含"伤害"技能中选一个令其获得至其回合结束
fumeng:addEffect(fk.TurnStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(fumeng.name)
      and target:isAlive() and TianzongEnergy.get(player) > 0
      and #target:getCardIds("h") > 0
      and #damage_skills(target) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local max_n = math.min(TianzongEnergy.get(player), #target:getCardIds("h"))
    local choices = {}
    for i = 1, max_n do table.insert(choices, tostring(i)) end
    local pick = room:askToChoice(player, {
      choices = choices,
      skill_name = fumeng.name,
      prompt = "#tianzong_geshi__fumeng-energy:::" .. TianzongEnergy.get(player),
      cancelable = true,
    })
    if not pick or pick == "" or pick == "Cancel" then return false end
    event:setCostData(self, { n = tonumber(pick) or 0 })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = event:getCostData(self).n or 0
    TianzongEnergy.cost(room, player, n)
    local ids = room:askToCards(target, {
      min_num = n,
      max_num = n,
      skill_name = fumeng.name,
      prompt = "#tianzong_geshi__fumeng-give::" .. player.id,
      cancelable = false,
    })
    if #ids > 0 then
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonGive, fumeng.name, nil, false, target)
    end
    gain_one(room, player, target, fumeng.name)
  end,
})

return fumeng
