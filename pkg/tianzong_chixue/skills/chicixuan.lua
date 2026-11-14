-- chicixuan.lua
-- 辞玄：转换技，每回合限一次，你可以
--   ①将至多三张牌置于“仁”区，然后摸等量的牌；
--   ②获得“仁”区至多三张牌。
-- “视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌”由副技能
-- chicixuan_viewas& 承担（本技能发动时授予，失去时收回）。
local U = require "packages.utility.utility"

local chicixuan = fk.CreateSkill{
  name = "chicixuan",
  tags = { Skill.Switch },
}

local USED = "chicixuan_used-turn"
local VIEWAS = "chicixuan_viewas&"

local function ren_count(player)
  return #U.GetRenPile(player.room)
end

chicixuan:addAcquireEffect(function(self, player)
  local room = player.room
  if room then
    room:handleAddLoseSkills(player, VIEWAS, nil, false, true)
  end
end)

chicixuan:addLoseEffect(function(self, player)
  local room = player.room
  if room then
    room:handleAddLoseSkills(player, "-" .. VIEWAS, nil, false, true)
  end
end)

chicixuan:addEffect("active", {
  anim_type = "support",
  prompt = "#chicixuan-invoke",
  card_num = 0,
  target_num = 0,

  can_use = function(self, player)
    if player:getMark(USED) ~= 0 then return false end
    if player:getSwitchSkillState(chicixuan.name) == fk.SwitchYang then
      return #player:getCardIds("he") > 0
    end
    return ren_count(player) > 0
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    -- 进入 on_use 时转换技标记已经翻转，取发动前的状态
    local yang = player:getSwitchSkillState(chicixuan.name, true) == fk.SwitchYang

    if yang then
      local cards = table.filter(player:getCardIds("he"), function(id)
        return not player:prohibitDiscard(id)
      end)
      if #cards == 0 then return end
      local ids = room:askToCards(player, {
        min_num = 0,
        max_num = math.min(3, #cards),
        include_equip = true,
        cancelable = true,
        skill_name = chicixuan.name,
        pattern = tostring(Exppattern{ id = cards }),
        prompt = "#chicixuan-ren-put",
        expand_pile = cards,
      })
      if #ids == 0 then return end
      room:setPlayerMark(player, USED, 1)
      U.AddToRenPile(player, ids, chicixuan.name)
      if player:isAlive() then player:drawCards(#ids, chicixuan.name) end
    else
      local ren = U.GetRenPile(room)
      if #ren == 0 then return end
      local ids = room:askToChooseCards(player, {
        target = player,
        min = 0,
        max = math.min(3, #ren),
        cancelable = true,
        flag = { card_data = { { "@$RenPile", ren } } },
        skill_name = chicixuan.name,
        prompt = "#chicixuan-ren-gain",
      })
      if #ids == 0 then return end
      room:setPlayerMark(player, USED, 1)
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, chicixuan.name, nil, true, player)
    end
  end,
})

Fk:loadTranslationTable{
  [":chicixuan_yang"] = "转换技，每回合限一次，你可以将至多三张牌置于“仁”区，然后摸等量的牌；" ..
    "或视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌。",
  [":chicixuan_yin"] = "转换技，每回合限一次，你可以获得“仁”区至多三张牌；" ..
    "或视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌。",
  ["#chicixuan-invoke"] = "辞玄：转换技，将至多三张牌置于“仁”区并摸等量的牌，或获得“仁”区至多三张牌",
  ["#chicixuan-ren-put"] = "辞玄：选择至多三张牌置入“仁”区",
  ["#chicixuan-ren-gain"] = "辞玄：选择获得“仁”区至多三张牌",
}

return chicixuan
