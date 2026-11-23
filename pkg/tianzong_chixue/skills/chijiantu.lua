local chijiantu = fk.CreateSkill{
  name = "chijiantu",
  tags = { Skill.Switch, Skill.Compulsory },
}

local SUITS_MARK = "chijiantu_suits-turn"

-- 花色 mark 显示：与调风一致，把已用花色（数字）转成扑克花色符号，直观提示本回合用过哪些花色
local function suit_symbol(s)
  if s == Card.Spade then return "♠" end
  if s == Card.Heart then return "♥" end
  if s == Card.Club then return "♣" end
  if s == Card.Diamond then return "♦" end
  return ""
end

Fk:addQmlMark{
  name = "chijiantu",
  how_to_show = function(_, value, p)
    if not p then return "" end
    local suits = p:getTableMark(SUITS_MARK)
    if type(suits) ~= "table" or #suits == 0 then return "" end
    -- 名字前缀由翻译键 ["@[chijiantu]"] 提供，此处只返回花色，避免重复
    return table.concat(table.map(suits, suit_symbol), "/")
  end,
  qml_data = function() return {} end,
  qml_path = function() return "" end,
}

Fk:loadTranslationTable{
  ["chijiantu"] = "蹇途",
  [":chijiantu"] = "转换技，锁定技，当你于回合内首次使用一种花色的单体目标牌指定手牌数不大于你的角色时，此牌视为：①闪电；②过河拆桥；对其使用。",
}

chijiantu:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(chijiantu.name) or not data.card or
      data.card.suit == Card.NoSuit or #data.tos ~= 1 then return false end
    local to = data.tos[1]
    return to and to:getHandcardNum() <= player:getHandcardNum() and
      not table.contains(player:getTableMark(SUITS_MARK), data.card.suit)
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { state = player:getSwitchSkillState(chijiantu.name) })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMarkIfNeed(player, SUITS_MARK, data.card.suit)
    -- 触发花色 mark 界面重绘（how_to_show 读取 SUITS_MARK）
    room:setPlayerMark(player, "@[chijiantu]", 1)

    local state = event:getCostData(self).state
    local is_lightning = state == fk.SwitchYang
    local name = is_lightning and "lightning" or "dismantlement"
    local suit, number = data.card.suit, data.card.number
    -- 保留原牌实体作为子卡：延时锦囊必须携带 realCardIds 才能被置入判定区，
    -- 否则核心 usecard.lua 因 #realCardIds==0 直接放弃，闪电消失且无效果。
    local subids = data.card.subcards
    if #subids == 0 and data.card.id and data.card.id >= 0 then
      subids = { data.card.id }
    end
    local card = Fk:cloneCard(name, suit, number)
    card.skillName = chijiantu.name
    if #subids > 0 then card:addSubcards(subids) end
    data.card = card
  end,
})

-- 回合开始清除花色 mark 显示（SUITS_MARK 由 -turn 后缀自动清，这里清显示触发 mark）
chijiantu:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@[chijiantu]") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[chijiantu]", 0)
  end,
})

return chijiantu
