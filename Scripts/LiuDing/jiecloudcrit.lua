local tbTable = GameMain:GetMod("_ModifierScript")
local MoreMagic = GameMain:GetMod("MoreMagic")
local tbModifier = tbTable:GetModifier("LDModifier_JieCloudCrit")


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
    CS.MoreEvents.EventManager.AddEvent("OnFabaoFB_BeHit", "LDModifier_JieCloudCrit", self.CallBack)
  end
end

--反注册事件。
function tbModifier:Unregister()
  local has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    CS.MoreEvents.EventManager.RemoveEvent("OnFabaoFB_BeHit", "LDModifier_JieCloudCrit")
  end
end

function tbModifier.CallBack(sender, e)
  local from = e.From
  local target = e.Target
  if target.IsJieCloud and from and from.FromItem and world:GetFlag(from.FromItem, MoreMagic.Events.FlagIDs["LDModifier_JieCloudCrit"]) > 0 then --目标是劫云，并且攻击方是带有flag的法宝。
    if CS.XiaWorld.World.RandomRate(0.1) then
      target:AddLing(-target.Ling * 0.5)
    end
  end
end