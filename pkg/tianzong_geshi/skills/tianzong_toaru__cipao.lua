local cipao = fk.CreateSkill { name = "tianzong_toaru__cipao" }

Fk:loadTranslationTable {
  ["tianzong_toaru__cipao"] = "磁炮",
  [":tianzong_toaru__cipao"] = "每回合限一次，你可以将任意张牌名字数不同的牌当作一张不计入次数、无距离限制、伤害改为X且需要使用X张闪响应的雷【杀】使用或打出（X为以此法转化的牌数）。",
  ["#tianzong_toaru__cipao"] = "磁炮：将牌名字数不同的牌当作一张雷【杀】使用或打出",
}

-- 只有当转化的牌「牌名字数各不相同」时才生效（X=转化牌数）
local function allDifferentLengths(cards)
  if #cards < 1 then return false end
  local seen = {}
  for _, id in ipairs(cards) do
    local length = Fk:getCardById(id):getNameLength()
    if seen[length] then return false end
    seen[length] = true
  end
  return true
end

cipao:addEffect("viewas", {
  pattern = "thunder__slash",
  prompt = "#tianzong_toaru__cipao",
  filter_pattern = { min_num = 1, max_num = math.huge, pattern = "." },
  view_as = function(self, player, cards)
    if #cards == 0 or not allDifferentLengths(cards) then return end
    local card = Fk:cloneCard("thunder__slash")
    card:addSubcards(cards)
    card.skillName = cipao.name
    return card
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    use.extra_data = use.extra_data or {}
    -- X = 转化牌数；伤害改为 X、需 X 张闪
    use.extra_data.tianzong_toaru__cipao_x = #use.card.subcards
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(cipao.name, Player.HistoryPhase) == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:usedSkillTimes(cipao.name, Player.HistoryPhase) == 0
  end,
})

-- 无距离限制 + 需 X 张闪响应
cipao:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == cipao.name
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data) -- 无距离限制
    local x = data.use.extra_data and data.use.extra_data.tianzong_toaru__cipao_x
    if x then
      data.fixedResponseTimesList = data.fixedResponseTimesList or {}
      data.fixedResponseTimesList[data.to] = x
    end
  end,
})

-- 伤害改为 X
cipao:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == cipao.name
  end,
  on_refresh = function(self, event, target, player, data)
    local use = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    local x = use and use.data.extra_data and use.data.extra_data.tianzong_toaru__cipao_x
    if x then data.damage = x end
  end,
})

return cipao
