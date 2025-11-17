--幻蛊迷心
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_huangumixin")


local RADIUS = 10 --定义寻找敌人的范围。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  --寻找附近的目标，并且将他们的ID存为序列。
  self.targetIDs = self.targetIDs or {}
  self.targetIDs[npc.ID] = self.targetIDs[npc.ID] or {}
  self.indices = self.indices or {}
  self.indices[npc.ID] = self.indices[npc.ID] or 1
  GridMgr:DoAroundKeyLua(npc.Key, RADIUS,
  function (i, grid)
    local npcs = Map.Things:GetNpcByKey(grid)
    if npcs then
      for _, n in pairs(npcs) do
        if n.Camp == g_emFightCamp.Enemy and n.ID ~= npc.ID then
          print(n.ID)
          table.insert(self.targetIDs[npc.ID], n.ID)
        end
      end
    end
    return true
  end
  )
end

--modifier step
function tbModifier:Step(modifier, npc, dt)
  if #self.targetIDs[npc.ID] ~= 0 then
    npc:SetCamp(g_emFightCamp.Friend)
    if self.indices[npc.ID] <= #self.targetIDs[npc.ID] then
      local cur_npc = ThingMgr:FindThingByID(self.targetIDs[npc.ID][self.indices[npc.ID]])
      if cur_npc and cur_npc.FightBody.TargetID == npc.ID then -- 如果成功让对方的目标变成自己，则换下一个目标。
        self.indices[npc.ID] = self.indices[npc.ID] + 1
      elseif cur_npc then --如果对方还没和自己战斗，则进入战斗。
        npc:FightWith(cur_npc)
        cur_npc:FightWith(npc)
      end
    end
  else --如果周围没有合适的目标，则保持脱战状态。
    npc.FightBody:FightEnd()
  end
end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
function tbModifier:Leave(modifier, npc)
  --离开时我们让所有的目标都结束战斗。
  for _,id in pairs(self.targetIDs) do
    local n = ThingMgr:FindThingByID(id)
    if n then
      n.FightBody:FightEnd()
    end
  end
  npc.FightBody:FightEnd()
  if npc.Camp == g_emFightCamp.Friend then
    npc:SetCamp(g_emFightCamp.Enemy)
  end
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return {
    targetIDs = self.targetIDs,
    indices = self.indices,
  }
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
  self.targetIDs = tbData.targetIDs or {}
  self.indices = self.indices or {}
end
