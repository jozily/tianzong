-- chisimi.lua (澌弭)
local chisimi = fk.CreateSkill{
  name = "chisimi",
  tags = { Skill.Switch },
  description = ":chisimi",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local state = player:getSwitchSkillState(self.name)
    local maxHp = player:getMaxHp()
    local handCount = #player:getCardIds("h")
    local diff = math.abs(handCount - maxHp)
    
    local stateStr = state == fk.SwitchYang and "◆阳" or "◇阴"
    return "澌弭" .. stateStr .. " 手" .. handCount .. "|体" .. maxHp .. "|差" .. diff
  end,
}

Fk:loadTranslationTable{
  ["chisimi"] = "澌弭",
  [":chisimi"] = "转换技，锁定技，当你的体力上限、手牌数或二者差值任意两个每轮首次相等后，你随机执行：①摸一张牌或增加一点体力上限；②随机弃置一张牌或失去一点体力上限。",
}

chisimi:addEffect(fk.HpChanged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    local state = player:getSwitchSkillState(skillName)
    local choice = math.random(1, 2)
    
    if state == fk.SwitchYang then
      if choice == 1 then
        player:drawCards(1, skillName)
      else
        room:changeMaxHp(player, 1)
      end
    else
      if choice == 1 then
        local ids = player:getCardIds("he")
        if #ids > 0 then
          room:throwCard({ids[math.random(1, #ids)]}, skillName, player, player)
        end
      else
        room:changeMaxHp(player, -1)
      end
    end
  end,
})

return chisimi
