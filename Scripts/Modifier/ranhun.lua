--离火破魔诀·燃魂
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_ranhun")


--注意：自定义modidifer要注意离开的时候将自定义效果移除
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
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  
end

