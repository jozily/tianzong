-- 寒塘的选牌校验骨架：所选牌的名字字数之和恰好为 extra_data.x 时，“确定”才可用
local chihantang_filter = fk.CreateSkill{
  name = "chihantang_filter",
  extra = {
    choiceFilter = function(cards, choice, extra_data)
      if choice ~= "chihantang_ok" then return true end
      if extra_data == nil or extra_data.x == nil then return false end
      local sum = 0
      for _, id in ipairs(cards) do
        sum = sum + Fk:getCardById(id):getNameLength(true)
      end
      return sum == extra_data.x
    end,
  },
}

return chihantang_filter
