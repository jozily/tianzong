-- chifufengRemake.lua (扶风)
local chifufengRemake = fk.CreateSkill{
  name = "chifufengRemake",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chifufengRemake"] = "扶风",
  [":chifufengRemake"] = "锁定技，当你于一个阶段首次展示一张牌后，你重铸你手牌中另一种颜色的所有牌，然后你将一张牌置于牌堆顶。",
}

chifufengRemake:addEffect(fk.CardShown, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local shownCard = data.card
    local shownColor = shownCard.color == Card.Red and "red" or "black"
    local oppositeColor = shownColor == "red" and "black" or "red"
    
    local handcards = player:getCardIds("h")
    local toRecycle = {}
    
    for _, id in ipairs(handcards) do
      local card = Fk:getCardById(id)
      local cardColor = card.color == Card.Red and "red" or "black"
      if cardColor == oppositeColor then
        table.insert(toRecycle, id)
      end
    end
    
    if #toRecycle > 0 then
      room:throwCard(toRecycle, skillName, player, player)
    end
    
    -- 选择一张牌置于牌堆顶
    local allCards = player:getCardIds("he")
    if #allCards > 0 then
      local choice = room:askToChooseCards(
        player,
        {
          min = 1,
          max = 1,
          flag = "he",
          skill_name = skillName,
        }
      )
      
      if #choice > 0 then
        room:moveCards({
          ids = choice,
          from = player.id,
          to = "deck",
          toArea = Card.DrawPile,
          reason = fk.ReasonJustMove,
          skillName = skillName,
          topOrBottom = "top",
        })
      end
    end
  end,
})

return chifufengRemake
