local chitiaofeng = fk.CreateSkill{ name = "chitiaofeng" }
local SUIT_MARK = "chitiaofeng_suits-phase"

-- 花色 mark 显示：把已用花色（数字）转成扑克花色符号，直观提示本阶段用过哪些花色
local function suit_symbol(s)
  if s == Card.Spade then return "♠" end
  if s == Card.Heart then return "♥" end
  if s == Card.Club then return "♣" end
  if s == Card.Diamond then return "♦" end
  return ""
end

Fk:addQmlMark{
  name = "chitiaofeng",
  how_to_show = function(_, value, p)
    if not p then return "" end
    local suits = p:getTableMark(SUIT_MARK)
    if type(suits) ~= "table" or #suits == 0 then return "" end
    return table.concat(table.map(suits, suit_symbol), "/")
  end,
  qml_data = function() return {} end,
  qml_path = function() return "" end,
}

local function suit_count(player)
  local suits = {}
  for _, id in ipairs(player:getCardIds("h")) do
    local suit = Fk:getCardById(id).suit
    if suit ~= Card.NoSuit then table.insertIfNeed(suits, suit) end
  end
  return #suits
end

chitiaofeng:addEffect("viewas", {
  pattern = "redistribute",
  prompt = "#chitiaofeng",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.suit ~= Card.NoSuit and not table.contains(player:getTableMark(SUIT_MARK), card.suit)
      and card:getNameLength(true) >= suit_count(player)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("redistribute")
    card.skillName = chitiaofeng.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    player:showCards(player:getCardIds("hej"))
    local card = Fk:getCardById(use.card.subcards[1])
    player.room:addTableMark(player, SUIT_MARK, card.suit)
    -- 触发花色 mark 界面重绘（how_to_show 读取 SUIT_MARK）
    player.room:setPlayerMark(player, "@[chitiaofeng]", 1)
    use.extra_data = use.extra_data or {}
    use.extra_data.chitiaofeng_x = suit_count(player)
  end,
  after_use = function(self, player, use)
    local x = use.extra_data and use.extra_data.chitiaofeng_x or 0
    if x > 0 and player:isAlive() then player:drawCards(x, chitiaofeng.name) end
  end,
  enabled_at_play = function(self, player)
    return table.find(player:getCardIds("he"), function(id)
      local card = Fk:getCardById(id)
      return card.suit ~= Card.NoSuit and not table.contains(player:getTableMark(SUIT_MARK), card.suit)
        and card:getNameLength(true) >= suit_count(player)
    end)
  end,
})

-- 回合开始清除花色 mark 显示（SUIT_MARK 由 -phase 后缀自动清，这里清显示触发 mark）
chitiaofeng:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@[chitiaofeng]") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[chitiaofeng]", 0)
  end,
})

return chitiaofeng
