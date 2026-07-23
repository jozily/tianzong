-- chishanquan.lua (潸泉)
local chishanquan = fk.CreateSkill{
  name = "chishanquan",
  description = ":chishanquan",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local handCount = #player:getCardIds("h")
    local maxHp = player:getMaxHp()
    local diff = math.abs(handCount - maxHp)
    return "潸泉：手牌" .. handCount .. "vs体力" .. maxHp .. "→差值" .. diff
  end,
}

Fk:loadTranslationTable{
  ["chishanquan"] = "潸泉",
  [":chishanquan"] = "每回合限一次，你可以交换你的手牌数和体力上限，视为使用或打出一张牌名字数为二者差的基本牌或普通锦囊牌。",
}

chishanquan:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local skillName = self.name
    
    local handCount = #player:getCardIds("h")
    local maxHp = player:getMaxHp()
    local diff = math.abs(handCount - maxHp)
    
    if diff == 0 then return end
    
    local candidateCards = {}
    for _, card in ipairs(Fk.cards) do
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        local nameLength = card:getNameLength(true)
        if nameLength == diff then
          table.insert(candidateCards, card)
        end
      end
    end
    
    if #candidateCards > 0 then
      local selectedCard = candidateCards[math.random(1, #candidateCards)]
      room:askToUseVirtualCard(
        player,
        {
          name = selectedCard.name,
          skill_name = skillName,
        }
      )
    end
  end,
})

return chishanquan
