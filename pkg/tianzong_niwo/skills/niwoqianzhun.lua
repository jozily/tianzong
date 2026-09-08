local s = fk.CreateSkill { name = "niwoqianzhun" }
local DM, TM = "niwoqianzhun_desc-turn", "niwoqianzhun_tag-turn"
local function names(target, mode, pattern)
  local out, x = {}, 1
  if mode == 2 then for _,k in ipairs(target:getSkillNameList()) do local a=Fk.skills[k];local b=a and a:getSkeleton();if b then x=x+#(b.tags or {}) end end end
  for _,n in ipairs(Fk:getAllCardNames("bt")) do
    local c=Fk:cloneCard(n)
    if (c.type==Card.TypeBasic or c:isCommonTrick()) and (not pattern or Exppattern:Parse(pattern):match(c)) then
      if mode==2 and c:getNameLength()<=x then table.insert(out,n) end
      if mode==1 then local tr=Fk:translate(n);if table.find(target:getSkillNameList(),function(k)return string.find(Fk:translate(":"..k),"【"..tr.."】",1,true)end) then table.insert(out,n) end end
    end
  end
  return out
end
local function spec(event)
  return {
    can_trigger=function(self,e,target,player,data)
      return target==player and player:hasSkill(s.name) and (player:getMark(DM)==0 or player:getMark(TM)==0)
    end,
    on_cost=function(self,e,target,player,data)
      local room=player.room
      local candidates=table.filter(room.alive_players,function(p)return (player:getMark(DM)==0 and #names(p,1,data.pattern)>0) or (player:getMark(TM)==0 and #names(p,2,data.pattern)>0) end)
      if #candidates==0 then return false end
      local who=room:askToChoosePlayers(player,{targets=candidates,min_num=1,max_num=1,skill_name=s.name,prompt="#niwoqianzhun-reference",cancelable=true})[1]
      if not who then return false end
      local opts={};if player:getMark(DM)==0 and #names(who,1,data.pattern)>0 then table.insert(opts,"niwoqianzhun_opt1") end;if player:getMark(TM)==0 and #names(who,2,data.pattern)>0 then table.insert(opts,"niwoqianzhun_opt2") end
      local opt=#opts==1 and opts[1] or room:askToChoice(player,{choices=opts,skill_name=s.name,prompt="#niwoqianzhun-choice"})
      local list=names(who,opt=="niwoqianzhun_opt1" and 1 or 2,data.pattern)
      local n=#list==1 and list[1] or room:askToChoice(player,{choices=list,skill_name=s.name,prompt="#niwoqianzhun-card"})
      local card=Fk:cloneCard(n);card.skillName=s.name;data.result={from=player,card=card};if event==fk.AskForCardUse then data.result.tos={} end
      room:setPlayerMark(player,opt=="niwoqianzhun_opt1" and DM or TM,1)
      return true
    end,
  }
end
s:addEffect(fk.AskForCardUse,spec(fk.AskForCardUse))
s:addEffect(fk.AskForCardResponse,spec(fk.AskForCardResponse))
return s
