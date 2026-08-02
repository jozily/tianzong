local common = require "packages/tianzong/pkg/tianzong_chixue/lib/common"

local chiraoluo = fk.CreateSkill{
  name = "chiraoluo",
}

local function normalize_choose_result(ret)
  if not ret then return nil end
  if type(ret) == "table" then
    if #ret > 0 then return ret[1] end
    return nil
  end
  return ret
end

local function choose_one_target(room, player, skill_name, prompt)
  local targets = {}
  for _, p in ipairs(room.alive_players) do
    table.insert(targets, p.id)
  end
  if #targets == 0 then return nil end
  if #targets == 1 then return room:getPlayerById(targets[1]) end

  local ret

  if room.askForChoosePlayers then
    local ok, res = pcall(room.askForChoosePlayers, room, player, targets, 1, 1, prompt, skill_name, true)
    if ok then
      ret = normalize_choose_result(res)
      if ret then return room:getPlayerById(ret) end
    end
  end

  if player.askForChoosePlayers then
    local ok, res = pcall(player.askForChoosePlayers, player, targets, 1, 1, prompt, skill_name, true)
    if ok then
      ret = normalize_choose_result(res)
      if ret then return room:getPlayerById(ret) end
    end
  end

  if room.askForChoosePlayer then
    local tries = {
      function() return room:askForChoosePlayer(player, targets, skill_name, prompt, true, true) end,
      function() return room:askForChoosePlayer(player, targets, prompt, skill_name, true) end,
      function() return room:askForChoosePlayer(player, targets, prompt, skill_name) end,
      function() return room:askForChoosePlayer(player, targets, skill_name, prompt) end,
    }
    for _, f in ipairs(tries) do
      local ok, res = pcall(f)
      if ok then
        ret = normalize_choose_result(res)
        if ret then return room:getPlayerById(ret) end
      end
    end
  end

  return nil
end

local function discard_one_from_target(room, player, target, skill_name)
  if target:isAllNude() then return false end

  local id = room:askForCardChosen(
    player,
    target,
    "hej",
    skill_name,
    "#chiraoluo-discard::" .. target.id,
    true,
    fk.ReasonDiscard
  )

  if id and id ~= -1 then
    room:throwCard({ id }, skill_name, target, player)
    return true
  end
  return false
end

local function get_premeditate_ids(player)
  if common.get_premeditate_ids then
    local ok, ids = pcall(common.get_premeditate_ids, player)
    if ok and type(ids) == "table" then return ids end
  end
  if common.getPremeditateIds then
    local ok, ids = pcall(common.getPremeditateIds, player)
    if ok and type(ids) == "table" then return ids end
  end

  local pile_names = { "premeditate", "$premeditate", "xumou", "$xumou" }
  if player.getPile then
    for _, pile_name in ipairs(pile_names) do
      local ok, ids = pcall(player.getPile, player, pile_name)
      if ok and type(ids) == "table" and #ids > 0 then
        return ids
      end
    end
  end

  return {}
end

local function try_do_gufu(room, target)
  if target.dead then return end

  if room.askForUseActiveSkill then
    local ok = pcall(room.askForUseActiveSkill, room, target, "chigufu", "#chiraoluo-gufu")
    if ok then return end
  end

  if room.askForUseCard then
    pcall(room.askForUseCard, room, target, ".|.|.|.|.|.", "#chiraoluo-gufu", nil, "chigufu")
  end
end

local function flip_player(room, target)
  if target.dead then return end
  if room.turnOver then
    local ok = pcall(room.turnOver, room, target)
    if ok then return end
  end
  if target.turnOver then
    pcall(target.turnOver, target)
  end
end

