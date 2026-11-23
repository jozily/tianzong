-- chiminghuai.lua (铭怀)
-- 每名角色的回合结束阶段，你可以将牌名字数之和等于4的任意张牌当做【随机应变】使用，
-- 然后你摸X张牌。（X为全场拥有“锁定技”的角色数，且不大于你的体力值）
local chiminghuai = fk.CreateSkill{
  name = "chiminghuai",
  description = ":chiminghuai",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chiminghuai"] = "铭怀",
  [":chiminghuai"] = "每名角色的回合结束阶段，你可以将牌名字数之和等于4的任意张牌当做【随机应变】使用，然后你摸X张牌。（X为全场拥有“锁定技”的角色数，且不大于你的体力值）",
  ["#chiminghuai-invoke"] = "铭怀：将牌名字数之和等于4的牌当【随机应变】使用",
  ["#chiminghuai-select"] = "铭怀：选择牌名字数之和等于4的牌",
}

local function sum_name_length(ids)
  local sum = 0
  for _, id in ipairs(ids) do
    sum = sum + Fk:getCardById(id):getNameLength(true)
  end
  return sum
end

-- X：全场拥有“锁定技”的角色数，且不大于自身体力值（每名角色只计一次）
local function compulsory_count(room)
  local count = 0
  for _, p in ipairs(room.alive_players) do
    for _, sk in ipairs(p.skills) do
      local skill = Fk.skills[sk]
      if skill and skill:hasTag(Skill.Compulsory) then
        count = count + 1
        break
      end
    end
  end
  return count
end

local function get_draw_count(player)
  return math.min(compulsory_count(player.room), player.hp)
end

-- 动态描述：选将/观战时无房间则回退静态描述
chiminghuai.dynamic_desc = function(self, player, lang)
  if not player or not player.room or not player.hp then return "" end
  local cnt = compulsory_count(player.room)
  local draw = math.min(cnt, player.hp)
  return "chiminghuai_dyn:" .. tostring(cnt) .. ":" .. tostring(draw)
end

Fk:loadTranslationTable{
  ["chiminghuai_dyn"] = "每名角色的回合结束阶段，你可以将牌名字数之和等于4的任意张牌当做【随机应变】使用，然后你摸{2}张牌。（全场共有{1}名角色拥有锁定技，X为你体力值）",
}

-- 是否存在“牌名字数之和=4”的牌组合（1~3张，牌名最短1字、单张最长4字）
local function has_valid_combo(cards)
  local n = #cards
  if n == 0 then return false end
  local len = {}
  for i = 1, n do len[i] = Fk:getCardById(cards[i]):getNameLength(true) end
  for i = 1, n do
    if len[i] == 4 then return true end
    for j = i + 1, n do
      if len[i] + len[j] == 4 then return true end
      for k = j + 1, n do
        if len[i] + len[j] + len[k] == 4 then return true end
      end
    end
  end
  return false
end

chiminghuai:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and
      target.phase == Player.Finish and player:isAlive() and
      has_valid_combo(player:getCardIds("he"))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#chiminghuai-invoke" })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = self.name
    local cards = player:getCardIds("he")

    -- 让玩家自选任意张牌（1~4张），校验名字数之和=4
    local chosen = room:askToCards(player, {
      min_num = 1,
      max_num = math.min(4, #cards),
      pattern = ".|.|.|^equip",
      prompt = "#chiminghuai-select",
      skill_name = skillName,
      cancelable = true,
    })
    if #chosen > 0 and sum_name_length(chosen) == 4 then
      -- 【随机应变】为被动转化牌，按引擎约定：以选定牌为子牌直接使用，
      -- 具体转化由其 adaptation_skill 的 cardskill/filter 效果处理
      local card = Fk:cloneCard("adaptation")
      card.skillName = skillName
      card:addSubcards(chosen)
      room:useCard({
        from = player,
        card = card,
        skillName = skillName,
      })
    end

    local draw = get_draw_count(player)
    if draw > 0 and player:isAlive() then
      player:drawCards(draw, skillName)
    end
  end,
})

return chiminghuai
