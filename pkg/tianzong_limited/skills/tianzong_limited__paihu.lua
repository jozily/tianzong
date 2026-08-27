local U = require "packages.utility.utility"
local paihu = fk.CreateSkill { name = "tianzong_limited__paihu", tags = { Skill.Limited } }

paihu:addEffect("active", {
  prompt = "#tianzong_limited__paihu", target_num = 1, card_num = 0,
  can_use = function(self, player) return player.phase == Player.Play and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #player.room.alive_players >= 3 end,
  target_filter = function(self, player, to_select, selected) return to_select ~= player and #selected == 0 end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    target:drawCards(math.max(1, player:getHandcardNum()), self.name)
    if target:isWounded() then room:recover { who = target, num = 1, recoverBy = player, skillName = self.name } end
    room:addTableMarkIfNeed(target, "@[list]tianzong_limited__yangmu", player)
  end,
})
return paihu
