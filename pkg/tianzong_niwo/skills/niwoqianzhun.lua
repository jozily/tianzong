local niwoqianzhun = fk.CreateSkill{
  name = "niwoqianzhun",
}

local ONCE_MARK = "@$niwoqianzhun"

niwoqianzhun:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player 
      and player:hasSkill(niwoqianzhun.name)
      and player:usedSkillTimes(niwoqianzhun.name, Player.HistoryRound) == 0
      and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niwoqianzhun.name,
      prompt = "#niwoqianzhun-invoke",
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
      skill_name = niwoqianzhun.name, prompt = "#niwoqianzhun-choose",
      cancelable = false,
    })
    local target_player = chosen[1]
    
    if not target_player then return end
    
    local choice = room:askToChoice(player, {
      choices = { "opt1", "opt2" }, skill_name = niwoqianzhun.name,
      prompt = "#niwoqianzhun-choice",
    })
    
    if choice == "opt1" then
      local skill_cards = {}
      for _, skill_id in ipairs(target_player:getSkillNameList()) do
        local skill = Fk.skills[skill_id]
        if skill and skill.description then
          local cards = string.match(skill.description, "【(.-)】")
          if cards then
            table.insertIfNeed(skill_cards, cards)
          end
        end
      end
      
      if #skill_cards > 0 then
        local choice_card = room:askToChoice(player, {
          choices = skill_cards, skill_name = niwoqianzhun.name,
          prompt = "#niwoqianzhun-card",
        })
        local use = room:askToUseCard(player, {
          skill_name = niwoqianzhun.name,
          prompt = "#niwoqianzhun-use",
          pattern = choice_card,
        })
        if use then
          room:useCard(use)
        end
      end
    else
      local skill_count = 0
      for _, skill_id in ipairs(target_player:getSkillNameList()) do
        local skill = Fk.skills[skill_id]
        if skill then
          skill_count = skill_count + 1
        end
      end
      
      local card_name_len = skill_count + 1
      local all_names = Fk:getAllCardNames("bt")
      local names = {}
      for _, card_name in ipairs(all_names) do
        local card = Fk:cloneCard(card_name)
        if card:getNameLength(true) == card_name_len then
          table.insert(names, card_name)
        end
      end
      
      if #names > 0 then
        local choice_card = room:askToChoice(player, {
          choices = names, skill_name = niwoqianzhun.name,
          prompt = "#niwoqianzhun-cardlen",
        })
        local use = room:askToUseCard(player, {
          skill_name = niwoqianzhun.name,
          prompt = "#niwoqianzhun-use",
          pattern = choice_card,
        })
        if use then
          room:useCard(use)
        end
      end
    end
    
    room:addTableMark(player, ONCE_MARK, 1)
  end,
})

niwoqianzhun:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoqianzhun.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, ONCE_MARK, 0)
  end,
})

return niwoqianzhun
