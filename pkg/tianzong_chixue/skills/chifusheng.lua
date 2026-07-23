-- chifusheng.lua (浮生)
local chifusheng = fk.CreateSkill{
  name = "chifusheng",
  description = ":chifusheng",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local swaps = {}
    for k, v in pairs(player.marks) do
      if string.find(k, "chifusheng_swap_") and v > 0 then
        table.insert(swaps, k)
      end
    end
    if #swaps == 0 then
      return "浮生：未激活"
    end
    local desc = "浮生·已交换："
    local names = {"已废除", "未废除", "体力上限", "杀次数", "手牌数", "体力值"}
    for _, swap in ipairs(swaps) do
      local parts = string.split(swap, "_")
      if parts[3] and parts[4] then
        local idx1 = tonumber(parts[3])
        local idx2 = tonumber(parts[4])
        desc = desc .. names[idx1] .. "↔" .. names[idx2] .. "; "
      end
    end
    return desc
  end,
}

Fk:loadTranslationTable{
  ["chifusheng"] = "浮生",
  [":chifusheng"] = "准备阶段或当你受到伤害后，你可以交换下面两项数值并于本轮移除之：①已废除装备栏；②未废除装备栏；③体力上限；④出牌阶段使用杀次数；⑤手牌数；⑥体力值。",
  ["#chifusheng-select1"] = "浮生：选择第一个要交换的项",
  ["#chifusheng-select2"] = "浮生：选择第二个要交换的项",
}

chifusheng:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and target.phase == Player.PrepareStage
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choice1 = room:askToChoose(player, {1,2,3,4,5,6}, self.name, "#chifusheng-select1")
    if not choice1 then return false end
    
    local remaining = {}
    for _, id in ipairs({1,2,3,4,5,6}) do
      if tostring(id) ~= choice1 then
        table.insert(remaining, id)
      end
    end
    
    local choice2 = room:askToChoose(player, remaining, self.name, "#chifusheng-select2")
    if not choice2 then return false end
    
    event:setCostData(self, { idx1 = tonumber(choice1), idx2 = tonumber(choice2) })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local idx1 = event:getCostData(self).idx1
    local idx2 = event:getCostData(self).idx2
    
    player:setMark("chifusheng_swap_" .. idx1 .. "_" .. idx2, 1)
    player:setMark("chifusheng_active", 1)
  end,
})

chifusheng:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choice1 = room:askToChoose(player, {1,2,3,4,5,6}, self.name, "#chifusheng-select1", true)
    if not choice1 then return false end
    
    local remaining = {}
    for _, id in ipairs({1,2,3,4,5,6}) do
      if tostring(id) ~= choice1 then
        table.insert(remaining, id)
      end
    end
    
    local choice2 = room:askToChoose(player, remaining, self.name, "#chifusheng-select2", true)
    if not choice2 then return false end
    
    event:setCostData(self, { idx1 = tonumber(choice1), idx2 = tonumber(choice2) })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local idx1 = event:getCostData(self).idx1
    local idx2 = event:getCostData(self).idx2
    
    player:setMark("chifusheng_swap_" .. idx1 .. "_" .. idx2, 1)
    player:setMark("chifusheng_active", 1)
  end,
})

chifusheng:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("chifusheng_active") > 0
  end,
  on_use = function(self, event, target, player, data)
    player:setMark("chifusheng_active", 0)
    for k in pairs(player.marks) do
      if string.find(k, "chifusheng_swap_") then
        player:setMark(k, 0)
      end
    end
    return false
  end,
})

return chifusheng
