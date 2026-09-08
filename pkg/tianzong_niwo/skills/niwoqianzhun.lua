local niwoqianzhun = fk.CreateSkill { name = "niwoqianzhun" }
local DESC_MARK, TAG_MARK = "niwoqianzhun_desc-turn", "niwoqianzhun_tag-turn"

local function tag_count(target)
  local n = 0
  for _, skill_name in ipairs(target:getSkillNameList()) do
    local skill = Fk.skills[skill_name]
    local skeleton = skill and skill:getSkeleton()
    if skeleton then n = n + #(skeleton.tags or {}) end
  end
  return n
end

local function supports(target, name, mode)
  if mode == 1 then
    local translated = Fk:translate(name)
    return table.find(target:getSkillNameList(), function(skill_name)
      return string.find(Fk:translate(":" .. skill_name), "【" .. translated .. "】", 1, true)
    end) ~= nil
  end
  return Fk:cloneCard(name):getNameLength() <= tag_count(target) + 1
end

local function available(player, mode)
  if player:getMark(mode == 1 and DESC_MARK or TAG_MARK) > 0 then return {} end
  return table.filter(player:getViewAsCardNames(niwoqianzhun.name, Fk:getAllCardNames("bt")), function(name)
    local card = Fk:cloneCard(name)
    return card and (card.type == Card.TypeBasic or card:isCommonTrick()) and
      table.find(Fk:currentRoom().alive_players, function(target) return supports(target, name, mode) end)
  end)
end

local function all_available(player)
  return table.connect(available(player, 1), available(player, 2))
end

niwoqianzhun:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwoqianzhun",
  interaction = function(self, player)
    local names = all_available(player)
    if #names > 0 then return UI.TianzongCardNameBox { choices = names, all_choices = Fk:getAllCardNames("bt") } end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards == 0 and self.interaction.data then
      local card = Fk:cloneCard(self.interaction.data)
      card.skillName = niwoqianzhun.name
      return card
    end
  end,
  before_use = function(self, player, use)
    local room, name = player.room, use.card.name
    local targets = table.filter(room.alive_players, function(p)
      return (player:getMark(DESC_MARK) == 0 and supports(p, name, 1)) or
        (player:getMark(TAG_MARK) == 0 and supports(p, name, 2))
    end)
    local target = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1,
      skill_name = niwoqianzhun.name, prompt = "#niwoqianzhun-reference", cancelable = false })[1]
    local choices = {}
    if player:getMark(DESC_MARK) == 0 and supports(target, name, 1) then table.insert(choices, "niwoqianzhun_opt1") end
    if player:getMark(TAG_MARK) == 0 and supports(target, name, 2) then table.insert(choices, "niwoqianzhun_opt2") end
    local choice = #choices == 1 and choices[1] or room:askToChoice(player, {
      choices = choices, skill_name = niwoqianzhun.name, prompt = "#niwoqianzhun-choice",
    })
    room:setPlayerMark(player, choice == "niwoqianzhun_opt1" and DESC_MARK or TAG_MARK, 1)
  end,
  enabled_at_play = function(self, player) return #all_available(player) > 0 end,
  enabled_at_response = function(self, player, response) return #all_available(player) > 0 end,
})

return niwoqianzhun
