local niwofuxue = fk.CreateSkill{
  name = "niwofuxue",
}

niwofuxue:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwofuxue.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, niwofuxue.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, niwofuxue.name)
    
    local choice = room:askToChoice(player, {"opt1", "opt2"}, niwofuxue.name, "#niwofuxue-choice")
    
    if choice == "opt1" then
      local mark_count = player:getMark("niwotianmeng_mark") or 0
      data.damage = data.damage + mark_count
      player:drawCards(2 * mark_count, niwofuxue.name)
    else
      local mark_count = player:getMark("niwotianmeng_mark") or 0
      room:recover({
        who = player,
        recover = mark_count,
        skillName = niwofuxue.name,
      })
    end
  end,
})

return niwofuxue
