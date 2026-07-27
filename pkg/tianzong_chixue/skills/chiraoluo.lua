local common = require "packages/tianzong/pkg/tianzong_chixue/lib/common"

local chiraoluo = fk.CreateSkill{
  name = "chiraoluo",
}

local function can_gufu(player)
  return not player:isNude()
    and not table.contains(player.sealedSlots, Player.JudgeSlot)
    and common.get_unremoved_count(player) > 0
end

local function use_gufu(room, player)
  local max_num = common.get_unremoved_count(player)
  local cards = room:askToCards(player, {
    min_num = 1,
    max_num = max_num,
    include_equip = true,
    skill_name = chiraoluo.name,
    cancelable = false,
    pattern = ".|.|.|he",
    prompt = "#chiraoluo-gufu",
  })
  if #cards == 0 then return end

  local place = room:askToChoice(player, {
    choices = { "Top", "Bottom" },
    skill_name = chiraoluo.name,
    prompt = "#chiraoluo-gufu-place",
  })
  room:recastCard(cards, player, chiraoluo.name)
  common.premeditate_n(room, player, #cards, place == "Bottom" and "bottom" or "top", chiraoluo.name)
end

local function discard_from_area(room, chooser, target)
  if target:isAllNude() then return false end
  local id = room:askToChooseCard(chooser, {
    target = target,
    flag = "hej",
    skill_name = chiraoluo.name,
    prompt = "#chiraoluo-discard::" .. target.id,
  })
  if not id or id == -1 then return false end
  room:throwCard({ id }, chiraoluo.name, target, chooser)
  return true
end

local function choose_target(room, player)
  local targets = room.alive_players
  local chosen = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    skill_name = chiraoluo.name,
    prompt = "#chiraoluo-choose",
    cancelable = true,
  })
  return #chosen > 0 and chosen[1] or nil
end

local function do_chiraoluo(room, player)
  local target = choose_target(room, player)
  if not target or target.dead then return end

  local can_gufu_now = can_gufu(target)
  local can_discard_now = not target:isAllNude()
  local choices = {}
  if can_gufu_now then table.insert(choices, "chiraoluo_opt1") end
  if can_discard_now then table.insert(choices, "chiraoluo_opt2") end
  if can_gufu_now and can_discard_now then table.insert(choices, "chiraoluo_opt3") end
  if #choices == 0 then return end

  local choice = #choices == 1 and choices[1] or room:askToChoice(target, {
    choices = choices,
    skill_name = chiraoluo.name,
    prompt = "#chiraoluo-choice::" .. player.id,
  })

  if choice == "chiraoluo_opt1" then
    use_gufu(room, target)
  elseif choice == "chiraoluo_opt2" then
    discard_from_area(room, player, target)
  elseif choice == "chiraoluo_opt3" then
    if not discard_from_area(room, player, target) then return end
    use_gufu(room, target)
    if not target.dead and not target:isAllNude() then
      discard_from_area(room, player, target)
    end
    if not target.dead then
      room:turnOver(target)
    end
  end
end

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiraoluo.name) and not player.dead
      and table.find(player.room.alive_players, function(p) return not p:isAllNude() end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chiraoluo.name,
      prompt = "#chiraoluo-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    do_chiraoluo(player.room, player)
  end,
}

chiraoluo:addEffect(fk.Damaged, spec)
chiraoluo:addEffect(fk.CardRespondFinished, spec)

Fk:loadTranslationTable{
  ["#chiraoluo-invoke"] = "扰洛：是否弃置一名角色区域内的一张牌？",
  ["#chiraoluo-choose"] = "扰洛：请选择一名有牌的角色",
  ["#chiraoluo-discard"] = "扰洛：弃置 %dest 区域内的一张牌",
  ["#chiraoluo-choice"] = "扰洛：请选择一项",
  ["chiraoluo_opt1"] = "发动一次孤凫",
  ["chiraoluo_opt2"] = "弃置其区域内的一张牌",
  ["chiraoluo_opt3"] = "背水：依次执行前两项，然后翻面",
  ["#chiraoluo-gufu"] = "扰洛：请选择要重铸的牌",
  ["#chiraoluo-gufu-place"] = "扰洛：请选择从牌堆顶或牌堆底蓄谋",
}

return chiraoluo
