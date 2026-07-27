local niwofuxue = fk.CreateSkill{ name = "niwofuxue" }
local CARD_MARK = "@@niwotianmeng"

local function count_mo(player)
  return #table.filter(player:getCardIds("hej"), function(id) return Fk:getCardById(id):getMark(CARD_MARK) > 0 end)
end

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwofuxue.name) and data.to and data.to:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = niwofuxue.name, prompt = "#niwofuxue-invoke::" .. data.to.id })
  end,
  on_use = function(self, event, target, player, data)
    local room, x = player.room, count_mo(data.to)
    room:loseHp(player, 1, niwofuxue.name)
    if player.dead then return end
    local choice = room:askToChoice(player, { choices = { "niwofuxue_damage", "niwofuxue_recover" }, skill_name = niwofuxue.name, prompt = "#niwofuxue-choice:::" .. x })
    if choice == "niwofuxue_damage" then
      data:changeDamage(x)
      player:drawCards(2 * x, niwofuxue.name)
    elseif x > 0 and player:isWounded() then
      room:recover{ who = player, num = x, skillName = niwofuxue.name }
    end
  end,
}
niwofuxue:addEffect(fk.DamageCaused, spec)
niwofuxue:addEffect(fk.DamageInflicted, spec)

Fk:loadTranslationTable{
  ["#niwofuxue-invoke"] = "复雪：是否失去1点体力，根据 %dest 的“殁”数修改伤害？",
  ["#niwofuxue-choice"] = "复雪：X为%arg，选择一项",
  ["niwofuxue_damage"] = "伤害+X，然后摸2X张牌",
  ["niwofuxue_recover"] = "恢复X点体力",
}
return niwofuxue
