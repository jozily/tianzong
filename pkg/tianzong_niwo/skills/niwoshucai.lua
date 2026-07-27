local niwoshucai = fk.CreateSkill{
  name = "niwoshucai",
}

local ROUND_MARK = "niwoshucai_suits-round"
local SHOW_MARK = "@niwoshucai-round"
local SUIT_SYMBOLS = {
  log_spade = "♠",
  log_heart = "♥",
  log_club = "♣",
  log_diamond = "♦",
}

local function is_lowest_or_tied(room, player)
  return table.every(room.alive_players, function(p)
    return player:getHandcardNum() <= p:getHandcardNum()
  end)
end

local function get_available_suits(player)
  local used = player:getTableMark(ROUND_MARK)
  local hand = player:getCardIds("h")
  local suits = table.filter({"log_spade", "log_heart", "log_club", "log_diamond"}, function(suit)
    return not table.contains(used, suit) and table.find(hand, function(id)
      return Fk:getCardById(id):getSuitString(true) == suit and not player:prohibitDiscard(id)
    end)
  end)
  return suits
end

niwoshucai:addEffect("viewas", {
  pattern = "jink",
  prompt = "#niwoshucai",

  interaction = function(self, player)
    local suits = get_available_suits(player)
    if #suits == 0 then return end

    local names = player:getViewAsCardNames(niwoshucai.name, {"jink"})
    if #names > 0 then
      return UI.CardNameBox {
        choices = names,
        all_choices = {"jink"},
      }
    end
  end,

  card_filter = Util.FalseFunc,

  view_as = function(self, player, cards)
    if not self.interaction or not self.interaction.data then 
      return nil 
    end
    local card_name = self.interaction.data
    if type(card_name) ~= "string" then
      return nil
    end
    local c = Fk:cloneCard(card_name)
    if not c then return nil end
    c.skillName = niwoshucai.name
    return c
  end,

  before_use = function(self, player, use)
    local room = player.room
    local hand = player:getCardIds("h")
    if #hand == 0 then return "" end

    player:showCards(hand)

    local suits = get_available_suits(player)
    if #suits == 0 then return "" end

    local choice = room:askToChoice(player, {
      choices = suits,
      skill_name = niwoshucai.name,
      prompt = "#niwoshucai-suit",
    })

    local ids = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id):getSuitString(true) == choice and not player:prohibitDiscard(id)
    end)

    if #ids == 0 then return "" end

    room:throwCard(ids, niwoshucai.name, player, player)
    room:addTableMark(player, ROUND_MARK, choice)
    local symbols = table.map(player:getTableMark(ROUND_MARK), function(suit)
      return SUIT_SYMBOLS[suit] or suit
    end)
    room:setPlayerMark(player, SHOW_MARK, table.concat(symbols))

    if not player.dead and is_lowest_or_tied(room, player) then
      local ids2 = room:getNCards(2, "bottom")
      if #ids2 > 0 then
        room:obtainCard(player, ids2, false, fk.ReasonPrey, player, niwoshucai.name)
      end
    end
  end,
  enabled_at_play = function(self, player)
    return #get_available_suits(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return #get_available_suits(player) > 0
  end,
})

Fk:loadTranslationTable{
  ["#niwoshucai"] = "殊彩：选择要视为使用的牌",
  ["#niwoshucai-suit"] = "殊彩：选择一种花色弃置你的所有该花色的手牌",
}

return niwoshucai
