local niwoqianzhun = fk.CreateSkill{ name = "niwoqianzhun" }

local function names_in_skills(target)
  local result = {}
  for _, skill_name in ipairs(target:getSkillNameList()) do
    local desc = Fk:translate(":" .. skill_name)
    for _, card_name in ipairs(Fk:getAllCardNames("bt")) do
      if desc:find("【" .. Fk:translate(card_name) .. "】", 1, true) then table.insertIfNeed(result, card_name) end
    end
  end
  return result
end

local function tagged_count(target)
  local n = 0
  for _, name in ipairs(target:getSkillNameList()) do
    local skill = Fk.skills[name]
    if skill then n = n + #(skill:getSkeleton().tags or {}) end
  end
  return n + 1
end

local function eligible_targets(player, card_name)
  return table.filter(player.room.alive_players, function(p)
    if table.contains(names_in_skills(p), card_name) then return true end
    local card = Fk:cloneCard(card_name)
    return (card.type == Card.TypeBasic or card:isCommonTrick()) and card:getNameLength(true) == tagged_count(p)
  end)
end

local function available_names(player)
  local result = {}
  for _, p in ipairs(player.room.alive_players) do
    table.insertTableIfNeed(result, names_in_skills(p))
    local x = tagged_count(p)
    for _, name in ipairs(Fk:getAllCardNames("bt")) do
      local card = Fk:cloneCard(name)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and card:getNameLength(true) == x then table.insertIfNeed(result, name) end
    end
  end
  return player:getViewAsCardNames(niwoqianzhun.name, result)
end

niwoqianzhun:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic,trick",
  prompt = "#niwoqianzhun",
  max_turn_use_time = 1,
  interaction = function(self, player)
    local names = available_names(player)
    if #names > 0 then return UI.CardNameBox{ choices = names, all_choices = names } end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = niwoqianzhun.name
    return card
  end,
  before_use = function(self, player, use)
    local targets = eligible_targets(player, use.card.name)
    if #targets == 0 then return "" end
    if #targets > 1 then
      local tos = player.room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1, skill_name = niwoqianzhun.name, prompt = "#niwoqianzhun-choose", cancelable = false })
      if #tos == 0 then return "" end
    end
  end,
})

Fk:loadTranslationTable{
  ["#niwoqianzhun"] = "千谆：选择符合一名角色技能牌名或技能标签数字数的牌",
  ["#niwoqianzhun-choose"] = "千谆：选择令此次声明成立的角色",
}
return niwoqianzhun
