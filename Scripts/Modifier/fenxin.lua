--离火破魔诀·焚心
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_fenxin")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
--破盾。
function tbModifier:Enter(modifier, npc)
  --print(string.format("entering fenxin, the applied npc is: %s, has ling: %f", npc.Name, npc.LingV))
  self.properties = self.properties or {}
  if npc then
    --我们这里要将护盾强度加值、护盾强度加成和五个属性的减免全部归零。为了之后能够恢复，我们需要储存它们。护盾值现在只降低70%而不是全部，没有下限，所以护盾越低越可怕。
    self.properties[npc.ID] = {
      NpcFight_ShieldConversionRate = npc:GetProperty("NpcFight_ShieldConversionRate") * 0.7,
      NpcFight_ShieldConversionEquipAdd = npc:GetProperty("NpcFight_ShieldConversionEquipAdd"),
      NpcFight_ShieldConversionRateAddP = npc:GetProperty("NpcFight_ShieldConversionRateAddP"),
      NpcFight_ShieldResistanceToJin = npc:GetProperty("NpcFight_ShieldResistanceToJin"),
      NpcFight_ShieldResistanceToMu = npc:GetProperty("NpcFight_ShieldResistanceToMu"),
      NpcFight_ShieldResistanceToShui = npc:GetProperty("NpcFight_ShieldResistanceToShui"),
      NpcFight_ShieldResistanceToHuo = npc:GetProperty("NpcFight_ShieldResistanceToHuo"),
      NpcFight_ShieldResistanceToTu = npc:GetProperty("NpcFight_ShieldResistanceToTu"),
    }
    for k,v in pairs(self.properties[npc.ID]) do
      --print(string.format("%s has a value of : %f", k, v))
      --print(string.format("npc has ling value of: %f", npc.LingV))
      if v > 0 then --只把大于零的归零。
        npc.PropertyMgr:ModifierProperty(k, -v, 0)
      end
    end
  end
end

--modifier step
function tbModifier:Step(modifier, npc, dt)

end

--层数更新
function tbModifier:UpdateStack(modifier, npc, add)
	
end

--离开modifier
--恢复护盾值。
function tbModifier:Leave(modifier, npc)
  if npc and self.properties[npc.ID] then
    for k,v in pairs(self.properties[npc.ID]) do
      if v > 0 then --只恢复大于零的。
        npc.PropertyMgr:ModifierProperty(k, v, 0)
      end
    end
  end
end

--获取存档数据
function tbModifier:OnGetSaveData()
	return {
    properties = self.properties,
  }
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData  = tbData or {}
  self.properties = tbData.properties or {}
end

