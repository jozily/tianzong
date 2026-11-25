local leibi = fk.CreateSkill { name = "tianzong_toaru__leibi" }

Fk:loadTranslationTable {
  ["tianzong_toaru__leibi"] = "雷壁",
  [":tianzong_toaru__leibi"] = "当其他角色使用的技能即将作用于你后，你可以与其依次横置，视为对其使用一张雷【杀】，若此【杀】造成伤害，其技能对你无效。",
  ["#tianzong_toaru__leibi-invoke"] = "雷壁：你可以与 %dest 依次横置，视为对其使用一张雷【杀】",
}

-- 技能即将作用于你：横置双方 → 视为用雷杀 → 若造成伤害则把该技能对你无效
-- 修复点：旧版造成伤害后只让"雷壁"自身失效，未取消该技能对你的作用；
-- 现改为从 data.skill_data.tos 中剔除你，令该技能本次对你无效（chiyidi 同款写法）。
leibi:addEffect(fk.SkillEffect, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(leibi.name) then return false end
    local from = data.who
    if not from or from == player or not data.skill_data or not data.skill_data.tos then return false end
    -- 不响应自身（视为用杀）造成的技能结算，避免递归
    if data.skill and data.skill.name == leibi.name then return false end
    if not table.contains(data.skill_data.tos, player) then return false end
    return player:canUseTo(Fk:cloneCard("thunder__slash"), from, { bypass_distances = true, bypass_times = true })
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = leibi.name, prompt = "#tianzong_toaru__leibi-invoke::" .. data.who.id }) then
      event:setCostData(self, { from = data.who })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = event:getCostData(self).from
    -- 依次横置：先你后其
    if not player.chained then
      player:setChainState(true, { who = player, reason = leibi.name })
    end
    if from:isAlive() and not from.chained then
      from:setChainState(true, { who = player, reason = leibi.name })
    end
    -- 视为对其使用雷杀
    local use = room:useVirtualCard("thunder__slash", nil, player, from, leibi.name, true, {
      bypass_distances = true,
      bypass_times = true,
    })
    -- 若此杀造成伤害，令该技能对你无效：把你从 tos 中剔除
    if use and use.damageDealt and next(use.damageDealt) and data.skill_data.tos then
      data.skill_data.tos = table.filter(data.skill_data.tos, function(p) return p ~= player end)
    end
  end,
})

return leibi
