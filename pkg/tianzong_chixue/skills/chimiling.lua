local chimiling = fk.CreateSkill{
  name = "chimiling",
}

local GENERAL_MARK = "@$chimiling-generals"
local RECORD_MARK = "@$chimiling-record"

Fk:loadTranslationTable{
  ["chimiling"] = "麋灵",
  [":chimiling"] = "<b>锁定技，</b>当你使用牌时，若此牌牌名字数你未以此法记录过，你记录之并将等量张武将牌置于你的武将牌上，称为\"麋\"；每轮开始时，你清除所有记录和\"麋\"。",
  ["#chimiling_log"] = "%from 发动【麋灵】，获得了%arg张\"麋\"",
  ["$chimiling1"] = "林深时见鹿，梦醒时见你。",
  ["$chimiling2"] = "万物有灵，生生不息。",
}

chimiling:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(chimiling.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    local cardName = card:getName()
    local nameLength = card:getNameLength()
    local recorded = player:getTableMark(RECORD_MARK) or {}
    
    if not table.contains(recorded, cardName) then
      table.insert(recorded, cardName)
      room:setPlayerMark(player, RECORD_MARK, recorded)
      
      local generals = player:getTableMark(GENERAL_MARK) or {}
      for i = 1, nameLength do
        table.insert(generals, "lu_" .. player.id .. "_" .. #generals + 1)
      end
      room:setPlayerMark(player, GENERAL_MARK, generals)
      
      room:sendLog{
        type = "#chimiling_log",
        from = player.id,
        arg = nameLength
      }
    end
  end,
})

chimiling:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(chimiling.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, RECORD_MARK, {})
    room:setPlayerMark(player, GENERAL_MARK, {})
  end,
})

return chimiling
