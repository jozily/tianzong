local niwoxiangming = fk.CreateSkill{
  name = "niwoxiangming",
}

local function get_gainable(ids)
  return table.filter(ids, function(id)
    local c = Fk:getCardById(id)
    return c and (c.is_damage_card or c.sub_type == Card.SubtypeWeapon)
  end)
end

niwoxiangming:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niwoxiangming.name)
  end,
  on_cost = function(self, event, target, player, data)
    local x = player.hp
    return player.room:askToSkillInvoke(player, {
      skill_name = niwoxiangming.name,
      prompt = "#niwoxiangming-invoke:::" .. x,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = math.max(0, player.hp)
    if x == 0 or #room.draw_pile == 0 then return end

    local top_ids = room:getNCards(x, "top")
    local bottom_ids = room:getNCards(x, "bottom")
    local show_ids = table.connect(top_ids, bottom_ids)

    if #show_ids == 0 then return end

    room:turnOverCardsFromDrawPile(player, show_ids, niwoxiangming.name)

    local gainable = get_gainable(show_ids)
    local rest = table.filter(show_ids, function(id)
      return not table.contains(gainable, id)
    end)

    local direct_gain = table.filter(gainable, function(id)
      local c = Fk:getCardById(id)
      return c and c.sub_type ~= Card.SubtypeWeapon
    end)
    if #direct_gain > 0 then
      room:obtainCard(player, direct_gain, false, fk.ReasonPrey, player, niwoxiangming.name)
    end

    local weapons = table.filter(gainable, function(id)
      local c = Fk:getCardById(id)
      return c and c.sub_type == Card.SubtypeWeapon
    end)
    for _, id in ipairs(weapons) do
      local c = Fk:getCardById(id)
      if room:askToSkillInvoke(player, {
        skill_name = niwoxiangming.name,
        prompt = "#niwoxiangming-equip:::" .. c:toLogString(),
      }) then
        room:moveCardTo(id, Card.PlayerEquip, player, fk.ReasonPut, niwoxiangming.name, nil, false, player)
      else
        room:obtainCard(player, id, false, fk.ReasonPrey, player, niwoxiangming.name)
      end
    end

    if #rest > 0 then
      room:askToGuanxing(player, {
        cards = rest,
        top_limit = { 0, #rest },
        bottom_limit = { 0, #rest },
        skill_name = niwoxiangming.name,
      })
    end
  end,
})

return niwoxiangming
