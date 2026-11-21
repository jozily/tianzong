local chifeishi = fk.CreateSkill{ name = "chifeishi" }

-- 红色牌取手牌与装备区；展示至多两张，不足两张则全部展示
local function getRedCards(p)
  return table.filter(p:getCardIds("he"), function(id)
    return Fk:getCardById(id).color == Card.Red
  end)
end

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chifeishi.name)
      and #table.filter(player.room:getOtherPlayers(player), function(p)
        return #getRedCards(p) > 0
      end) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(player.room:getOtherPlayers(player), function(p)
      return #getRedCards(p) > 0
    end)
    local chosen = player.room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 2,
      skill_name = chifeishi.name, prompt = "#chifeishi-choose", cancelable = true,
    })
    if #chosen > 0 then
      event:setCostData(self, { tos = chosen })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room, shown = player.room, {}
    for _, p in ipairs(event:getCostData(self).tos) do
      local reds = getRedCards(p)
      local cards = {}
      for i = 1, math.min(2, #reds) do
        table.insert(cards, reds[i])
      end
      if #cards > 0 then
        p:showCards(cards)
        table.insertTable(shown, cards)
      end
    end
    if #shown == 0 then return end
    local chosen = room:askToCards(player, {
      min_num = 1, max_num = 1, pattern = tostring(Exppattern{ id = shown }),
      expand_pile = shown,
      -- 关键修复：choose_cards_skill 对处于装备区的牌，只有 include_equip 为真时才允许选中。
      -- 展示牌里含红色装备时，原先未设此项导致“展示了却拿不到”。
      include_equip = true,
      skill_name = chifeishi.name,
      prompt = "#chifeishi-gain", cancelable = false,
    })
    if #chosen > 0 and room:getCardArea(chosen[1]) ~= Card.Void then
      room:obtainCard(player, chosen[1], true, fk.ReasonPrey, player, chifeishi.name)
    end
  end,
}
chifeishi:addEffect(fk.DamageCaused, spec)
chifeishi:addEffect(fk.DamageInflicted, spec)

return chifeishi
