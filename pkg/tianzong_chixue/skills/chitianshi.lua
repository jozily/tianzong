-- chitianshi.lua (恬适)
local chitianshi = fk.CreateSkill{
  name = "chitianshi",
  tags = { Skill.Compulsory },
  description = ":chitianshi",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    -- 无 player / 无房间（选将、技能一览、观战）时返回空串，
    -- 引擎会自动回退到静态描述 :chitianshi，避免显示"该房间不可用"等错误文本
    if not player or not player.room or not player.hp then return "" end
    return "chitianshi_dyn:" .. tostring(player.hp)
  end,
}

Fk:loadTranslationTable{
  ["chitianshi"] = "恬适",
  [":chitianshi"] = "锁定技，其他角色于回合内对你使用的首张牌名字数不小于你体力值的牌对你无效。其他角色于回合内使用的首张牌名字数不小于X的牌结算后，你视为使用之。",
  -- {1} = 当前体力值。英文冒号分段是引擎 descFormatter 的约定。
  [":chitianshi_dyn"] = "锁定技，其他角色于回合内对你使用的首张牌名字数不小于{1}的牌对你无效（你当前体力{1}）。其他角色于回合内使用的首张牌名字数不小于X的牌结算后，你视为使用之。",
}

chitianshi:addEffect(fk.CardEffecting, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.from and data.from ~= player and
      player:usedSkillTimes(self.name .. "_" .. data.from.id, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local skillName = self.name
    local nameLength = data.card:getNameLength(true)
    
    if nameLength >= player.hp then
      data.nullified = true
      player.room:setPlayerMark(player, skillName .. "_" .. data.from.id, 1)
    end
  end,
})

chitianshi:addEffect(fk.CardEffectFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from ~= player and player:hasSkill(self.name) and
      player:usedSkillTimes("chitianshi_use_" .. data.from.id, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local nameLength = data.card:getNameLength(true)
    
    -- X 为你的体力值（与静态/动态描述一致）
    if nameLength >= player.hp then
      room:askToUseVirtualCard(
        player,
        {
          name = data.card.name,
          skill_name = skillName,
        }
      )
      player.room:setPlayerMark(player, "chitianshi_use_" .. data.from.id, 1)
    end
  end,
})

return chitianshi
