-- ==================== pkg\tianzong\pkg\tianzong_chixue\skills\chiyinghun.lua ====================

local chiyinghun = fk.CreateSkill {
  name = "chiyinghun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chiyinghun"] = "萦魂",
  [":chiyinghun"] = "锁定技，当你使用一张牌后/当你受到伤害后，此牌所有目标翻面/你与伤害来源翻面，且本回合所有武将牌正面朝上角色的非锁定技失效。你与武将牌状态一致角色的距离始终为1。",
  ["@@chiyinghun-turn"] = "萦魂",
}

-- 使用牌后：翻面所有目标（用 fk.CardUsing，与知识库 quanbian 一致）
chiyinghun:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyinghun.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data.tos) do
      if not p.dead then
        p:turnOver()  -- 知识库惯用翻面
      end
    end
    for _, p in ipairs(room.alive_players) do
      if p.faceup then
        room:setPlayerMark(p, "@@chiyinghun-turn", 1)
      end
    end
  end,
})

-- 受到伤害后：翻面自己和伤害来源（若 fk.Damaged 报错请改为 fk.Damage）
chiyinghun:addEffect(fk.Damaged, {  -- 第36行附近，如报错改为 fk.Damage
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyinghun.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:turnOver()
    if data.from and not data.from.dead then
      data.from:turnOver()
    end
    for _, p in ipairs(room.alive_players) do
      if p.faceup then
        room:setPlayerMark(p, "@@chiyinghun-turn", 1)
      end
    end
  end,
})

-- 距离调整：使用知识库确认有效的 "targetmod" 类型
chiyinghun:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(chiyinghun.name) and card
  end,
})

-- 回合结束时清除失效标记
chiyinghun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Finish and player:hasSkill(chiyinghun.name) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@@chiyinghun-turn", 0)
    end
  end,
})

return chiyinghun