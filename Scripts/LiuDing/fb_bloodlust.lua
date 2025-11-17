local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("LDModifier_FBBloodLust")
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
  local has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    CS.MoreEvents.EventManager.AddEvent("OnFabaoFB_BeHit", "LDModifier_FBBloodLust", self.CallBack)
  end
end

--反注册事件。
function tbModifier:Unregister()
  local has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    CS.MoreEvents.EventManager.RemoveEvent("OnFabaoFB_BeHit", "LDModifier_FBBloodLust")
  end
end

function tbModifier.CallBack(sender, e)
  local from = e.From
  local target = e.Target
  if from and from.FromItem and world:GetFlag(from.FromItem, MoreMagic.Events.FlagIDs["LDModifier_FBBloodLust"]) > 0 then --如果攻击方的法宝物品带有这个标签，则进入判定。
    print("Ling Steal!")
    if from.State == g_emFaBaoState.Atk then
      local power = from:GetAtkPower(2, nil, from) * 0.05 --主动攻击时吸取法宝伤害值5%的灵气
      from:AddLing(power)
    else
      local power = from:GetPower() * 0.01 --其他时候吸取法宝伤害值1%的灵气
      from:AddLing(power)
    end
  end
end