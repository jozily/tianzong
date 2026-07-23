local niwotianmeng = fk.CreateSkill{
  name = "niwotianmeng",
}

local MARK = "niwotianmeng_mark"

niwotianmeng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player 
      and player:hasSkill(niwotianmeng.name)
      and player:usedSkillTimes(niwotianmeng.name, Player.HistoryRound) == 0
      and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, niwotianmeng.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isAlive() then
        table.insert(targets, p.id)
      end
    end
    
    if #targets == 0 then return end
    
    local target_id = room:askToChoose(player, targets, niwotianmeng.name, "#niwotianmeng-choose")
    local target_player = room:getPlayerById(tonumber(target_id))
    
    if not target_player then return end
    
    local cards = {}
    for _, id in ipairs(target_player:getCardIds("he")) do
      table.insert(cards, id)
    end
    
    if #cards == 0 then return end
    
    local choice_card = room:askToChoose(player, cards, niwotianmeng.name, "#niwotianmeng-card")
    local card_id = tonumber(choice_card)
    
    room:setPlayerMark(player, MARK .. "_" .. target_player.id .. "_" .. card_id, 1)
    room:addTableMark(player, MARK, 1)
  end,
})

niwotianmeng:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwotianmeng.name) then return false end
    if not data.from or not data.from:isAlive() then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, niwotianmeng.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isAlive() then
        table.insert(targets, p.id)
      end
    end
    
    if #targets == 0 then return end
    
    local target_id = room:askToChoose(player, targets, niwotianmeng.name, "#niwotianmeng-choose")
    local target_player = room:getPlayerById(tonumber(target_id))
    
    if not target_player then return end
    
    local cards = {}
    for _, id in ipairs(target_player:getCardIds("he")) do
      table.insert(cards, id)
    end
    
    if #cards == 0 then return end
    
    local choice_card = room:askToChoose(player, cards, niwotianmeng.name, "#niwotianmeng-card")
    local card_id = tonumber(choice_card)
    
    room:setPlayerMark(player, MARK .. "_" .. target_player.id .. "_" .. card_id, 1)
  end,
})

niwotianmeng:addEffect("viewas", {
  pattern = ".",
  prompt = "#niwotianmeng",
  
  interaction = function(self, player)
    local marks = player:getTableMark(MARK)
    if not marks or #marks == 0 then return end
    
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(niwotianmeng.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = "",
    subcards = {}
  },
  
  card_filter = function(self, to_filter, player, focused)
    local marks = player:getTableMark("niwotianmeng_mark")
    if not marks or #marks == 0 then return false end
    
    for _, mark_key in ipairs(marks) do
      if string.match(mark_key, to_filter) then
        return true
      end
    end
    return false
  end,
  
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction or not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = niwotianmeng.name
    return card
  end,
})

niwotianmeng:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwotianmeng.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, MARK, 0)
  end,
})

return niwotianmeng
