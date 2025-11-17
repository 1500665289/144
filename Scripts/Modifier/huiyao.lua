--瀚海灵光·辉耀
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_hanhailingguang_huiyao")

local BASE_DAMAGE = 200 --辉耀反伤的基础值，暂时定为200。

--注意：自定义modidifer要注意离开的时候将自定义效果移除
--进入modifier
function tbModifier:Enter(modifier, npc)
  self.scales = self.scales or {}
  self.scales[npc.ID] = modifier.Scale
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
	return {
  scales = self.scales,
  }
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)
  tbData = tbData or {}
  self.scales = tbData.scales or {}
end

--非拓展模块方法：固定反弹基础伤害*太和法伤的伤害。
--拓展模块方法：反弹所受伤害的1%*太和法伤。
function tbModifier:Register()
  local f_better = function (sender, e)
    local from = e.From
    local target = e.Target
    local damage = e.Return
    local mod = nil
    if target and target.PropertyMgr then
      mod = target.PropertyMgr:FindModifier("modifier_hanhailingguang_huiyao")
    end
    local scale = 1
    if mod then
      scale = mod.helper:GetTable().scales[target.ID] or 1
    end
    if from and target and mod and from.ThingType == CS.XiaWorld.g_emThingType.Npc and from.MaxLing > 0 then
      from:ReduceDamage(damage * scale * 0.01)
    end
    return damage
  end
  local f_normal = function (data, thing, objs)
    local from = objs[2]
    local mod = nil
    if thing and thing.PropertyMgr then
      mod = thing.PropertyMgr:FindModifier("modifier_hanhailingguang_huiyao")
    end
    if from and thing and mod and from.ThingType == CS.XiaWorld.g_emThingType.Npc and from.MaxLing > 0 then
      from:AddLing(-BASE_DAMAGE * scale)
    end
  end
  has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    print("register better huiyao!")
    CS.MoreEvents.EventManager.AddEvent("OnReduceDamage", "hanhailingguang_huiyao", f_better)
    CS.MoreEvents.EventManager.AddEvent("OnReduceLingDamage", "hanhailingguang_huiyao", f_better)
  else
    print("register normal huiyao!")
    GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.WillFightBodyBeHit, f_normal, "hanhailingguang_huiyao")
  end
  return true
end

function tbModifier:Unregister()
  has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    print("unregister better huiyao!")
    CS.MoreEvents.EventManager.RemoveEvent("OnReduceDamage", "hanhailingguang_huiyao")
    CS.MoreEvents.EventManager.RemoveEvent("OnReduceLingDamage", "hanhailingguang_huiyao")
  end
end