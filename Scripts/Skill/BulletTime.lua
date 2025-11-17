--止水脚本
local tbTable = GameMain:GetMod("_SkillScript")
local tbSkill = tbTable:GetSkill("BulletTime_Skill")


local BASE_TIME = 15 --法宝冻结时间。

--技能被释放
function tbSkill:Cast(skilldef, from)
  local is_kuihua = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_kuihua = from.PropertyMgr.Practice.Gong.Name == "Gong_11_Tu"
  end
  local is_yuqing = false
  if from and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_yuqing = from.PropertyMgr.Practice.Gong.Name == "Gong_4_None"
  end
  local fabaoIDs = FightMgr.FabaoMgr:GetFabaosByCamp(g_emFightCamp.Enemy)
  if (is_kuihua or is_yuqing) and fabaoIDs then
    local power = BASE_TIME
    if is_yuqing then power = power * 0.5 end
    for _,id in pairs(fabaoIDs) do
      local fabao = FightMgr.FabaoMgr:GetFaBao(id)
      if fabao then
        fabao:Freezen(power)
      end
    end
  end
end

--技能在key点生效
function tbSkill:Apply(skilldef, key, from)
	--print(1)
	
end

--技能在fightbody身上生效
--将目标直接从阵眼位置打落。
function tbSkill:FightBodyApply(skilldef, fightbody, from)
  
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