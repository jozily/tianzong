local MAIN_SKILL = "tianzong_limited__hengwen"

local restore = fk.CreateSkill { name = "#tianzong_limited__hengwen_restore" }

restore:addEffect(fk.HpChanged, {
  can_trigger = function(self, event, target, player, data)
    return target and target:isAlive() and target.hp > 0 and
      target:getMark("@tianzong_limited__hengwen") == player.id and
      player:hasSkill(MAIN_SKILL, true) and
      target.hp ~= target:getMark("tianzong_limited__hengwen_hp")
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = MAIN_SKILL,
      prompt = "#tianzong_limited__hengwen-invoke::" .. target.id,
    }) then
      event:setCostData(self, { tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room, hp = player.room, target:getMark("tianzong_limited__hengwen_hp")
    room:setPlayerMark(target, "@tianzong_limited__hengwen", 0)
    room:setPlayerMark(target, "tianzong_limited__hengwen_hp", 0)
    if target.hp < hp then
      room:recover { who = target, num = hp - target.hp, recoverBy = player, skillName = MAIN_SKILL }
    elseif target.hp > hp then
      room:loseHp(target, target.hp - hp, MAIN_SKILL)
    end
    player:setSkillUseHistory("tianzong_limited__zonghuan", 0, Player.HistoryGame)
  end,
})

return restore
