-- chidaojie.lua (蹈节)
local chidaojie = fk.CreateSkill{
  name = "chidaojie",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chidaojie"] = "蹈节",
  [":chidaojie"] = "锁定技，当你每回合第一次使用非伤害普通锦囊牌结算结束后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名角色获得此牌。",
  ["#chidaojie-choose"] = "蹈节：选择一项",
  ["chidaojie1"] = "失去1点体力",
  ["chidaojie2"] = "失去一个锁定技",
}

chidaojie:addEffect(fk.CardEffectFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card and data.card:isCommonTrick() and
      not data.card.is_damage_card and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local choices = { "chidaojie1", "chidaojie2" }
    local choice = room:askToChoice(player, {
      choices = choices, skill_name = skillName, prompt = "#chidaojie-choose",
    })
    
    if choice == "chidaojie1" then
      room:loseHp(player, 1, skillName)
    else
      -- 失去一个锁定技
      local compulsorySkills = {}
      for _, skillName_iter in ipairs(player:getSkillNameList()) do
        local skill = Fk.skills[skillName_iter]
        if skill and table.contains(skill.tags or {}, Skill.Compulsory) then
          table.insert(compulsorySkills, skillName_iter)
        end
      end
      
      if #compulsorySkills > 0 then
        local lostSkill = room:askToChoice(player, {
          choices = compulsorySkills, skill_name = skillName,
          prompt = "#chidaojie-skill",
        })
        player:loseSkill(lostSkill)
      end
    end
    
    -- 选择一名角色获得此牌
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      table.insert(targets, p)
    end
    
    if #targets > 0 then
      local chosen = room:askToChoosePlayers(player, {
        targets = targets, min_num = 1, max_num = 1,
        skill_name = skillName, prompt = "#chidaojie-target",
        cancelable = false,
      })
      local targetPlayer = chosen[1]
      if targetPlayer then
        room:moveCards({
          ids = { data.card.id },
          to = targetPlayer.id,
          toArea = Card.PlayerHand,
          reason = fk.ReasonJustMove,
          skillName = skillName,
        })
      end
    end
  end,
})

return chidaojie
