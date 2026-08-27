local U = require "packages.utility.utility"
local duxin = fk.CreateSkill { name = "tianzong_limited__duxin", tags = { Skill.Charge } }

duxin:addEffect("active", {
  prompt = "#tianzong_limited__duxin-choose", target_num = 1, card_num = 0,
  can_use = function(self, player)
    return player.phase == Player.Play and player:getMark("skill_charge") > 0 and
      table.find(player.room.alive_players, function(p) return p ~= player and not p:isKongcheng() end) ~= nil
  end,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player and #selected == 0 and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    U.skillCharged(player, -1)
    room:viewCards(player, { cards = target:getCardIds("h"), skill_name = self.name, prompt = "$ViewCardsFrom:" .. target.id })
    local id = room:askToChooseCard(player, { target = target, flag = "h", skill_name = self.name, prompt = "#tianzong_limited__duxin-card" })
    if id then
      local use = room:askToUseRealCard(target, {
        pattern = { id }, expand_pile = { id }, skill_name = self.name,
        prompt = "#tianzong_limited__duxin-card", cancelable = true,
        skip = true, extra_data = { expand_pile = { id }, bypass_times = true, extraUse = true },
      })
      if use then room:useCard(use) end
    end
  end,
})

duxin:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duxin.name) and player:getMark("skill_charge_max") > 0
  end,
  on_use = function(self, event, target, player, data) U.skillCharged(player, 0, -1) end,
})

duxin:addAcquireEffect(function(self, player) U.skillCharged(player, 1, 7) end)
duxin:addLoseEffect(function(self, player) U.skillCharged(player, -1, -7) end)
return duxin
