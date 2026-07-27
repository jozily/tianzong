local niwoshudu = fk.CreateSkill{
  name = "niwoshudu",
  related_skills = { "niwocangji", "niwochencangRemake", "niwochoulu" },
  tags = { Skill.Compulsory },
}
local PLUS = "niwoshudu_plus"
local MINUS = "niwoshudu_minus"

local function add_distance(room, from, to, mark)
  room:addTableMark(from, mark, to.id)
end

local function check_awaken(player)
  if table.every(player.room:getOtherPlayers(player), function(p) return not p:inMyAttackRange(player) end) then
    player.room:handleAddLoseSkills(player, "niwocangji|niwochoulu")
  end
end

niwoshudu:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoshudu.name) and data.firstTarget
      and data.card.is_damage_card and table.find(data.use.tos, function(p) return p ~= player end)
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(data.use.tos) do if p ~= player then add_distance(player.room, p, player, PLUS) end end
    check_awaken(player)
  end,
})

niwoshudu:addEffect(fk.TargetConfirming, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwoshudu.name) and data.from and data.from ~= player and data.card.is_damage_card
  end,
  on_use = function(self, event, target, player, data)
    add_distance(player.room, player, data.from, PLUS)
    check_awaken(player)
  end,
})

niwoshudu:addEffect("distance", {
  correct_func = function(self, from, to)
    local plus = #table.filter(from:getTableMark(PLUS), function(id) return id == to.id end)
    local minus = #table.filter(from:getTableMark(MINUS), function(id) return id == to.id end)
    return plus - minus
  end,
})

return niwoshudu
