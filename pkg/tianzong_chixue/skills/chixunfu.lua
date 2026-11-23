local chixunfu = fk.CreateSkill{
  name = "chixunfu",
  tags = { Skill.Compulsory },
}

local RECORD_MARK = "@[chixunfu_names]xunxu-round"

-- 徇覆"已记录"mark：注册可点开的展开面板（复用剧本的记录列表框）
Fk:addQmlMark {
  name = "chixunfu_names",
  how_to_show = function(_, value)
    if type(value) ~= "table" then return "" end
    return #value > 0 and tostring(#value) or ""
  end,
  qml = function(mark, value)
    local items = {}
    if type(value) == "table" then
      table.insert(items, "【已记录牌名】")
      for _, name in ipairs(value) do
        table.insert(items, Fk:translate(name))
      end
    end
    return {
      url = "packages/tianzong/qml/JubenMarkBox.qml",
      prop = { name = mark, value = items },
    }
  end,
}

Fk:loadTranslationTable{
  ["chixunfu"] = "徇覆",
  [":chixunfu"] = "锁定技，当你成为一张本轮未以此法记录过的非装备牌的目标时，来源需展示另一种颜色的一张手牌，否则此牌对你无效，然后你记录此牌牌名。",
  ["#chixunfu-show"] = "徇覆：展示一张与此牌颜色不同的手牌，否则此牌对 %dest 无效",
  ["@[chixunfu_names]xunxu-round"] = "徇覆·已记录",
}

chixunfu:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chixunfu.name) and data.card and
      data.card.type ~= Card.TypeEquip and data.from and data.from:isAlive() and
      not table.contains(player:getTableMark(RECORD_MARK), data.card.trueName)
  end,
  on_use = function(self, event, target, player, data)
    local room, from = player.room, data.from
    local wanted = data.card.color == Card.Red and Card.Black or Card.Red
    local ids = table.filter(from:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == wanted
    end)
    local shown = {}
    if #ids > 0 then
      shown = room:askToCards(from, {
        min_num = 1,
        max_num = 1,
        pattern = tostring(Exppattern{ id = ids }),
        skill_name = chixunfu.name,
        prompt = "#chixunfu-show::" .. player.id,
        cancelable = true,
      })
    end
    if #shown > 0 then
      from:showCards(shown)
    else
      data.nullified = true
    end
    room:addTableMarkIfNeed(player, RECORD_MARK, data.card.trueName)
  end,
})

return chixunfu
