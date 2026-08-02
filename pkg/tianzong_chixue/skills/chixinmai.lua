-- chixinmai.lua (薪脉)
local chixinmai = fk.CreateSkill{
  name = "chixinmai",
  description = ":chixinmai",
  anim_type = "support",
  dynamic_desc = function(self, player, lang)
    if not player then return "" end
    local used = player:usedSkillTimes(self.name, Player.HistoryRound)
    return "薪脉：" .. (used == 0 and "可用✓" or "已用✗")
  end,
}

Fk:loadTranslationTable{
  ["chixinmai"] = "薪脉",
  ["#chixinmai-choose"] = "薪脉：选择一项",
  ["chixinmai1"] = "对选中角色造成一点雷属性伤害",
  ["chixinmai2"] = "其非属性杀视为无懈可击",
}

chixinmai:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  target_filter = function(self, to_select, selected)
    return Fk:currentRoom().players[to_select] ~= Fk:currentRoom().current.player
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    if #targets == 0 then return end
    
    local target = room:getPlayerById(targets[1])
    local skillName = self.name
    
    local slashes = {}
    for _, card in ipairs(room.discard_pile) do
      if card.name == "slash" then
        table.insert(slashes, card.id)
      end
    end
    
    if #slashes > 0 then
      for _, id in ipairs(slashes) do
        room:moveCards({
          ids = { id },
          to = target.id,
          toArea = Card.PlayerHand,
          reason = fk.ReasonJustMove,
          skillName = skillName,
        })
      end
    end
    
    local choices = { "chixinmai1", "chixinmai2" }
    local choice = room:askToChoice(target, {
      choices = choices, skill_name = skillName, prompt = "#chixinmai-choose",
    })
    
    if choice == "chixinmai1" then
      room:damage({
        to = target,
        from = player,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = skillName,
      })
    else
      target:setMark("chixinmai_slash_mark", 1)
    end
  end,
})

chixinmai:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    -- 同active效果
  end,
})

return chixinmai
