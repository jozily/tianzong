local U = require "packages.utility.utility"
local juben = fk.CreateSkill { name = "tianzong_toaru__juben" }

-- 剧本的三类记录（牌名、角色、花色）合并为一个标记
local JB = "@[juben]"
local suits = { log_spade = Card.Spade, log_heart = Card.Heart, log_club = Card.Club, log_diamond = Card.Diamond }

Fk:addQmlMark {
  name = "juben",
  how_to_show = function(_, value)
    if type(value) ~= "table" then return "" end
    local n = #(value.names or {}) + #(value.pids or {}) + #(value.suits or {})
    return n > 0 and tostring(n) or ""
  end,
  qml = function(mark, value)
    local items, suits_sym = {}, { [Card.Spade] = "♠", [Card.Heart] = "♥", [Card.Club] = "♣", [Card.Diamond] = "♦" }
    if type(value) == "table" then
      local names, generals, suit_list = value.names or {}, value.generals or {}, value.suits or {}
      if #names > 0 then
        table.insert(items, "【牌名】")
        for _, name in ipairs(names) do table.insert(items, Fk:translate(name)) end
      end
      if #generals > 0 then
        table.insert(items, "【角色】")
        local seen = {}
        for _, general in ipairs(generals) do
          local text = Fk:translate(general)
          if not seen[text] then
            seen[text] = true
            table.insert(items, text)
          end
        end
      end
      if #suit_list > 0 then
        table.insert(items, "【花色】")
        for _, suit in ipairs(suit_list) do table.insert(items, suits_sym[suit] or tostring(suit)) end
      end
    end
    return {
      url = "packages/tianzong/qml/JubenMarkBox.qml",
      prop = { name = mark, value = items },
    }
  end,
}

-- 读取时统一补全字段，写入时始终换新表，避免共享表被就地改写
local function markOf(player)
  local m = player:getTableMark(JB)
  return {
    names = m.names or {},
    pids = m.pids or {},
    generals = m.generals or {},
    suits = m.suits or {},
    -- 永久去重：记录过的角色 id 永不移除，即使该条记录被消耗
    allPids = m.allPids or {},
  }
end

local function save(room, player, m)
  room:setPlayerMark(player, JB, m)
end

local function push(list, value)
  local t = table.simpleClone(list)
  if table.insertIfNeed(t, value) then return t end
  return list
end

local function pull(list, value)
  local t = table.simpleClone(list)
  if table.removeOne(t, value) then return t end
  return list
end

local function generalOf(player)
  return player.general ~= "anjiang" and player.general or player.deputyGeneral
end

local function indexOf(list, value)
  for i, v in ipairs(list) do
    if v == value then return i end
  end
end

local function hasName(player, name)
  return table.contains(markOf(player).names, name)
end

local function hasSuit(player, suit)
  return table.contains(markOf(player).suits, suit)
end

local function recordedPlayer(player, to)
  if not to then return end
  local m = markOf(player)
  if table.contains(m.pids, to.id) then return to end
end

-- 消耗一条记录，并摸两张牌
local function take(room, player, kind, value)
  local m = markOf(player)
  if kind == "name" then
    m.names = pull(m.names, value)
  elseif kind == "suit" then
    m.suits = pull(m.suits, value)
  else
    local i = indexOf(m.pids, value)
    if i then
      local pids, generals = table.simpleClone(m.pids), table.simpleClone(m.generals)
      table.remove(pids, i)
      table.remove(generals, i)
      m.pids, m.generals = pids, generals
    end
  end
  save(room, player, m)
  if not player.dead then player:drawCards(2, juben.name) end
end

