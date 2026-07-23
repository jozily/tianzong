-- chidangdan.lua
local chidangdan = fk.CreateSkill{
  name = "chidangdan",
  tags = { Skill.Contract },
  description = ":chidangdan",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chidangdan"] = "荡胆",
  [":chidangdan"] = "契定技，当你使用牌指定目标后，若其体力值与此牌合法目标数相等，你可以增加一点体力上限。",
}

chidangdan:addEffect(fk.TargetSpecified, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and
      data and #data.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targetCount = #data.tos
    
    for _, targetId in ipairs(data.tos) do
      local targetPlayer = room:getPlayerById(targetId)
      if targetPlayer and targetPlayer:getHp() == targetCount then
        room:changeMaxHp(player, 1)
        break
      end
    end
  end,
})

return chidangdan
