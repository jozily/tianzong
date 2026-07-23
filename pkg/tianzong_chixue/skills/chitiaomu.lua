-- chitiaomu.lua (迢目)
local chitiaomu = fk.CreateSkill{
  name = "chitiaomu",
  description = ":chitiaomu",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chitiaomu"] = "迢目",
  [":chitiaomu"] = "每回合限一次，当你需要使用或打出一张基本牌或普通锦囊牌时，你可以从弃牌堆随机获得一张牌名字数或合法目标相同的牌视为使用或打出之。若两张牌牌名相同，本技能使用次数+1。",
}

chitiaomu:addEffect(fk.CardRequiredRespond, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data and data.card_type and
      (data.card_type == Card.TypeBasic or data.card_type == Card.TypeTrick)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local discardPile = room.discard_pile
    
    local candidates = {}
    for _, card in ipairs(discardPile) do
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        table.insert(candidates, card)
      end
    end
    
    if #candidates > 0 then
      local selected = candidates[math.random(1, #candidates)]
      room:askToUseVirtualCard(
        player,
        {
          name = selected.name,
          skill_name = skillName,
        }
      )
    end
  end,
})

return chitiaomu
