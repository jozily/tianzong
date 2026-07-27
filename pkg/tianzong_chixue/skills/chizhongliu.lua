local chizhongliu = fk.CreateSkill{
  name = "chizhongliu",
  tags = { Skill.Compulsory },
}

chizhongliu:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(chizhongliu.name) or not data.card then return false end
    local ids = Card:getIdList(data.card)
    if #ids == 0 then return true end
    return table.find(ids, function(id)
      return player.room:getCardArea(id) ~= Card.PlayerHand or player.room:getCardOwner(id) ~= player
    end) ~= nil
  end,
  on_use = function(self, event, target, player, data)
    for _, skill_name in ipairs(player:getSkillNameList()) do
      player:setSkillUseHistory(skill_name, 0, Player.HistoryPhase)
      player:setSkillUseHistory(skill_name, 0, Player.HistoryTurn)
      player:setSkillUseHistory(skill_name, 0, Player.HistoryRound)
      player:setSkillUseHistory(skill_name, 0, Player.HistoryGame)
    end
  end,
})

return chizhongliu
