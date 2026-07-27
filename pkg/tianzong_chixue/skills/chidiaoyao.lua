local chidiaoyao = fk.CreateSkill{
  name = "chidiaoyao",
}

Fk:addQmlMark{
  name = "chidiaoyao_top",
  how_to_show = function(name, value, p)
    return tostring(value)
  end,
  qml = function(name, value, p)
    if type(value) ~= "number" or value < 1 or not Self:isBuddy(p) or not p:hasSkill(chidiaoyao.name) then
      return nil
    end
    local drawPile = Fk:currentRoom().draw_pile
    local cards = {}
    for i = 1, math.min(value, #drawPile), 1 do
      table.insert(cards, drawPile[i])
    end
    return {
      uri = "LunarLtk.Pages.InfoPopups",
      name = "ViewPile",
      prop = { ids = cards },
    }
  end,
}

Fk:addQmlMark{
  name = "chidiaoyao_bottom",
  how_to_show = function(name, value, p)
    return tostring(value)
  end,
  qml = function(name, value, p)
    if type(value) ~= "number" or value < 1 or not Self:isBuddy(p) or not p:hasSkill(chidiaoyao.name) then
      return nil
    end
    local drawPile = Fk:currentRoom().draw_pile
    local cards = {}
    local n = math.min(value, #drawPile)
    for i = #drawPile, math.max(#drawPile - n + 1, 1), -1 do
      table.insert(cards, drawPile[i])
    end
    return {
      uri = "LunarLtk.Pages.InfoPopups",
      name = "ViewPile",
      prop = { ids = cards },
    }
  end,
}

chidiaoyao:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chidiaoyao.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[chidiaoyao_top]", 1)
    room:setPlayerMark(player, "@[chidiaoyao_bottom]", 1)
    local yang = player:getSwitchSkillState("chishuowen") == fk.SwitchYang
    room:setPlayerMark(player, "@[chishuowen_yang]", yang and 1 or 0)
    room:setPlayerMark(player, "@[chishuowen_yin]", yang and 0 or 1)
  end,
})

chidiaoyao:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chidiaoyao.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local extra = player:getMark("chishuowen_count-turn")
    if type(extra) ~= "number" then extra = 0 end
    room:setPlayerMark(player, "@[chidiaoyao_top]", 1 + extra)
    room:setPlayerMark(player, "@[chidiaoyao_bottom]", 1 + extra)
    local yang = player:getSwitchSkillState("chishuowen") == fk.SwitchYang
    room:setPlayerMark(player, "@[chishuowen_yang]", yang and 1 or 0)
    room:setPlayerMark(player, "@[chishuowen_yin]", yang and 0 or 1)
  end,
})

chidiaoyao:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(chidiaoyao.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[chidiaoyao_top]", 1)
    room:setPlayerMark(player, "@[chidiaoyao_bottom]", 1)
    local yang = player:getSwitchSkillState("chishuowen") == fk.SwitchYang
    room:setPlayerMark(player, "@[chishuowen_yang]", yang and 1 or 0)
    room:setPlayerMark(player, "@[chishuowen_yin]", yang and 0 or 1)
  end,
})

return chidiaoyao
