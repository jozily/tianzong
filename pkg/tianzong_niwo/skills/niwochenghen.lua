local Util = require "packages.utility.utility"  -- 新增导入

local niwochenghen = fk.CreateSkill{
  name = "niwochenghen",
}

niwochenghen:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(niwochenghen.name) then return false end
    -- 修正：使用 table.contains 判断卡牌技能
    if not table.contains(data.card.skillNames, "niwotianmeng") then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 获取卡牌实体 ID（若为虚拟卡请根据实际逻辑调整）
    local card_id = data.card.id
    if card_id then
      room:obtainCard(player, {card_id}, true, fk.ReasonJustMove, player, niwochenghen.name)
    end
  end,
})

niwochenghen:addEffect(fk.Dying, {  -- 事件常量改为 fk.Dying
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niwochenghen.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niwochenghen.name,
      prompt = "#niwochenghen-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    if #targets == 0 then return end

    -- 使用 askToChoosePlayers 选择目标
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = niwochenghen.name,
      prompt = "#niwochenghen-choose",
    })
    if #tos == 0 then return end
    local target_player = tos

    -- 获取技能列表（假设返回字符串名称）
    local skill_list = {}  -- 或直接使用 player:getSkillNames() 等方法
    for _, skill_id in ipairs(player:getSkills()) do
      table.insert(skill_list, skill_id)
    end
    if #skill_list > 0 then
      local choice_skill = room:askToChoose(player, skill_list, niwochenghen.name, "#niwochenghen-skill")
      target_player:addSkill(choice_skill)
    end
  end,
})

return niwochenghen