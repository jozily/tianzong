local chifeichen = fk.CreateSkill{ name = "chifeichen" }

chifeichen:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chifeichen.name)
      and data.from and data.from:isAlive()
      and data.card and data.card.color == Card.Red
      and player:usedSkillTimes(chifeichen.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = chifeichen.name, prompt = "#chifeichen-invoke::" .. data.from.id })
  end,
  on_use = function(self, event, target, player, data)
    local source = data.from
    source:showCards(source:getCardIds("h"))
    local same_type_red = table.find(source:getCardIds("h"), function(id)
      local card = Fk:getCardById(id)
      return card.color == Card.Red and card.type == data.card.type
    end)
    if not same_type_red then
      -- 引擎结算时读取的是 useCardData.additionalEffect（见 server/events/usecard.lua），
      -- 之前写在 AimData 的 data.additionalEffect 上不会生效，锦囊因此不会二次结算。
      if data.use then
        data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
      end
      data.additionalEffect = (data.additionalEffect or 0) + 1
    end
  end,
})

return chifeichen
