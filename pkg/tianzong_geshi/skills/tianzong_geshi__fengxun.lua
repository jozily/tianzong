local fengxun = fk.CreateSkill{ name = "tianzong_geshi__fengxun" }

-- 风循：四种伤害时机。
--   受到伤害后    -> fk.Damaged
--   造成伤害后    -> fk.Damage
--   即将受到伤害时 -> fk.DamageInflicted
--   即将造成伤害时 -> fk.DamageCaused
-- 新机制：可消耗 1 点能量，于此时机从三个"触发时机与此相同"的技能中选一个发动；
--         当有角色发动描述带有"伤害"的技能后，你获得 1 点能量（上限 5）。
-- 照十周年许劭"评荐"官方写法：获得 -> 同时机主动触发一次 -> 立即移除。
-- 绝不对候选做 add/remove 探测（会残留 onAcquire/onLose 副作用）；
-- 静态筛选候选池，选中后只 add 一次、remove 一次。

local USED_MARK = "tianzong_geshi__fengxun_used_skills"
-- 记录风循当前临时持有的技能名，供回合结束 refresh 兜底移除
local FENGXUN_TEMP_MARK = "tianzong_geshi__fengxun_temp"

local TIMINGS = {
  { event = fk.Damaged,         label = "受到伤害后" },
  { event = fk.Damage,          label = "造成伤害后" },
  { event = fk.DamageInflicted, label = "即将受到伤害时" },
  { event = fk.DamageCaused,    label = "即将造成伤害时" },
}

local function is_hegemony(name, skill)
  if name:find("heg__", 1, true) then return true end
  local pkg = skill.package
  if pkg then
    if pkg.extensionName and tostring(pkg.extensionName):find("heg", 1, true) then
      return true
    end
    for _, m in ipairs(pkg.game_modes_whitelist or {}) do
      if tostring(m):find("heg", 1, true) then return true end
    end
  end
  return false
end

-- 排除"神人许劭"（srxs）等 mamashengde 单人/模式专属技能。
-- 这类技能的 package.name == "srxs"，或 extensionName == "mamashengde"，
-- 前缀形如 zhushuai__/srxs__/jccl__/clwj__ 等，属于模式将卡技能，
-- 不应出现在风循/覆梦的通用候选池里。
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

-- 排除"天书"类技能：OL 动态天书 tianshu1..N / tianshu_active，
-- 移动版 mobile__tianshu，sxfy__tianshu。这类临时技能描述含"伤害"，
-- 会污染风循/覆梦的通用候选池。
local function is_tianshu(name, skill)
  -- OL 动态天书 tianshu1..N / tianshu_active、移动版 mobile__tianshu、
  -- sxfy__tianshu 等，技能名统一含 tianshu
  return name:find("tianshu", 1, true) ~= nil
end

local function get_candidates(player, event)
  local ret = {}
  for name, skill in pairs(Fk.skills) do
    if skill.visible and not player:hasSkill(name, true)
      and name ~= fengxun.name and name ~= "tianzong_geshi__fumeng"
      and not table.contains(player:getTableMark(USED_MARK), name)
      and not is_hegemony(name, skill) and not is_special_mode(name, skill)
      and not is_tianshu(name, skill) then
      local skel = Fk.skill_skels[name]
      if skel and skel.effects then
        for _, eff in ipairs(skel.effects) do
          if eff:isInstanceOf(TriggerSkill) and eff.event == event and not eff.global then
            table.insertIfNeed(ret, name)
            break
          end
        end
      end
    end
  end
  return ret
end

local function do_fengxun(real_event, event, target, player, data, label)
  local room = player.room
  -- 消耗 1 点能量
  if not TianzongEnergy.cost(room, player, 1) then return end
  local pool = get_candidates(player, event)
  if #pool == 0 then return end

  local choices = room:tableRandomPick(pool, 3)
  local pick = room:askToChoice(player, {
    choices = choices,
    skill_name = fengxun.name,
    prompt = "#tianzong_geshi__fengxun-invoke:::" .. label,
    detailed = true,
  })
  if not pick or pick == "" then return end

  room:addTableMark(player, USED_MARK, pick)
  room:notifySkillInvoked(player, fengxun.name, "special")

  room:handleAddLoseSkills(player, pick)
  room:setPlayerMark(player, FENGXUN_TEMP_MARK, pick)
  local skel = Fk.skill_skels[pick]
  if skel then
    -- 候选技能trigger可能抛错（历史日志：skill_data 为 nil）。
    -- 用 pcall 包住，确保无论触发是否报错，临时技能都能被移除，
    -- 否则"技能永久保留"正是用户看到的现象。
    for _, eff in ipairs(skel.effects) do
      if eff:isInstanceOf(TriggerSkill) and eff.event == event then
        local ok, triggerable = pcall(function()
          return eff:triggerable(real_event, target, player, data)
        end)
        if ok and triggerable then
          pcall(function()
            eff:trigger(real_event, target, player, data)
          end)
        end
      end
    end
  end
  room:handleAddLoseSkills(player, "-" .. pick)
  room:setPlayerMark(player, FENGXUN_TEMP_MARK, "")
