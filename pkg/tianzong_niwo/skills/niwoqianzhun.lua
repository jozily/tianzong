local Common = require "packages.tianzong.pkg.tianzong_niwo.lib.common"
local U = require "packages.utility.utility"

local niwoqianzhun = fk.CreateSkill{ name = "niwoqianzhun" }

local function description_names(player, target)
  local names = {}
  for _, skill_name in ipairs(target:getSkillNameList()) do
    local desc = Fk:translate(":" .. skill_name)
    if desc and desc ~= ":" .. skill_name then
      for _, name in ipairs(Fk:getAllCardNames("bt")) do
        if string.find(desc, "【" .. Fk:translate(name) .. "】", 1, true) then
          table.insertIfNeed(names, name)
        end
      end
    end
  end
  return player:getViewAsCardNames(niwoqianzhun.name, names)
end

local function tag_length_names(player, target)
  local tags = 0
  for _, skill_name in ipairs(target:getSkillNameList()) do
    local skill = Fk.skills[skill_name]
    local skeleton = skill and skill:getSkeleton()
    if skeleton then tags = tags + #(skeleton.tags or {}) end
  end
  local x = tags + 1
  local names = table.filter(Fk:getAllCardNames("bt"), function(name)
    local card = Fk:cloneCard(name)
    return card and (card.type == Card.TypeBasic or card:isCommonTrick()) and
      card:getNameLength() == x
  end)
  return player:getViewAsCardNames(niwoqianzhun.name, names)
end

local function use_one(room, player, names, prompt)
  if #names == 0 then return end
  local chosen = U.askForChooseCardNames(room, player, names, 1, 1,
    niwoqianzhun.name, prompt, names, false)[1]
  if chosen then
    room:askToUseVirtualCard(player, {
      name = chosen,
      skill_name = niwoqianzhun.name,
      prompt = "#niwoqianzhun-use",
      cancelable = false,
      extra_data = { bypass_times = true },
    })
  end
end

niwoqianzhun:addEffect("active", {
  anim_type = "control",
  prompt = "#niwoqianzhun",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(niwoqianzhun.name, Player.HistoryTurn) == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and
      (#description_names(player, to_select) > 0 or #tag_length_names(player, to_select) > 0)
  end,
  on_use = function(self, room, effect)
    local player, to = effect.from, effect.tos[1]
    local by_desc, by_tags = description_names(player, to), tag_length_names(player, to)
    local choices = {}
    if #by_desc > 0 then table.insert(choices, "niwoqianzhun_opt1") end
    if #by_tags > 0 then table.insert(choices, "niwoqianzhun_opt2") end
    local choice = #choices == 1 and choices[1] or room:askToChoice(player, {
      choices = choices,
      skill_name = niwoqianzhun.name,
      prompt = "#niwoqianzhun-choice",
    })
    if choice == "niwoqianzhun_opt1" then
      use_one(room, player, by_desc, "#niwoqianzhun-card")
    else
      use_one(room, player, by_tags, "#niwoqianzhun-cardlen")
    end
  end,
})

return niwoqianzhun
