local extension = Package:new("tianzong_chixue")
extension.extensionName = "tianzong"

extension:loadSkillSkelsByPath("./packages/tianzong/pkg/tianzong_chixue/skills")

local chi__zhenji = General:new(extension, "chi__zhenji", "wei", 3, 3, General.Female)
chi__zhenji:addSkills { "chijinghong", "chigufu", "chiraoluo" }

local chi__caiwenji = General:new(extension, "chi__caiwenji", "qun", 3, 3, General.Female)
chi__caiwenji:addSkills { "chijuanxiang", "chishuowen", "chidiaoyao" }

local chi__xiahoulingnv = General:new(extension, "chi__xiahoulingnv", "wei", 4, 4, General.Female)
chi__xiahoulingnv:addSkills { "chicangsui", "chihantang" }

local chi__xiahouqingyi = General:new(extension, "chi__xiahouqingyi", "wei", 3, 3, General.Female)
chi__xiahouqingyi:addSkills { "chiqingya", "chiwangchen" }

local chi__xuelingyun = General:new(extension, "chi__xuelingyun", "wei", 3, 3, General.Female)
chi__xuelingyun:addSkills { "chifeimeng", "chidieren", "chixique" }

local chi__pangfengyi = General:new(extension, "chi__pangfengyi", "shu", 3, 3, General.Female)
chi__pangfengyi:addSkills { "chixingjue", "chiyongtang" }

local chi__guozhao = General:new(extension, "chi__guozhao", "wei", 3, 3, General.Female)
chi__guozhao:addSkills { "chixiege", "chishangjiao" }


local chi__zhanghuai = General:new(extension, "chi__zhanghuai", "wu", 1, 1, General.Female)
chi__zhanghuai:addSkills { "chimiling", "chicangsheng", "chikongyao" }

local chi__mifuren = General:new(extension, "chi__mifuren", "shu", 3, 3, General.Female)
chi__mifuren:addSkills { "chifusheng", "chijianian" }
local chi__xiahoumao = General:new(extension, "chi__xiahoumao", "wei", 4, 4)
chi__xiahoumao:addSkills { "chirenfu", "chiyanzu" }


local chi__lukai = General:new(extension, "chi__lukai", "wu", 3, 3, General.Male)
chi__lukai:addSkills { "chijiantu", "chiduye", "chizelie" }

local chi__yangzhong = General:new(extension, "chi__yangzhong", "qun", 4, 4, General.Male)
chi__yangzhong:addSkills { "chidangliao" }

local chi__wangqian = General:new(extension, "chi__wangqian", "jin", 3, 3, General.Female)
chi__wangqian:addSkills { "chizhuoxi", "chixiarong","chizhongliu" }


local chi__xunxu = General:new(extension, "chi__xunxu", "wei", 3, 3, General.Male)
chi__xunxu:addSkills { "chiyilvRemake", "chifufengRemake", "chixunfu", "chidaojie" }

-- 炽陆逊 001
local chi__luxun = General:new(extension, "chi__luxun", "wu", 3, 3, General.Male)
chi__luxun:addSkills { "chiquege", "chishaoshan", "chimaoqi" }

-- 炽张春华 002
local chi__zhangchunhua = General:new(extension, "chi__zhangchunhua", "wei", 4, 4, General.Female)
chi__zhangchunhua:addSkills { "chifenqing", "chisuhen", "chiyuanque" }


-- 炽诸葛果 008
local chi__zhugeguo = General:new(extension, "chi__zhugeguo", "shu", 3, 3, General.Female)
chi__zhugeguo:addSkills { "chihuangli", "chisusu" }

-- 炽黄月英 009
local chi__huangyueying = General:new(extension, "chi__huangyueying", "shu", 3, 3, General.Female)
chi__huangyueying:addSkills { "chiyingshan", "chishennie" }

-- 炽于吉 011
local chi__yuji = General:new(extension, "chi__yuji", "qun", 3, 3, General.Male)
chi__yuji:addSkills { "chiliangdao", "chifushui" }

-- 炽胡金定 013
local chi__hujinding = General:new(extension, "chi__hujinding", "shu", 3, 3, General.Female)
chi__hujinding:addSkills { "chiqianmeng", "chihuaiji" }

-- 炽邹氏 014
local chi__zoushi = General:new(extension, "chi__zoushi", "qun", 3, 3, General.Female)
chi__zoushi:addSkills { "chiyinghun", "chiyugu" }

-- 炽朱佩兰 015
local chi__zhupeilan = General:new(extension, "chi__zhupeilan", "wu", 3, 3, General.Female)
chi__zhupeilan:addSkills { "chikuili", "chitiaomu" }

-- 炽董予安 016
local chi__dongguiren = General:new(extension, "chi__dongguiren", "qun", 3, 3, General.Female)
chi__dongguiren:addSkills { "chishanquan", "chisimi" }

-- 炽任婉 017
local chi__renwan = General:new(extension, "chi__renwan", "wei", 3, 3, General.Female)
chi__renwan:addSkills { "chilingmeng", "chilique" }


-- 020 炽荀粲
local chi__xuncan = General:new(extension, "chi__xuncan", "wei", 3, 3, General.Male)
chi__xuncan:addSkills { "chicigu", "chiyouming" }

-- 021 炽荀采
local chi__xuncai = General:new(extension, "chi__xuncai", "qun", 3, 3, General.Female)
chi__xuncai:addSkills { "chijulei", "chizhichen" }

-- 022 炽王沦
local chi__wanglun = General:new(extension, "chi__wanglun", "wei", 3, 3, General.Male)
chi__wanglun:addSkills { "chitianshi", "chiminghuai" }

-- 023 炽王沈
local chi__wangshen = General:new(extension, "chi__wangshen", "jin", 3, 3, General.Male)
chi__wangshen:addSkills { "chitiaofeng", "chijiwang" }


-- 026 炽荀悦
local chi__xunyue = General:new(extension, "chi__xunyue", "wei", 3, 3, General.Male)
chi__xunyue:addSkills { "chijieji", "chishuji" }


-- 030 炽夏侯惇
local chi__xiahoudun = General:new(extension, "chi__xiahoudun", "wei", 4, 4)
chi__xiahoudun:addSkills { "chiliaozhi", "chizhenjie" }

-- 031 炽夏侯玄
local chi__xiahouxuan = General:new(extension, "chi__xiahouxuan", "wei", 3, 3, General.Male)
chi__xiahouxuan:addSkills { "chicixuan", "chiqihai" }

-- 032 炽夏侯杰
local chi__xiahoujie = General:new(extension, "chi__xiahoujie", "wei", 3, 3, General.Male)
chi__xiahoujie:addSkills { "chiyushe", "chidangdan" }

-- 033 炽夏侯荣
local chi__xiahourong = General:new(extension, "chi__xiahourong", "wei", 3, 3, General.Female)
chi__xiahourong:addSkills { "chidulie", "chijiaotan" }

-- 034 炽夏侯涓
local chi__xiahoushi = General:new(extension, "chi__xiahoushi", "shu", 3, 3, General.Female)
chi__xiahoushi:addSkills { "chixinmai", "chiyusui" }

-- 035 炽夏侯徽
local chi__xiahouhui = General:new(extension, "chi__xiahouhui", "jin", 3, 3, General.Female)
chi__xiahouhui:addSkills { "chifeishi", "chifeichen" }

