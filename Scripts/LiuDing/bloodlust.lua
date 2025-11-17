local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("LDModifier_BloodLust")
local MoreMagic = GameMain:GetMod("MoreMagic")


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--------同名Modifier会共享luatable，所以不要在luatable里记录个体数据
--进入modifier
function tbModifier:Enter(modifier, npc)

end

--modifier step
function tbModifier:Step(modifier, npc, dt)

end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
	
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return nil;
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

--注册事件。
function tbModifier:Register()
  GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.WillFightBodyBeHit, self.CallBack, "LDModifier_BloodLust")
end

--反注册事件。
function tbModifier:Unregister()

end

function tbModifier.CallBack(data, thing, objs)
  local from = objs[2]
  local target = thing
  local modifier = nil
  if from then modifier = from.PropertyMgr:FindModifier(data) end
  if modifier then
    local target_ling = target.LingV * 0.01
    target:AddLing(-target_ling)
    from:AddLing(target_ling)
  end
end