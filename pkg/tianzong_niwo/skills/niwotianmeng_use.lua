-- 殄梦·殁：把一张“殁”当任意单体伤害牌使用或打出。
-- 名字以 “&” 结尾：不占武将牌技能栏，由【殄梦】的 addAcquireEffect 授予本人。
local niwotianmeng_use = fk.CreateSkill{
  name = "niwotianmeng_use&",
}

Fk:loadTranslationTable{
  ["niwotianmeng_use&"] = "殄梦·殁",
  [":niwotianmeng_use&"] = "你可以将你的一张“殁”当任意单体伤害牌使用或打出。",
  ["#niwotianmeng_use&"] = "殄梦：选择一张“殁”和要视为使用的单体伤害牌",
}

local CARD_MARK = "@@niwo_mo"
local OWNER_MARK = "niwo_mo_owner"

local function my_mo(player)
  return table.filter(player:getCardIds("hej"), function(id)
    local card = Fk:getCardById(id)
    return card:getMark(CARD_MARK) > 0 and card:getMark(OWNER_MARK) == player.id
  end)
end

local function names(player)
  local result = table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card and card.is_damage_card and not card.multiple_targets and
      card.skill:getMaxTargetNum(player) <= 1
  end)
  return player:getViewAsCardNames(niwotianmeng_use.name, result)
end

niwotianmeng_use:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwotianmeng_use&",
  expand_pile = function(self, player) return my_mo(player) end,
  interaction = function(self, player)
    local choices = names(player)
    if #choices > 0 then return UI.CardNameBox{ choices = choices, all_choices = choices } end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(my_mo(player), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = niwotianmeng_use.name
    return card
  end,
  -- 出牌阶段不单独占一个转化按钮：转化统一走【殄梦】active 按钮里的二选一选项。
  -- 这里只保留回合外的响应（打出殁牌）。askToUseVirtualCard 显式指定本技能名，不受此开关影响。
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    return #my_mo(player) > 0 and #names(player) > 0
  end,
})

return niwotianmeng_use
