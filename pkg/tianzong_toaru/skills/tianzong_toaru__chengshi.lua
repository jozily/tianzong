local chengshi = fk.CreateSkill { name = "tianzong_toaru__chengshi", tags = { Skill.Compulsory } }

chengshi:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player) return player:hasSkill(chengshi.name) end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local names = {}
    for name, skill in pairs(Fk.skills) do
      local desc = Fk:translate(":" .. name)
      if skill.visible and name ~= chengshi.name and type(desc) == "string" and desc:find("【杀】", 1, true) then
        table.insert(names, name)
      end
    end
    if #names > 0 then player.room:handleAddLoseSkills(player, player.room:tableRandomPick(names), chengshi.name) end
  end,
})
return chengshi
