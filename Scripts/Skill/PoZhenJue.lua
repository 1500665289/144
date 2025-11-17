--破阵诀脚本
local tbTable = GameMain:GetMod("_SkillScript");
local tbSkill = tbTable:GetSkill("PoZhenJue_Skill");


--技能被释放
function tbSkill:Cast(skilldef, from)

end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
--将目标直接从阵眼位置打落。
function tbSkill:FightBodyApply(skilldef, fightbody, from)
  local is_yuqing = false;
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None";
  end
	if is_yuqing and fightbody and fightbody.Npc then
		local npc = fightbody.Npc;
    ZhenMgr:BrokenNpcNode(npc);
	end
end

--技能产生的子弹在pos点爆炸
function tbSkill:MissileBomb(skilldef, pos, from)	

end

--数值加值
function tbSkill:GetValueAddv(skilldef, fightbody, from)
	return 0;
end

--飞行检测
function tbSkill:FlyCheck(skilldef, keys, from)
	return 0;
end