--幻蛊迷心脚本
local tbTable = GameMain:GetMod("_SkillScript")
local tbSkill = tbTable:GetSkill("HuanGuMiXin_Skill")


local POWER_ADD = 5 --玉石俱焚伤害的法宝威力倍数。

--技能被释放
function tbSkill:Cast(skilldef, from)
  
end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
function tbSkill:FightBodyApply(skilldef, fightbody, from)
	local is_taishang = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_taishang = from.PropertyMgr.Practice.Gong.Name == "Gong_7_Huo"
  end
  if is_taishang and fightbody and fightbody.Npc then
    fightbody.Npc:AddModifier("Modifier_Target_HuanGuMiXin")
  end
end

--技能产生的子弹在pos点爆炸
function tbSkill:MissileBomb(skilldef, pos, from)	

end

--数值加值
function tbSkill:GetValueAddv(skilldef, fightbody, from)
  return 0
end

--飞行检测
function tbSkill:FlyCheck(skilldef, keys, from)
	return 0
end