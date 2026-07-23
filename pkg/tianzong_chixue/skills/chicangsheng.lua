local chicangsheng = fk.CreateSkill{
  name = "chicangsheng",
}

local GENERAL_MARK = "@$chimiling-generals"

local function getTargetsNum(player, card)
  if player:prohibitUse(card) or not player:canUse(card) then return 0 end
  if card.skill:getMinTargetNum() == 0 and not card.multiple_targets then
    return 1
  else
    local x = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if not player:isProhibited(p, card) and card.skill:modTargetFilter(player, p, {}, card) then
        x = x + 1
      end
    end
    return x
  end
end

Fk:loadTranslationTable{
  ["chicangsheng"] = "苍生",
  [":chicangsheng"] = "<b>转换技，</b>你可以弃置X张\"麋\"视为使用或打出一张：①（阳）牌名字数为X的基本牌或普通锦囊牌；②（阴）合法目标数为X的基本牌或普通锦囊牌。",
  ["#chicangsheng"] = "苍生：选择弃置的\"麋\"数量",
  ["#chicangsheng-yang"] = "苍生-阳：弃置%arg张\"麋\"",
  ["#chicangsheng-yin"] = "苍生-阴：弃置%arg张\"麋\"",
  ["$chicangsheng1"] = "以此身，换取苍生之念。",
  ["$chicangsheng2"] = "一念为苍生，一念为己身。",
}

chicangsheng:addEffect("active", {
  anim_type = "control",
  prompt = "#chicangsheng",
  card_num = 0,
  target_num = 0,
  interaction = function(self, player)
    local generals = player:getTableMark(GENERAL_MARK) or {}
    local maxNum = #generals
    if maxNum == 0 then return end
    return UI.Spin {
      from = 1,
      to = maxNum,
    }
  end,
  can_use = function(self, player)
    local generals = player:getTableMark(GENERAL_MARK) or {}
    return #generals > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local num = self.interaction.data
    if not num or num == 0 then return end
    
    local generals = player:getTableMark(GENERAL_MARK) or {}
    if #generals < num then return end
    
    local newGenerals = {}
    for i = 1, #generals do
      if i > num then
        table.insert(newGenerals, generals[i])
      end
    end
    room:setPlayerMark(player, GENERAL_MARK, newGenerals)
    
    local choice = room:askToChoice(player, {
      choices = {"yang", "yin"},
      skill_name = "chicangsheng"
    })
    
    if choice == "yang" then
      room:sendLog{
        type = "#chicangsheng-yang",
        from = player.id,
        arg = num
      }
    else
      room:sendLog{
        type = "#chicangsheng-yin",
        from = player.id,
        arg = num
      }
    end
  end,
})

return chicangsheng
