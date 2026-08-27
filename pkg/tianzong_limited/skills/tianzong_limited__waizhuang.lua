local U = require "packages.utility.utility"
local waizhuang = fk.CreateSkill { name = "tianzong_limited__waizhuang", tags = { Skill.Compulsory }, related_skills = { "tianzong_limited__yangmu" } }

waizhuang:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data) return target == player and player:hasSkill(waizhuang.name) and player:getMark("skill_charge") < player:getMark("skill_charge_max") end,
  on_use = function(self, event, target, player, data) U.skillCharged(player, 1) end,
})

waizhuang:addEffect("filter", {
  handly_cards = function(self, player)
    local cards = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.contains(p:getTableMark("@[list]tianzong_limited__yangmu"), player) then
        table.insertTable(cards, p:getCardIds("h"))
      end
    end
    return #cards > 0 and cards or nil
  end,
})

waizhuang:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(waizhuang.name) then return false end
    return table.find(player.room.alive_players, function(p)
      return p:getMark("tianzong_limited__yangmu_guard-round") == 0 and
        table.contains(p:getTableMark("@[list]tianzong_limited__yangmu"), player)
    end) ~= nil
  end,
  on_cost = function(self, event, target, player, data)
    local candidates = table.filter(player.room.alive_players, function(p)
      return p:getMark("tianzong_limited__yangmu_guard-round") == 0 and
        table.contains(p:getTableMark("@[list]tianzong_limited__yangmu"), player)
    end)
    local who = player.room:askToChoosePlayers(player, { targets = candidates, min_num = 1, max_num = 1,
      skill_name = "tianzong_limited__yangmu", prompt = "#tianzong_limited__yangmu-guard", cancelable = true })[1]
    if who then event:setCostData(self, { tos = { who } }); return true end
  end,
  on_use = function(self, event, target, player, data)
    local admirer = event:getCostData(self).tos[1]
    player.room:setPlayerMark(admirer, "tianzong_limited__yangmu_guard-round", 1)
    player.room:changeMaxHp(admirer, -1)
    data:preventDamage()
  end,
})

return waizhuang
