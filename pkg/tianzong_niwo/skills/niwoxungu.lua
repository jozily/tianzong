local niwoxungu = fk.CreateSkill{
  name = "niwoxungu",
}

-- “风”：置于武将牌旁的私人牌堆，可以如手牌般使用或打出
local WIND = "niwoxungu_wind&"
local USED = "niwoxungu_used-turn"

niwoxungu:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoxungu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local winds = player:getPile(WIND)
    if #winds > 0 then room:throwCard(winds, niwoxungu.name, player, player) end
    if player.dead then return end

    local judged, names, gain, rest = {}, {}, {}, {}
    local dup = false
    while not dup do
      local judge = { who = player, reason = niwoxungu.name }
      room:judge(judge)
      local card = judge.card
      if not card then break end
      table.insert(judged, card.id)
      if table.contains(names, card.name) then
        dup = card.id
        break
      end
      table.insert(names, card.name)
      if #judged >= 40 then break end
    end
    if #judged == 0 then return end

    -- 装备牌与二次出现的牌收入手牌，其余留在武将牌旁
    for _, id in ipairs(judged) do
      local card = Fk:getCardById(id, true)
      if card then
        if id == dup or card.type == Card.TypeEquip then
          table.insert(gain, id)
        else
          table.insert(rest, id)
        end
      end
    end

    if #gain > 0 then
      room:obtainCard(player, gain, false, fk.ReasonPrey, player, niwoxungu.name)
    end
    if #rest > 0 and player:isAlive() then
      player:addToPile(WIND, rest, true, niwoxungu.name, player)
      -- 给每张“风”打标记，供衔望识别其进入弃牌堆的事件
      for _, id in ipairs(rest) do room:setCardMark(Fk:getCardById(id), "@@niwo_wind", 1) end
    end
  end,
})

-- 每回合限一次，视为使用或打出一张“风”
niwoxungu:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwoxungu-use",
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    -- 排除装备牌：避免装备区被自动展开后，装备牌混进“风”的选牌范围
    pattern = ".|.|.|^equip",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local origin = Fk:getCardById(cards[1])
    if not origin then return nil end
    local card = Fk:cloneCard(origin.name, origin.suit, origin.number)
    card:addSubcards(cards)
    card.skillName = niwoxungu.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, USED, 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark(USED) == 0 and #player:getPile(WIND) > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark(USED) == 0 and #player:getPile(WIND) > 0
  end,
})

Fk:loadTranslationTable{
  [WIND] = "风",
  ["#niwoxungu-use"] = "寻古：使用或打出一张“风”",
}

return niwoxungu
