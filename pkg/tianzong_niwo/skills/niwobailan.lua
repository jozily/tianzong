local niwobailan = fk.CreateSkill{ name = "niwobailan", tags = { Skill.Limited } }

niwobailan:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player) return player:usedSkillTimes(niwobailan.name, Player.HistoryGame) == 0 end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.find(to_select:getSkillNameList(), function(name)
      local skill = Fk.skills[name]
      return skill and #(skill:getSkeleton().tags or {}) == 0
    end)
  end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    local names = table.filter(target:getSkillNameList(), function(name)
      local skill = Fk.skills[name]
      return skill and #(skill:getSkeleton().tags or {}) == 0
    end)
    if #names == 0 then return end
    local name = room:askToChoice(player, { choices = names, skill_name = niwobailan.name, prompt = "#niwobailan-skill::" .. target.id })
    table.insertIfNeed(Fk.skills[name]:getSkeleton().tags, Skill.Limited)
    room:addTableMarkIfNeed(target, "@$niwobailan", name)
    if target ~= player then room:loseHp(player, player.hp, niwobailan.name) end
  end,
})

Fk:loadTranslationTable{
  ["#niwobailan-skill"] = "百览：选择令 %dest 增加“限定技”标签的技能",
  ["@$niwobailan"] = "百览",
}
return niwobailan
