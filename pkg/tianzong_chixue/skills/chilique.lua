local chilique = fk.CreateSkill{
  name = "chilique",
  tags = { Skill.Compulsory },
}
local PATH = "chilique_path-turn"
local LAST = "chilique_last-turn"
local COUNT = "chilique_count-turn"
local INVALID = "chilique_invalid-turn"

-- 离阙路径 mark：随当前选择显示「离阙 递增」/「离阙 递减」
Fk:addQmlMark{
  name = "chilique_path",
  how_to_show = function(_, value, p)
    -- value 本身就是显示文本（服务端 setPlayerMark 写入），避免依赖内部 mark 的客户端同步
    if type(value) == "string" and value ~= "" then return value end
    return ""
  end,
  qml_data = function() return {} end,
  qml_path = function() return "" end,
}

local function add_targets(room, player, data, number)
  local current = data.tos or {}
  local candidates = table.filter(room.alive_players, function(p)
    return not table.contains(current, p) and not player:isProhibited(p, data.card)
      and data.card.skill:modTargetFilter(player, p, current, data.card, { bypass_times = true })
  end)
  if #candidates == 0 then return end
  local chosen = room:askToChoosePlayers(player, { targets = candidates, min_num = 1, max_num = math.min(number, #candidates), skill_name = chilique.name, prompt = "#chilique-target:::" .. number, cancelable = false })
  for _, p in ipairs(chosen) do data:addTarget(p) end
end

local function apply_effect(room, player, data, path, index)
  if path == "chilique_increase" then
    if index == 1 then data.extraUse = true
    elseif index == 2 then data.additionalEffect = (data.additionalEffect or 0) + 1
    elseif index == 3 then add_targets(room, player, data, 1)
    else data.additionalEffect = (data.additionalEffect or 0) + index - 1 end
  else
    if index == 1 then data.additionalEffect = (data.additionalEffect or 0) + 1
    elseif index == 2 then add_targets(room, player, data, 1)
    elseif index == 3 then data.extraUse = true
    else add_targets(room, player, data, index) end
  end
end

chilique:addEffect(fk.AfterCardUseDeclared, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chilique.name) and player:getMark(INVALID) == 0 and data.card
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark(COUNT) + 1
    local path = player:getMark(PATH)
    if path == 0 then
      path = room:askToChoice(player, { choices = { "chilique_increase", "chilique_decrease" }, skill_name = chilique.name, prompt = "#chilique-path" })
      room:setPlayerMark(player, PATH, path)
    else
      local last = player:getMark(LAST)
      local length = data.card:getNameLength(true)
      local valid = path == "chilique_increase" and length > last or path == "chilique_decrease" and length < last
      if not valid then
        room:setPlayerMark(player, INVALID, 1)
        local n = math.min(count, #player:getCardIds("he"))
        if n > 0 then room:askToDiscard(player, { min_num = n, max_num = n, include_equip = true, skill_name = chilique.name, cancelable = false }) end
        return
      end
    end
    -- 触发离阙路径 mark 界面重绘：value 直接写入显示文本
    -- 名字前缀由翻译键 ["@[chilique_path]"] 提供，此处只写状态，避免显示成 @[chilique_path] 原文
    room:setPlayerMark(player, "@[chilique_path]", path == "chilique_increase" and "递增" or "递减")
    room:setPlayerMark(player, COUNT, count)
    room:setPlayerMark(player, LAST, data.card:getNameLength(true))
    apply_effect(room, player, data, path, count)
    if count == player.hp then apply_effect(room, player, data, path == "chilique_increase" and "chilique_decrease" or "chilique_increase", count) end
  end,
})

-- 回合开始清除路径 mark 显示（PATH 由 -turn 后缀自动清，这里清显示触发 mark）
chilique:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@[chilique_path]") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[chilique_path]", 0)
  end,
})

return chilique
