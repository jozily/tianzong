local niwocangji = fk.CreateSkill{
  name = "niwocangji",
  tags = { Skill.Limited },
}

niwocangji:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player 
      and player:hasSkill(niwocangji.name)
      and player:usedSkillTimes(niwocangji.name, Player.HistoryGame) == 0
      and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = niwocangji.name })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= player and not p:inMyAttackRange(player) then
        table.insert(targets, p)
      end
    end
    
    if #targets == 0 then return end
    
    for _, target_player in ipairs(targets) do
      local judge_result = { who = target_player, reason = niwocangji.name, pattern = "." }
      room:judge(judge_result)
      local card = judge_result.card
      local damage_num = card:getNameLength(true)
      local damage_type = card.type == Card.TypeBasic and fk.ThunderDamage
        or card.type == Card.TypeTrick and fk.FireDamage
        or fk.IceDamage
      
      room:damage({
        from = player,
        to = target_player,
        damage = damage_num,
        damageType = damage_type,
        skillName = niwocangji.name,
      })
    end
    
    for _, p in ipairs(room.alive_players) do
      local to_lose = table.filter(p:getSkillNameList(), function(name)
        return Fk:translate(":" .. name):find("距离", 1, true) ~= nil
      end)
      if #to_lose > 0 then
        room:handleAddLoseSkills(p, table.concat(table.map(to_lose, function(name) return "-" .. name end), "|"))
      end
    end
    room:handleAddLoseSkills(player, "-niwochencang|niwochencangRemake|niwochoulu|weimu")
  end,
})

return niwocangji