end

for idx, t in ipairs(TIMINGS) do
  fengxun:addEffect(t.event, {
    anim_type = "special",
    can_trigger = function(self, event, target, player, data)
      if not player:hasSkill(fengxun.name) then return false end
      if TianzongEnergy.get(player) < 1 then return false end
      if t.event == fk.Damaged or t.event == fk.DamageInflicted then
        return target == player
      else
        return target == player and data.from == player
      end
    end,
    on_cost = function(self, event, target, player, data)
      return player.room:askToSkillInvoke(player, {
        skill_name = fengxun.name,
        prompt = "#tianzong_geshi__fengxun-invoke:::" .. t.label,
      })
    end,
    on_use = function(self, event, target, player, data)
      do_fengxun(event, t.event, target, player, data, t.label)
    end,
  })

  -- （能量获取已改为监听 fk.AfterSkillEffect，见文件末尾，不再在此按伤害时机积攒）
end

-- 判断技能描述是否带有"伤害"二字（与覆梦 damage_skills 的判定标准一致）。
-- 按用户要求排除风恂自身：发动风恂本身不算"发动描述带伤害的技能"；
-- 覆梦等其他技能仍计入。
local function has_damage_in_desc(name)
  if name == fengxun.name then return false end
  local desc = Fk:translate(":" .. name)
  return type(desc) == "string" and desc:find("伤害", 1, true) ~= nil
end

-- 当有角色发动了描述带有"伤害"且不为风恂的技能后，风循拥有者获得 1 点能量；
-- 能量已满（5 点）时改为摸一张牌。
-- 用 AfterSkillEffect 的 refresh 通道：遍历所有在场玩家，
-- 每位风循主都因任意角色发动的伤害描述技能而积攒能量。
-- has_damage_in_desc 按描述含"伤害"判定，并排除风恂自身。
fengxun:addEffect(fk.AfterSkillEffect, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(fengxun.name) then return false end
    if player.dead then return false end
    local skill = data.skill
    if not skill then return false end
    return has_damage_in_desc(skill.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if TianzongEnergy.get(player) >= TianzongEnergy.max() then
      player:drawCards(1, fengxun.name)
    else
      TianzongEnergy.gain(room, player, 1)
    end
  end,
})

-- 能量获取统一为"有角色发动描述带有'伤害'且不为风恂的技能后"（见上方 AfterSkillEffect）。
-- 原来另挂的四条"自己达成伤害时机"refresh 已删除：那套按伤害事件本身回能，
-- 与新描述"发动技能后"不符，且会对"自己发动伤害技能"重复计能量。

-- 回合结束时强制移除风循的临时技能（refresh 通道遍历所有玩家，
-- 只读玩家身上的 FENGXUN_TEMP_MARK 判断，不依赖 hasSkill / cleaner）。
fengxun:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if player.dead then return false end
    local name = player:getMark(FENGXUN_TEMP_MARK)
    return type(name) == "string" and name ~= ""
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local name = player:getMark(FENGXUN_TEMP_MARK)
    room:handleAddLoseSkills(player, "-" .. name, nil, false, true)
    room:setPlayerMark(player, FENGXUN_TEMP_MARK, "")
  end,
})

-- 开局常驻能量条：游戏开始时给拥有风循或覆梦的角色建立能量 mark（0 能量也显示 5 空格）
fengxun:addEffect(fk.GameStart, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(fengxun.name) or player:hasSkill("tianzong_geshi__fumeng")
  end,
  on_refresh = function(self, event, target, player, data)
    TianzongEnergy.init(player.room, player)
  end,
})

return fengxun
