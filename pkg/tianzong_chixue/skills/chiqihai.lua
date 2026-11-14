-- chiqihai.lua (歧海)
local U = require "packages.utility.utility"

local chiqihai = fk.CreateSkill{
  name = "chiqihai",
}

local function ren_types(room)
  local t = {}
  for _, id in ipairs(U.GetRenPile(room)) do
    t[Fk:getCardById(id).type] = true
  end
  return t
end

-- 选择者手牌/装备中，类型不在“仁”区的牌
local function puttable(who, room)
  local types = ren_types(room)
  return table.filter(who:getCardIds("he"), function(id)
    return not types[Fk:getCardById(id).type] and not who:prohibitDiscard(id)
  end)
end

-- “仁”区中可以对 to 使用的牌
local function usable_ren(room, owner, to)
  return table.filter(U.GetRenPile(room), function(id)
    return owner:canUseTo(Fk:getCardById(id), to)
  end)
end

local function ask_from_hand(room, who, cards, skill)
  if #cards == 0 then return nil end
  if #cards == 1 then return cards[1] end
  local ids = room:askToCards(who, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    cancelable = false,
    skill_name = skill,
    pattern = tostring(Exppattern{ id = cards }),
    expand_pile = cards,
    prompt = "#chiqihai-choose-card",
  })
  return ids[1]
end

local function ask_from_ren(room, who, cards, skill)
  if #cards == 0 then return nil end
  if #cards == 1 then return cards[1] end
  local ids = room:askToChooseCards(who, {
    target = who,
    min = 1,
    max = 1,
    flag = { card_data = { { "@$RenPile", cards } } },
    skill_name = skill,
    prompt = "#chiqihai-choose-card",
  })
  return #ids > 0 and ids[1] or nil
end

-- chooser：选择一项的人（伤害来源）；to：②中被指定的人
local function trigger_qihai(room, owner, chooser, to)
  local put_cards = puttable(chooser, room)
  local ren_cards = usable_ren(room, owner, to)
  local choices = {}
  if #put_cards > 0 then table.insert(choices, "chiqihai_put") end
  if #ren_cards > 0 then table.insert(choices, "chiqihai_use") end
  if #choices == 0 then return end

  local choice = room:askToChoice(chooser, {
    choices = choices,
    skill_name = chiqihai.name,
    prompt = "#chiqihai-choose",
  })

  if choice == "chiqihai_put" then
    local id = ask_from_hand(room, chooser, put_cards, chiqihai.name)
    if not id then return end
    U.AddToRenPile(chooser, id, chiqihai.name)
  else
    local id = ask_from_ren(room, chooser, ren_cards, chiqihai.name)
    if not id or not owner:isAlive() or not to:isAlive() then return end
    -- 仁区的牌离开仁区时，仁区触发器会自行从 banner 中剔除
    room:useCard {
      from = owner,
      tos = { to },
      card = Fk:getCardById(id),
    }
  end
end

chiqihai:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiqihai.name) and
      data.from and data.from ~= player and data.from:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = chiqihai.name, prompt = "#chiqihai-invoke" })
  end,
  on_use = function(self, event, target, player, data)
    -- 令伤害来源（data.from）选择一项，“对其使用”指对受伤者（data.to）使用
    trigger_qihai(player.room, player, data.from, data.to)
  end,
})

chiqihai:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(chiqihai.name) and
      data.to and data.to ~= player and data.to:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = chiqihai.name, prompt = "#chiqihai-invoke" })
  end,
  on_use = function(self, event, target, player, data)
    trigger_qihai(player.room, player, player, data.to)
  end,
})

Fk:loadTranslationTable{
  ["#chiqihai-invoke"] = "歧海：是否令伤害来源选择一项？",
  ["#chiqihai-choose"] = "歧海：选择一项",
  ["#chiqihai-choose-card"] = "歧海：选择一张牌",
  ["chiqihai_put"] = "将一张“仁”区没有的类型的牌置入“仁”区",
  ["chiqihai_use"] = "移除一张“仁”牌，视为对其使用",
}

return chiqihai
