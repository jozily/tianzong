local yuanpu = require "packages.tianzong.pkg.tianzong_geshi.skills.tianzong_geshi__yuanpu"

local SUIT_SYMBOL = {
  [Card.Spade] = "♠",
  [Card.Club] = "♣",
  [Card.Heart] = "♥",
  [Card.Diamond] = "♦",
}

-- 候选只取元瀑当前花色：背水永久移除后不会出现，虹梦不会再把它恢复回来
local SUIT_CHOICE = {
  [Card.Spade] = "tianzong_geshi__hongmeng_spade",
  [Card.Club] = "tianzong_geshi__hongmeng_club",
  [Card.Heart] = "tianzong_geshi__hongmeng_heart",
  [Card.Diamond] = "tianzong_geshi__hongmeng_diamond",
}

-- 全部四种花色作为 all_choices：选择框始终列出四色，四色时也弹框而非直接返回
local ALL_SUIT_CHOICES = {
  SUIT_CHOICE[Card.Spade],
  SUIT_CHOICE[Card.Club],
  SUIT_CHOICE[Card.Heart],
  SUIT_CHOICE[Card.Diamond],
}

local hongmeng = fk.CreateSkill{
  name = "tianzong_geshi__hongmeng",
  dynamic_desc = function(self, player)
    local suits = yuanpu.getSuits(player)
    local syms = {}
    for _, s in ipairs(suits) do
      local sym = SUIT_SYMBOL[s]
      if sym then table.insert(syms, sym) end
    end
    return "tianzong_geshi__hongmeng_inner" .. ":" .. tostring(#suits) .. ":" .. table.concat(syms, "")
  end,
}

hongmeng:addEffect(fk.Damaged, {
  anim_type = "drawcards",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hongmeng.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = hongmeng.name,
      prompt = "#tianzong_geshi__hongmeng-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = yuanpu.getSuits(player)
    if #suits == 0 then return end
    local choices = table.map(suits, function(s) return SUIT_CHOICE[s] end)
    -- 必须选满当前元瀑花色数：未被背水移除时为 4，移除 n 个后为 (4-n) 个
    -- all_choices 传全部四色：即使四色时 choices==min_num，也会弹出选择框让玩家亲手确认，不再直接摸牌
    local selected = room:askToChoices(player, {
      choices = choices,
      all_choices = ALL_SUIT_CHOICES,
      min_num = #suits,
      max_num = #suits,
      cancelable = false,
      skill_name = hongmeng.name,
      prompt = "#tianzong_geshi__hongmeng-choose-suit",
    })
    if #selected == 0 then return end
    local chosen = {}
    for _, c in ipairs(selected) do
      for s, key in pairs(SUIT_CHOICE) do
        if key == c then
          table.insert(chosen, s)
          break
        end
      end
    end
    if #chosen == 0 then return end
    yuanpu.setSuits(room, player, chosen)
    player:drawCards(#chosen, hongmeng.name)
  end,
})

Fk:loadTranslationTable{
  -- 矜名式动态描述：{1}=当前元瀑花色数，{2}=当前花色符号
  [":tianzong_geshi__hongmeng_inner"] = "当你受到伤害后，你可以从当前“元瀑”花色（现有{1}种：{2}）中选满这些花色重新构成“元瀑”，然后摸X张牌（X为选择的花色数，即{1}）。被“背水”永久移除的花色不会出现在选择中。",
}

return hongmeng
