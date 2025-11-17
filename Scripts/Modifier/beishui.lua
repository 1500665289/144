--七杀克身诀·背水
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_beishui")
local MoreMagic = GameMain:GetMod("MoreMagic")


local UPDATE_TIME = 1 --更新时间，单位为秒。
local LING_RATE = 0.1 --每少1%灵气增加多少法宝根本威力。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  self.durations = self.durations or {}
  MoreMagic.modifier_beishui.prev_lings = MoreMagic.modifier_beishui.prev_lings or {}
  MoreMagic.modifier_beishui.kuangbaos = MoreMagic.modifier_beishui.kuangbaos or {}
  self.durations[npc.ID] = (self.durations[npc.ID] or 0) + dt
  if self.durations[npc.ID] >= UPDATE_TIME then
    self.durations[npc.ID] = 0
    local is_qisha = false
    if npc and npc.PropertyMgr.Practice and npc.PropertyMgr.Practice.Gong then 
      is_qisha = npc.PropertyMgr.Practice.Gong.Name == "Gong_3_Jin"
    end
    if is_qisha then
      local cur_ling = 1 - (npc.LingV / npc.MaxLing)
      local diff = cur_ling - (MoreMagic.modifier_beishui.prev_lings[npc.ID] or 0)
      local baddp = diff * LING_RATE
      npc.PropertyMgr:ModifierProperty("NpcFight_FabaoPowerAddP", 0, 0, 0, baddp)
      MoreMagic.modifier_beishui.prev_lings[npc.ID] = cur_ling
      --狂暴的管理。
      --如果灵气不足1%且未狂暴，则狂暴。
      if cur_ling >= 0.99 and not self.kuangbaos[npc.ID] then
        MoreMagic.modifier_beishui.kuangbaos[npc.ID] = true
        npc:AddModifier("Modifier_BeiShui_KuangBao")
      end
      --一旦灵气恢复过99%，且属于脱战状态，则解除狂暴flag，可以再次狂暴。
      if cur_ling < 0.01 and not npc.FightBody.IsFighting and MoreMagic.modifier_beishui.kuangbaos[npc.ID] then
        MoreMagic.modifier_beishui.kuangbaos[npc.ID] = false
      end
    end
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
  local baddp = (-MoreMagic.modifier_beishui.prev_lings[npc.ID] or 0) * LING_RATE
  npc.PropertyMgr:ModifierProperty("NpcFight_FabaoPowerAddP", 0, 0, 0, baddp)
end

--获取存档数据
function tbModifier:OnGetSaveData()

end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end