local function use_one_premeditated(room, target, skill_name)
  local ids = get_premeditate_ids(target)
  if #ids == 0 then return false end

  local chosen = room:askForCardChosen(
    target,
    target,
    { card_data = { { skill_name, ids } } },
    skill_name,
    "#chiraoluo-use-pm",
    true
  )
  if not chosen or chosen == -1 then return false end

  local card = Fk:getCardById(chosen)
  if not card then return false end

  if room.moveCardTo then
    pcall(function()
      room:moveCardTo(chosen, Card.Processing, nil, fk.ReasonJustMove, skill_name, nil, true, target.id)
    end)
  end

  local ok = pcall(function()
    room:useCard{
      from = target.id,
      card = Fk:getCardById(chosen) or card,
    }
  end)
  return ok
end

local function try_use_hand_or_premeditate(room, target, skill_name)
  if target.dead then return end

  local has_hand = not target:isKongcheng()
  local pm_ids = get_premeditate_ids(target)
  local has_pm = #pm_ids > 0

  if not has_hand and not has_pm then return end

  local choices = {}
  if has_hand then table.insert(choices, "chiraoluo_use_hand") end
  if has_pm then table.insert(choices, "chiraoluo_use_premeditate") end

  local choice
  if #choices == 1 then
    choice = choices[1]
  else
    choice = room:askForChoice(target, choices, skill_name, "#chiraoluo-use-choice")
  end

  if choice == "chiraoluo_use_hand" then
    if room.askForUseCard then
      pcall(room.askForUseCard, room, target, ".|.|.|hand", "#chiraoluo-use-hand", nil)
    end
    return
  end

  if choice == "chiraoluo_use_premeditate" then
    use_one_premeditated(room, target, skill_name)
  end
end

local function do_chiraoluo(room, player, skill_name)
  local target = choose_one_target(room, player, skill_name, "#chiraoluo-choose")
  if not target then return end

  discard_one_from_target(room, player, target, skill_name)
  if target.dead then return end

  local choices = { "chiraoluo_opt1", "chiraoluo_opt2", "chiraoluo_opt3" }
  local choice = room:askForChoice(target, choices, skill_name, "#chiraoluo-choice::" .. player.id)

  if choice == "chiraoluo_opt1" then
    try_do_gufu(room, target)
    return
  end

  if choice == "chiraoluo_opt2" then
    try_use_hand_or_premeditate(room, target, skill_name)
    return
  end

  try_do_gufu(room, target)
  if not target.dead then
    try_use_hand_or_premeditate(room, target, skill_name)
  end
  if not target.dead then
    flip_player(room, target)
  end
end

chiraoluo:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player
      and target == player
      and player:hasSkill(chiraoluo.name)
      and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    do_chiraoluo(player.room, player, chiraoluo.name)
  end,
})

Fk:loadTranslationTable{
  ["chiraoluo"] = "扰洛",
  [":chiraoluo"] = "当你受到伤害后或响应牌后，你可以弃置一名角色区域内的一张牌并令其选择一项：1.发动一次孤凫；2.使用一张手牌或蓄谋牌；3.背水（依次执行前两项）：翻面。",

  ["#chiraoluo-choose"] = "扰洛：请选择一名角色",
  ["#chiraoluo-discard"] = "扰洛：弃置 %dest 区域内的一张牌",
  ["#chiraoluo-choice"] = "扰洛：请选择一项",
  ["chiraoluo_opt1"] = "发动一次孤凫",
  ["chiraoluo_opt2"] = "使用一张手牌或蓄谋牌",
  ["chiraoluo_opt3"] = "背水：依次执行前两项，然后翻面",

  ["#chiraoluo-gufu"] = "扰洛：请发动一次孤凫",
  ["#chiraoluo-use-choice"] = "扰洛：请选择使用手牌或蓄谋牌",
  ["chiraoluo_use_hand"] = "使用一张手牌",
  ["chiraoluo_use_premeditate"] = "使用一张蓄谋牌",
  ["#chiraoluo-use-hand"] = "扰洛：请使用一张手牌",
  ["#chiraoluo-use-pm"] = "扰洛：请选择一张蓄谋牌使用",
}

return chiraoluo
