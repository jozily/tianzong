-- chiduye.lua (笃谒)
local chiduye = fk.CreateSkill{
  name = "chiduye",
  description = ":chiduye",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local optionCount = 0
    for k, v in pairs(player.marks) do
      if string.find(k, "chiduye_option_") and v > 0 then
        optionCount = optionCount + 1
      end
    end
    return "笃谒：本阶段已选" .. optionCount .. "项"
  end,
}

Fk:loadTranslationTable{
  ["chiduye"] = "笃谒",
  [":chiduye"] = "出牌阶段限一次，你可以依次展示场上至多四张牌，归属者依次选择一项并移除：①摸X张牌；②X个回合内获得【謇谔】；③本回合结束后执行一个第X个阶段（逆序）；④使用此牌，然后置于牌堆顶。（X为已选选项数+1）",
  ["chiduye1"] = "摸%arg张牌",
  ["chiduye2"] = "%arg个回合内获得【謇谔】",
  ["chiduye3"] = "本回合结束后执行第%arg个阶段",
  ["chiduye4"] = "使用此牌，置于牌堆顶",
}

chiduye:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local skillName = self.name
    
    local allCards = {}
    for _, p in ipairs(room.alive_players) do
      local cards = p:getCardIds("he")
      for _, id in ipairs(cards) do
        table.insert(allCards, { id = id, owner = p })
      end
    end
    
    if #allCards == 0 then return end
    
    local selected = {}
    for i = 1, math.min(4, #allCards) do
      local idx = math.random(1, #allCards)
      table.insert(selected, allCards[idx])
      table.remove(allCards, idx)
    end
    
    local optionCount = 0
    
    for _, cardInfo in ipairs(selected) do
      local card = Fk:getCardById(cardInfo.id)
      local owner = cardInfo.owner
      
      optionCount = optionCount + 1
      local X = optionCount
      
      player:setMark("chiduye_option_" .. optionCount, 1)
      
      local choices = {
        "chiduye1",
        "chiduye2",
        "chiduye3",
        "chiduye4",
      }
      
      local choice = room:askToChoice(owner, {
        choices = choices, skill_name = skillName, prompt = "#chiduye-choice",
      })
      
      if choice == "chiduye1" then
        owner:drawCards(X, skillName)
      elseif choice == "chiduye2" then
        owner:setMark("chiduye_dukou_" .. X, 1)
      elseif choice == "chiduye3" then
        player:setMark("chiduye_phase_" .. X, 1)
      elseif choice == "chiduye4" then
        room:moveCards({
          ids = { card.id },
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

return chiduye
