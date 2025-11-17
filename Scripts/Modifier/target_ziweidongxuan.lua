--紫微洞玄敌人DEBUFF
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_target_ziweidongxuan")

local LING_PERCENT = 0.0005 --每点基础御器等级的削减灵气百分比。
local LING_PERCENT_ADD = 0.002 --每点突破御器等级削减的灵气百分比。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
--削减敌人最大灵气。
function tbModifier:Enter(modifier, npc)
  if npc and npc.MaxLing > 0 then
    print("紫微洞玄！")
    local yuqi = modifier.Scale --北斗的御器等级会被传递过来。
    local percent = self:GetPercent(yuqi)
    npc:AddLing(-npc.MaxLing * percent)
  end
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

--custom methods.
function tbModifier:GetPercent(yuqi)
  local base = math.min(20, yuqi) --基础御器等级最高到20级。
  local addi = math.max(yuqi - 20, 0) --突破等级是超出20的部分。
  return base * LING_PERCENT + addi * LING_PERCENT_ADD
end