--真武洞神
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_zhenwudongshen")

local UPDATE_TIME = 1 --更新时间，单位为秒。
local MIND_RATE = 0.00025 --每点心境转化为多少点回灵百分比。

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
    local is_beidou = false
    if npc and npc.PropertyMgr.Practice and npc.PropertyMgr.Practice.Gong then 
      is_beidou = npc.PropertyMgr.Practice.Gong.Name == "Gong_8_Jin"
    end
    if is_beidou then
      local cur_mind = npc.Needs:GetNeedValue(CS.XiaWorld.g_emNeedType.MindState)
      npc:AddLing(npc.MaxLing * cur_mind * MIND_RATE) --每秒根据心境回复一定比例的灵气。
    end
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
	return {
    durations = self.durations,
  }
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
  self.durations = tbData.durations or {}
end