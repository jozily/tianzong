-- chicixuan_viewas.lua
-- 辞玄的副技能：“视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌”。
-- 由 chicixuan 发动时授予，失去时收回，名字以 & 结尾，不进入武将技能栏。
local U = require "packages.utility.utility"

local chicixuan_viewas = fk.CreateSkill{
  name = "chicixuan_viewas&",
}

local USED = "chicixuan_used-turn"

local function available_names(player)
  local n = #U.GetRenPile(player.room)
  if n == 0 then return {} end
  local all = table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card and (card.type == Card.TypeBasic or card:isCommonTrick()) and card:getNameLength(true) == n
  end)
  return player:getViewAsCardNames(chicixuan_viewas.name, all)
end

chicixuan_viewas:addEffect("viewas", {
  pattern = ".",
  prompt = "#chicixuan-viewas",

  interaction = function(self, player)
    local names = available_names(player)
    if #names > 0 then
      return UI.TianzongCardNameBox{ choices = names, all_choices = names }
    end
  end,

  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {},
  },

  card_filter = Util.FalseFunc,

  view_as = function(self, player, cards)
    if #cards > 0 then return nil end
    local name = self.interaction and self.interaction.data
    if not name or Fk.all_card_types[name] == nil then return nil end
    local card = Fk:cloneCard(name)
    card.skillName = chicixuan_viewas.name
    return card
  end,

  before_use = function(self, player, use)
    player.room:setPlayerMark(player, USED, 1)
  end,

  enabled_at_play = function(self, player)
    if player:getMark(USED) ~= 0 then return false end
    if player.phase ~= Player.Play then return false end
    return #available_names(player) > 0
  end,

  enabled_at_response = function(self, player, response)
    if player:getMark(USED) ~= 0 then return false end
    return #available_names(player) > 0
  end,
})

Fk:loadTranslationTable{
  ["chicixuan_viewas&"] = "辞玄",
  [":chicixuan_viewas&"] = "视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌。",
  ["#chicixuan-viewas"] = "辞玄：视为使用或打出一张牌名字数等于“仁”区牌数的牌",
}

return chicixuan_viewas
