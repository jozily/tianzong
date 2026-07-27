local chicangsui_draw = fk.CreateSkill{
  name = "chicangsui_draw",
}

local USED_MARK = "chicangsui_used-turn"

local function get_after_abort_len(player)
  local aborted = 5 - #player:getAvailableEquipSlots()
  return math.max(1, aborted + 1)
end

local function get_names_by_len(len)
  local all_names = Fk:getAllCardNames("bt")
  return table.filter(all_names, function(name)
    local c = Fk:cloneCard(name)
    return c and c:getNameLength(true) == len
  end)
end

local function ask_abort_slot(room, player)
  local choices = table.simpleClone(player:getAvailableEquipSlots())
  table.insert(choices, "Cancel")
  local all_choices = {
    "WeaponSlot",
    "ArmorSlot",
    "DefensiveRideSlot",
    "OffensiveRideSlot",
    "TreasureSlot",
    "Cancel",
  }
  return room:askToChoice(player, {
    choices = choices,
    all_choices = all_choices,
    skill_name = "chicangsui",
    prompt = "#$chicangsui-choice",
  })
end

chicangsui_draw:addEffect("active", {
  anim_type = "drawcard",
  prompt = function(self, player)
    local x = get_after_abort_len(player)
    return "#chicangsui-status:::" .. x .. ":chicangsui_unavailable"
  end,
  card_num = 0,
  target_num = 0,

  can_use = function(self, player)
    if player.phase ~= Player.Play then return false end
    if player:getMark(USED_MARK) ~= 0 then return false end
    if #player:getAvailableEquipSlots() == 0 then return false end

    local x = get_after_abort_len(player)
    local all_names = get_names_by_len(x)
    return #player:getViewAsCardNames("chicangsui", all_names) == 0
  end,

  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,

  on_use = function(self, room, effect)
    local player = effect.from
    local choice = ask_abort_slot(room, player)
    if choice == "Cancel" then return end
    room:abortPlayerArea(player, { choice })
    room:setPlayerMark(player, USED_MARK, 1)

    local x = math.max(1, 5 - #player:getAvailableEquipSlots())
    player:drawCards(x, "chicangsui")
  end,
})

return chicangsui_draw
