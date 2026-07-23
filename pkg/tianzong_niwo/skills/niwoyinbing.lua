local niwoyinbing = fk.CreateSkill{
  name = "niwoyinbing",
  tags = { Skill.Contract },
}

niwoyinbing:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing.name) and data.from and data.from:isAlive() and data.from ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local damage_from = data.from
    
    local use = room:askToUseCard(damage_from, {
      skill_name = niwoyinbing.name,
      prompt = "#niwoyinbing-ice",
      pattern = "ice__slash",
      extra_data = {
        exclusive_targets = { damage_from.id },
        bypass_times = true,
      }
    })
    
    if use then
      room:useCard(use)
      
      if not use.damageDealt or use.damageDealt == 0 then
        damage_from:drawCards(2, niwoyinbing.name)
        room:loseHp(damage_from, 1, niwoyinbing.name)
      else
        local has_death = false
        for _, to in ipairs(use.to or {}) do
          if to.dead then
            has_death = true
            break
          end
        end
        
        if has_death then
          local targets = {}
          for _, p in ipairs(room:getOtherPlayers(player)) do
            if p:isAlive() then
              table.insert(targets, p.id)
            end
          end
          
          if #targets > 0 then
            local choice = room:askToChoose(player, targets, niwoyinbing.name, "#niwoyinbing-acquire")
            local target_player = room:getPlayerById(tonumber(choice))
            if target_player then
              target_player:addSkill(niwoyinbing.name)
            end
          end
        end
      end
    end
  end,
})

return niwoyinbing
