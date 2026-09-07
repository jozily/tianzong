local niwobailan = fk.CreateSkill{
  name = "niwobailan",
  tags = { Skill.Limited },
}
local Common = require "packages.tianzong.pkg.tianzong_niwo.lib.common"
local BAILAN_MARK = "@[list]niwobailan"

local function available_skills(player)
  return table.filter(Common.get_skill_names(player), function(skill_name)
    local skill = Fk.skills[skill_name]
    local skeleton = skill and skill:getSkeleton()
    return skill and skill.visible and skeleton and not table.contains(skeleton.tags or {}, Skill.Limited)
  end)
end

local function tag_count(room)
  local n = 0
  for _, p in ipairs(room.alive_players) do
    for _, skill_name in ipairs(p:getSkillNameList()) do
      local skill = Fk.skills[skill_name]
      local skeleton = skill and skill:getSkeleton()
      if skeleton then n = n + #(skeleton.tags or {}) end
    end
  end
  return n
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
    return #selected == 0 and #available_skills(to_select) > 0
  end,
  on_use = function(self, room, effect)
    local player, target = effect.from, effect.tos[1]
    local x = tag_count(room)
    if x > 0 then target:drawCards(4 * x, niwobailan.name) end
    if target.dead then return end
    local skills = available_skills(target)
    if #skills == 0 then return end
    local choice_skill = #skills == 1 and skills[1] or room:askToChoice(player, {
      choices = skills,
      skill_name = niwobailan.name,
      prompt = "#niwobailan-skill",
    })
    room:setPlayerMark(target, BAILAN_MARK, { choice_skill })
    if target ~= player and player:isAlive() and x > 0 then
      room:loseHp(player, x, niwobailan.name)
    end
  end,
})

niwobailan:addEffect(fk.AfterSkillEffect, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not data.skill then return false end
    local skeleton = data.skill:getSkeleton()
    local skill_name = skeleton and skeleton.name or data.skill.name
    return table.contains(player:getTableMark(BAILAN_MARK), skill_name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local skeleton = data.skill:getSkeleton()
    local skill_name = skeleton and skeleton.name or data.skill.name
    player.room:setPlayerMark(player, BAILAN_MARK, 0)
    player.room:handleAddLoseSkills(player, "-" .. skill_name, niwobailan.name, true, false)
  end,
})

return niwobailan
