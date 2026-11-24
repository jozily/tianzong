local canbei_up = fk.CreateSkill{
  name = "tianzong_geshi__canbei_up",
  tags = { Skill.Limited }, -- 限定技图标特效（金色"限"字+大招动画）；不限次数由本技能自己不写 usedSkillTimes 检查实现
}

-- 与基础参北共用的失效状态标记，保证升级前后失效/恢复连续
local INVALID_MARK = "tianzong_geshi__canbei_invalid"
local INVALID_SHOW = "@[tianzong_geshi__canbei_invalid]"

local function canbeiOnCost(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, {
    skill_name = canbei_up.name,
    prompt = "#tianzong_geshi__canbei-invoke",
  })
end

local function canbeiOnUse(self, event, target, player, data)
  local room = player.room
  local old_hp = player.hp
  local lost = player.maxHp - old_hp
  local diff = math.abs(lost - old_hp)
  if diff < 1 then diff = 1 end
  -- 先自我失效，避免 setPlayerProperty 触发的再次 HpChanged 递归
  room:setPlayerMark(player, INVALID_MARK, 1)
  room:invalidateSkill(player, canbei_up.name)
  room:setPlayerMark(player, INVALID_SHOW, 1)
  if lost ~= old_hp then
    room:setPlayerProperty(player, "hp", lost)
    if player.hp < 1 then
      room:enterDying({ who = player })
    end
  end
  if not player.dead then
    player:drawCards(diff, canbei_up.name)
  end
end

-- 修改后的参北：体力值变化后，若你未处于濒死状态，交换体力值与已损失体力值并摸差值张牌
-- 然后此技能失效直至有角色进入濒死状态（仅外观为限定技，不限每局次数）
canbei_up:addEffect(fk.HpChanged, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(canbei_up.name)
      and player:getMark(INVALID_MARK) == 0
      and player.hp >= 0 and player.hp <= player.maxHp
      and not player.dying
  end,
  on_cost = canbeiOnCost,
  on_use = canbeiOnUse,
})

-- 任意角色濒死 → 恢复（解除失效）
canbei_up:addEffect(fk.EnterDying, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return not target.dead and player:getMark(INVALID_MARK) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:validateSkill(player, canbei_up.name)
    room:setPlayerMark(player, INVALID_SHOW, 0)
    room:setPlayerMark(player, INVALID_MARK, 0)
  end,
})

-- @[...] 形式 mark 的 qml spec 与翻译在基础参北文件里已注册，共用同名 mark，此处无需重复

return canbei_up
