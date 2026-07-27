local niwotianmeng = fk.CreateSkill{
  name = "niwotianmeng",
  related_skills = { "niwotianmeng_mark" },
}
local CARD_MARK = "@@niwotianmeng"

local function damage_names(player)
  return player:getViewAsCardNames(niwotianmeng.name, table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card.is_damage_card and not card.multiple_targets and not card.is_passive
  end))
end

niwotianmeng:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwotianmeng",
  expand_pile = function(self, player) return player:getCardIds("he") end,
  interaction = function(self, player)
    local names = damage_names(player)
    if #names > 0 then return UI.CardNameBox{ choices = names, all_choices = names } end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("he"), to_select)
      and Fk:getCardById(to_select):getMark(CARD_MARK) > 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = niwotianmeng.name
    card:addSubcard(cards[1])
    return card
  end,
})

Fk:loadTranslationTable{
  [CARD_MARK] = "殁",
  ["#niwotianmeng-invoke"] = "天梦：是否标记你与另一名角色各一张牌为“殁”？",
  ["#niwotianmeng-choose"] = "天梦：选择一名有牌的其他角色",
  ["#niwotianmeng-card"] = "天梦：选择 %dest 的一张牌标记为“殁”",
  ["#niwotianmeng"] = "天梦：将一张“殁”当任意单体伤害牌使用或打出",
}
return niwotianmeng
