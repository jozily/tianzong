local __tianzong_card_name_ui = (function()
local M = {}

function M.create(spec)
  spec = type(spec) == "table" and spec or {}
  local choices = type(spec.choices) == "table" and spec.choices or {}
  if #choices == 0 then return end

  return UI.CardNameBox {
    choices = choices,
    all_choices = spec.all_choices or choices,
    default = spec.default,
  }
end

return M
end)()
UI.TianzongCardNameBox = __tianzong_card_name_ui.create

local tianzong_niwo = require "packages/tianzong/pkg/tianzong_niwo"
local tianzong_chixue = require "packages/tianzong/pkg/tianzong_chixue"
local tianzong_cards = require "packages/tianzong/pkg/tianzong_cards"
local tianzong_geshi = require "packages/tianzong/pkg/tianzong_geshi"

local __tianzong_runtime_trans = (function()
Fk:loadTranslationTable {
  ["#tianzong_toaru__cipao"] = "磁炮：请选择至少一张牌，视为使用一张雷【杀】",
}

return true
end)()

return {  
  tianzong_niwo,
  tianzong_chixue,
  tianzong_cards,
  tianzong_geshi,
}
