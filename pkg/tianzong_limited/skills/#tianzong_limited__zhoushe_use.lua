local MAIN_SKILL = "tianzong_limited__zhoushe"

local zhoushe_use = fk.CreateSkill { name = "#tianzong_limited__zhoushe_use" }

local function current_room(player)
  return player.room or Fk:currentRoom()
end

zhoushe_use:addEffect("active", {
  prompt = "#tianzong_limited__zhoushe-use",
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local room = current_room(player)
    if not room then return false end
    local slash = Fk:cloneCard("thunder__slash")
    return table.find(room.alive_players, function(p)
      return p ~= player and to_select:inMyAttackRange(p) and
        player:canUseTo(slash, p, { bypass_times = true })
    end) ~= nil
  end,
  can_use = function(self, player)
    return player:hasSkill(MAIN_SKILL) and
      player:getMark("tianzong_limited__zhoushe_use-turn") == 0
  end,
  on_use = function(self, room, effect)
    local player, anchor = effect.from, effect.tos[1]
    local slash = Fk:cloneCard("thunder__slash")
    slash.skillName = MAIN_SKILL
    local tos = table.filter(room.alive_players, function(p)
      return p ~= player and anchor:inMyAttackRange(p) and
        player:canUseTo(slash, p, { bypass_times = true })
    end)
    if #tos == 0 then return end
    room:setPlayerMark(player, "tianzong_limited__zhoushe_use-turn", 1)
    room:useCard { from = player, tos = tos, card = slash, extraUse = true }
  end,
})

return zhoushe_use
