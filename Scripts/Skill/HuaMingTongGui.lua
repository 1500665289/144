--化命同归脚本
local tbTable = GameMain:GetMod("_SkillScript")
local tbSkill = tbTable:GetSkill("HuaMingTongGui_Skill")

--技能被释放
function tbSkill:Cast(skilldef, from)
  local is_changsheng = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_changsheng = from.PropertyMgr.Practice.Gong.Name == "Gong_9_Mu"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
  if from and (is_changsheng or is_yuqing) then
    local age = from.PropertyMgr.Age
    local max_age = from.PropertyMgr:GetProperty("MaxAge", false, false)
    self.life = math.max((max_age - age) * 0.5, 0) --消耗寿命的50%。
    from.PropertyMgr:AddMaxAge(-self.life)
  end
end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
function tbSkill:FightBodyApply(skilldef, fightbody, from)
  local is_changsheng = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_changsheng = from.PropertyMgr.Practice.Gong.Name == "Gong_9_Mu"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
	if (is_changsheng or is_yuqing) and fightbody and fightbody.Npc and fightbody.Npc.PropertyMgr then
    local life = self.life or 0
    fightbody.Npc:AddLing(-life*50) --现改为造成50倍失去寿命的伤害。
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