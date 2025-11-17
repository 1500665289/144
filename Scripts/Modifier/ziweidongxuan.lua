--紫微洞玄
local tbTable = GameMain:GetMod("_ModifierScript")
local tbModifier = tbTable:GetModifier("modifier_ziweidongxuan")

--注意：自定义modidifer要注意离开的时候将自定义效果移除
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
	return nil
end

--载入存档数据
function tbModifier:OnLoadData(modifier, npc, tbData)

end

function tbModifier:Register()
  local f_better = function (sender, e)
    local from = e.From
    local target = e.Target
    tbModifier.CallBack(from, target)
    return e.Return
  end
  local f_normal = function (data, thing, objs)
    local from = objs[2]
    local target = thing
    tbModifier.CallBack(from, target)
  end
  has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    print("register better ziweidongxuan!")
    CS.MoreEvents.EventManager.AddEvent("OnReduceDamage", "ziweidongxuan", f_better)
  else
    print("register normal ziweidongxuan!")
    GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.WillFightBodyBeHit, f_normal, "ziweidongxuan")
  end
  return true
end

function tbModifier:Unregister()
  has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    print("unregister better ziweidongxuan!")
    CS.MoreEvents.EventManager.RemoveEvent("OnReduceDamage", "ziweidongxuan")
  end
end

--根据御器等级造成最大灵气一定比例的伤害。具体伤害数值请看紫微洞玄敌方DEBUFF。
function tbModifier.CallBack(from, target)
  local is_beidou = false
  local has_ziwei = false
  if from and from.PropertyMgr and from.PropertyMgr.Practice and from.PropertyMgr.Practice.Gong then 
    is_beidou = from.PropertyMgr.Practice.Gong.Name == "Gong_8_Jin"
    has_ziwei = from.PropertyMgr:FindModifier("modifier_ziweidongxuan") ~= nil
  end
  
  if from and is_beidou and has_ziwei and target and target.ThingType == CS.XiaWorld.g_emThingType.Npc and target.MaxLing > 0 then
    local mind = from.Needs:GetNeedValue(CS.XiaWorld.g_emNeedType.MindState)
    local yuqi = from.LuaHelper:GetSkillLevel("Fabao")
    local rate = mind / 50 * 0.025
    if CS.XiaWorld.World.RandomRate(rate) then
      target:AddModifier("Modifier_Target_ZiWeiDongXuan", yuqi)
    end
  end
end