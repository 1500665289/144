--戊癸合火
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_wugui")
local MoreMagic = GameMain:GetMod("MoreMagic")


local UPDATE_TIME = 1 --更新时间，单位为秒。
local LING_RATE = 0.0000002 -- 500W灵气增加1级。
local HUDUN_RATE = 0.2 --5级护盾增加1级术法。


--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  self.durations = self.durations or {}
  MoreMagic.modifier_wugui.prev_calcs = MoreMagic.modifier_wugui.prev_calcs or {}
  self.durations[npc.ID] = (self.durations[npc.ID] or 0) + dt
  if self.durations[npc.ID] >= UPDATE_TIME then
    self.durations[npc.ID] = 0
    local hudun = npc.LuaHelper:GetSkillLevel("Barrier")
    local cur_calc = math.floor(hudun * HUDUN_RATE + npc.MaxLing * LING_RATE)
    local diff = cur_calc - (MoreMagic.modifier_wugui.prev_calcs[npc.ID] or 0)
    npc.PropertyMgr.SkillData:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.FightSkill, diff)
    MoreMagic.modifier_wugui.prev_calcs[npc.ID] = cur_calc
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
  local lvl = -MoreMagic.modifier_wugui.prev_calcs[npc.ID] or 0
  npc.PropertyMgr.SkillData:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.FightSkill, lvl)
end

--获取存档数据
function tbModifier:OnGetSaveData()

end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end
