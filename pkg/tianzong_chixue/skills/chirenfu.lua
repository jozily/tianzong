local chirenfu = fk.CreateSkill{
  name = "chirenfu",
}

Fk:loadTranslationTable{
  ["chirenfu"] = "荏腹",
  [":chirenfu"] = "锁定技，当你每回合首次使用普通锦囊牌时，你摸已使用基本牌数量张牌。若摸牌数小于2，你受到来自当前回合角色的一点雷属性伤害，且若不为你的回合，你移动你与其一张牌；若无法移动，则改为手牌少的一方获得手牌多的一方一张手牌。",
}

return chirenfu
