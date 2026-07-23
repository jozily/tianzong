local niwobailan = fk.CreateSkill{
  name = "niwobailan",
  tags = { Skill.Limited },
}

niwobailan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player 
      and player:hasSkill(niwobailan.name)
      and player:usedSkillTimes(niwobailan.name, Player.HistoryGame) == 0
      and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, niwobailan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isAlive() then
        table.insert(targets, p.id)
      end
    end
    
    if #targets == 0 then return end
    
    local target_id = room:askToChoose(player, targets, niwobailan.name, "#niwobailan-choose")
    local target_player = room:getPlayerById(tonumber(target_id))
    
    if not target_player then return end
    
    local skills_to_tag = {}
    for _, skill_id in ipairs(target_player:getSkills()) do
      local skill = Fk:getSkillById(skill_id)
      if skill and not skill:hasTag(Skill.Limited) then
        table.insert(skills_to_tag, skill_id)
      end
    end
    
    if #skills_to_tag > 0 then
      local choice_skill = room:askToChoose(player, skills_to_tag, niwobailan.name, "#niwobailan-skill")
      local skill = Fk:getSkillById(choice_skill)
      if skill then
        skill:addTag(Skill.Limited)
        
        if target_player ~= player then
          local damage_count = player:getHp()
          room:loseHp(player, damage_count, niwobailan.name)
        end
      end
    end
  end,
})

return niwobailan
