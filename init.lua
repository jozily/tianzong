UI.TianzongCardNameBox = require("packages.tianzong.pkg.card_name_ui").create

local tianzong_niwo = require "packages/tianzong/pkg/tianzong_niwo"
local tianzong_chixue = require "packages/tianzong/pkg/tianzong_chixue"
local tianzong_cards = require "packages/tianzong/pkg/tianzong_cards"
local tianzong_toaru = require "packages/tianzong/pkg/tianzong_toaru"

-- 大梦仙尊头像资源载体：只作为头像图片 ID 注册，total_hidden 后不进选将框、
-- 也不在武将一览出现。getGeneralExtraPic 依赖 Fk.generals[id].package.extensionName
-- 定位图片，故 extensionName 设为 tianzong，对应 image/generals/avatar/ 下的原画。
local tianzong_avatar = Package:new("tianzong_avatar", Package.GeneralPack)
tianzong_avatar.extensionName = "tianzong"
local concealed_mengzhouxuan = General(tianzong_avatar, "concealed_mengzhouxuan", "wei", 3)
concealed_mengzhouxuan.total_hidden = true
Fk:loadTranslationTable {
  ["concealed_mengzhouxuan"] = "大梦仙尊",
  ["#concealed_mengzhouxuan"] = "专属头像",
}

require "packages/tianzong/pkg/runtime_translations"

return {
  tianzong_niwo,
  tianzong_chixue,
  tianzong_cards,
  tianzong_toaru,
  tianzong_avatar,
}
