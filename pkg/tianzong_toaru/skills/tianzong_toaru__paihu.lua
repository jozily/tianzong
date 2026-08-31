local U = require "packages.utility.utility"
local paihu = fk.CreateSkill { name = "tianzong_toaru__paihu", tags = { Skill.Limited } }

paihu:addEffect("active", {
  prompt = "#tianzong_toaru__paihu", target_num = 1, card_num = 0,
  can_use = function(self, player) return player.phase == Player.Play and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #Fk:currentRoom().alive_players >= 3 end,
  target_filter = function(self, player, to_select, selected) return to_select ~= player and #selected == 0 end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    local x = math.max(1, #table.filter(room.alive_players, function(p) return p.kingdom == player.kingdom end))
    target:drawCards(x, self.name)
    if target:isWounded() then room:recover { who = target, num = 1, recoverBy = player, skillName = self.name } end
    room:addTableMarkIfNeed(target, "@[list]tianzong_toaru__yangmu", player)
  end,
})
return paihu


