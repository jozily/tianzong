local hengwen = fk.CreateSkill {
  name = "tianzong_limited__hengwen",
  tags = { Skill.Limited },
  related_skills = { "#tianzong_limited__hengwen_restore" },
}

hengwen:addEffect("active", {
  prompt = "#tianzong_limited__hengwen",
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select:getMark("@tianzong_limited__hengwen") == 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(hengwen.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local to = effect.tos[1]
    room:setPlayerMark(to, "@tianzong_limited__hengwen", effect.from.id)
    room:setPlayerMark(to, "tianzong_limited__hengwen_hp", to.hp)
  end,
})

hengwen:addTest(function()
  local restore = Fk.skill_skels["#tianzong_limited__hengwen_restore"]
  lu.assertNotNil(restore)
  lu.assertFalse(table.contains(restore.tags or {}, Skill.Limited))
end)

Fk:loadTranslationTable {
  ["#tianzong_limited__hengwen"] = "恒温：令一名角色获得“恒温”并记录其当前体力值",
  ["#tianzong_limited__hengwen-invoke"] = "恒温：你可以令 %dest 的体力值恢复至记录值",
  ["@tianzong_limited__hengwen"] = "恒温",
}

return hengwen
