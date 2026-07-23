-- chijianian.lua (佳年)
local chijianian = fk.CreateSkill{
  name = "chijianian",
  description = ":chijianian",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local hasEqual = false
    for k, v in pairs(player.marks) do
      if string.find(k, "chifusheng_swap_") and v > 0 then
        local parts = string.split(k, "_")
        if parts[3] and parts[4] then
          local idx1 = tonumber(parts[3])
          local idx2 = tonumber(parts[4])
          if idx1 == idx2 then
            hasEqual = true
            break
          end
        end
      end
    end
    if hasEqual then
      return "佳年：浮生有相等项✓"
    else
      return "佳年：浮生无相等项"
    end
  end,
}

Fk:loadTranslationTable{
  ["chijianian"] = "佳年",
}

chijianian:addEffect(fk.CardRequiredRespond, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data and data.card_type and
      (data.card_type == Card.TypeBasic or data.card_type == Card.TypeTrick)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    -- 检查浮生是否有相等项
    local hasEqual = false
    for k, v in pairs(player.marks) do
      if string.find(k, "chifusheng_swap_") and v > 0 then
        local parts = string.split(k, "_")
        if parts[3] and parts[4] then
          local idx1 = tonumber(parts[3])
          local idx2 = tonumber(parts[4])
          if idx1 == idx2 then
            hasEqual = true
            break
          end
        end
      end
    end
    
    if hasEqual then
      player:recover({ recover_hp = 1 }, skillName)
    end
  end,
})

return chijianian