local function record(room, player)
  local m = markOf(player)
  local names = table.filter(Fk:getAllCardNames("bt"), function(n) return not table.contains(m.names, n) end)
  -- 已记录过的角色（含被消耗过的）不能再被记录
  local people = table.filter(room.alive_players, function(p)
    return not table.contains(m.pids, p.id) and not table.contains(m.allPids, p.id)
  end)
  local suit_names = table.filter({ "log_spade", "log_heart", "log_club", "log_diamond" }, function(s)
    return not table.contains(m.suits, suits[s])
  end)
  if #names > 0 then
    local name = U.askForChooseCardNames(room, player, names, 1, 1, juben.name, "#tianzong_toaru__juben-name", names, false)[1]
    if name then m.names = push(m.names, name) end
  end
  if #people > 0 then
    local who = room:askToChoosePlayers(player, { targets = people, min_num = 1, max_num = 1,
      skill_name = juben.name, prompt = "#tianzong_toaru__juben-player", cancelable = false })[1]
    if who and not table.contains(m.pids, who.id) and not table.contains(m.allPids, who.id) then
      m.pids = push(m.pids, who.id)
      m.allPids = push(m.allPids, who.id)
      m.generals = push(m.generals, generalOf(who))
    end
  end
  if #suit_names > 0 then
    local suit = room:askToChoice(player, { choices = suit_names, skill_name = juben.name,
      prompt = "#tianzong_toaru__juben-suit" })
    if suits[suit] then m.suits = push(m.suits, suits[suit]) end
  end
  save(room, player, m)
end

local record_spec = {
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, { skill_name = juben.name, prompt = "#tianzong_toaru__juben-record" })
  end,
  on_use = function(self, event, target, player) record(player.room, player) end,
}
juben:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(juben.name)
  end,
  on_cost = record_spec.on_cost, on_use = record_spec.on_use,
})
juben:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(juben.name) and player.phase == Player.Play
  end,
  on_cost = record_spec.on_cost, on_use = record_spec.on_use,
})

juben:addEffect(fk.AfterCardTargetDeclared, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juben.name) and
      (hasName(player, data.card.name) or
       table.find(data.tos, function(p) return recordedPlayer(player, p) end))
  end,
  on_cost = function(self, event, target, player, data)
    local choices, extras = {}, data:getExtraTargets()
    local removals = table.filter(data.tos, function(p)
      local remaining = table.filter(data.tos, function(other) return other ~= p end)
      return data.card.skill:feasible(data.from, remaining, {})
    end)
    if #extras > 0 or #removals > 0 then table.insert(choices, "tianzong_toaru__juben_target") end
    local names = table.filter(Fk:getAllCardNames("bt"), function(name)
      if name == data.card.name then return false end
      local card = Fk:cloneCard(name, data.card.suit, data.card.number)
      return card.skill and card.skill:feasible(data.from, data.tos, {})
    end)
    if #names > 0 then table.insert(choices, "tianzong_toaru__juben_card") end
    if #choices == 0 then return false end
    table.insert(choices, "Cancel")
    local choice = player.room:askToChoice(player, { choices = choices, skill_name = juben.name })
    if choice == "Cancel" then return false end
    event:setCostData(self, { choice = choice, names = names, extras = extras, removals = removals })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room, cost = player.room, event:getCostData(self)
    local used_name = hasName(player, data.card.name) and data.card.name
    local used_player = table.find(data.tos, function(p) return recordedPlayer(player, p) end)
    if cost.choice == "tianzong_toaru__juben_target" then
      local candidates = table.simpleClone(cost.extras)
      table.insertTableIfNeed(candidates, cost.removals)
      local to = room:askToChoosePlayers(player, { targets = candidates, min_num = 1, max_num = 1,
        skill_name = juben.name, prompt = "#tianzong_toaru__juben-change-target", cancelable = false })[1]
      if table.contains(data.tos, to) then data:removeTarget(to) else data:addTarget(to) end
    else
      local name = U.askForChooseCardNames(room, player, cost.names, 1, 1, juben.name,
        "#tianzong_toaru__juben-change-card", cost.names, false)[1]
      data:changeCard(name, data.card.suit, data.card.number, juben.name)
    end
    if used_name then
      take(room, player, "name", used_name)
    elseif used_player then
      take(room, player, "player", used_player.id)
    end
  end,
})

