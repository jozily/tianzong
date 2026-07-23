local chikongyao = fk.CreateSkill{
  name = "chikongyao",
}

local GENERAL_MARK = "@$chimiling-generals"

Fk:loadTranslationTable{
  ["chikongyao"] = "空杳",
  [":chikongyao"] = "<b>锁定技，</b>当你即将受到伤害时，若你有\"麋\"，你弃置一张并防止此伤害。",
  ["#chikongyao_log"] = "%from 发动【空杳】，弃置了一张\"麋\"，防止了伤害",
  ["$chikongyao1"] = "万籁俱寂，空杳无声。",
  ["$chikongyao2"] = "归于虚无，便是你的终途。",
}

chikongyao:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if player ~= data.to then return false end
    if not player:hasSkill(chikongyao.name) then return false end
    
    local generals = player:getTableMark(GENERAL_MARK) or {}
    return #generals > 0 and data.from ~= nil
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = player:getTableMark(GENERAL_MARK) or {}
    
    if #generals == 0 then return end
    
    local selected = math.random(1, #generals)
    local newGenerals = {}
    for i = 1, #generals do
      if i ~= selected then
        table.insert(newGenerals, generals[i])
      end
    end
    
    room:setPlayerMark(player, GENERAL_MARK, newGenerals)
    data.damage = 0
    
    room:sendLog{
      type = "#chikongyao_log",
      from = player.id,
      to = data.from.id
    }
  end,
})

return chikongyao
