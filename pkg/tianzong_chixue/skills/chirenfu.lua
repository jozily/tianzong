-- chirenfu.lua (荏腹)
local chirenfu = fk.CreateSkill{
  name = "chirenfu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chirenfu"] = "荏腹",
  [":chirenfu"] = "锁定技，当你每回合首次使用普通锦囊牌时，你摸已使用基本牌数量张牌。若摸牌数小于2，你受到来自当前回合角色的一点雷属性伤害，且若不为你的回合，你移动你与其一张牌。（无法移动则改为手牌少的获得手牌多的一方一张手牌）。",
  ["#chirenfu-exchange"] = "荏腹：选择一张牌与 %dest 交换",
}

chirenfu:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card:isCommonTrick() and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    
    -- 计算已使用的基本牌数量
    local usedBasicCount = 0
    -- 这里需要根据引擎版本的历史记录方式来获取
    local history = room.logic:getEventsByRule("UseCard", Player.HistoryRound)
    for _, ev in ipairs(history) do
      if ev.data.card.type == Card.TypeBasic then
        usedBasicCount = usedBasicCount + 1
      end
    end
    
    player:drawCards(usedBasicCount, skillName)
    
    -- 如果摸牌数小于2
    if usedBasicCount < 2 then
      -- 受到来自当前回合角色的一点雷属性伤害
      local current_player = room.current.player
      if current_player and current_player:isAlive() then
        room:damage({
          to = player,
          from = current_player,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = skillName,
        })
      end
      
      -- 如果不是自己的回合，移动一张牌
      if player ~= current_player and player:isAlive() and current_player:isAlive() then
        local playerCards = player:getCardIds("he")
        local otherCards = current_player:getCardIds("he")
        
        if #playerCards > 0 and #otherCards > 0 then
          local playerChoice = room:askToChooseCards(
            player,
            {
              min = 1,
              max = 1,
              flag = "he",
              skill_name = skillName,
              prompt = "#chirenfu-exchange::" .. current_player.id,
            }
          )
          
          if #playerChoice > 0 then
            local otherChoice = room:askToChooseCards(
              current_player,
              {
                min = 1,
                max = 1,
                flag = "he",
                skill_name = skillName,
                prompt = "#chirenfu-exchange::" .. player.id,
              }
            )
            
            if #otherChoice > 0 then
              room:moveCards({
                {
                  ids = playerChoice,
                  from = player.id,
                  to = current_player.id,
                  toArea = Card.PlayerHand,
                  reason = fk.ReasonGive,
                  skillName = skillName,
                },
                {
                  ids = otherChoice,
                  from = current_player.id,
                  to = player.id,
                  toArea = Card.PlayerHand,
                  reason = fk.ReasonGive,
                  skillName = skillName,
                },
              })
            end
          end
        elseif #playerCards == 0 and #otherCards > 0 then
          -- 手牌少的获得手牌多的一张手牌
          local choice = room:askToChooseCards(
            current_player,
            {
              min = 1,
              max = 1,
              flag = "h",
              skill_name = skillName,
            }
          )
          if #choice > 0 then
            room:moveCards({
              ids = choice,
              from = current_player.id,
              to = player.id,
              toArea = Card.PlayerHand,
              reason = fk.ReasonGive,
              skillName = skillName,
            })
          end
        end
      end
    end
  end,
})

return chirenfu
