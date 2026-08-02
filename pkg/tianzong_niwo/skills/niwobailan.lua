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
    return player.room:askToSkillInvoke(player, {
      skill_name = niwobailan.name,
      prompt = "#niwobailan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isAlive() then
        table.insert(targets, p)
      end
    end
    
    if #targets == 0 then return end
    
    local chosen = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 1,
      skill_name = niwobailan.name, prompt = "#niwobailan-choose",
      cancelable = false,
    })
    local target_player = chosen[1]
    
    if not target_player then return end
    
    local skills_to_tag = {}
    for _, skill_id in ipairs(target_player:getSkillNameList()) do
      local skill = Fk.skills[skill_id]
      if skill and not skill:hasTag(Skill.Limited) then
        table.insert(skills_to_tag, skill_id)
      end
    end
    
    if #skills_to_tag > 0 then
      local choice_skill = room:askToChoice(player, {
        choices = skills_to_tag, skill_name = niwobailan.name,
        prompt = "#niwobailan-skill",
      })
      local skill = Fk.skills[choice_skill]
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
