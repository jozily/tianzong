-- chiminghuai.lua (铭怀)
local chiminghuai = fk.CreateSkill{
  name = "chiminghuai",
  description = ":chiminghuai",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    -- 无 player / 无房间 / 无体力（选将、技能一览、观战）时返回空串，
    -- 引擎回退静态描述，避免显示"该房间不可用"等错误文本
    if not player or not player.room or not player.hp then return "" end
    local room = player.room

    local limitedCount = 0
    for _, p in ipairs(room.players) do
      for _, sk in ipairs(p.skills) do
        local skill = Fk:getSkill(sk)
        if skill and table.contains(skill.tags or {}, Skill.Limited) then
          limitedCount = limitedCount + 1
        end
      end
    end

    local drawCount = math.min(limitedCount, player.hp)
    return "chiminghuai_dyn:" .. tostring(limitedCount) .. ":" .. tostring(drawCount)
  end,
}

Fk:loadTranslationTable{
  ["chiminghuai"] = "铭怀",
  ["#chiminghuai-invoke"] = "铭怀：将牌名字数之和等于四的牌当【随机应变】使用",
  -- {1}=全场限定技数，{2}=实际摸牌数（受体力上限约束）
  ["chiminghuai_dyn"] = "每名角色的回合结束阶段，你可以将牌名字数之和等于四的任意张牌当做【随机应变】使用，然后你摸{2}张牌。（全场共有{1}个限定技，X为你体力值）",
}

chiminghuai:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#chiminghuai-invoke" })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local cards = player:getCardIds("he")
    if #cards == 0 then return end
    
    local validCombinations = {}
    
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      local nameLength = card:getNameLength(true)
      
      if nameLength == 4 then
        table.insert(validCombinations, { id })
      end
    end
    
    for i, id1 in ipairs(cards) do
      for j, id2 in ipairs(cards) do
        if i < j then
          local card1 = Fk:getCardById(id1)
          local card2 = Fk:getCardById(id2)
          if card1:getNameLength(true) + card2:getNameLength(true) == 4 then
            table.insert(validCombinations, { id1, id2 })
          end
        end
      end
    end
    
    if #validCombinations == 0 then return end
    
    local choice = validCombinations[math.random(1, #validCombinations)]
    
    local card = Fk:cloneCard("random_responce")
    card.skillName = skillName
    
    room:useCard({
      from = player,
      card = card,
      skillName = skillName,
    })
    
    local limitedCount = 0
    for _, p in ipairs(room.alive_players) do
      for _, sk in ipairs(p.skills) do
        local skill = Fk:getSkill(sk)
        if skill and table.contains(skill.tags or {}, Skill.Limited) then
          limitedCount = limitedCount + 1
        end
      end
    end
    
    local drawCount = math.min(limitedCount, player.hp)
    if drawCount > 0 then
      player:drawCards(drawCount, skillName)
    end
  end,
})

return chiminghuai
