--离火破魔诀脚本
local tbTable = GameMain:GetMod("_SkillScript")
local tbSkill = tbTable:GetSkill("LiHuoPoMo_Skill")


local BASE_VALUE = 400 --离火的基础伤害值。

--技能被释放
function tbSkill:Cast(skilldef, from)

end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
--根据是否习得升华技能来决定是否添加DEBUFF。
function tbSkill:FightBodyApply(skilldef, fightbody, from)
  local is_sanyang = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_sanyang = from.PropertyMgr.Practice.Gong.Name == "Gong_10_Huo"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
	if (is_sanyang or is_yuqing) and fightbody and fightbody.Npc then
    if from.PropertyMgr.Practice:CheckIsLearnedEsoteric("Skill_LiHuoPoMo_1") then --燃魂，玉清也能叠
      fightbody.Npc:AddModifier("Modifier_Target_LiHuoPoMo_RanHun")
    end
    if is_sanyang and from.PropertyMgr.Practice:CheckIsLearnedEsoteric("Skill_LiHuoPoMo_2") then--焚心
      fightbody.Npc:AddModifier("Modifier_Target_LiHuoPoMo_FenXin")
    end
	end
end

--技能产生的子弹在pos点爆炸
function tbSkill:MissileBomb(skilldef, pos, from)

end

--数值加值
function tbSkill:GetValueAddv(skilldef, fightbody, from)
  local is_sanyang = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_sanyang = from.PropertyMgr.Practice.Gong.Name == "Gong_10_Huo"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
  local layers = 1
  if (is_sanyang or is_yuqing) and fightbody and fightbody.Npc and fightbody.Npc.PropertyMgr then
    local mod = fightbody.Npc.PropertyMgr:FindModifier("Modifier_Target_LiHuoPoMo_RanHun")
    if mod then
      layers = layers + mod.Stack
    end
    local zhen = ZhenMgr:GetZhen(fightbody.Npc)
    if zhen then
     layers = zhen.npcInZhen.Count * 2^layers
    end
    local power = BASE_VALUE * layers
    if is_yuqing then power = power * 0.5 end
    return power
  else
    return 0
  end
end

--飞行检测
function tbSkill:FlyCheck(skilldef, keys, from)
	return 0
end