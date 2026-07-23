-- chishuji.lua (疏纪)
local chishuji = fk.CreateSkill{
  name = "chishuji",
  tags = { Skill.Contract },
  description = ":chishuji",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chishuji"] = "疏纪",
  [":chishuji"] = "契定技，当你每回合首次成为一张多目标锦囊牌的目标后，若此牌的合法目标数不小于你的手牌数，你弃置半数手牌（向下取整），并将此锦囊牌的目标数调整至与你手牌数相同（至少为1）。",
}

chishuji:addEffect(fk.TargetSpecified, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and
      data.card and data.card:isCommonTrick() and
      #data.tos > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local handCount = #player:getCardIds("h")
    local targetCount = #data.tos
    
    if targetCount >= handCount then
      local discard = math.floor(handCount / 2)
      if discard > 0 then
        local cards = player:getCardIds("h")
        local toDiscard = {}
        for i = 1, discard do
          table.insert(toDiscard, cards[i])
        end
        room:throwCard(toDiscard, skillName, player, player)
      end
      
      local newHandCount = #player:getCardIds("h")
      local newTargets = {}
      for i = 1, math.max(1, newHandCount) do
        if i <= #data.tos then
          table.insert(newTargets, data.tos[i])
        end
      end
      
      if #newTargets > 0 then
        data.tos = newTargets
      end
    end
  end,
})

return chishuji
