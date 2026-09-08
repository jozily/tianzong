local niwoyinbing = fk.CreateSkill{
  name = "niwoyinbing",
  tags = { Skill.Contract },
}

niwoyinbing:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoyinbing.name) and data.from and data.from:isAlive() and
      data.to and data.to:isAlive() and data.from ~= data.to and
      (data.from == player or data.to == player)
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("contracted_skills"), niwoyinbing.name) then
      return true
    end
    return player.room:askToSkillInvoke(player, {
      skill_name = niwoyinbing.name,
      prompt = "#niwoyinbing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room, user, source = player.room, data.to, data.from
    room:addTableMarkIfNeed(player, "contracted_skills", niwoyinbing.name)
    local contracted = table.contains(player:getTableMark("contracted_skills"), niwoyinbing.name)
    local use
    if contracted then
      local card = Fk:cloneCard("ice__slash")
      card.skillName = niwoyinbing.name
      use = { from = user, card = card, tos = { { source.id } }, skillName = niwoyinbing.name,
        extraUse = true, bypassTimes = true, bypassDistances = true }
    else
      use = room:askToUseVirtualCard(user, {
        name = "ice__slash", skill_name = niwoyinbing.name,
        prompt = "#niwoyinbing-ice::" .. source.id, cancelable = true, skip = true,
        extra_data = { exclusive_targets = { source.id }, bypass_times = true, bypass_distances = true },
      })
      if not use then return end
    end
    room:useCard(use)

    local dealt = false
    for _, n in pairs(use.damageDealt or {}) do
      if n > 0 then dealt = true break end
    end
    if not dealt and user:isAlive() then
      user:drawCards(2, niwoyinbing.name)
      if user:isAlive() then room:loseHp(user, 1, niwoyinbing.name) end
    end
    if source.dead and player:isAlive() then
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return p:isAlive() and not p:hasSkill(niwoyinbing.name, true)
      end)
      if #targets > 0 then
        local chosen = room:askToChoosePlayers(player, {
          targets = targets,
          min_num = 1,
          max_num = 1,
          skill_name = niwoyinbing.name,
          prompt = "#niwoyinbing-acquire",
          cancelable = false,
        })
        if #chosen > 0 then
          room:handleAddLoseSkills(chosen[1], niwoyinbing.name, nil, true, false)
        end
      end
    end
  end,
})

return niwoyinbing
