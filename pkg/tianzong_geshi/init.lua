local extension = Package:new("tianzong_geshi")
extension.extensionName = "tianzong"

-- 加载亚索共享能量系统（风循/覆梦共用，上限5）
require "packages.tianzong.pkg.tianzong_geshi.energy"

extension:loadSkillSkelsByPath("./packages/tianzong/pkg/tianzong_geshi/skills")

local fengji_equips = {
  { name = "&weapon__tianzong_toaru__fengji", subtype = Card.SubtypeWeapon },
  { name = "&armor__tianzong_toaru__fengji", subtype = Card.SubtypeArmor },
  { name = "&offensive_horse__tianzong_toaru__fengji", subtype = Card.SubtypeOffensiveRide },
  { name = "&defensive_horse__tianzong_toaru__fengji", subtype = Card.SubtypeDefensiveRide },
  { name = "&treasure__tianzong_toaru__fengji", subtype = Card.SubtypeTreasure },
}
for _, spec in ipairs(fengji_equips) do
  local card = fk.CreateCard {
    name = spec.name,
    type = Card.TypeEquip,
    sub_type = spec.subtype,
  }
  extension:loadCardSkels { card }
  extension:addCardSpec(spec.name:sub(2))
end

General:new(extension, "tianzong_toaru__misaka", "tianzong_science", 4, 4, General.Female)
  :addSkills { "tianzong_toaru__leibi", "tianzong_toaru__cipao" }
General:new(extension, "tianzong_toaru__shirai", "tianzong_science", 3, 3, General.Female)
  :addSkills { "tianzong_toaru__shunyi", "tianzong_toaru__fengji" }
General:new(extension, "tianzong_toaru__uiharu", "tianzong_science", 3, 3, General.Female)
  :addSkills { "tianzong_toaru__hengwen", "tianzong_toaru__zonghuan" }
General:new(extension, "tianzong_toaru__kungou", "tianzong_science", 4, 4, General.Female)
  :addSkills { "tianzong_toaru__zhoushe", "tianzong_toaru__kongli" }
General:new(extension, "tianzong_toaru__saten", "tianzong_science", 4, 4, General.Female)
  :addSkills { "tianzong_toaru__yichu", "tianzong_toaru__juben", "tianzong_toaru__daoyan" }
General:new(extension, "tianzong_toaru__shokuhou", "tianzong_science", 3, 3, General.Female)
  :addSkills { "tianzong_toaru__duxin", "tianzong_toaru__paihu", "tianzong_toaru__waizhuang" }

-- 恍若隔世（以我之名系列）
General:new(extension, "tianzong_geshi__yasuo", "prisma", 4, 4, General.Male)
  :addSkills { "tianzong_geshi__fengxun", "tianzong_geshi__fumeng" }
General:new(extension, "tianzong_geshi__senna", "prisma", 4, 4, General.Female)
  :addSkills { "tianzong_geshi__anmeng", "tianzong_geshi__canbei" }
General:new(extension, "tianzong_geshi__qiyana", "prisma", 3, 3, General.Female)
  :addSkills { "tianzong_geshi__yuanpu", "tianzong_geshi__hongmeng" }

