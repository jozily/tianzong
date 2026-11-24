local MODIFY_MARK = "tianzong_geshi__canbei_modified"
local INVALID_MARK = "tianzong_geshi__canbei_invalid"
-- 失效状态的可见文字 mark（@[...] 前缀才会显示在武将牌旁）
local INVALID_SHOW = "@[tianzong_geshi__canbei_invalid]"

local canbei = fk.CreateSkill{
  name = "tianzong_geshi__canbei",
  -- 修改后的描述不再作为主描述切换，改为基础描述里的重定向链接指向
  -- （<a href=':tianzong_geshi__canbei_up'>参北</a>，衍生技样式展示）。
}

-- 参北的消耗与结算，基础与修改后共用
local canbeiOnCost = function(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, {
    skill_name = canbei.name,
    prompt = "#tianzong_geshi__canbei-invoke",
  })
end

local canbeiOnUse = function(self, event, target, player, data)
  local room = player.room
  local old_hp = player.hp
  local lost = player.maxHp - old_hp
  local diff = math.abs(lost - old_hp)
  -- 体力值与已损失体力值相同时差值为 0，摸牌数至少为 1
  if diff < 1 then diff = 1 end
  -- 先自我失效，避免 setPlayerProperty 触发的再次 HpChanged 递归
  room:setPlayerMark(player, INVALID_MARK, 1)
  -- 技能图标加锁（官方 invalidateSkill 令技能在技能栏置灰加锁）
  room:invalidateSkill(player, canbei.name)
  -- 显示文字 mark「参北·失效」
  room:setPlayerMark(player, INVALID_SHOW, 1)
  if lost ~= old_hp then
    room:setPlayerProperty(player, "hp", lost)
    -- setPlayerProperty 直接写 hp，不经过 ChangeHp:main 的濒死判定；
    -- 体力被交换到 0 以下时必须手动触发濒死，否则会"没血却不死、还能继续出牌"
    if player.hp < 1 then
      room:enterDying({ who = player })
    end
  end
  if not player.dead then
    player:drawCards(diff, canbei.name)
  end
end

-- 体力值变化后，交换体力值与已损失体力值并摸差值张牌，
-- 然后此技能失效直至有角色进入濒死状态。
-- 参北被修改后，额外要求「你未处于濒死状态」才能发动。
canbei:addEffect(fk.HpChanged, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(canbei.name)
      and player:getMark(INVALID_MARK) == 0
      and player.hp >= 0 and player.hp <= player.maxHp
      and (player:getMark(MODIFY_MARK) == 0 or not player.dying)
  end,
  on_cost = canbeiOnCost,
  on_use = canbeiOnUse,
})

-- 此技能失效直至有角色进入濒死状态：任意角色濒死都令参北恢复。
-- 注意：此前已 invalidateSkill，player:hasSkill(canbei.name) 会返回 false，
-- 故此处不能依赖 hasSkill，改用 INVALID_MARK 判断。
-- 用 refresh 通道（对所有在场 player 调用），确保技能失效时仍能触发。
canbei:addEffect(fk.EnterDying, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return not target.dead
      and player:getMark(INVALID_MARK) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 解除技能图标锁
    room:validateSkill(player, canbei.name)
    -- 清除失效文字 mark
    room:setPlayerMark(player, INVALID_SHOW, 0)
    room:setPlayerMark(player, INVALID_MARK, 0)
  end,
})

-- 若进入濒死的角色为你，你修改「参北」——
-- 此后发动参北需满足「你未处于濒死状态」。
-- 修改独立于失效恢复：任何时候你自己进入濒死都会修改，
-- 不要求参北正处于失效状态。
-- 用 hasSkill(name, true) 忽略失效，确保参北失效期间自己濒死也能识别到技能。
canbei:addEffect(fk.EnterDying, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and not target.dead
      and player:hasSkill(canbei.name, true)
      and player:getMark(MODIFY_MARK) == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, MODIFY_MARK, 1)
  end,
})

-- @[...] 形式的 mark 必须在客户端注册 qml_mark spec；
-- 否则 GetQmlMark 因找不到 spec 返回空表，QML 取 data.text 得到 undefined，
-- 武将牌旁就会显示「参北失效 undefined」。how_to_show 返回空串，
-- 显示文字「参北失效」由下面的翻译键提供。
Fk:addQmlMark{
  name = "tianzong_geshi__canbei_invalid",
  how_to_show = function() return "" end,
}

Fk:loadTranslationTable{
  ["@[tianzong_geshi__canbei_invalid]"] = "参北失效",
}

return canbei
