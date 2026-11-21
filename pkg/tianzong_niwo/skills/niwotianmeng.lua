-- 殄梦（赵娥）
-- 出牌阶段开始时或当你受到伤害后，你可以明置你与一名角色的一张手牌成为“殁”。
--
-- 转化（原在本技能的 active 二选一里）按新文案归入【承痕】①，
-- 故本技能只负责“明置手牌成为殁”。viewas 仍在 niwotianmeng_use.lua，
-- 由【承痕】通过 addAcquireEffect 授予本人（名字以 & 结尾，不占技能栏）。
local niwotianmeng = fk.CreateSkill{
  name = "niwotianmeng",
}

local CARD_MARK = "@@niwo_mo"
local OWNER_MARK = "niwo_mo_owner"

local function update_marks(room)
  for _, p in ipairs(room.alive_players) do
    local n = #table.filter(p:getCardIds("hej"), function(id)
      return Fk:getCardById(id):getMark(CARD_MARK) > 0
    end)
    room:setPlayerMark(p, "@niwo_mo", n)
  end
end

niwotianmeng:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(niwotianmeng.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    update_marks(player.room)
  end,
})

local function valid_mark_targets(player)
  return table.filter(player.room:getOtherPlayers(player), function(p)
    return #p:getCardIds("h") > 0
  end)
end

-- 明置你与一名角色各一张手牌，成为“殁”
local function reveal_mo(room, player, target)
  if target.dead or #target:getCardIds("h") == 0 or #player:getCardIds("h") == 0 then return end
  local own = room:askToCards(player, {
    min_num = 1, max_num = 1, pattern = ".|.|.|hand",
    skill_name = niwotianmeng.name, prompt = "#niwotianmeng-selfcard", cancelable = false,
  })
  if #own == 0 then return end
  local other = room:askToChooseCard(player, {
    target = target, flag = "h", skill_name = niwotianmeng.name,
    prompt = "#niwotianmeng-targetcard::" .. target.id,
  })
  if not other then return end
  room:showCards({ own[1], other }, player)
  local own_card, other_card = Fk:getCardById(own[1]), Fk:getCardById(other)
  room:setCardMark(own_card, CARD_MARK, 1)
  room:setCardMark(own_card, OWNER_MARK, player.id)
  room:setCardMark(other_card, CARD_MARK, 1)
  room:setCardMark(other_card, OWNER_MARK, target.id)
end

-- 出牌阶段开始时
niwotianmeng:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwotianmeng.name)
      and data.phase == Player.Play
      and #player:getCardIds("h") > 0
      and #valid_mark_targets(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = valid_mark_targets(player), min_num = 1, max_num = 1,
      skill_name = niwotianmeng.name, prompt = "#niwotianmeng-choose", cancelable = true,
    })
    if #tos > 0 then event:setCostData(self, { to = tos[1] }); return true end
  end,
  on_use = function(self, event, target, player, data)
    reveal_mo(player.room, player, event:getCostData(self).to)
  end,
})

-- 当你受到伤害后
niwotianmeng:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwotianmeng.name)
      and #player:getCardIds("h") > 0
      and #valid_mark_targets(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = valid_mark_targets(player), min_num = 1, max_num = 1,
      skill_name = niwotianmeng.name, prompt = "#niwotianmeng-choose", cancelable = true,
    })
    if #tos > 0 then event:setCostData(self, { to = tos[1] }); return true end
  end,
  on_use = function(self, event, target, player, data)
    reveal_mo(player.room, player, event:getCostData(self).to)
  end,
})

return niwotianmeng