Fk:loadTranslationTable {
  ["tianzong_toaru"] = "学园都市",
  ["tianzong_geshi"] = "恍若隔世",
  ["tianzong_science"] = "科学",
  ["prisma"] = "棱彩",

  ["tianzong_toaru__misaka"] = "御坂美琴",
  ["#tianzong_toaru__misaka"] = "最强无敌的电击公主",
  ["designer:tianzong_toaru__misaka"] = "公冶天纵",
  ["illustrator:tianzong_toaru__misaka"] = "灰村清孝",
  ["tianzong_toaru__leibi"] = "雷壁",
  [":tianzong_toaru__leibi"] = "其他角色使用的技能每回合首次即将作用于你时，你可视为对其使用一张雷【杀】，若此【杀】造成伤害，此技能无效。当你即将受到雷属性伤害时，你可令其取消之，然后你恢复等量点体力值。当场上有角色即将受到雷属性伤害后，你摸等同于此次伤害值张牌。",
  ["tianzong_toaru__cipao"] = "磁炮",
  [":tianzong_toaru__cipao"] = "每回合限一次，你可以将任意张牌当作一张不计入次数且无视防具的雷【杀】使用。若这些牌的牌名字数均不同，此【杀】伤害改为X（X为以此法转化的牌数）；若这些牌的类别均不同，目标需打出等同于以此法转化牌数量的【闪】。<a href='#ChengShi'>乘势</a>：你随机获得一个技能描述中含有【杀】的技能。",

  ["tianzong_toaru__shirai"] = "白井黑子",
  ["#tianzong_toaru__shirai"] = "正义的风纪委员",
  ["designer:tianzong_toaru__shirai"] = "公冶天纵",
  ["illustrator:tianzong_toaru__shirai"] = "灰村清孝",
  ["tianzong_toaru__shunyi"] = "瞬移",
  [":tianzong_toaru__shunyi"] = "出牌阶段限一次，你可以将与你距离不大于1的一名角色的：①一张手牌区、装备区或判定区的牌移动至另一名角色的相应区域；②将一名角色的座次移动至两名其他角色中间，然后移除此选项。",
  ["tianzong_toaru__fengji"] = "风纪",
  [":tianzong_toaru__fengji"] = "每轮限一次，当有角色受到伤害后，若伤害来源与你距离为1，你可以将一张【杀】置入其装备区并发动一次“风纪”；有角色装备区有除了装备牌外的牌进入时，其需选择一项：1.本回合不能使用或打出与此牌花色相同的牌且所有非锁定技失效；2.保留此牌和一张手牌，然后弃置所有牌。",
  ["weapon__tianzong_toaru__fengji"] = "风纪",
  ["armor__tianzong_toaru__fengji"] = "风纪",
  ["offensive_horse__tianzong_toaru__fengji"] = "风纪",
  ["defensive_horse__tianzong_toaru__fengji"] = "风纪",
  ["treasure__tianzong_toaru__fengji"] = "风纪",
  [":weapon__tianzong_toaru__fengji"] = "你被【风纪委员】白井黑子逮捕了！这只是一颗平平无奇的钢钉而已。",
  [":armor__tianzong_toaru__fengji"] = "你被【风纪委员】白井黑子逮捕了！这只是一颗平平无奇的钢钉而已。",
  [":offensive_horse__tianzong_toaru__fengji"] = "你被【风纪委员】白井黑子逮捕了！这只是一颗平平无奇的钢钉而已。",
  [":defensive_horse__tianzong_toaru__fengji"] = "你被【风纪委员】白井黑子逮捕了！这只是一颗平平无奇的钢钉而已。",
  [":treasure__tianzong_toaru__fengji"] = "你被【风纪委员】白井黑子逮捕了！这只是一颗平平无奇的钢钉而已。",

  ["tianzong_toaru__uiharu"] = "初春饰利",
  ["#tianzong_toaru__uiharu"] = "Lv1.定温保存",
  ["designer:tianzong_toaru__uiharu"] = "公冶天纵",
  ["illustrator:tianzong_toaru__uiharu"] = "幻想收束",
  ["tianzong_toaru__hengwen"] = "恒温",
  [":tianzong_toaru__hengwen"] = "限定技，出牌阶段，你可以令一名角色获得一枚“恒温”标记并记录其体力值。其体力值变化后，你可以令其恢复或失去体力至记录体力值，然后移除其“恒温”标记并重置“纵幻”。",
  ["tianzong_toaru__zonghuan"] = "纵幻",
  [":tianzong_toaru__zonghuan"] = "限定技，每当你成为其他角色牌的目标时，你可重置“恒温”并令此牌对你无效，然后你为此牌选择一个额外合法目标（若有，可为使用者自己）。",

  ["tianzong_toaru__kungou"] = "婚后光子",
  ["#tianzong_toaru__kungou"] = "Lv.4.空力使",
  ["designer:tianzong_toaru__kungou"] = "公冶天纵",
  ["illustrator:tianzong_toaru__kungou"] = "幻想收束",
  ["tianzong_toaru__zhoushe"] = "轴射",
  [":tianzong_toaru__zhoushe"] = "每轮限一次，你可以视为使用或打出一张雷【杀】。若此【杀】被【闪】抵消，目标需选择一项：1.失去一点体力值；2.获得【混乱】。",
  ["tianzong_toaru__kongli"] = "空力",
  [":tianzong_toaru__kongli"] = "锁定技，当你即将造成伤害时，25%概率令对方非锁定技失效直到本回合结束；25%概率令其获得【混乱】；5%概率令其所有技能失效直到其下个回合结束。",
  ["tianzong_toaru__hunluan"] = "混乱",
  [":tianzong_toaru__hunluan"] = "锁定技，当你使用牌时，50%概率为此牌随机选择一个目标。每名角色的回合结束后，若你本回合未受到过伤害且未成为过牌的目标，你失去此技能。",

  ["tianzong_toaru__saten"] = "佐天泪子",
  ["#tianzong_toaru__saten"] = "Lv.0.都市传说探索者",
  ["designer:tianzong_toaru__saten"] = "公冶天纵",
  ["illustrator:tianzong_toaru__saten"] = "灰村清孝",
  ["tianzong_toaru__yichu"] = "衣橱",
  [":tianzong_toaru__yichu"] = "锁定技，你的手牌上限和体力上限+X；每轮开始时，你随机将牌堆的一张装备牌置入你的装备区（X为你装备区牌的数量）。当你的装备区首次有牌离开后，你永久获得该装备牌效果。当你每轮首次造成伤害后，目标随机弃置一张牌，若为装备牌，你获得之。",
  ["tianzong_toaru__juben"] = "剧本",
  [":tianzong_toaru__juben"] = "出牌阶段开始时或每轮开始时，你可以记录一个不重复的牌名、角色和花色。①当有角色使用牌指定目标后，若此牌牌名或目标已记录，你可以更改此牌目标或牌名（需合法）。②当已记录角色发动技能时，你可以改为你发动此技能。③当出现已记录花色或牌名的判定牌后，你可以将此牌改为你记录的花色或牌名。当你触发上述效果后，你移除对应记录并摸两张牌。",
  ["tianzong_toaru__daoyan"] = "导演",
  [":tianzong_toaru__daoyan"] = "限定技，出牌阶段，你可以获得牌堆中所有已记录牌名的牌、已记录角色的所有牌和弃牌堆中所有已记录花色且由你使用或弃置的牌，然后你失去“剧本”。",

  ["tianzong_toaru__shokuhou"] = "食蜂操祈",
  ["#tianzong_toaru__shokuhou"] = "常盘台的女王",
  ["designer:tianzong_toaru__shokuhou"] = "公冶天纵",
  ["illustrator:tianzong_toaru__shokuhou"] = "灰村清孝",
  ["tianzong_toaru__duxin"] = "读心",
  [":tianzong_toaru__duxin"] = "蓄力技（1/7），①出牌阶段，你可以消耗一枚蓄力点并选择一名角色，观看其手牌并使用其中一张（视为该角色使用）；②当有其他角色发动技能指定目标后或使用单体牌指定目标后，你可消耗2枚蓄力点重新选择目标。",
  ["#tianzong_toaru__duxin-choose"] = "读心：选择一名角色观看其手牌",
  ["#tianzong_toaru__duxin-card"] = "读心：选择其一张手牌使用",
  ["tianzong_toaru__paihu"] = "派阀",
  [":tianzong_toaru__paihu"] = "限定技，出牌阶段，若场上角色数量不小于3，你可以令一名其他角色摸X张牌并恢复一点体力值（X为与你同阵营的角色数且至少为1），若其获胜条件与你不一致且其所处阵营剩余人数大于1人，你可以令其获胜条件改为与你一致并获得“仰慕”。",
  ["#tianzong_toaru__paihu"] = "派阀：选择一名其他角色令其摸牌并恢复体力",
  ["#tianzong_toaru__paihu-convert"] = "派阀：是否令 %dest 的获胜条件改为与你一致并令其获得“仰慕”？",
  ["tianzong_toaru__waizhuang"] = "外装",
  [":tianzong_toaru__waizhuang"] = "锁定技，当你使用了一组基本牌、锦囊牌和装备牌后或你的回合内，一组基本牌、锦囊牌和装备牌因被使用或弃置离开其他角色的区域后，你获得一枚蓄力点；当你受到伤害后，你的“读心”蓄力值上限-1。",
  ["tianzong_toaru__yangmu"] = "仰慕",
  [":tianzong_toaru__yangmu"] = "食蜂操祈可随时观看你的手牌。每轮各限一次，①当食蜂操祈即将受到伤害后，你可以失去一点体力上限防止此伤害；②食蜂操祈可如手牌般使用或打出你的手牌。",
  ["#tianzong_toaru__yangmu-guard"] = "仰慕：选择一名角色失去1点体力上限并防止你受到的伤害",
  ["@[list]tianzong_toaru__yangmu"] = "仰慕",
  ["@[juben]"] = "剧本",
  ["@[yichu_saved]"] = "衣橱",

  -- 恍若隔世 · 亚索
  ["tianzong_geshi__yasuo"] = "亚索",
  ["#tianzong_geshi__yasuo"] = "以我之名",
  ["designer:tianzong_geshi__yasuo"] = "公冶天纵",
  ["illustrator:tianzong_geshi__yasuo"] = "拳头游戏",
  -- 亚索共享能量（数值标记，上限5，武将牌旁显示5格）
  ["@[tianzong_geshi__energy]"] = "",
  ["#tianzong_geshi__fumeng-energy"] = "覆梦：消耗能量令其交出等量张牌（你当前能量 %arg）",

  ["tianzong_geshi__fengxun"] = "风循",
  [":tianzong_geshi__fengxun"] = "当你受到伤害后/当你造成伤害后，或当你即将受到伤害时/当你即将造成伤害时，你可消耗一点能量于此时机内从三个触发时机与此相同的技能中选择一个发动。若有角色发动描述带有“伤害”且不为“风恂”的技能后，你获得一点能量（已满则改为摸一张牌）。",
  ["#tianzong_geshi__fengxun-invoke"] = "风循：消耗一点能量，从三个触发时机相同（%arg）的技能中选择一个发动？",
  ["tianzong_geshi__fumeng"] = "覆梦",
  [":tianzong_geshi__fumeng"] = "出牌阶段限一次，你可以从三个技能描述中含有“伤害”的技能中选择一个获得直到回合结束。若你发动此技能造成伤害，你获得一点能量。其他角色的回合开始时，你可消耗任意点能量令其交给你等量的牌，然后你从三个技能描述中含有“伤害”的技能中选择一个令其获得直到回合结束。",
  ["#tianzong_geshi__fumeng-active"] = "覆梦：从三个含【伤害】的技能中选择一个获得",
  ["#tianzong_geshi__fumeng-choose"] = "覆梦：选择一个技能获得",
  ["#tianzong_geshi__fumeng-invoke"] = "覆梦：是否令 %dest 交给你两张牌并获得一个技能？",
  ["#tianzong_geshi__fumeng-give"] = "覆梦：交给 %dest 等量张牌",

  -- 恍若隔世 · 赛娜
  ["tianzong_geshi__senna"] = "赛娜",
  ["#tianzong_geshi__senna"] = "以我之名",
  ["designer:tianzong_geshi__senna"] = "公冶天纵",
  ["illustrator:tianzong_geshi__senna"] = "拳头游戏",
  ["tianzong_geshi__anmeng"] = "黯梦",
  [":tianzong_geshi__anmeng"] = "当你使用伤害牌指定目标后，你可以改为召唤<a href='#tianzong_geshi__anmeng_anxing'>“黯星”</a>攻击任意目标，然后因此失去体力的角色本回合非锁定技失效。",
  ["#tianzong_geshi__anmeng_anxing"] = "黯星：概率偷取（其失去，你恢复）对方体力值，你的体力值越高，概率越大。",
  ["#tianzong_geshi__anmeng-choose"] = "黯梦：选择“黯星”攻击的目标",
  ["tianzong_geshi__canbei"] = "参北",
  [":tianzong_geshi__canbei"] = "当你的体力值变化后，你可以交换你的体力值与已损失体力值并摸X张牌（X为体力值与已损失体力值的差值，至少为1），然后此技能失效直至有角色进入濒死状态。",
  ["#tianzong_geshi__canbei-invoke"] = "参北：交换体力值与已损失体力值并摸牌？",

  -- 恍若隔世 · 奇亚娜（套用炽李煜 览华/遗代）
  ["tianzong_geshi__qiyana"] = "奇亚娜",
  ["#tianzong_geshi__qiyana"] = "以我之名",
  ["designer:tianzong_geshi__qiyana"] = "公冶天纵",
  ["illustrator:tianzong_geshi__qiyana"] = "拳头游戏",
  ["tianzong_geshi__yuanpu"] = "元瀑",
  [":tianzong_geshi__yuanpu"] = "锁定技，当你使用♥/♠/♦/♣花色的牌结算完毕后，你令一名角色选择一项：1.弃置一张花色相同的牌；2.受到一点来自你的火焰伤害。背水：若剩余花色数不为1则永久移除一个“元瀑”可选数。",
  ["@[tianzong_geshi__yuanpu]"] = "元瀑",
  ["#tianzong_geshi__yuanpu-choose"] = "元瀑：选择一名角色，令其选择一项",
  ["#tianzong_geshi__yuanpu-choice"] = "元瀑：请选择一项",
  ["#tianzong_geshi__yuanpu-discard"] = "元瀑：弃置一张花色相同的牌",
  ["#tianzong_geshi__yuanpu-rm-suit"] = "元瀑·背水：永久移除一个“元瀑”花色",
  ["tianzong_geshi__yuanpu_discard"] = "弃置一张相同花色的牌",
  ["tianzong_geshi__yuanpu_damage"] = "受到一点来自奇亚娜的火焰伤害",
  ["tianzong_geshi__yuanpu_backwater"] = "背水：若剩余花色数不为1则永久移除一个“元瀑”花色。",
  ["tianzong_geshi__yuanpu_rm_1"] = "♠",
  ["tianzong_geshi__yuanpu_rm_2"] = "♣",
  ["tianzong_geshi__yuanpu_rm_3"] = "♥",
  ["tianzong_geshi__yuanpu_rm_4"] = "♦",
  ["tianzong_geshi__hongmeng"] = "虹梦",
  [":tianzong_geshi__hongmeng"] = "当你受到伤害后，你可以从四种花色中重新选择触发“虹梦”的花色并摸等量张牌。",
  ["#tianzong_geshi__hongmeng-invoke"] = "虹梦：是否重新选择“元瀑”花色并摸牌？",
  ["#tianzong_geshi__hongmeng-choose-suit"] = "虹梦：选择要纳入“元瀑”的花色（可多选）",
  ["tianzong_geshi__hongmeng_done"] = "完成",
  ["tianzong_geshi__hongmeng_spade"] = "♠",
  ["tianzong_geshi__hongmeng_club"] = "♣",
  ["tianzong_geshi__hongmeng_heart"] = "♥",
  ["tianzong_geshi__hongmeng_diamond"] = "♦",
  -- 恍若隔世 · 三将技能语音与阵亡台词
  ["$tianzong_geshi__fengxun1"] = "想杀我，你可以试一试。",
  ["$tianzong_geshi__fengxun2"] = "如果你要来杀我，希望你把朋友们也带上。",
  ["$tianzong_geshi__fengxun3"] = "蠢货是无药可治的。",
  ["$tianzong_geshi__fengxun4"] = "还是别出招了，反正是我赢。",
  ["$tianzong_geshi__fumeng1"] = "一剑，一念。",
  ["$tianzong_geshi__fumeng2"] = "不是你死，就是我亡。",
  ["$tianzong_geshi__fumeng3"] = "想独自平静一会儿吗？很快你就可以了。",
  ["$tianzong_geshi__fumeng4"] = "我命由我，不由天。",
  ["~tianzong_geshi__yasuo"] = "……",
  ["$tianzong_geshi__anmeng1"] = "睁大双眼！",
  ["$tianzong_geshi__anmeng2"] = "永不停歇！",
  ["$tianzong_geshi__anmeng3"] = "这个世界我们做主！",
  ["$tianzong_geshi__anmeng4"] = "听啊，我的心声。",
  ["$tianzong_geshi__canbei1"] = "忘我地舞蹈。",
  ["$tianzong_geshi__canbei2"] = "我的故事他们已经听过了，现在，他们会听到我的歌。",
  ["$tianzong_geshi__canbei3"] = "梦想越大，我们就会站得越高。",
  ["$tianzong_geshi__canbei4"] = "音乐给了我们生命，这就是捍卫它的理由。",
  ["~tianzong_geshi__senna"] = "寒冬总会过去。",
  ["$tianzong_geshi__yuanpu1"] = "把你们打成这样，真是累坏我了。",
  ["$tianzong_geshi__yuanpu2"] = "你的魔法真是粗糙，和你的品味一样。",
  ["$tianzong_geshi__yuanpu3"] = "感觉到风里的寒意？那就是我。",
  ["$tianzong_geshi__yuanpu4"] = "这场战斗有阶级之分，你最好知道自己的位置。",
  ["$tianzong_geshi__hongmeng1"] = "我不要再做个NPC了，从现在开始我要自己决定。",
  ["$tianzong_geshi__hongmeng2"] = "我们应该办个宴会，但得想个庆祝的由头，我知道了，庆祝一场大胜好了。",
  ["$tianzong_geshi__hongmeng3"] = "从基地到群山之外，代码结束的地方为止，都是我理所当然的领地。",
  ["$tianzong_geshi__hongmeng4"] = "青草适合长在敌人的坟头上。",
  ["~tianzong_geshi__qiyana"] = "怎么可能？",
}

return extension

