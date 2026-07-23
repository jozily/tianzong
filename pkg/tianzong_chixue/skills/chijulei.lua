-- chijulei.lua
local chijulei = fk.CreateSkill{
  name = "chijulei",
  description = ":chijulei",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["chijulei"] = "炬泪",
  [":chijulei"] = "你可以横置视为使用或打出一张火杀火攻或翻面使用或打出一张酒逐近弃远若当前回合角色或此牌目标角色拥有尘标记你弃置其尘标记然后选择一项此牌不计入使用次数或重置你的武将牌。",
}

return chijulei
