--丙辛合水
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_bingxin")


local UPDATE_TIME = 1 --更新时间，单位为秒。
local RATE = 0.001 --每级斗法或者御器增加多少回灵百分比。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  self.durations = self.durations or {}
  self.durations[npc.ID] = (self.durations[npc.ID] or 0) + dt
  if self.durations[npc.ID] >= UPDATE_TIME then
    self.durations[npc.ID] = 0
    local fashu = npc.LuaHelper:GetSkillLevel("FightSkill")
    local yuqi = npc.LuaHelper:GetSkillLevel("Fabao")
    npc:AddLing(npc.MaxLing * (fashu + yuqi) * RATE)
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
  
end

--获取存档数据
function tbModifier:OnGetSaveData()

end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
end
