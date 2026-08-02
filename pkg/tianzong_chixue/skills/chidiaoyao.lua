local chidiaoyao = fk.CreateSkill{
  name = "chidiaoyao",
}

Fk:addQmlMark{
  name = "chidiaoyao_top",
  how_to_show = function(name, value, p)
    return tostring(value)
  end,
  qml_data = function(name, value, p)
    if type(value) ~= "number" or value < 1 then return {} end
    local drawPile = Fk:currentRoom().draw_pile
    local cards = {}
    for i = 1, math.min(value, #drawPile), 1 do
      table.insert(cards, drawPile[i])
    end
    return cards
  end,
  qml_path = function(name, value, p)
    if Self:isBuddy(p) and p:hasSkill(chidiaoyao.name) and value > 0 then
      return "packages/utility/qml/ViewPile"
    end
    return ""
  end,
}

Fk:addQmlMark{
  name = "chidiaoyao_bottom",
  how_to_show = function(name, value, p)
    return tostring(value)
  end,
  qml_data = function(name, value, p)
    if type(value) ~= "number" or value < 1 then return {} end
    local drawPile = Fk:currentRoom().draw_pile
    local cards = {}
    local n = math.min(value, #drawPile)
    for i = #drawPile, math.max(#drawPile - n + 1, 1), -1 do
      table.insert(cards, drawPile[i])
    end
    return cards
  end,
  qml_path = function(name, value, p)
    if Self:isBuddy(p) and p:hasSkill(chidiaoyao.name) and value > 0 then
      return "packages/utility/qml/ViewPile"
    end
    return ""
  end,
}

-- 每回合结束都清除显示；再次发动朔闻才重新显示
chidiaoyao:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chidiaoyao.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[chidiaoyao_top]", 0)
    room:setPlayerMark(player, "@[chidiaoyao_bottom]", 0)
  end,
})

return chidiaoyao
