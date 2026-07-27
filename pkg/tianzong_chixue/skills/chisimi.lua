local U = require "packages.utility.utility"
local chisimi = fk.CreateSkill{ name = "chisimi", tags = { Skill.Switch, Skill.Compulsory } }

local function is_equal(player)
  local max_hp, hand = player.maxHp, player:getHandcardNum()
  local diff = math.abs(max_hp - hand)
  return max_hp == hand or max_hp == diff or hand == diff
end

local spec = {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chisimi.name) and player:usedSkillTimes(chisimi.name, Player.HistoryRound) == 0 and is_equal(player)
  end,
  on_use = function(self, event, target, player, data)
    local room, state = player.room, player:getSwitchSkillState(chisimi.name)
    U.SetSwitchSkillState(player, chisimi.name, state)
    if state == fk.SwitchYang then
      if room:random(1, 2) == 1 then player:drawCards(1, chisimi.name) else room:changeMaxHp(player, 1) end
    else
      local cards = player:getCardIds("he")
      if #cards > 0 and room:random(1, 2) == 1 then
        room:throwCard({ room:tableRandomPick(cards, 1)[1] }, chisimi.name, player, player)
      else
        room:changeMaxHp(player, -1)
      end
    end
  end,
}
chisimi:addEffect(fk.MaxHpChanged, spec)
chisimi:addEffect(fk.AfterCardsMove, spec)

return chisimi
