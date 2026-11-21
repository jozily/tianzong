local RANDOM_POOL = {
  "ty_ex__jueqing", "shangshi", "jianmie", "liangyan", "minghui",
  "ol__huishi", "qingleng", "chiejue", "mini__juejue",
  "mini__qingshiz", "mini__qingjuez",
}

local chiyuanque = fk.CreateSkill{
  name = "chiyuanque",
  related_skills = RANDOM_POOL,
  tags = { Skill.Quest },
}
local COUNT_MARK = "chiyuanque_damage_count"  -- 隐藏计数，仍是数字
local DAMAGE_MARK = "@chiyuanque_damage"       -- 显示用，"X/3"
local FINISHED = "chiyuanque_finished"
local THRESHOLD = 3

local function acquire_random(room, player, number)
  local pool = table.filter(RANDOM_POOL, function(name)
    return Fk.skills[name] ~= nil and not player:hasSkill(name, true)
  end)
  local gained = {}
  while #pool > 0 and #gained < number do
    local name = room:tableRandomPick(pool)
    table.removeOne(pool, name)
    table.insert(gained, name)
  end
  if #gained > 0 then room:handleAddLoseSkills(player, table.concat(gained, "|"), nil, true, false) end
end

local function success(room, player)
  room:setPlayerMark(player, FINISHED, 1)
  room:updateQuestSkillState(player, chiyuanque.name, false)
  if player:isWounded() then room:recover{ who = player, num = player.maxHp - player.hp, skillName = chiyuanque.name } end
  room:handleAddLoseSkills(player, "-chifenqing|-chisuhen", nil, true, false)
  acquire_random(room, player, room.current ~= player and 3 or 2)
end

-- 累计值用隐藏数字标记维护，显示标记写成 "X/3"（封顶 3），与官方 shilue 的 X/3 写法一致
local function add_damage(player, amount)
  local room = player.room
  room:addPlayerMark(player, COUNT_MARK, amount)
  local n = player:getMark(COUNT_MARK)
  room:setPlayerMark(player, DAMAGE_MARK, math.min(n, THRESHOLD) .. "/" .. THRESHOLD)
  if n >= THRESHOLD and player:getMark(FINISHED) == 0 then success(room, player) end
end

chiyuanque:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chiyuanque.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, DAMAGE_MARK, "0/" .. THRESHOLD)
  end,
})

chiyuanque:addEffect(fk.AcquireSkill, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyuanque.name) and player:getMark(DAMAGE_MARK) == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, DAMAGE_MARK, math.min(player:getMark(COUNT_MARK), THRESHOLD) .. "/" .. THRESHOLD)
  end,
})

chiyuanque:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyuanque.name) and player:getMark(FINISHED) == 0
      and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data) add_damage(player, data.damage) end,
})
chiyuanque:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.from ~= player and player:hasSkill(chiyuanque.name) and player:getMark(FINISHED) == 0
      and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data) add_damage(player, data.damage) end,
})

chiyuanque:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyuanque.name) and player:getMark(FINISHED) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, FINISHED, 1)
    room:updateQuestSkillState(player, chiyuanque.name, true)
    if player.hp < 1 then room:recover{ who = player, num = 1 - player.hp, skillName = chiyuanque.name } end
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "-chifenqing|-chisuhen", nil, true, false)
    -- 追思：获得一名已死亡角色武将牌上的所有技能
    local dead = table.filter(room.players, function(p) return not p:isAlive() end)
    if #dead > 0 then
      local chosen = room:askToChoosePlayers(player, { targets = dead, min_num = 1, max_num = 1, skill_name = chiyuanque.name, prompt = "#chiyuanque-memory", cancelable = true })
      if #chosen > 0 then
        local to = chosen[1]
        local skills = Fk.generals[to.general]:getSkillNameList()
        if to.deputyGeneral and to.deputyGeneral ~= "" then
          table.insertTableIfNeed(skills, Fk.generals[to.deputyGeneral]:getSkillNameList())
        end
        skills = table.filter(skills, function(skill_name)
          local skill = Fk.skills[skill_name]
          return skill ~= nil and not skill:hasTag(Skill.Lord)
        end)
        if #skills > 0 then room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false) end
      end
    end
  end,
})

return chiyuanque
