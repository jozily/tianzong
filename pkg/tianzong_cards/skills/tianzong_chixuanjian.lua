local chixuanjian = fk.CreateSkill{
  name = "#tianzong_chixuanjian_skill",  -- 加上 #
  tags = { Skill.Compulsory },  -- 用 Skill 不是 chixuanjian
  attached_equip = "tianzong_chixuanjian",
}

chixuanjian:addEffect("atkrange", {
  correct_func = function(self, from, to)
    return 1  -- 增加1点攻击范围
  end,
})

Fk:loadTranslationTable{
  ["#tianzong_chixuanjian_skill"] = "炽·玄剑",
}

chixuanjian:addTest(function (room, me)
  local tar = table.find(room:getOtherPlayers(me, false), function(p)
    return H.compareKingdomWith(me, p)
  end)
  if tar then
    local card = room:printCard("tianzong_chixuanjian")
    FkTest.runInRoom(function()
      room:useCard {
        from = me,
        tos = { me },
        card = card,
      }
    end)
    lu.assertEquals(me:getAttackRange(), 3)
  end
end)

return chixuanjian
