-- 亚索共享能量系统（类似蓄力值的数值标记，上限 5）
-- 风循/覆梦共用同一能量池；"能量"只是标记物，不涉及变身。
-- 以全局表暴露，供两个技能文件共用。
--
-- 【显示方案】mark 存储值 = 真实能量 + 1（偏移1）。
-- 这样开局 0 能量时 mark=1（非0），GetQmlMark 不会因 value==0 而隐藏，
-- 能量条从游戏开始就常驻在武将牌下方（5 个空格子 ◇◇◇◇◇）。
TianzongEnergy = TianzongEnergy or {}

local ENERGY_MARK = "@[tianzong_geshi__energy]"
local MAX_ENERGY = 5
local OFFSET = 1

-- 返回真实能量（0-5）
function TianzongEnergy.get(player)
  local v = player:getMark(ENERGY_MARK)
  if type(v) ~= "number" or v <= 0 then return 0 end
  return math.max(0, math.min(MAX_ENERGY, v - OFFSET))
end

-- 获得能量，不超过上限；返回实际增加量
function TianzongEnergy.gain(room, player, n)
  n = n or 1
  local cur = TianzongEnergy.get(player)
  local add = math.min(n, math.max(0, MAX_ENERGY - cur))
  if add > 0 then
    room:addPlayerMark(player, ENERGY_MARK, add)
  elseif player:getMark(ENERGY_MARK) <= 0 then
    -- 尚未初始化时也要建立常驻显示（0 能量 → mark=1）
    room:setPlayerMark(player, ENERGY_MARK, OFFSET)
  end
  return add
end

-- 消耗 num 点能量；返回是否成功（能量足够）。num=nil 表示全部
function TianzongEnergy.cost(room, player, num)
  local cur = TianzongEnergy.get(player)
  if num == nil then num = cur end
  if num <= 0 or cur < num then return false end
  room:removePlayerMark(player, ENERGY_MARK, num)
  return true
end

function TianzongEnergy.max()
  return MAX_ENERGY
end

function TianzongEnergy.avail(player)
  return math.min(TianzongEnergy.get(player), MAX_ENERGY)
end

-- 开局初始化：游戏开始时给拥有风循/覆梦的角色建立常驻能量条（0 能量 → 5 空格）
function TianzongEnergy.init(room, player)
  if player:getMark(ENERGY_MARK) <= 0 then
    room:setPlayerMark(player, ENERGY_MARK, OFFSET)
  end
end

-- 武将牌下方显示：5 格能量条（点亮橙色实心◆，熄灭灰色空心◇）
Fk:addQmlMark{
  name = "tianzong_geshi__energy",
  how_to_show = function(_, value)
    local real = (tonumber(value) or OFFSET) - OFFSET
    local s = {}
    for i = 1, MAX_ENERGY do
      if i <= real then
        table.insert(s, "<font color='#FFB733'>◆</font>")
      else
        table.insert(s, "<font color='#666666'>◇</font>")
      end
    end
    return table.concat(s, "")
  end,
}
