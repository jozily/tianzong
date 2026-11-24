local yuanpu = fk.CreateSkill{ name = "tianzong_geshi__yuanpu", tags = { Skill.Compulsory } }

local SUIT_MARK = "tianzong_geshi__yuanpu_suits"
-- 默认花色与 mark 显示顺序统一为 ♥/♠/♦/♣
local DEFAULT_SUITS = { Card.Heart, Card.Spade, Card.Diamond, Card.Club }
local DISPLAY_SUITS = { Card.Heart, Card.Spade, Card.Diamond, Card.Club }

local function suit_symbol(s)
  if s == Card.Spade then return "♠" end
  if s == Card.Heart then return "♥" end
  if s == Card.Club then return "♣" end
  if s == Card.Diamond then return "♦" end
  return ""
end

-- 元瀑花色集：未设置时默认四花色；虹梦重设后按新集合
function yuanpu.getSuits(player)
  local suits = player:getTableMark(SUIT_MARK)
  if type(suits) ~= "table" or #suits == 0 then return DEFAULT_SUITS end
  return suits
end

function yuanpu.setSuits(room, player, suits)
  room:setPlayerMark(player, SUIT_MARK, suits)
  room:setPlayerMark(player, "@[tianzong_geshi__yuanpu]", 1) -- 触发 mark 重绘
end

-- 矜名式动态描述：描述里只列出当前可触发的花色；背水永久移除一个后，
-- 该花色不再出现在描述中，触发花色数相应减少。
yuanpu.dynamic_desc = function(self, player)
  local suits = yuanpu.getSuits(player)
  local syms = {}
  for _, s in ipairs(DISPLAY_SUITS) do
    if table.contains(suits, s) then table.insert(syms, suit_symbol(s)) end
  end
  return "tianzong_geshi__yuanpu_inner" .. ":" .. table.concat(syms, "/")
end

Fk:addQmlMark{
  name = "tianzong_geshi__yuanpu",
  how_to_show = function(_, value, p)
    if not p then return "" end
    local suits = p:getTableMark(SUIT_MARK)
    if type(suits) ~= "table" or #suits == 0 then suits = DEFAULT_SUITS end
    -- 只显示当前元瀑花色数量（mark 名「元瀑」+ 数字 X）
    return tostring(#suits)
  end,
  qml_data = function() return {} end,
  qml_path = function() return "" end,
}

yuanpu:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yuanpu.name) then return false end
    if not data.card or data.card.suit == Card.NoSuit then return false end
    return table.contains(yuanpu.getSuits(player), data.card.suit)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local chosen = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      skill_name = yuanpu.name,
      prompt = "#tianzong_geshi__yuanpu-choose",
      cancelable = false,
    })
    if #chosen == 0 then return false end
    event:setCostData(self, { tos = chosen, suit = data.card.suit })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    local to, suit = cost.tos[1], cost.suit
    if not to:isAlive() then return end

    -- 选项1：弃置一张与触发牌花色相同的牌
    local same_ids = table.filter(to:getCardIds("he"), function(id)
      return Fk:getCardById(id).suit == suit
    end)
    local can_discard = #same_ids > 0
    local choices = {}
    if can_discard then table.insert(choices, "tianzong_geshi__yuanpu_discard") end
    table.insert(choices, "tianzong_geshi__yuanpu_damage")
    -- 背水须至少保留一个花色，否则空表会被 getSuits 当作未设置而回退默认四花色
    if can_discard and #yuanpu.getSuits(player) > 1 then table.insert(choices, "tianzong_geshi__yuanpu_backwater") end

    local sel = room:askToChoices(to, {
      choices = choices,
      min_num = 1,
      max_num = 1,
      cancelable = false,
      skill_name = yuanpu.name,
      prompt = "#tianzong_geshi__yuanpu-choice::" .. player.id,
    })
    local choice = sel[1]
    if not choice then return end

    -- 背水：由奇亚娜付出代价——永久移除一个【元瀑】花色，再强制依次执行选项1、2
    if choice == "tianzong_geshi__yuanpu_backwater" then
      local suits = yuanpu.getSuits(player)
      if #suits > 1 then
        local suit_choices = table.map(suits, function(s) return "tianzong_geshi__yuanpu_rm_" .. s end)
        local rm_sel = room:askToChoices(to, {
          choices = suit_choices,
          min_num = 1,
          max_num = 1,
          cancelable = false,
          skill_name = yuanpu.name,
          prompt = "#tianzong_geshi__yuanpu-rm-suit",
        })
        local rm = rm_sel[1]
        if rm then
          local rm_suit = tonumber((rm:gsub("tianzong_geshi__yuanpu_rm_", "")))
          local new_suits = table.filter(suits, function(s) return s ~= rm_suit end)
          yuanpu.setSuits(room, player, new_suits)
        end
      end
    end

    if choice == "tianzong_geshi__yuanpu_discard" or choice == "tianzong_geshi__yuanpu_backwater" then
      local dropped = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        pattern = tostring(Exppattern{ id = same_ids }),
        skill_name = yuanpu.name,
        prompt = "#tianzong_geshi__yuanpu-discard",
        cancelable = false,
      })
      if #dropped > 0 then room:throwCard(dropped, yuanpu.name, to, player) end
    end
    if choice == "tianzong_geshi__yuanpu_damage" or choice == "tianzong_geshi__yuanpu_backwater" then
      if to:isAlive() then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = yuanpu.name,
        }
      end
    end
  end,
})

Fk:loadTranslationTable{
  -- 矜名式动态描述：{1}=当前可触发的花色（背水永久移除后相应减少）
  [":tianzong_geshi__yuanpu_inner"] = "锁定技，当你使用{1}花色的牌结算完毕后，你令一名角色选择一项：1.弃置一张花色相同的牌；2.受到一点来自你的火焰伤害。背水：若剩余花色数不为1则永久移除一个“元瀑”可选数。",
}

return yuanpu
