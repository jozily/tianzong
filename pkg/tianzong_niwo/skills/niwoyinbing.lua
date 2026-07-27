local niwoyinbing = fk.CreateSkill{
  name = "niwoyinbing",
  tags = { Skill.Contract },
}

niwoyinbing:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing.name) and target and target:isAlive()
      and data.from and data.from:isAlive() and data.from ~= target
      and (target == player or data.from == player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local injured = target
    local damage_from = data.from
    
    local use = room:askToUseCard(injured, {
      skill_name = niwoyinbing.name,
      prompt = "#niwoyinbing-ice::" .. damage_from.id,
      pattern = "ice__slash",
      extra_data = {
        exclusive_targets = { damage_from.id },
        bypass_distances = true,
        bypass_times = true,
      }
    })
    
    if use then
      room:useCard(use)
      
      if not use.damageDealt or not next(use.damageDealt) then
        injured:drawCards(2, niwoyinbing.name)
        room:loseHp(injured, 1, niwoyinbing.name)
      else
        local has_death = false
        for _, to in ipairs(use.tos or {}) do
          if to.dead then
            has_death = true
            break
          end
        end
        
        if has_death then
          local targets = {}
          for _, p in ipairs(room:getOtherPlayers(player)) do
            if p:isAlive() then
              table.insert(targets, p)
            end
          end
          
          if #targets > 0 then
            local chosen = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1, skill_name = niwoyinbing.name, prompt = "#niwoyinbing-acquire", cancelable = false })
            local target_player = chosen[1]
            if target_player then
              room:handleAddLoseSkills(target_player, niwoyinbing.name)
            end
          end
        end
      end
    end
  end,
})

return niwoyinbing
