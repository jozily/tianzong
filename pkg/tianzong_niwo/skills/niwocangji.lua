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
    return player.room:askToSkillInvoke(player, {
      skill_name = niwocangji.name,
      prompt = "#niwocangji-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= player and not player:inMyAttackRange(p) then
        table.insert(targets, p)
      end
    end
    
    if #targets == 0 then return end
    
    for _, target_player in ipairs(targets) do
      local judge_result = room:judge(target_player, niwocangji.name)
      local damage_num = judge_result.card:getNameLength(true)
      local damage_type = nil
      
      local suit = judge_result.card:getSuit()
      if suit == Card.Spade or suit == Card.Club then
        damage_type = fk.Thunder
      elseif suit == Card.Heart then
        damage_type = fk.Fire
      elseif suit == Card.Diamond then
        damage_type = fk.Ice
      end
      
      room:damage({
        from = player,
        to = target_player,
        damage = damage_num,
        damageType = damage_type,
        skillName = niwocangji.name,
      })
    end
    
    player:removeSkill("niwochencang")
    player:addSkill("niwochencangRemake")
  end,
})

return niwocangji
