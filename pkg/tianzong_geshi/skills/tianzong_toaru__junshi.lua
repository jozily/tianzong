local junshi = fk.CreateSkill {
  name = "tianzong_toaru__junshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["tianzong_toaru__junshi"] = "钧世",
  [":tianzong_toaru__junshi"] = "锁定技，当你受到雷属性伤害后，你立刻恢复等量点体力值（优先于濒死状态）且随机获得一个技能描述中带有“杀”/“雷”/“电”的技能；场上有角色受到雷属性伤害后，你摸等同于此数值张牌且随机获得一个此类技能。",
}

-- 技能池：描述含"杀/雷/电"的技能；剔除国战包（hegemony / fengsui）
local function gainThunderSkill(player)
  if player.dead then return end
  local names = {}
  for name, skill in pairs(Fk.skills) do
    local ext = skill.package and skill.package.extensionName
    if ext ~= "hegemony" and ext ~= "fengsui" and
      skill.visible and not player:hasSkill(name, true) then
      local desc = Fk:getDescription(name, "zh_CN")
      if type(desc) == "string" and
        (desc:find("杀", 1, true) or desc:find("雷", 1, true) or desc:find("电", 1, true)) then
        table.insert(names, name)
      end
    end
  end
  if #names > 0 then
    player.room:handleAddLoseSkills(player, player.room:tableRandomPick(names), junshi.name)
  end
end

-- 第一段：你即将受到雷属性伤害时，防止伤害、立刻恢复等量体力（优先于濒死）并立刻获得技能
junshi:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(junshi.name) and
      data.damageType == fk.ThunderDamage and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local damage = data.damage
    data:preventDamage()
    player.room:recover {
      who = player,
      num = damage,
      recoverBy = player,
      skillName = junshi.name,
    }
    gainThunderSkill(player)
  end,
})

-- 第二段：场上任意角色受到雷属性伤害后，摸等同伤害值张牌 + 随机获得含"杀/雷/电"的技能
junshi:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(junshi.name) and data.damageType == fk.ThunderDamage and
      data.damage > 0 and target and target:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(data.damage, junshi.name)
    gainThunderSkill(player)
  end,
})

return junshi
