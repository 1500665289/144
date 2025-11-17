--掌心天玄雷脚本
local tbTable = GameMain:GetMod("_SkillScript")
local tbSkill = tbTable:GetSkill("ZhangXinTianXuanLei_Skill")

local AGE_COST = -60

--技能被释放
function tbSkill:Cast(skilldef, from)

end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
function tbSkill:FightBodyApply(skilldef, fightbody, from)
  local is_beidou = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_beidou = from.PropertyMgr.Practice.Gong.Name == "Gong_8_Jin"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
	local my_penalty = from.PropertyMgr.Practice:GetPenalty()
	if (is_beidou or is_yuqing) and my_penalty == 0 then
		if fightbody and fightbody.Npc and fightbody.Npc.MaxLing > 0 then --只做用于有灵气的目标。
      --寿元不够不会触发。防止暴死。
      if from.MaxAge - from.Age > 0 then
        local npc = fightbody.Npc
        --打断工作。
        npc.JobEngine:InterruptJob("掌心天玄雷", false)
        --添加闭锁秘术的DEBUFF。
        npc:AddModifier("Modifier_Target_ZhangXinTianXuanLei")
        --降低自己寿元。
        from:AddMaxAge(AGE_COST)
      end
		end
	end
end

--技能产生的子弹在pos点爆炸
function tbSkill:MissileBomb(skilldef, pos, from)	

end

--数值加值
function tbSkill:GetValueAddv(skilldef, fightbody, from)

end

--飞行检测
function tbSkill:FlyCheck(skilldef, keys, from)
	return 0
end