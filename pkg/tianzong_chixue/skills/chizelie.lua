-- chizelie.lua
local chizelie = fk.CreateSkill{
  name = "chizelie",
  description = ":chizelie",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chizelie"] = "泽烈",
}

chizelie:addEffect(fk.CardsMoved, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return false end
    
    local loseAll = false
    for _, move in ipairs(data) do
      if move.from == player.id and #move.ids > 0 then
        loseAll = true
        break
      end
    end
    return loseAll
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= player then
        table.insert(targets, p.id)
      end
    end
    
    if #targets == 0 then return end
    
    local targetId = room:askToChoose(player, targets, self.name, "")
    local targetPlayer = room:getPlayerById(tonumber(targetId))
    
    if not targetPlayer then return end
    
    local choices = { "draw", "discard" }
    local choice = room:askToChoose(player, choices, self.name, "")
    
    if choice == "draw" then
      targetPlayer:setMark("chizelie_extra_draw", 1)
    else
      targetPlayer:setMark("chizelie_extra_discard", 1)
    end
  end,
})

return chizelie
