-- chitianshi.lua (恬适)
-- 锁定技，其他角色于回合内对你使用的首张牌名字数不小于X的牌对你无效；
-- 该牌结算后，你视为使用之。X 为你当前的体力值。
local chitianshi = fk.CreateSkill{
  name = "chitianshi",
  tags = { Skill.Compulsory },
  description = ":chitianshi",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chitianshi"] = "恬适",
  [":chitianshi"] = "锁定技，其他角色于回合内对你使用的首张牌名字数不小于X的牌对你无效，然后你视为使用之。（X为你当前的体力值）",
  ["#chitianshi-use"] = "恬适：视为使用结算后的牌",
}

-- “每名其他角色每回合首张符合的牌”用 mark 记录，mark 名带 -turn 由引擎每回合自动清空。
-- 无效化在 CardEffecting（结算前），视为使用在 CardEffectFinished（结算后）。
local function first_card_mark(from)
  return "chitianshi_first-" .. tostring(from.id) .. "-turn"
end

chitianshi:addEffect(fk.CardEffecting, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.from and data.from ~= player and
      data.card and
      player:getMark(first_card_mark(data.from)) == 0 and
      data.card:getNameLength(true) >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.nullified = true
    -- 记录该来源本回合的首张符合牌；结算后 effect 据此“视为使用”
    room:setPlayerMark(player, first_card_mark(data.from), 1)
    room:setPlayerMark(player, "chitianshi_pending-" .. tostring(data.from.id) .. "-turn", data.card.name)
  end,
})

chitianshi:addEffect(fk.CardEffectFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from ~= player and player:hasSkill(self.name) and
      data.card and
      player:getMark("chitianshi_pending-" .. tostring(data.from.id) .. "-turn") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pending_mark = "chitianshi_pending-" .. tostring(data.from.id) .. "-turn"
    local card_name = player:getMark(pending_mark)
    room:setPlayerMark(player, pending_mark, 0)
    if card_name and card_name ~= 0 then
      room:askToUseVirtualCard(player, {
        name = card_name,
        skill_name = self.name,
        prompt = "#chitianshi-use",
        cancelable = true,
      })
    end
  end,
})

return chitianshi