Fk:loadTranslationTable{
  ["#chizelie-target"] = "泽烈：选择一名角色获得后续效果",
  ["#chizelie-choice"] = "泽烈：令 %dest 本回合下一次摸牌或弃牌后执行对应效果",
  ["chizelie_draw"] = "下一次摸牌后再摸一张牌",
  ["chizelie_discard"] = "下一次弃牌后再弃置一张牌",
  ["chi"] = "炽血青魂",
    ["chixue"] = "炽血青魂",
  ["niwo"] = "逆涡之流",
  ["tianzong_chixue"] = "炽血青魂",
  ["tianzong_niwo"] = "逆涡之流",
  ["tianzong"] = "天纵崇壑",

  ["chi__zhenji"] = "甄宓",
  ["#chi__zhenji"] = "薄尘几粟",
  ["~chi__zhenji"] = "此身飘零，如水无痕……",
  ["designer:chi__zhenji"] = "公冶天纵",
  ["illustrator:chi__zhenji"] = "佚名",
  ["cv:chi__zhenji"] = "暂无",
  ["chijinghong"] = "惊鸿",
  [":chijinghong"] = "当你需要视为使用或打出一张基本牌时，你可以展示当前回合角色的一张牌并将之置于牌堆顶或牌堆底，视为使用或打出一张基本牌，然后移除此牌名。当你的蓄谋牌有已移除牌名时，恢复之。",
  ["chigufu"] = "孤凫",
  [":chigufu"] = "出牌阶段限一次，你可以重铸任意张牌（至多“惊鸿”未移除牌名张），然后蓄谋牌堆顶或牌堆底的等量张牌。",
  ["chiraoluo"] = "扰洛",
  [":chiraoluo"] = "当你受到伤害后或响应牌后，你可以弃置一名角色区域内的一张牌并令其选择一项：①发动一次“孤凫”；②获得判定区的一张牌；背水，其翻面。",
  ["@$chijinghong"] = "惊鸿已移除",
  ["#chijinghong"] = "惊鸿：展示当前回合角色区域内的一张牌并将之置于牌堆顶或牌堆底，视为使用或打出一张基本牌",
  ["#chijinghong-choose"] = "惊鸿：选择当前回合角色区域内的一张牌",
  ["chijinghong_top"] = "置于牌堆顶",
  ["chijinghong_bottom"] = "置于牌堆底",
  ["#chigufu"] = "孤凫：出牌阶段限一次，选择至多X张牌重铸，然后选择从牌堆顶或牌堆底蓄谋等量牌",
  ["Top"] = "牌堆顶",
  ["Bottom"] = "牌堆底",
  ["#chiraoluo-choose"] = "扰洛：请选择一名角色",
  ["#chiraoluo-choice"] = "扰洛：请选择一项",
  ["chiraoluo_opt1"] = "发动一次“孤凫”",
  ["chiraoluo_opt2"] = "使用一张手牌或蓄谋牌",
  ["$chijinghong1"] = "惊鸿一掠，影落苍波。",
  ["$chijinghong2"] = "翩若惊鸿，婉若游龙。",
  ["$chigufu1"] = "孤雁独飞，自有归处。",
  ["$chigufu2"] = "凫雁满回塘，宛在水中央。",
  ["$chiraoluo1"] = "洛水波澜，自此扰动。",
  ["$chiraoluo2"] = "扰我洛水，当付代价。",

  ["chi__caiwenji"] = "蔡琰",
  ["#chi__caiwenji"] = "罔漠不归汉",
  ["~chi__caiwenji"] = "故园不可见，朔风徒自哀……",
  ["designer:chi__caiwenji"] = "公冶天纵",
  ["illustrator:chi__caiwenji"] = "佚名",
  ["cv:chi__caiwenji"] = "暂无",

  ["chijuanxiang"] = "眷乡",
  [":chijuanxiang"] = "当你的手牌数不因此技能而变化后，若与你本回合使用过的牌名数相等，你重置<b>“朔闻”</b>并选择一项：1.摸X张牌，然后可以将X张牌置于牌堆底；2.获得牌堆底的X张牌，然后可以将X张牌置于牌堆顶（X为本回合“朔闻”发动次数+1）。",

  ["chishuowen"] = "朔闻",
  [":chishuowen"] = "转换技，每回合限一次，当你需要使用或打出一张基本牌或普通锦囊牌时，你可以观看：阳，牌堆顶的一张牌；阴，牌堆底的一张牌；并将之当做一张牌名字数相同且本轮未以此法使用或打出过的牌使用或打出之。",

  ["chidiaoyao"] = "窎窅",
  [":chidiaoyao"] = "锁定技，牌堆顶和牌堆底的X张牌始终对你可见（X为本回合“朔闻”发动次数+1）。",

  ["#chijuanxiang-invoke"] = "眷乡：你可以重置【朔闻】并执行一项",
  ["chijuanxiang_draw"] = "摸X张牌，然后将X张牌置于牌堆底",
  ["chijuanxiang_gain"] = "获得牌堆底的X张牌，然后将X张牌置于牌堆顶",

  ["#chishuowen"] = "朔闻：你可以将牌堆顶/底的一张牌当作同字数的基本牌或普通锦囊牌使用或打出",
  ["@[chidiaoyao_top]"] = "窎窅·顶",
  ["@[chidiaoyao_bottom]"] = "窎窅·底",
  ["@chishuowen-turn"] = "朔闻次数",
  ["chijuanxiang_names-turn"] = "眷乡牌名记录",
  ["chishuowen-round"] = "朔闻轮次记录",

  ["$chijuanxiang1"] = "乡关何处，梦里依稀。",
  ["$chijuanxiang2"] = "离思难绝，归心未休。",
  ["$chishuowen1"] = "朔风所闻，皆是离声。",
  ["$chishuowen2"] = "闻雁惊秋，念家愈切。",
  ["$chidiaoyao1"] = "天高路远，窎窅难寻。",
  ["$chidiaoyao2"] = "目极穹苍，惟见归鸿。",

  ["@@chiraoluo_judge_used-turn"] = "扰洛判定",
  ["chiraoluo_pending_judge-turn"] = "扰洛待判定",
  ["#chiraoluo-discard-hand"] = "扰洛：请弃置一张手牌",
  ["#chiraoluo-discard-equip"] = "扰洛：请弃置一张装备区的牌",
  ["#chiraoluo-discard-judge"] = "扰洛：请弃置一张判定区的牌",
  ["chiraoluo_opt1"] = "弃置其区域内各一张牌，然后其立刻发动一次【孤凫】",
  ["chiraoluo_opt2"] = "令其于当前回合结束时执行一个额外的判定阶段",

  ["chiraoluo_opt1"] = "弃置其区域内各一张牌，然后其立刻执行一次【孤凫】",

  ["@@chiraoluo_judge-turn"] = "扰洛判定",
  ["chiraoluo_opt2"] = "其于当前回合结束时执行一个额外的判定阶段",

  ["#chishuowen-yang"] = "朔闻（阳）：当前观看牌堆顶的%arg，你可以将之当作同字数的基本牌或普通锦囊牌使用或打出",
  ["#chishuowen-yin"] = "朔闻（阴）：当前观看牌堆底的%arg，你可以将之当作同字数的基本牌或普通锦囊牌使用或打出",
  ["chishuowen_count-turn"] = "朔闻次数记录",

  ["@$chijuanxiang_names-turn"] = "眷乡牌名",
  ["chijuanxiang_block-turn"] = "眷乡阻断",

  ["chi__xiahoulingnv"] = "夏侯令女",
  ["#chi__xiahoulingnv"] = "寒梦透骨",
  ["~chi__xiahoulingnv"] = "寒塘月冷，旧梦难寻……",
  ["designer:chi__xiahoulingnv"] = "公冶天纵",
  ["illustrator:chi__xiahoulingnv"] = "佚名",
  ["cv:chi__xiahoulingnv"] = "暂无",
  ["chicangsui"] = "沧遂",
  [":chicangsui"] = "每回合限一次，你可以废除一个装备栏，视为使用或打出一张牌名字数为X的牌。若无符合条件的牌，你摸X张牌。（X为你已废除装备栏数量且至少为1，下同）",
  ["chihantang"] = "寒塘",
  [":chihantang"] = "出牌阶段限一次，或当你于回合内首次造成或受到伤害后，你可以选择一项：①弃置牌名字数之和为X的任意张牌，对一名角色造成1点伤害；若该角色本轮受到你造成的伤害/为你，你恢复一个装备栏/摸X张牌。②摸X张牌并重置【沧遂】。",
  ["#chicangsui"] = "沧遂：废除一个装备栏，视为使用或打出一张牌名字数为X的牌",
  ["#chicangsui-draw"] = "沧遂：无符合条件的牌，你摸%arg张牌",
  ["#$chicangsui-choice"] = "沧遂：选择要废除的装备栏",
  ["#chihantang"] = "寒塘：你可以发动【寒塘】",
  ["chihantang_opt1"] = "弃置牌名字数之和为X的牌，对一名角色造成1点伤害",
  ["chihantang_opt2"] = "摸X张牌并重置【沧遂】",
  ["#chihantang-discard"] = "寒塘：弃置牌名字数之和恰好为 %arg 的任意张牌",
  ["#chihantang-target"] = "寒塘：选择一名角色造成1点伤害",
  ["$chicangsui1"] = "沧波不尽，遂意而行。",
  ["$chicangsui2"] = "断栏折甲，亦可成谋。",
  ["$chihantang1"] = "寒塘孤影，照见离心。",
  ["$chihantang2"] = "塘冷风清，旧怨未平。",

  ["chicangsui"] = "沧遂",
  [":chicangsui"] = "每回合限一次，你可以废除一个装备栏，视为使用或打出一张牌名字数为X的牌。若无符合条件的牌，你摸X张牌。（X为你已废除装备栏数量且至少为1，下同）",
  ["chihantang"] = "寒塘",
  [":chihantang"] = "出牌阶段限一次，或当你于回合内首次造成或受到伤害后，你可以选择一项：①弃置牌名字数之和为X的任意张牌，对一名角色造成1点伤害；若该角色本轮受到过此技能伤害/为你，你恢复一个装备栏/摸X张牌。②摸X张牌并重置【沧遂】。",
   ["#chicangsui-draw"] = "沧遂：无符合条件的牌，你可以废除一个装备栏并摸%arg张牌",

  ["chi__xiahouqingyi"] = "夏侯轻衣",
  ["#chi__xiahouqingyi"] = "危崖寄君",
  ["~chi__xiahouqingyi"] = "桥畔霜重，尘梦成空……",
  ["designer:chi__xiahouqingyi"] = "公冶天纵",
  ["illustrator:chi__xiahouqingyi"] = "佚名",
  ["cv:chi__xiahouqingyi"] = "暂无",
  ["chiqingya"] = "罄崖",
  [":chiqingya"] = "每回合限一次，当你成为伤害类卡牌的目标后，或当你使用伤害类卡牌后，你可以与目标或来源延时拼点，此牌结算后揭示。若此牌：造成伤害，拼点没赢的角色连接其所有点数大于其拼点牌点数的牌；未造成伤害，拼点败者对胜者使用一张拼点牌。",
  ["chiwangchen"] = "望尘",
  [":chiwangchen"] = "当你拼点时，你可以使用弃牌堆顶的牌进行拼点；当有连接牌因弃置而进入弃牌堆后，你可以获得之；你的连接牌点数大于/小于6的始终为K/A。",
  ["#chiqingya-target"] = "罄崖：选择一名目标角色进行延时拼点",
  ["#chiwangchen-invoke"] = "望尘：是否使用弃牌堆顶牌进行拼点？",
  ["@$chiwangchen-round"] = "望尘",
  ["$chiqingya1"] = "绝壁回声，尽诉锋芒。",
  ["$chiqingya2"] = "罄崖一啸，风雪皆停。",
  ["$chiwangchen1"] = "望尘逐影，意在先机。",
  ["$chiwangchen2"] = "轻衣临风，望尽来尘。",

  ["chi__xuelingyun"] = "薛灵芸",
  ["#chi__xuelingyun"] = "思闺默泣",
  ["~chi__xuelingyun"] = "绯梦易散,伊人难留……",
  ["designer:chi__xuelingyun"] = "公冶天纵",
  ["illustrator:chi__xuelingyun"] = "佚名",
  ["cv:chi__xuelingyun"] = "暂无",
  ["chifeimeng"] = "绯梦",
  [":chifeimeng"] = "每回合限一次，当你造成伤害后或受到伤害后，你可以选择一项：①随机获得对方区域内一张与此牌牌名字数相同的牌（若无则改为牌堆）；②亮出牌堆底起第一张红色牌，若此牌可使用则你使用之并重复此流程，否则你将其置于牌堆顶。",
  ["chidieren"] = "叠纴",
  [":chidieren"] = "每种牌名每轮限一次，你可以将任意张牌当作一张牌名字数等于其之和的基本牌或普通锦囊牌使用或打出。",
  ["#chifeimeng"] = "绯梦：你可以发动绯梦",
  ["chi_feimeng_opt1"] = "随机获得一张同字数的牌",
  ["chi_feimeng_opt2"] = "亮出牌堆底起第一张红色牌并尝试连续使用",
  ["#chidieren"] = "叠纴：你可以将任意张牌当作一张字数等于其之和的基本牌或普通锦囊牌使用或打出",
  ["#chidieren_active"] = "叠纴：弃置一张牌，并依次视为使用任意张字数之和等于X的牌",
  ["#chi_dieren_discard"] = "叠纴：弃置一张牌名字数为X的牌",
  ["#chi_dieren_choose"] = "叠纴：继续选择要视为使用的牌名（当前剩余字数：%arg）",
  ["$chi_feimeng1"] = "绯梦乍醒,伊人如幻。",
  ["$chi_feimeng2"] = "一梦成绮，半生成殇。",
  ["$chi_dieren1"] = "裁锦叠纴，尽入心机。",
  ["$chi_dieren2"] = "丝缕交叠，可织千端。",

  ["chidieren_active"] = "叠纴",
  [":chidieren_active"] = "出牌阶段，你可以弃置一张牌名字数为X的牌，并依次选择任意张牌名字数之和为X的基本牌或普通锦囊牌，依次视为使用之且不计入次数。",
  ["#chidieren_active"] = "叠纴：弃置一张牌，并依次视为使用总字数等于X的牌",

  ["chidieren&"] = "叠纴",
  [":chidieren&"] = "出牌阶段，你可以弃置一张牌名字数为X的牌，并依次选择任意张牌名字数之和为X的基本牌或普通锦囊牌，依次视为使用之且不计入次数。",
  ["#chi_dieren_choose"] = "叠纴：选择要视为使用的牌名（当前剩余字数：%arg）",
  ["#chi_dieren_target"] = "叠纴：为 %arg 选择目标",

  ["chixique"] = "析阙",
  [":chixique"] = "出牌阶段限一次，你可以弃置一张牌，视为依次使用任意张牌名字数之和为其的基本牌或普通锦囊牌（不计入次数）。",
  ["#chixique"] = "析阙：弃置一张牌，并依次视为使用总字数等于X的牌",
  ["#chi_xique_choose"] = "析阙：选择要视为使用的牌名（当前剩余字数：%arg）",
  ["#chi_xique_target"] = "析阙：为 %arg 选择目标",

  ["chidieren-round"] = "叠纴轮次记录",

  ["@$chidieren-round"] = "叠纴",


  
  ["chi__guozhao"] = "郭照",
  ["#chi__guozhao"] = "众星拥后",
  ["~chi__guozhao"] = "椒兰零落，空阁余寒……",
  ["designer:chi__guozhao"] = "公冶天纵",
  ["illustrator:chi__guozhao"] = "佚名",
  ["cv:chi__guozhao"] = "暂无",
  ["chixiege"] = "携阁",
  [":chixiege"] = "每轮开始时，你可以选择一名角色，令其与上家：①出牌阶段使用【杀】次数为[1]；②摸牌阶段摸牌数为[1]；③受到或造成伤害后摸[1]张牌。当【携阁】目标使用伤害类卡牌指定目标后，或成为伤害类卡牌的目标后，你可以令任一括号内数值于本轮内+1。",
  ["chishangjiao"] = "尚椒",
  [":chishangjiao"] = "锁定技，①当你每回合首次成为一张牌名字数小于/大于当前回合角色体力值的牌的目标后，所有目标摸/弃差值张牌。②你于摸牌阶段外获得的牌不计入本轮手牌上限。",
  ["#chixiege-choose"] = "携阁：选择一名角色，其与上家本轮获得数值效果",
  ["#chixiege-plus"] = "携阁：你可以令一项数值+1",
  ["chixiege_slash"] = "【杀】次数上限",
  ["chixiege_draw"] = "摸牌阶段摸牌数",
  ["chixiege_damage"] = "造成或受到伤害后摸牌数",
  ["@chixiege_slash-round"] = "携阁杀数",
  ["@chixiege_draw-round"] = "携阁摸牌",
  ["@chixiege_damage-round"] = "携阁伤摸",
  ["$chixiege1"] = "携香入阁，静待风回。",
  ["$chixiege2"] = "高阁有序，万事皆可筹。",
  ["$chishangjiao1"] = "椒香尚烈，亦可乱心。",
  ["$chishangjiao2"] = "尚椒一缕，寒意自生。",

  ["chi__zhanghuai"] = "张怀",
  ["#chi__zhanghuai"] = "空谷之麋",
  ["~chi__zhanghuai"] = "空阑风冷，影散无归……",
  ["designer:chi__zhanghuai"] = "公冶天纵",
  ["illustrator:chi__zhanghuai"] = "佚名",
  ["cv:chi__zhanghuai"] = "暂无",
  ["chikonglan"] = "空阑",
  [":chikonglan"] = "锁定技，你的黑桃牌与点数小于场上人数的牌不计入本轮手牌上限；当你成为一张牌的目标后，若此牌牌名字数你本轮未以此法记录过，你记录之并获得相同张【影】，轮次刷新后你清除记录。",
  ["chixuanzhao"] = "悬照",
  [":chixuanzhao"] = "转换技，每轮每种牌名限一次，你可以将X张【影】当一张：①牌名字数；②合法目标数：为X的基本牌或普通锦囊牌使用或打出。",
  ["@$chikonglan-round"] = "空阑·已触发数字",
  ["#chikonglan-record"] = "空阑：你记录了字数 %arg 并获得 %arg2 张【影】",
  ["#chixuanzhao"] = "悬照：将X张【影】当牌使用或打出",
  ["$chikonglan1"] = "空阑影寂，独照寒心。",
  ["$chikonglan2"] = "阑外风定，影里藏机。",
  ["$chixuanzhao1"] = "悬光映影，照彻百端。",
  ["$chixuanzhao2"] = "照形观势，影中有机。",

    ["chimiling"] = "麋灵",
  [":chimiling"] = "<b>锁定技，</b>当你成为一张牌的目标后，若此牌牌名字数你未以此法记录过，你记录之并将等量张武将牌置于你的武将牌上，称为“麋”；每轮开始时，你清除所有记录和“麋”。",
  ["#chimiling_log"] = "%from 发动【麋灵】，获得了%arg张“麋”",
  ["$chimiling1"] = "林深时见鹿，梦醒时见你。",
  ["$chimiling2"] = "万物有灵，生生不息。",

  -- 苍生
  ["chicangsheng"] = "苍生",
  [":chicangsheng"] = "<b>转换技，</b>你可以弃置X张“麋”视为使用或打出一张：①（阳）牌名字数为X的基本牌或普通锦囊牌；②（阴）合法目标数为X的基本牌或普通锦囊牌。",
  ["#chicangsheng-yang"] = "苍生-阳：弃置等同于【牌名字数】的“麋”，视为使用/打出此牌",
  ["#chicangsheng-yin"] = "苍生-阴：弃置等同于【目标数量】的“麋”，视为使用/打出此牌",
  ["#chicangsheng-discard"] = "苍生：请选择弃置一张“麋”（剩余 %arg 张）",
  ["$chicangsheng1"] = "以此身，换取苍生之念。",
  ["$chicangsheng2"] = "一念为苍生，一念为己身。",

  -- 空杳
  ["chikongyao"] = "空杳",
  [":chikongyao"] = "<b>锁定技，</b>当你即将受到伤害时，若你有与伤害来源势力相同的“麋”，你弃置之并防止此伤害。",
  ["#chikongyao-discard"] = "空杳：请选择一张与 %dest 势力相同的“麋”弃置，以防止此伤害",
  ["$chikongyao1"] = "万籁俱寂，空杳无声。",
  ["$chikongyao2"] = "归于虚无，便是你的终途。",

  
  ["chikonglan_nums-round"] = "空阑数字记录",
  ["chikonglan_names-round"] = "空阑牌名记录",

  ["@chikonglan"] = "空阑",

  
  ["@[chixuanzhao]"] = "悬照",
  ["chixuanzhao_used-round"] = "悬照隐藏记录",

  ["@$chixuanzhao-round"] = "悬照",

  ["@[niwoshucai]"] = "殊彩",

  ["@@chishangjiao_round"] = "尚椒",
  ["@@chixingjue_xu"] = "醑",

  ["@@chiraoluo_judge"] = "扰洛判定",
  ["@@chiraoluo_judge_used-turn"] = "扰洛判定限制",

  ["@@chiraoluo_judge"] = "扰洛",
  ["chiraoluo_opt2"] = "其于当前回合结束后执行一个仅含判定阶段的额外回合",

  ["@@chikonglan_round"] = "空阑",
  ["chikonglan_shadow-round"] = "空阑影记录",

  
  ["@[chimingzhi]"] = "酩志",
  ["@[chiyongtang]"] = "雍赯",
  ["chimingzhi_suits-turn"] = "酩志隐藏记录",
  ["chiyongtang_suits-turn"] = "雍赯隐藏记录",

  ["chi__mifuren"] = "糜贞",
  ["#chi__mifuren"] = "乱世洄临",
  ["~chi__mifuren"] = "一跃清波尽，竟无归处……",
  ["designer:chi__mifuren"] = "公冶天纵",
  ["illustrator:chi__mifuren"] = "佚名",
  ["cv:chi__mifuren"] = "暂无",
  ["chizhijian"] = "炙间",
  [":chizhijian"] = "锁定技，准备阶段或当你受到伤害后，你随机交换下面两项：①已废除装备栏；②未废除装备栏；③体力上限；④额定攻击次数；⑤体力值；⑥手牌数（不能是本回合选择过的，若均已选择过则不触发）。",
  ["chilindu"] = "临渡",
  [":chilindu"] = "使命技，当你响应一张牌后，你修改“炙间”一项描述。<br>成功：当“炙间”均修改完成后，你将体力恢复至体力上限，然后获得“谲忆”，并将其他所有角色非手牌区的所有牌替换为【毒】。",
  ["chijueyi"] = "谲忆",
  [":chijueyi"] = "当你需要使用或打出一张基本牌或普通锦囊牌时，你可以发动一次【炙间】，视为使用或打出一张牌名字数等于本次交换两项当前数值之和的牌。",
  ["@chizhijian"] = "炙间",
  ["#chizhijian-choose"] = "炙间：选择要交换的两项",
  ["#chizhijian-viewas"] = "炙间：你可以发动一次炙间视为使用或打出一张牌",
  ["chizhijian_1"] = "已废除装备栏",
  ["chizhijian_2"] = "未废除装备栏",
  ["chizhijian_3"] = "体力上限",
  ["chizhijian_4"] = "额定攻击次数",
  ["chizhijian_5"] = "体力值",
  ["chizhijian_6"] = "手牌数",
  ["$chilindu_success"] = "渡尽前尘，此心方成。",
  ["$chizhijian1"] = "炙焰流转，祸福倒悬。",
  ["$chizhijian2"] = "一间之隔，生死互易。",
  ["$chilindu1"] = "临流待渡，前缘难断。",
  ["$chilindu2"] = "既临此渡，当绝往生。",
  ["$chijueyi1"] = "旧忆纷错，皆成谲谋。",
  ["$chijueyi2"] = "谲辞杂忆，可乱真伪。",

  [":chizhijian"] = "锁定技，准备阶段，你随机交换下面两项：①已废除装备栏；②未废除装备栏；③体力上限；④额定攻击次数（出牌阶段使用【杀】次数）。",
  ["chizhijian2"] = "炙间",
  [":chizhijian2"] = "锁定技，准备阶段，你随机交换下面两项：①已废除装备栏；②未废除装备栏；③体力上限；④额定攻击次数（出牌阶段使用【杀】次数）；⑤体力值；⑥手牌数。",
  ["chizhijian3"] = "炙间",
  [":chizhijian3"] = "锁定技，准备阶段或当你受到伤害后，你随机交换下面两项：①已废除装备栏；②未废除装备栏；③体力上限；④额定攻击次数（出牌阶段使用【杀】次数）；⑤体力值；⑥手牌数。（不能是本轮选择过的，若均已选择过则不触发）",
  ["chizhijian4"] = "炙间",
  [":chizhijian4"] = "准备阶段或当你受到伤害后，你可以交换下面两项：①已废除装备栏；②未废除装备栏；③体力上限；④额定攻击次数（出牌阶段使用【杀】次数）；⑤体力值；⑥手牌数（不能是本回合选择过的，若均已选择过则不触发）",
  [":chijueyi"] = "当你需要使用或打出一张基本牌或普通锦囊牌时，你可以发动一次“炙间”视为使用之。",
  ["#chizhijian-viewas"] = "谲忆：你可以发动一次炙间，视为使用或打出一张牌",

  ["@chizhijian_swap"] = "炙间交换",
  
            
  ["chifusheng"] = "浮生",
  [":chifusheng"] = "准备阶段或当你受到伤害后，你可以交换下面两项数值并于本轮移除之：①已废除装备栏；②未废除装备栏；③体力上限；④出牌阶段使用杀次数；⑤手牌数；⑥体力值。",
  ["chijianian"] = "佳年",
  [":chijianian"] = "当你需要使用或打出一张基本牌或普通锦囊牌时，你可以发动一次“浮生”视为使用之。若“浮生”已被移除的项中有相等项，你恢复之。",
        
  ["chi__mifuren2"] = "糜贞",
  ["#chi__mifuren2"] = "渡尽前尘",
  ["~chi__mifuren2"] = "一跃清波尽，竟无归处……",
  ["designer:chi__mifuren2"] = "公冶天纵",
  ["illustrator:chi__mifuren2"] = "佚名",
  ["cv:chi__mifuren2"] = "暂无",
  
  ["chiyanzu"] = "衍族",
  [":chiyanzu"] = "每回合限一次，当你需要使用或打出一张基本牌或普通锦囊牌时，或当你受到伤害后，你可以使用本回合进入弃牌堆的一张可使用的基本牌或普通锦囊牌。若此牌牌名字数大于场上角色数，你刷新此技能且摸场上角色数张牌。",
  ["#chiyanzu_choose_use"] = "衍族：选择本回合进入弃牌堆的一张可使用或打出的基本牌或普通锦囊牌",
  ["#chiyanzu_choose_damaged"] = "衍族：选择本回合进入弃牌堆的一张基本牌或普通锦囊牌使用",
  ["chi__xiahoumao"] = "夏侯楙",
  ["#chi__xiahoumao"] = "浮华宗子",
  ["~chi__xiahoumao"] = "浮华散尽，方知此身空误……",
  ["designer:chi__xiahoumao"] = "公冶天纵",
  ["illustrator:chi__xiahoumao"] = "佚名",
  ["cv:chi__xiahoumao"] = "暂无",
  ["chirenfu"] = "荏腹",
  [":chirenfu"] = "锁定技，当你每回合首次使用普通锦囊牌时，你摸已使用基本牌数量张牌。若摸牌数小于2，你受到来自当前回合角色的一点雷属性伤害，且若不为你的回合，你移动你与其一张牌。（无法移动则改为手牌少的获得手牌多的一方一张手牌）。",
  ["chirenfu2"] = "荏腹",
  [":chirenfu2"] = "锁定技，当你每回合首次使用锦囊牌时，你摸本回合已使用基本牌数张牌。若以此法摸牌数小于2，你受到来自当前回合角色的一点雷电伤害然后移动你与其区域内的一张牌。",
  ["chiyanzu2"] = "衍族",
  [":chiyanzu2"] = "每回合限一次，①当你需要使用或打出一张基本牌或普通锦囊牌时；②当你受到伤害后；你可以使用本回合进入弃牌堆的一张合法同名牌。若此牌合法目标数大于场上角色数，你刷新此技能。",

    -- 炽陆凯
  ["chi__lukai"] = "陆凯",
  ["chi__lukai_prefix"] = "炽",
  ["~chi__lukai"] = "蹇途已尽，笃谒成空……",
  ["designer:chi__lukai"] = "公冶天纵",
  ["illustrator:chi__lukai"] = "佚名",
  ["cv:chi__lukai"] = "暂无",
  ["chijiantu"] = "蹇途",
  [":chijiantu"] = "转换技，锁定技，当你于回合内首次使用一种花色的单体目标牌指定手牌数不大于你的角色时，此牌视为：阴：闪电；阳：过河拆桥。",
  ["chiduye"] = "笃谒",
  [":chiduye"] = "出牌阶段限一次，你可以依次展示场上至多四张牌，归属者依次选择一项并移除：①摸X张牌；②X个回合内获得【謇谔】；③本回合结束后执行一个第X个阶段（逆序）；④使用此牌，然后置于牌堆顶。（X为已选选项数+1）",
  ["chizelie"] = "泽烈",
  [":chizelie"] = "当角色失去其场上的所有牌后，你可令一名角色本回合下次摸牌/弃置牌后，其摸一张牌/弃置一张牌。",
  ["$chijiantu1"] = "蹇途难行，自有坦途。",
  ["$chijiantu2"] = "路虽蹇涩，志不可移。",
  ["$chiduye1"] = "笃行谒见，诚意可鉴。",
  ["$chiduye2"] = "谒而笃之，礼数周全。",
  ["$chizelie1"] = "泽被苍生，烈火淬金。",
  ["$chizelie2"] = "烈而有泽，刚柔并济。",

    -- 荀勖
  ["chi__xunxu"] = "荀勖",
  ["chi__xunxu_prefix"] = "炽",
  ["~chi__xunxu"] = "律法既定，奈何人心难测……",
  ["designer:chi__xunxu"] = "公冶天纵",
  ["illustrator:chi__xunxu"] = "佚名",
  ["cv:chi__xunxu"] = "暂无",
  ["chiyilvRemake"] = "绎律",
  [":chiyilvRemake"] = "锁定技，当你的体力值发生变化时，或一号位的准备阶段开始时，你选择一种颜色并依次展示牌堆顶X张牌，使用其中另一种颜色的牌，并获得其余的牌（X为为“徇覆”已记录的锦囊牌牌名数且至少为1）。",
  ["chifufengRemake"] = "扶风",
  [":chifufengRemake"] = "锁定技，当你于一个阶段首次展示一张牌后，你重铸你手牌中另一种颜色的所有牌，然后你将一张牌置于牌堆顶。。",
  ["chixunfu"] = "徇覆",
  [":chixunfu"] = "锁定技，当你成为一张本轮未以此法记录过的非装备牌的目标时，来源需展示另一种颜色的一张手牌，否则此牌对你无效，然后你记录此牌牌名。",
  ["chidaojie"] = "蹈节",
  [":chidaojie"] = "锁定技，当你每回合第一次使用非伤害普通锦囊牌结算结束后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名角色获得此牌。",
  ["$chiyilvRemake1"] = "律吕相生，绎而不绝。",
  ["$chiyilvRemake2"] = "音律既正，万象归序。",
  ["$chifufengRemake1"] = "扶风所至，尘埃皆定。",
  ["$chifufengRemake2"] = "风行草偃，自有章法。",
  ["$chixunfu1"] = "徇私覆公，非吾所为。",
  ["$chixunfu2"] = "覆而徇之，法不容情。",
  ["$chidaojie1"] = "道之所诫，不可逾越。",
  ["$chidaojie2"] = "诫而守道，方为正途。",


  -- 炽杨众
  ["chi__yangzhong"] = "杨众",
  ["chi__yangzhong_prefix"] = "炽",
  ["~chi__yangzhong"] = "荡燎已熄，余烬难续……",
  ["designer:chi__yangzhong"] = "公冶天纵",
  ["illustrator:chi__yangzhong"] = "佚名",
  ["cv:chi__yangzhong"] = "暂无",
  ["chidangliao"] = "荡燎",
  [":chidangliao"] = "转换技，阴：当你的红色牌进入弃牌堆后；阳：当你成为红色牌的目标后；你可令当前回合角色依此牌牌名字数与X的大小执行：①大于：其将此牌视为【火攻】/火【杀】使用（装备牌则视为使用）；②小于：其于此回合结束后执行一个等于X的阶段（摸牌/出牌/弃牌）；③等于：背水，然后你翻面。（X为本回合选项执行次数，大于3时重置为1）",
  ["$chidangliao1"] = "荡荡燎原，烈火无边。",
  ["$chidangliao2"] = "燎火荡尽，灰烬重生。",


    -- 炽王倩
  ["chi__wangqian"] = "王倩",
  ["chi__wangqian_prefix"] = "炽",
  ["~chi__wangqian"] = "擢息已止，遐容难留……",
  ["designer:chi__wangqian"] = "公冶天纵",
  ["illustrator:chi__wangqian"] = "佚名",
  ["cv:chi__wangqian"] = "暂无",
  ["chizhuoxi"] = "擢息",
  [":chizhuoxi"] = "限定技，锁定技，转换技，当你距离不大于1的角色使用基本牌和普通锦囊牌时，若此牌为：阴：实体牌；阳：转化牌；你获得该牌并重置武将牌。",
    ["chizhongliu"] = "中流",
  [":chizhongliu"] = "锁定技，当你使用牌时，若此牌不为你的手牌，你武将牌上的技能视为未发动过。",
 
  ["chixiarong"] = "遐容",
  [":chixiarong"] = "限定技，当你需要使用或打出一张牌名字数本轮未以此法重复且为X的牌时，你可以翻面并观看与你距离不小于X的一名其他角色的手牌，将你们任意张牌名字数之和等于X的牌转化为之，然后本轮该角色/其他角色与你的距离-X/+X。",
  ["$chizhuoxi1"] = "擢而息之，得其所哉。",
  ["$chizhuoxi2"] = "息而擢之，静中有动。",
  ["$chixiarong1"] = "遐容远望，自有风仪。",
  ["$chixiarong2"] = "容止可观，遐迩皆知。",
  ["$chizhongliu1"] = "中流击水，浪遏飞舟。",
  ["$chizhongliu2"] = "砥柱中流，岿然不动。",

  -- 胡金定
  ["chi__hujinding"] = "胡金定",
  ["chi__hujinding_prefix"] = "炽",
  ["~chi__hujinding"] = "此身飘零，如水无痕……",
  ["designer:chi__hujinding"] = "公冶天纵",
  ["illustrator:chi__hujinding"] = "佚名",
  ["cv:chi__hujinding"] = "暂无",
  ["chiqianmeng"] = "遣梦",
  [":chiqianmeng"] = "你可以失去任意点体力上限当作一张牌名字数相等的基本牌或普通锦囊牌使用或打出。若此牌为基本牌或你此时体力上限等于该牌牌名字数，你增加一点体力上限。",
  ["chihuaiji"] = "怀赍",
  [":chihuaiji"] = "转换技，阴：当你使用一张牌后，你可以失去该牌目标数点体力上限为此牌重新指定目标。阳：当你成为一张牌的目标后，你可以增加该牌目标数点体力上限。",
  ["$chiqianmeng1"] = "此身所余，唯此一诺。",
  ["$chiqianmeng2"] = "宥人者，先宥己也。",
  ["$chihuaiji1"] = "怀中所赍，皆是旧情。",
  ["$chihuaiji2"] = "赍志而没，何其悲哉。",

  -- 朱佩兰
  ["chi__zhupeilan"] = "朱佩兰",
  ["chi__zhupeilan_prefix"] = "炽",
  ["~chi__zhupeilan"] = "佳人薄命，红颜丧于虎狼之口。",
  ["designer:chi__zhupeilan"] = "公冶天纵",
  ["illustrator:chi__zhupeilan"] = "佚名",
  ["cv:chi__zhupeilan"] = "暂无",
  ["chi_kuiliRemake3"] = "暌离",
  [":chi_kuiliRemake3"] = "转换技，每回合限一次，当你使用一张基本牌或普通锦囊牌时，若有与此牌①牌名字数②合法目标数相同的牌，你展示之并计算二者差X，此牌额外结算X次/额外选择X个目标；若X等于体力值，你转换状态且刷新本技能。",
  ["chi_tiaomu"] = "迢目",
  [":chi_tiaomu"] = "每回合限一次，当你需要使用或打出一张基本牌或普通锦囊牌时，你可以从弃牌堆随机获得一张牌名字数或合法目标相同的牌视为使用或打出之。若两张牌牌名相同，本技能使用次数+1。",
  ["$chi_kuiliRemake31"] = "妾提不得刀兵、聚不起人马，于汝何害之有？",
  ["$chi_kuiliRemake32"] = "诸公明鉴，我何罪之有？",
  ["$chi_tiaomu1"] = "朝堂多朱紫，诸君何故问计于妇人？",
  ["$chi_tiaomu2"] = "我所知者，女红之术、书画之艺，难承社稷之重。",

  -- 邹氏
  ["chi__zoushi"] = "邹氏",
  ["chi__zoushi_prefix"] = "炽",
  ["~chi__zoushi"] = "生逢乱世，身何由己？",
  ["designer:chi__zoushi"] = "公冶天纵",
  ["illustrator:chi__zoushi"] = "佚名",
  ["cv:chi__zoushi"] = "暂无",
  ["chiyinghun"] = "萦魂",
  [":chiyinghun"] = "锁定技，当你使用一张牌后/当你受到伤害后，此牌所有目标翻面/你与伤害来源翻面，且本回合所有武将牌正面朝上角色的非锁定技失效。你与武将牌状态一致角色的距离始终为1。",
  ["chisiyu"] = "飔毓",
  [":chisiyu"] = "转换技，你可以翻面视为使用或打出一张不计入次数的：①牌名字数为X的基本牌或普通锦囊牌；②目标数不大于所有已翻面角色数的基本牌或普通锦囊牌。（X为场上翻面的角色数）",
  ["$chiyinghun1"] = "温柔乡里忘归路，香唇软语最噬人。",
  ["$chiyinghun2"] = "将军，还是把脸蒙起来吧。",
  ["$chisiyu1"] = "武夫以力破阵，佳人凭貌倾城。",
  ["$chisiyu2"] = "佳人倾城又倾国，何怨幽王戏诸侯？",

  -- 董予安
  ["chi__dongguiren"] = "董予安",
  ["chi__dongguiren_prefix"] = "炽",
  ["~chi__dongguiren"] = "奈何生为女儿身，不能提剑清君侧。",
  ["designer:chi__dongguiren"] = "公冶天纵",
  ["illustrator:chi__dongguiren"] = "佚名",
  ["cv:chi__dongguiren"] = "暂无",
  ["chishanquan"] = "潸泉",
  [":chishanquan"] = "每回合限一次，你可以交换你的手牌数和体力上限，视为使用或打出一张牌名字数为二者差的基本牌或普通锦囊牌。",
  ["chisimi"] = "澌弭",
  [":chisimi"] = "转换技，锁定技，当你的体力上限、手牌数或二者差值任意两个每轮首次相等后，你随机执行：①摸一张牌或增加一点体力上限；②随机弃置一张牌或失去一点体力上限。",
  ["$chishanquan1"] = "泪落成泉，心事难言。",
  ["$chishanquan2"] = "潸然泪下，非为软弱。",
  ["$chisimi1"] = "澌灭之势，弭于无形。",
  ["$chisimi2"] = "冰消雪融，自有归处。",

  -- 炽陆逊 001
  ["chi__luxun"] = "陆逊",
  ["#chi__luxun"] = "暂无",
  ["~chi__luxun"] = "风冷，无归……",
  ["designer:chi__luxun"] = "公冶天纵",
  ["illustrator:chi__luxun"] = "佚名",
  ["cv:chi__luxun"] = "暂无",
  ["chiquege"] = "阒阁",
  [":chiquege"] = "锁定技，若你回合内首次：①体力值等于体力上限，你摸此数值牌；②手牌数等于手牌上限，你视为使用一张不计入次数的火【杀】；③“睄睒”任一选项首次等于在你攻击范围内的角色数：你可以摸一张牌并恢复“睄睒”中一个被移除的选项。④死亡人数等于存活人数，你移除此选项并与一名其他玩家易位。",
  ["chishaoshan"] = "睄睒",
  [":chishaoshan"] = "出牌阶段，你可以交换以下两个属性的数值，然后本回合移除对应选项，未被选到的属性下次选择时+1：①体力值；②手牌上限；③出杀次数；④你与一号位的距离；⑤手牌数；⑥体力上限。若交换后奇/偶数次有属性溢出，你摸/弃等同于此溢出量的牌。",
  ["chimaoqi"] = "榫棋",
  [":chimaoqi"] = "当你于非摸牌阶段获得牌时，你可以将其中任意张置于你的武将牌上，称为“棋”。出牌阶段限一次，你可以获得任意张“棋”。每个回合结束时，若“棋”的数量大于场上人数，你失去一点体力值。",

  -- 炽张春华 002
  ["chi__zhangchunhua"] = "张春华",
  ["#chi__zhangchunhua"] = "炽张春华",
  ["~chi__zhangchunhua"] = "焚尽旧梦，方知此心……",
  ["designer:chi__zhangchunhua"] = "公冶天纵",
  ["illustrator:chi__zhangchunhua"] = "佚名",
  ["cv:chi__zhangchunhua"] = "暂无",
  ["chifenqing"] = "焚情",
  [":chifenqing"] = "出牌阶段限一次，你可以选择一名其他角色，你与其横置并分别选择一项：①令对方受到来自你的一点火属性伤害②令对方翻面③背水：若只有一名角色选择该选项则交换双方效果。若你与其选择相同选择则均不执行且你与其各恢复一点体力值。",
  ["chisuhen"] = "夙痕",
  [":chisuhen"] = "锁定技，每回合限一次，当你受到或造成属性伤害后，伤害来源重置其武将牌，然后你视为对伤害来源或目标发动一次“焚情”。每个回合结束时，若当前回合角色于本回合内受到或造成过属性伤害，你可以观看牌堆顶两张牌并使用其中可以使用的牌。",
  ["chiyuanque"] = "缘阙",
  [":chiyuanque"] = "使命技，当你累计造成或受到不小于X点属性伤害时，<br>成功：你将体力值恢复至体力上限，失去“焚情”和“夙疾”，然后随机获得两个技能。若此时为你的回合外，你额外获得一个技能。<br>失败：若你进入濒死状态，你将体力值恢复至1，失去一点体力上限和“焚情”和“夙疾”，并追忆一名角色。",
  ["chiejue"] = "扼绝",
  [":chiejue"] = "锁定技，当你/攻击范围不包含你的角色使用【杀】或【决斗】即将对攻击范围不包含你的角色/你造成伤害时，此伤害+1。",


  -- 炽庞凤衣 007
  ["chi__pangfengyi"] = "庞凤衣",
  ["#chi__pangfengyi"] = "炽庞凤衣",
  ["~chi__pangfengyi"] = "有酿醇醇，醒魂犹寒……",
  ["designer:chi__pangfengyi"] = "公冶天纵",
  ["illustrator:chi__pangfengyi"] = "佚名",
  ["cv:chi__pangfengyi"] = "暂无",
  ["chixingjue"] = "醒釂",
  [":chixingjue"] = "锁定技，你的回合内/外，所有角色牌名字数大于/小于其体力值的手牌均视为【酒】，这些牌称为“醑”。当有角色失去一张“醑”时，你摸一张牌。",
  ["chiyongtang"] = "雍赯",
  [":chiyongtang"] = "锁定技，当你成为单体基本牌或普通锦囊牌的目标后，你需判定，若判定牌花色与此牌花色不同/相同，则额外其指定下家/上家为目标，然后本回合与判定牌相同花色的牌无使用次数限制。",

  -- 炽诸葛果 008
  ["chi__zhugeguo"] = "诸葛果",
  ["#chi__zhugeguo"] = "炽诸葛果",
  ["~chi__zhugeguo"] = "篁竹摇落，簌肃成音……",
  ["designer:chi__zhugeguo"] = "公冶天纵",
  ["illustrator:chi__zhugeguo"] = "佚名",
  ["cv:chi__zhugeguo"] = "暂无",
  ["chihuangli"] = "篁礼",
  [":chihuangli"] = "锁定技，准备阶段或当你受到伤害后，你展示牌堆顶或牌堆底至多三张牌。若这些牌：颜色相同，你获得这些牌并卜算2；类型相同，当前回合角色使用的下一张牌无次数距离限制；花色均不相同，你令一名角色恢复一点体力值； 若均不满足，当前回合角色失去一点体力且重铸所有牌。",
  ["chisusu"] = "簌肃",
  [":chisusu"] = "锁定技，当你于每回合首次使用非基本牌后，你于本回合使用的下一张牌可额外指定一个目标。当你于每回合首次使用基本牌后，你于本回合使用的下一张牌可额外结算一次。",

  -- 炽黄月英 009
  ["chi__huangyueying"] = "黄月英",
  ["#chi__huangyueying"] = "炽黄月英",
  ["~chi__huangyueying"] = "映山如画，神臬成谋……",
  ["designer:chi__huangyueying"] = "公冶天纵",
  ["illustrator:chi__huangyueying"] = "佚名",
  ["cv:chi__huangyueying"] = "暂无",
  ["chiyingshan"] = "映山",
  [":chiyingshan"] = "每回合限一次，出牌阶段或当你受到伤害后，你可以连接你的一张手牌。若此牌牌名字数与你体力值相等，你可以选择一项：1.恢复一点体力值；2.“映山”本回合使用次数+1；3.令“神臬”③本回合失效。",
  ["chishennie"] = "神臬",
  [":chishennie"] = "锁定技，①你的锦囊牌始终为连接状态；你的连接牌且使用外无法弃置、不计入手牌和使用次数上限且无距离限制。②当你受到或造成伤害后，你连接伤害来源或目标一张手牌。③当一张连接牌因使用或打出而进入弃牌堆后，你摸一张牌，全场角色本回合无法打出或使用牌名字数与此牌相等的牌。",


  -- 炽于吉 011
  ["chi__yuji"] = "于吉",
  ["#chi__yuji"] = "炽于吉",
  ["~chi__yuji"] = "倞道既成，诣谛何求……",
  ["designer:chi__yuji"] = "公冶天纵",
  ["illustrator:chi__yuji"] = "佚名",
  ["cv:chi__yuji"] = "暂无",
  ["chiliangdao"] = "倞道",
  [":chiliangdao"] = "每种牌名限一次，当你使用的牌即将生效且此牌不为响应而使用或打出时，你可以在本次结算中将此牌牌面描述上的任意牌名用与之牌名字数相等的其余牌名替代之。",
  ["chifushui"] = "覆水",
  [":chifushui"] = "当其他角色响应你的牌后，你摸剩余选项张牌并依次执行：①“每种牌名限一次”改为“每轮限一次”；②“牌名”平行选项增加“或颜色”；③恢复体力值至体力上限，获得“诣谛”。",
  ["chiyidi"] = "诣谛",
  [":chiyidi"] = "每轮各限一次，①当有角色发动技能时，你可以为其指定其一作用目标。②出牌阶段或当你受到伤害后，你可令一名角色的一个技能描述上的牌名/颜色修改为任一其他牌名/颜色。",


  -- 炽邹氏 014
  ["chi__zoushi"] = "邹氏",
  ["#chi__zoushi"] = "炽邹氏",
  ["~chi__zoushi"] = "生逢乱世，身何由己？",
  ["designer:chi__zoushi"] = "公冶天纵",
  ["illustrator:chi__zoushi"] = "佚名",
  ["cv:chi__zoushi"] = "暂无",
  ["chiyugu"] = "毓骨",
  [":chiyugu"] = "转换技，你可以翻面视为使用或打出一张不计入次数的：①牌名字数为X的基本牌或普通锦囊牌；②目标数不大于所有已翻面角色数的基本牌或普通锦囊牌（X为场上翻面的角色数）",
  ["chiyinghun"] = "萦魂",
  [":chiyinghun"] = "锁定技，当你使用一张牌后/当你受到伤害后，此牌所有目标翻面/你与伤害来源翻面，且本回合所有武将牌正面朝上角色的非锁定技失效。你与武将牌状态一致角色的距离始终为1。",

  -- 炽朱佩兰 015
  ["chi__zhupeilan"] = "朱佩兰",
  ["#chi__zhupeilan"] = "炽朱佩兰",
  ["~chi__zhupeilan"] = "佳人薄命，红颜丧于虎狼之口。",
  ["designer:chi__zhupeilan"] = "公冶天纵",
  ["illustrator:chi__zhupeilan"] = "佚名",
  ["cv:chi__zhupeilan"] = "暂无",
  ["chikuili"] = "暌离",
  [":chikuili"] = "转换技，每回合限一次，当你使用一张基本牌或普通锦囊牌时，若你有与此牌：①牌名字数；②合法目标数相同的牌，你可展示之并令此牌额外结算X次/额外选择X个目标；若X不大于1，你刷新本技能（X为牌名字数/合法目标数与展示牌张数之差）。",
  ["chitiaomu"] = "迢目",
  [":chitiaomu"] = "每回合限一次，你可以从弃牌堆获得满足条件的第一张牌名字数或合法目标相同的牌视为使用或打出一张基本牌或普通锦囊牌，若两张牌牌名相同，你刷新本技能。",

  -- 炽董予安 016
  ["chi__dongguiren"] = "董予安",
  ["#chi__dongguiren"] = "炽董予安",
  ["~chi__dongguiren"] = "奈何生为女儿身，不能提剑清君侧。",
  ["designer:chi__dongguiren"] = "公冶天纵",
  ["illustrator:chi__dongguiren"] = "佚名",
  ["cv:chi__dongguiren"] = "暂无",
  ["chishanquan"] = "潸泉",
  [":chishanquan"] = "每回合限一次，你可以交换你的手牌数和体力上限，视为使用或打出一张牌名字数为二者差的基本牌或普通锦囊牌。",
  ["chisimi"] = "澌弭",
  [":chisimi"] = "转换技，锁定技，当你的体力上限、手牌数或二者差值任意两个每轮首次相等后，你①摸一张牌或增加一点体力上限；②弃置一张牌或失去一点体力上限。",

  -- 炽任婉 017
  ["chi__renwan"] = "任婉",
  ["#chi__renwan"] = "炽任婉",
  ["~chi__renwan"] = "此身若梦，终将离阙……",
  ["designer:chi__renwan"] = "公冶天纵",
  ["illustrator:chi__renwan"] = "佚名",
  ["cv:chi__renwan"] = "暂无",
  ["chilingmeng"] = "泠梦",
  [":chilingmeng"] = "锁定技，当你即将造成/受到有实体牌的伤害时，若目标/来源区域内有与此实体牌牌名字数相等的牌，防止此伤害并展示这些牌，其/你获得你/其区域内所有展示的牌。",
  ["chilique"] = "离阙",
  [":chilique"] = "锁定技，你于每回合使用的第一张牌即将生效时，按该牌及其后三张牌的牌名字数，选择一条路径执行效果：递增：①不计入次数②执行两次③目标＋1④执行X次；递减：①执行两次②目标＋1③不计入次数④目标＋X；若你使用的牌不符合所选路径，你弃置X张牌且本回合技能失效。若此时X等于你体力值，该牌仍执行下个路径效果（X为本流程已使用牌数）。",

  -- 炽杨众 019
  ["chi__yangzhong"] = "杨众",
  ["#chi__yangzhong"] = "炽杨众",
  ["~chi__yangzhong"] = "荡燎既熄，余烬难续……",
  ["designer:chi__yangzhong"] = "公冶天纵",
  ["illustrator:chi__yangzhong"] = "佚名",
  ["cv:chi__yangzhong"] = "暂无",
  ["chidangliao"] = "荡燎",
  [":chidangliao"] = "当你成为红色牌的目标后，或你的红色牌因弃置而进入弃牌堆后，你可令当前回合角色按照此牌牌名字数与X的大小执行：①大于：其将此牌视为【火攻】或火【杀】（不计入次数）使用；②小于：其于此回合结束后执行一个等于X的阶段（摸牌/出牌/弃牌）；③等于：背水，然后你翻面。（X为本回合“荡燎”发动次数）",

    -- 炽荀粲 020
  ["chi__xuncan"] = "荀粲",
  ["#chi__xuncan"] = "炽荀粲",
  ["~chi__xuncan"] = "刺骨入心，幽明自现……",
  ["designer:chi__xuncan"] = "公冶天纵",
  ["illustrator:chi__xuncan"] = "佚名",
  ["cv:chi__xuncan"] = "暂无",
  ["chicigu"] = "刺骨",
  [":chicigu"] = "出牌阶段或当你受到伤害后，你可以将一名角色的一张牌置于你的武将牌上，称为“刺”（至多体力值张），若此牌的点数与你体力值的余数大于1，你受到的一点此牌来源的冰属性伤害。回合结束阶段，你选择一项：1.弃置所有“刺”视为对一名角色使用一张冰【杀】；2.获得体力值张“刺”。",
  ["chiyouming"] = "幽明",
  [":chiyouming"] = "当你每轮首次：①成为一张牌的目标后，你可以观看来源两张手牌并将其中一张置于牌堆顶；②进入濒死状态时，若你武将牌正面朝上，你翻面并将体力恢复至一点，然后你将牌堆顶的牌当做【出其不意】对伤害来源使用，若此牌造成伤害，你重置武将牌。",

  -- 炽荀采 021
  ["chi__xuncai"] = "荀采",
  ["#chi__xuncai"] = "炽荀采",
  ["~chi__xuncai"] = "炬泪成火，炙心成灰……",
  ["designer:chi__xuncai"] = "公冶天纵",
  ["illustrator:chi__xuncai"] = "佚名",
  ["cv:chi__xuncai"] = "暂无",
  ["chijulei"] = "炬泪",
  [":chijulei"] = "你可以横置视为使用或打出一张火【杀】/【火攻】或翻面使用或打出一张【酒】/【逐近弃远】，若当前回合角色或此牌目标角色拥有“尘”标记，你弃置其“尘”标记然后选择一项：①此牌不计入使用次数；②重置你的武将牌。",
  ["chizhichen"] = "炙尘",
  [":chizhichen"] = "锁定技，每轮开始时，你的上家和下家获得“尘”标记。当你受到/造成伤害后，你令伤害来源/目标横置并获得“尘”标记，若当前回合角色横置或翻面，你重铸手牌中花色最多的所有牌。",

  -- 炽王沦 022
  ["chi__wanglun"] = "王沦",
  ["#chi__wanglun"] = "炽王沦",
  ["~chi__wanglun"] = "恬适心安，铭怀世事……",
  ["designer:chi__wanglun"] = "公冶天纵",
  ["illustrator:chi__wanglun"] = "佚名",
  ["cv:chi__wanglun"] = "暂无",
  ["chitianshi"] = "恬适",
  [":chitianshi"] = "锁定技，其他角色于回合内对你使用的首张牌名字数不小于你体力值的牌对你无效。其他角色于回合内使用的首张牌名字数不小于X的牌结算后，你视为使用之。",
  ["chiminghuai"] = "铭怀",
  [":chiminghuai"] = "每名角色的回合结束阶段，你可以将牌名字数之和等于四的任意张牌当做【随机应变】使用，然后你摸X张牌。（X为全场技能描述拥有“限一次”的角色数且不大于你的体力值）",

  -- 炽王沈 023
  ["chi__wangshen"] = "王沈",
  ["#chi__wangshen"] = "炽王沈",
  ["~chi__wangshen"] = "调风成舞，脊望如剑……",
  ["designer:chi__wangshen"] = "公冶天纵",
  ["illustrator:chi__wangshen"] = "佚名",
  ["cv:chi__wangshen"] = "暂无",
  ["chitiaofeng"] = "调风",
  [":chitiaofeng"] = "出牌阶段每种花色限一次，你可以展示所有牌，并将一张牌名字数不小于X的牌当作【调剂盐梅】使用，然后你摸X张牌。（X为你手牌花色数）",
  ["chijiwang"] = "脊望",
  [":chijiwang"] = "锁定技，当你的牌不因使用或打出而离开手牌区时，你展示之且你、当前回合角色和牌堆中所有与此牌花色相同的牌均视为【杀】直到回合本结束。当你成为一张多目标牌的目标后，若此牌其他目标已损失体力值均不大于你，当前回合角色使用的下一张牌你作为目标额外执行一次。",

  -- 炽陆凯 024
  ["chi__lukai"] = "陆凯",
  ["#chi__lukai"] = "炽陆凯",
  ["~chi__lukai"] = "蹇途已尽，笃谒成空……",
  ["designer:chi__lukai"] = "公冶天纵",
  ["illustrator:chi__lukai"] = "佚名",
  ["cv:chi__lukai"] = "暂无",
  ["chijiantu"] = "蹇途",
  [":chijiantu"] = "转换技，锁定技，当你于回合内首次使用一种花色的单体目标牌指定手牌数不大于你的角色时，此牌视为：①闪电；②过河拆桥；对其使用。",
  ["chiduye"] = "笃谒",
  [":chiduye"] = "出牌阶段限一次，你可以依次展示场上至多四张牌，归属者依次选择一项并移除：①摸X张牌；②X个回合内获得【謇谔】；③本回合结束后执行一个第X个阶段（逆序）；④使用此牌，然后置于牌堆顶。（X为已选选项数+1）",
  ["chizelie"] = "泽烈",
  [":chizelie"] = "当你失去任意区域的所有牌后，你可令一名角色本回合下一次摸牌/弃牌后，其再摸一张牌/弃一张牌。",
  ["chixieque"] = "謇谔",
  [":chixieque"] = "锁定技，①当你对其他角色使用的牌生效后，其本回合不能再抵消牌；②当你抵消牌后，你本回合不能再成为所有角色使用牌的目标。",

  -- 炽荀悦 026
  ["chi__xunyue"] = "荀悦",
  ["#chi__xunyue"] = "炽荀悦",
  ["~chi__xunyue"] = "借笈而思，疏纪成律……",
  ["designer:chi__xunyue"] = "公冶天纵",
  ["illustrator:chi__xunyue"] = "佚名",
  ["cv:chi__xunyue"] = "暂无",
  ["chijieji"] = "借笈",
  [":chijieji"] = "出牌阶段限一次，你可以观看一名手牌数或技能数不小于你的角色的手牌，并将其中一张牌当做一张合法目标数相同的基本牌或普通锦囊牌使用，然后其摸X张牌。你于本回合内使用到此牌结算后的第X张牌后，此技能视为未发动过（X为此牌合法目标数）。",
  ["chishuji"] = "疏纪",
  [":chishuji"] = "<a href='sxrm__contract'>契定技</a>，当你每回合首次成为一张多目标锦囊牌的目标后，若此牌的合法目标数不小于你的手牌数，你可以弃置半数手牌（向下取整），并将此锦囊牌的目标数调整至与你手牌数相同（至少为1）。",
  ["#chishuji-invoke"] = "疏纪：你可以弃置半数手牌，将此锦囊牌的目标数调整至你的手牌数（当前手牌数为%arg）",
  ["#chishuji-discard"] = "疏纪：请弃置%arg张手牌",
  ["#chishuji-target"] = "疏纪：请选择此锦囊牌调整后的%arg名目标",


  -- 炽夏侯惇 030
  ["chi__xiahoudun"] = "夏侯惇",
  ["#chi__xiahoudun"] = "炽夏侯惇",
  ["~chi__xiahoudun"] = "燎志如火，赈节如海……",
  ["designer:chi__xiahoudun"] = "公冶天纵",
  ["illustrator:chi__xiahoudun"] = "佚名",
  ["cv:chi__xiahoudun"] = "暂无",
  ["chiliaozhi"] = "燎志",
  [":chiliaozhi"] = "出牌阶段开始时或每轮结束时，你可以与至多X名角色同时拼点，拼点赢的角色视为对所有没赢的角色使用一张火【杀】，然后你摸此流程中受到伤害的角色数张牌（X为你已损失体力值+1）。",
  ["chizhenjie"] = "赈节",
  [":chizhenjie"] = "与你距离不大于1的角色造成或受到属性伤害后，你可以观看牌堆顶两张牌并令你或其使用其中可以使用的牌。",

  -- 炽夏侯玄 031
  ["chi__xiahouxuan"] = "夏侯玄",
  ["#chi__xiahouxuan"] = "炽夏侯玄",
  ["~chi__xiahouxuan"] = "辞玄成海，歧路难辨……",
  ["designer:chi__xiahouxuan"] = "公冶天纵",
  ["illustrator:chi__xiahouxuan"] = "佚名",
  ["cv:chi__xiahouxuan"] = "暂无",
  ["chicixuan"] = "辞玄",
  [":chicixuan"] = "转换技，每回合限一次，你可以①将至多三张牌置于“仁”区然后摸等量的牌；②获得“仁”区至多三张牌；视为使用或打出一张牌名字数等于“仁”区牌数的基本牌或普通锦囊牌。",
  ["chiqihai"] = "歧海",
  [":chiqihai"] = "当你受到或造成伤害后，你可以令伤害来源选择一项：①将一张“仁”区没有的类型的牌置入“仁”区；②移除一张“仁”牌，视为对其使用之（需合法）。",

  -- 炽夏侯杰 032
  ["chi__xiahoujie"] = "夏侯杰",
  ["#chi__xiahoujie"] = "炽夏侯杰",
  ["~chi__xiahoujie"] = "逾慑而行，荡胆成刺……",
  ["designer:chi__xiahoujie"] = "公冶天纵",
  ["illustrator:chi__xiahoujie"] = "佚名",
  ["cv:chi__xiahoujie"] = "暂无",
  ["chiyushe"] = "逾慑",
  ["@$chiyushe"] = "逾慑已用牌名",
  [":chiyushe"] = "<a href='sxrm__contract'>契定技</a>，当你使用一张牌后，若不为你本回合使用的第一张牌，你可以摸X张牌并使用一张本局未以此法使用过的、与原牌合法目标相同的基本牌或普通锦囊牌，若无合法牌名，你失去一点体力并弃置X张牌（X为你使用的上一张牌的合法目标数）。",
  ["#chiyushe-invoke"] = "逾慑：你可以摸%arg张牌，然后使用一张合法目标数相同且未以此法使用过的牌",
  ["#chiyushe-use"] = "逾慑：请使用一张与原牌合法目标数相同的基本牌或普通锦囊牌",
  ["#chiyushe-discard"] = "逾慑：无合法牌名，请弃置%arg张牌",
  ["chidangdan"] = "荡胆",
  [":chidangdan"] = "<a href='sxrm__contract'>契定技</a>，当你使用牌指定目标后，若其体力值与此牌合法目标数相等，你可以选择一项：1.增加一点体力上限并恢复一点体力；2.“逾慑”本回合失效。",
  ["#chidangdan-invoke"] = "荡胆：%dest的体力值与此牌的合法目标数（%arg）相等，你可以发动此技能",
  ["#chidangdan-choice"] = "荡胆：请选择一项（当前目标：%dest）",
  ["chidangdan_maxhp"] = "增加1点体力上限并恢复1点体力",
  ["chidangdan_yushe"] = "令“逾慑”本回合失效",

  -- 炽夏侯荣 033
  ["chi__xiahourong"] = "夏侯荣",
  ["#chi__xiahourong"] = "炽夏侯荣",
  ["~chi__xiahourong"] = "犊烈初心，皦谈成诺……",
  ["designer:chi__xiahourong"] = "公冶天纵",
  ["illustrator:chi__xiahourong"] = "佚名",
  ["cv:chi__xiahourong"] = "暂无",
  ["chidulie"] = "犊烈",
  [":chidulie"] = "锁定技，你于本局游戏首次受到和造成的伤害均翻倍，均触发后你失去本技能。",
  ["chijiaotan"] = "皦谈",
  [":chijiaotan"] = "出牌阶段限一次，你可以令任意技能数大于你的角色议事，你可为本次议事增加一张上次“皦谈”结果的牌。议事结束后你可以观看一名异议角色的手牌并使用其议事牌，若其手牌中有与本次议事结果颜色不同的牌，你摸两张牌。",

  -- 炽夏侯涓 034
  ["chi__xiahoushi"] = "夏侯涓",
  ["#chi__xiahoushi"] = "炽夏侯涓",
  ["~chi__xiahoushi"] = "薪脉如火，毓髓成诗……",
  ["designer:chi__xiahoushi"] = "公冶天纵",
  ["illustrator:chi__xiahoushi"] = "佚名",
  ["cv:chi__xiahoushi"] = "暂无",
  ["chixinmai"] = "薪脉",
  [":chixinmai"] = "每轮限一次，出牌阶段或当你受到伤害后，你可以令一名角色获得本回合进入弃牌堆的所有【杀】，然后令其选择一项：①你对其造成一点雷属性伤害；②其所有非属性【杀】视为【无懈可击】直至其下回合结束或受到属性伤害，然后你重置“薪脉”。",
  ["chiyusui"] = "毓髓",
  [":chiyusui"] = "当有角色受到属性伤害后，你可以与其各摸一张牌；当有角色跳过任意阶段后，你可以弃置所有手牌令其于本回合结束后执行一个额外的被跳过的此阶段。",

  -- 炽夏侯徽 035
  ["chi__xiahouhui"] = "夏侯徽",
  ["#chi__xiahouhui"] = "炽夏侯徽",
  ["~chi__xiahouhui"] = "匪氏之心，斐谌成诗……",
  ["designer:chi__xiahouhui"] = "公冶天纵",
  ["illustrator:chi__xiahouhui"] = "佚名",
  ["cv:chi__xiahouhui"] = "暂无",
  ["chifeishi"] = "匪氏",
  [":chifeishi"] = "当你即将造成或受到伤害时，你可以令两名其他角色各展示一张红色牌，然后你选择其中一张获得之。",
  ["chifeichen"] = "斐谌",
  [":chifeichen"] = "每回合限一次，当你成为红色牌的目标后，你可以展示来源的所有手牌，若其手牌中没有与此牌类别相同的红色牌，你令此牌额外结算一次。",
}






-- <<< chi__xiahoumao auto generated end
return extension
