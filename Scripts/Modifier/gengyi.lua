--庚乙合金
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_gengyi")
local MoreMagic = GameMain:GetMod("MoreMagic")


local UPDATE_TIME = 1 --更新时间，单位为秒。
local RATE = 0.0005 --每2000点寿命增加1级御器。


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  self.durations = self.durations or {}
  MoreMagic.modifier_gengyi.prev_lvls = MoreMagic.modifier_gengyi.prev_lvls or {}
  self.durations[npc.ID] = (self.durations[npc.ID] or 0) + dt
  if self.durations[npc.ID] >= UPDATE_TIME then
    self.durations[npc.ID] = 0
    local cur_life = npc.MaxAge - npc.Age
    local lvl = math.floor(cur_life * RATE)
    local diff = lvl - (MoreMagic.modifier_gengyi.prev_lvls[npc.ID] or 0)
    npc.PropertyMgr.SkillData:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Fabao, diff)
    MoreMagic.modifier_gengyi.prev_lvls[npc.ID] = lvl
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
  local lvl = (-MoreMagic.modifier_gengyi.prev_lvls[npc.ID] or 0)
  npc.PropertyMgr.SkillData:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Fabao, lvl)
end

--获取存档数据
function tbModifier:OnGetSaveData()

end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end