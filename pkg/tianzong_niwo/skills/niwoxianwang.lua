local niwoxianwang = fk.CreateSkill{
  name = "niwoxianwang",
  tags = { Skill.Compulsory },
}

niwoxianwang:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwoxianwang.name) then return false end
    if not data.card:hasSkill("niwoxungu") then return false end
    
    local winds = player:getTableMark("niwoxungu_wind")
    if not winds or #winds == 0 then return false end
    
    local card_name = data.card:getName()
    for _, wind_id in ipairs(winds) do
      local wind_card = Fk:getCardById(wind_id)
      if wind_card:getName() == card_name then
        return true
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, niwoxianwang.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_name = data.card:getName()
    local winds = player:getTableMark("niwoxungu_wind")
    
    for _, wind_id in ipairs(winds) do
      local wind_card = Fk:getCardById(wind_id)
      if wind_card:getName() == card_name then
        local suit = wind_card:getSuit()
        room:throwCard({wind_id}, niwoxianwang.name, player, player)
        
        local new_winds = {}
        for _, id in ipairs(winds) do
          if id ~= wind_id then
            table.insert(new_winds, id)
          end
        end
        room:setPlayerMark(player, "niwoxungu_wind", new_winds)
        
        local same_suit_count = 0
        for _, remaining_wind_id in ipairs(new_winds) do
          local remaining_wind = Fk:getCardById(remaining_wind_id)
          if remaining_wind:getSuit() == suit then
            same_suit_count = same_suit_count + 1
          end
        end
        
        if same_suit_count > 0 then
          player:drawCards(same_suit_count, niwoxianwang.name)
        end
        
        data.extra_data = data.extra_data or {}
        data.extra_data.niwoxianwang_repeat = true
        
        room:useCard({
          from = player.id,
          card = data.card,
          to = data.to,
        })
        break
      end
    end
  end,
})

return niwoxianwang
