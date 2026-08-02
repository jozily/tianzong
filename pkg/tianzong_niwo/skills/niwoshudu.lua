local niwoshudu = fk.CreateSkill{
  name = "niwoshudu",
  related_skills = { "niwocangji", "niwochencangRemake", "niwochoulu" },
  tags = { Skill.Compulsory },
}

niwoshudu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoshudu.name) then return false end
    if not data.to or #data.to == 0 then return false end
    
    for _, p in ipairs(data.to or {}) do
      if p:isAlive() and p ~= player then
        return true
      end
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    for _, p in ipairs(data.to or {}) do
      if p:isAlive() and p ~= player then
        player:addSkillDistance(p, 1)
      end
    end
    
    local in_range = false
    for _, other in ipairs(room:getOtherPlayers(player)) do
      if player:inMyAttackRange(other) then
        in_range = true
        break
      end
    end
    
    if not in_range then
      player:addSkill("niwocangji")
      player:addSkill("niwochoulu")
    end
  end,
})

niwoshudu:addEffect(fk.Damaged, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoshudu.name) then return false end
    if not data.from or not data.from:isAlive() or data.from == player then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    player:addSkillDistance(data.from, 1)
    
    local in_range = false
    for _, other in ipairs(room:getOtherPlayers(player)) do
      if player:inMyAttackRange(other) then
        in_range = true
        break
      end
    end
    
    if not in_range then
      player:addSkill("niwocangji")
      player:addSkill("niwochoulu")
    end
  end,
})

return niwoshudu
