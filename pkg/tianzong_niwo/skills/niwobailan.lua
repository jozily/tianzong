local niwobailan = fk.CreateSkill{
  name = "niwobailan",
  tags = { Skill.Limited },
}
local Common = require "packages.tianzong.pkg.tianzong_niwo.lib.common"
local LIMITED_MARK = "niwobailan_limited"

local function available_skills(player)
  return table.filter(player:getSkillNameList(), function(skill_name)
    local skill = Fk.skills[skill_name]
    local skeleton = skill and skill:getSkeleton()
    return skeleton and #(skeleton.tags or {}) == 0
  end)
end

niwobailan:addEffect("active", {
  anim_type = "support",
  prompt = "#niwobailan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(niwobailan.name, Player.HistoryGame) == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and #available_skills(to_select) > 0
  end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    local skills = available_skills(target)
    if #skills == 0 then return end
    local choice_skill = #skills == 1 and skills[1] or room:askToChoice(player, {
      choices = skills,
      skill_name = niwobailan.name,
      prompt = "#niwobailan-skill",
    })
    room:addTableMarkIfNeed(target, LIMITED_MARK, choice_skill)
    if player:isAlive() then
      room:loseHp(player, player.hp, niwobailan.name)
    end
  end,
})

niwobailan:addEffect("invalidity", {
  recheck_invalidity = true,
  invalidity_func = function(self, from, skill)
    local skeleton = skill:getSkeleton()
    local skill_name = skeleton and skeleton.name or skill.name
    return table.contains(from:getTableMark(LIMITED_MARK), skill_name) and
      from:usedSkillTimes(skill_name, Player.HistoryGame) > 0
  end,
})

return niwobailan
