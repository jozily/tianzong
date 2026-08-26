local daoyan = fk.CreateSkill {
  name = "tianzong_limited__daoyan",
  tags = { Skill.Limited },
}
daoyan:addEffect("active", {
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(daoyan.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local names = player:getTableMark("@tianzong_limited__juben_names")
    local people = player:getTableMark("@tianzong_limited__juben_players")
    local suits = player:getTableMark("@tianzong_limited__juben_suits")
    local ids = table.filter(room.draw_pile, function(id)
      return table.contains(names, Fk:getCardById(id).name)
    end)
    for _, pid in ipairs(people) do
      local p = room:getPlayerById(pid)
      if p then table.insertTableIfNeed(ids, p:getCardIds("hej")) end
    end
    for _, id in ipairs(player:getTableMark("tianzong_limited__juben_discards")) do
      if room:getCardArea(id) == Card.DiscardPile and table.contains(suits, Fk:getCardById(id, true).suit) then
        table.insertIfNeed(ids, id)
      end
    end
    if #ids > 0 then room:obtainCard(player, ids, true, fk.ReasonPrey, player, daoyan.name) end
    room:handleAddLoseSkills(player, "-tianzong_limited__juben", daoyan.name)
  end,
})

return daoyan
