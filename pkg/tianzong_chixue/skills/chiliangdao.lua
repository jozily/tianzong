local chiliangdao = fk.CreateSkill{
  name = "chiliangdao",
  dynamic_desc = function(self, player, lang)
    -- 无房间/无体力（选将、技能一览）时回退静态描述
    if not player or not player.room then return "" end
    local nameBoost = player:getMark("chifushui_name_round") > 0
    local colorBoost = player:getMark("chifushui_color_round") > 0
    local s1 = nameBoost and "chiliangdao_dyn_name" or ""
    local s2 = colorBoost and "chiliangdao_dyn_color" or ""
    return "chiliangdao_dyn:" .. s1 .. ":" .. s2
  end,
}
local NAME_MARK = "chiliangdao_names"
local ROUND_MARK = "chiliangdao_used-round"

-- 动态描述：{1}=覆水选项1（每轮限一次），{2}=覆水选项2（替换条件增加颜色相同）
Fk:loadTranslationTable{
  [":chiliangdao_dyn"] = "每种牌名限一次。当你使用的牌即将生效，且此牌不为响应而使用或打出时，你可以在本次结算中将此牌牌面描述上的任意牌名替换为与其字数相等的其他牌名。{1}{2}",
  ["chiliangdao_dyn_name"] = "（覆水已强化：改为每轮限一次。）",
  ["chiliangdao_dyn_color"] = "（覆水已强化：替换条件增加颜色相同。）",
}

local function candidates(player, source)
  local result = {}
  for _, name in ipairs(Fk:getAllCardNames("bt")) do
    local card = Fk:cloneCard(name)
    if card.name ~= source.name and (card.type == Card.TypeBasic or card:isCommonTrick()) then
      local same_length = card:getNameLength(true) == source:getNameLength(true)
      local same_color = player:getMark("chifushui_color_round") > 0 and source.color ~= Card.NoColor and card.color == source.color
      if same_length or same_color then table.insertIfNeed(result, name) end
    end
  end
  return result
end

chiliangdao:addEffect(fk.CardEffecting, {
  can_trigger = function(self, event, target, player, data)
    if data.from ~= player or not player:hasSkill(chiliangdao.name) or not data.card or data.responseToEvent then return false end
    if player:getMark("chifushui_name_round") > 0 and player:getMark(ROUND_MARK) > 0 then return false end
    if player:getMark("chifushui_name_round") == 0 and table.contains(player:getTableMark(NAME_MARK), data.card.name) then return false end
    return #candidates(player, data.card) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local choices = candidates(player, data.card)
    table.insert(choices, "Cancel")
    -- detailed 列表 UI：每个牌名一行并附其卡牌说明
    local choice = player.room:askToChoice(player, { choices = choices, skill_name = chiliangdao.name, prompt = "#chiliangdao-choice::" .. target.id, detailed = true })
    if choice ~= "Cancel" then event:setCostData(self, { choice = choice }); return true end
  end,
  on_use = function(self, event, target, player, data)
    local original = data.card
    local replacement = Fk:cloneCard(event:getCostData(self).choice, original.suit, original.number)
    replacement.skillName = chiliangdao.name
    replacement:addSubcards(Card:getIdList(original))
    -- 只替换效果层的牌（CardEffect:main 用 data.card 取 skill 结算新效果）。
    -- 切勿改 data.use.card：use 层的 onAction 需继续用原牌，五谷丰登等牌的
    -- closeAG 收尾才能执行，否则亮出的牌会一直留在桌面。
    data.card = replacement
    if player:getMark("chifushui_name_round") > 0 then player.room:setPlayerMark(player, ROUND_MARK, 1)
    else player.room:addTableMarkIfNeed(player, NAME_MARK, original.name) end
  end,
})

return chiliangdao
