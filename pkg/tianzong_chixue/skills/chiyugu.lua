
local chiyugu = fk.CreateSkill {
  name = "chiyugu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["chiyugu"] = "毓骨",
  [":chiyugu"] = "转换技，你可以翻面视为使用或打出一张不计入次数的：①牌名字数为X的基本牌或普通锦囊牌；②目标数不大于所有已翻面角色数的基本牌或普通锦囊牌（X为场上翻面的角色数）",
  ["#chiyugu-invoke"] = "毓骨：你可以翻面视为使用一张牌",
  ["#chiyugu-choice"] = "毓骨：请选择要使用的牌",
  ["#chiyugu-target"] = "毓骨：请选择目标（至多%arg个）",
  ["chiyugu_yang"] = "牌名字数为X的牌",
  ["chiyugu_yin"] = "目标数≤翻面数的牌",
}

-- 获取场上翻面的角色数（faceup==false）
local function getTurnedOverNum(room)
  local count = 0
  for _, p in ipairs(room.alive_players) do
    if not p.faceup then
      count = count + 1
    end
  end
  return count
end

-- 获取牌名的中文字数（UTF-8环境下）
local function getCardNameLength(card)
  local name = Fk:translate(card.trueName)
  -- 中文字符每个占3字节，所以用字节数除以3取整
  return math.floor(#name / 3)
end

-- 获取牌的最大目标数（简化版，只区分群体/单体）
local function getCardMaxTargets(card)
  local trueName = card.trueName
  -- 群体类锦囊（如桃园、五谷、南蛮、万箭、决斗等）的目标数取决于存活角色数，这里返回一个极大值
  if trueName == "peach_garden" or trueName == "god_salvation" or
     trueName == "archery_attack" or trueName == "savage_assault" or
     trueName == "amazing_grace" or trueName == "duel" then
    return 99
  end
  -- 大多数牌的目标数为1
  return 1
end

chiyugu:addEffect("active", {
  anim_type = "switch",
  prompt = "#chiyugu-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    -- 出牌阶段内，每回合限一次
    return player.phase == Player.Play and
      player:usedSkillTimes(chiyugu.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    -- 翻面并切换状态
    player:turnOver()
    local state = player:getSwitchSkillState(chiyugu.name)  -- 0为阳，1为阴
    local x = getTurnedOverNum(room)

    -- 收集符合条件的基本牌和普通锦囊牌
    local validNames = {}
    for _, name in ipairs(Fk:getAllCardNames()) do
      local card = Fk:cloneCard(name)
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        if state == 0 then
          -- 阳：牌名字数为X
          if getCardNameLength(card) == x then
            table.insert(validNames, name)
          end
        else
          -- 阴：目标数不大于翻面数
          if getCardMaxTargets(card) <= x then
            table.insert(validNames, name)
          end
        end
      end
    end
    if #validNames == 0 then
      -- 没有可用牌，技能无效
      return
    end

    -- 让玩家选择一种牌名
    local choice = room:askToChoice(player, {
      choices = validNames,
      skill_name = chiyugu.name,
      prompt = "#chiyugu-choice",
    })
    local card = Fk:cloneCard(choice)

    -- 选择目标（阴时限制目标数≤x，阳时按牌本身规则）
    local maxTargets = getCardMaxTargets(card)
    if state == 1 then
      maxTargets = math.min(maxTargets, x)
    end
    local targets = {}
    -- 仅当牌需要指定目标时（非自己使用或不需要目标除外）
    if card:needTargets() then
      local targetList = room:getOtherPlayers(player, false)
      -- 如果牌可以指定自己，则加入自己
      if not card:isCancelable(player) then
        table.insert(targetList, player)
      end
      targets = room:askToChoosePlayers(player, {
        min_num = 0,
        max_num = maxTargets,
        targets = targetList,
        skill_name = chiyugu.name,
        prompt = "#chiyugu-target:::" .. maxTargets,
      })
    end

    -- 视为使用牌，不计入次数
    room:useCard({
      from = player,
      tos = targets,
      card = card,
      skill_name = chiyugu.name,
      extraUse = true,           -- 不计入出牌次数
      -- 如需强制指定额外数据，可在此添加 extra_data
    })

    -- 切换转换技状态
    U.SetSwitchSkillState(player, chiyugu.name, state == 0 and 1 or 0)
  end,
})

-- 可选：响应打出（如【杀】【闪】【桃】【酒】等）时也可发动
-- 此处仅演示主动使用，如需完整覆盖“打出”可参考以下结构（需纳入同一技能）：
-- chiyugu:addEffect(fk.CardResponding, {
--   anim_type = "switch",
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(chiyugu.name) and
--            player.phase == Player.Play and  -- 实际打出可能在任何阶段，需调整
--            player:usedSkillTimes(chiyugu.name, Player.HistoryTurn) == 0
--   end,
--   on_use = function(self, event, target, player, data)
--     -- 类似上面逻辑，但最后使用 data:respondCard(card) 或 room:responseCard
--   end,
-- })

return chiyugu