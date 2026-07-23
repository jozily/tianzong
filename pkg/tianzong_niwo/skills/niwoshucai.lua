local niwoshucai = fk.CreateSkill{
  name = "niwoshucai",
}

local ROUND_MARK = "@$niwoshucai-round"

local function suit_symbol(s)
  if s == "log_spade" then return "♠" end
  if s == "log_heart" then return "♥" end
  if s == "log_club" then return "♣" end
  if s == "log_diamond" then return "♦" end
  return s
end

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
      return Fk:getCardById(id):getSuitString(true) == suit
    end)
  end)
  return suits
end

niwoshucai:addEffect("viewas", {
  pattern = "jink,fire__slash",
  prompt = "#niwoshucai",

  interaction = function(self, player)
    local suits = get_available_suits(player)
    if #suits == 0 then return end

    local names = player:getViewAsCardNames(niwoshucai.name, {"jink", "fire__slash"})
    if #names > 0 then
      return UI.CardNameBox {
        choices = names,
        all_choices = {"jink", "fire__slash"},
      }
    end
  end,

  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },

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

    if not player.dead and is_lowest_or_tied(room, player) then
      local ids2 = room:getNCards(2, "bottom")
      if #ids2 > 0 then
        room:obtainCard(player, ids2, false, fk.ReasonPrey, player, niwoshucai.name)
      end
    end
  end,
})

niwoshucai:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoshucai.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, ROUND_MARK, 0)
  end,
})

Fk:loadTranslationTable{
  ["#niwoshucai"] = "殊彩：选择要视为使用的牌",
  ["#niwoshucai-suit"] = "殊彩：选择一种花色弃置你的所有该花色的手牌",
}

return niwoshucai
