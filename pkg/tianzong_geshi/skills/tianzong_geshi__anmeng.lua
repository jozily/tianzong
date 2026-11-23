local anmeng = fk.CreateSkill{ name = "tianzong_geshi__anmeng" }

-- 黯梦：当你使用伤害牌指定目标后，你可以改为召唤"黯星"攻击任意目标。
-- 然后因此失去体力的角色本回合非锁定技失效。
-- "黯星"：概率偷取（其失去，你恢复）对方体力值，你的体力值越高，概率越大。
-- 视觉：每个目标依次播放"巨大行星撞击"全屏特效。

local CRASH_QML = "packages/tianzong/qml/AnStarCrash.qml"

local function play_crash(room, player, to)
  -- 撞击点按目标在 rooms 中的座次粗略映射到屏幕，避免每次都在正中
  local all = room.alive_players
  local idx = table.indexOf(all, to) or 1
  local n = math.max(1, #all)
  local xr = 0.3 + 0.4 * ((idx - 1) / n)
  room:doSuperLightBox(CRASH_QML, { xRatio = xr, yRatio = 0.52 }, 900, 200, true)
end

local function steal_hp(room, player, to)
  if not to:isAlive() then return end
  -- 概率随自身体力值增大：hp>=maxHp 时 100%，hp<=0 时 20%，线性插值
  local hp = math.max(0, player.hp)
  local maxhp = math.max(1, player.maxHp)
  local prob = 0.2 + 0.8 * hp / maxhp
  if math.random() < prob then
    room:loseHp(to, 1, anmeng.name)
    if to:isAlive() then
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    end
    if player:isAlive() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = anmeng.name,
      }
    end
  end
end

anmeng:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    -- 必须是我自己使用伤害牌指定目标后（target 即出牌者）
    if target ~= player or not player:hasSkill(anmeng.name) then return false end
    if not data.card or not data.card.is_damage_card then return false end
    -- 从这张牌已指定的目标中选择
    return #data.tos > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local chosen = room:askToChoosePlayers(player, {
      targets = table.simpleClone(data.tos),
      min_num = 1,
      max_num = #data.tos,
      skill_name = anmeng.name,
      prompt = "#tianzong_geshi__anmeng-choose",
      cancelable = true,
    })
    if #chosen == 0 then return false end
    event:setCostData(self, { tos = chosen })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    local tos = cost.tos
    -- 取消此次伤害牌对所选目标的指定，改由"黯星"攻击
    for _, to in ipairs(tos) do
      if table.contains(data.tos, to) then data:removeTarget(to) end
    end
    room:notifySkillInvoked(player, anmeng.name, "special")
    -- 多目标依次撞击：逐个播放行星撞击特效并偷取体力
    for _, to in ipairs(tos) do
      if not player.dead then
        play_crash(room, player, to)
        steal_hp(room, player, to)
      end
    end
  end,
})

return anmeng