juben:addEffect(fk.SkillEffect, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juben.name) and data.who and data.who ~= player and
      recordedPlayer(player, data.who) and not data.prevented
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = juben.name,
      prompt = "#tianzong_toaru__juben-skill::" .. data.who.id .. ":" .. data.skill.name })
  end,
  on_use = function(self, event, target, player, data)
    local room, original = player.room, data.who
    data.prevented = true
    take(room, player, "player", original.id)
    if player.dead then return end
    data.skill_data.from = player
    local trigger_event = data.skill_data.trigger_event
    if trigger_event then
      room:useSkill(player, data.skill, function()
        return data.skill:use(trigger_event, trigger_event.target, player, trigger_event.data)
      end, data.skill_data)
    else
      room:useSkill(player, data.skill, data.skill_cb, data.skill_data)
    end
  end,
})

juben:addEffect(fk.FinishRetrial, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juben.name) and data.card and
      (hasName(player, data.card.name) or hasSuit(player, data.card.suit))
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, { skill_name = juben.name, prompt = "#tianzong_toaru__juben-judge" })
  end,
  on_use = function(self, event, target, player, data)
    local room, options = player.room, {}
    local m = markOf(player)
    if #m.names > 0 then table.insert(options, "tianzong_toaru__juben_card") end
    if #m.suits > 0 then table.insert(options, "tianzong_toaru__juben_suit") end
    local choice = #options == 1 and options[1] or room:askToChoice(player, { choices = options, skill_name = juben.name })
    if choice == "tianzong_toaru__juben_card" then
      local names = m.names
      local name = U.askForChooseCardNames(room, player, names, 1, 1, juben.name, "#tianzong_toaru__juben-change-card", names, false)[1]
      data.card = Fk:cloneCard(name, data.card.suit, data.card.number)
      take(room, player, "name", name)
    else
      local values, labels = m.suits, {}
      for label, value in pairs(suits) do if table.contains(values, value) then table.insert(labels, label) end end
      local value = suits[room:askToChoice(player, { choices = labels, skill_name = juben.name })]
      data.card = Fk:cloneCard(data.card.name, value, data.card.number)
      take(room, player, "suit", value)
    end
  end,
})

juben:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(juben.name, true) and table.find(data, function(move)
      return move.from == player and move.toArea == Card.DiscardPile and
        table.contains({ fk.ReasonUse, fk.ReasonDiscard }, move.moveReason)
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player and move.toArea == Card.DiscardPile and
        table.contains({ fk.ReasonUse, fk.ReasonDiscard }, move.moveReason) then
        for _, info in ipairs(move.moveInfo) do
          player.room:addTableMarkIfNeed(player, "tianzong_toaru__juben_discards", info.cardId)
        end
      end
    end
  end,
})

juben:addLoseEffect(function(self, player)
  local room = player.room
  for _, mark in ipairs({ JB, "tianzong_toaru__juben_discards" }) do
    room:setPlayerMark(player, mark, 0)
  end
end)

Fk:loadTranslationTable {
  [JB] = "剧本",
  ["#tianzong_toaru__juben-record"] = "剧本：是否记录一个新牌名、角色和花色？",
  ["#tianzong_toaru__juben-name"] = "剧本：记录一个未记录过的牌名",
  ["#tianzong_toaru__juben-player"] = "剧本：记录一名未记录过的角色",
  ["#tianzong_toaru__juben-suit"] = "剧本：记录一个未记录过的花色",
  ["tianzong_toaru__juben_target"] = "更改目标", ["tianzong_toaru__juben_card"] = "更改牌名",
  ["tianzong_toaru__juben_suit"] = "更改花色",
  ["#tianzong_toaru__juben-change-target"] = "剧本：增加或移除一个合法目标",
  ["#tianzong_toaru__juben-change-card"] = "剧本：选择要更改成的牌名",
  ["#tianzong_toaru__juben-skill"] = "剧本：是否改为由你发动 %dest 的“%arg”？",
  ["#tianzong_toaru__juben-judge"] = "剧本：是否更改此判定牌？",
}
return juben
