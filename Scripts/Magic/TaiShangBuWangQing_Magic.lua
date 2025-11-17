--太上不忘情
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local hyMagic = tbTable:GetMagic("TaiShangBuWangQing_Magic")--创建一个新的神通class

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function hyMagic:Init() 
end

--神通是否可用
function hyMagic:EnableCheck(npc)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function hyMagic:TargetCheck(key, t)	
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Npc then
		return false
	end
	if t.Race.Name == "Human" then
		return true
	end
	return false
end

--开始施展神通
function hyMagic:MagicEnter(IDs, IsThing)
	self.targetID = IDs[0]--获取目标信息
  self:SelectPeiOu()
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
function hyMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_7_Huo" then
      return -1
    end
  end
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >= self.magic.Param1 and self.targetID and self.targetID2 then
    return 1
  elseif duration >= self.magic.Param1 and not self.targetID2 then
    return -1
  else
    return 0
	end
end

--施展完成/失败 success是否成功
function hyMagic:MagicLeave(success)
  -- 成功的事件。
  local target = ThingMgr:FindThingByID(self.targetID)
  local target2 = ThingMgr:FindThingByID(self.targetID2)
  if success and target and target2 then
    target.PropertyMgr.RelationData:AddRelationShip(target2, "Spouse")
  -- 失败的事件。
  else
    world:AddMsg("施展神通太上不忘情失败！")
  end
  -- 无论成功与否都发生的事件。
end

--存档 如果没有返回空 有就返回Table(KV)
function hyMagic:OnGetSaveData()
	return {
    targetID2 = self.targetID2,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function hyMagic:OnLoadData(tbData,IDs, IsThing)	
  tbData = tbData or {}
	self.targetID = IDs[0]--获取目标信息
  self.targetID2 = tbData.targetID2
end

function hyMagic:SelectPeiOu()
	local tbInfo = {
		KC = "Npc",
		Line = {StartObj = self.target},
    Magic = self,
		HeadMsg = "请选择配偶的另一方",
		Apply = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Npc, k, map)
        if tbMode.tbInfo.Magic then
          tbMode.tbInfo.Magic.targetID2 = t.ID
        end
			end,
		Check = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Npc, k, map)
				return t.Race.Name == "Human"
			end,
	}

	world:EnterUILuaMode("TableCtrl", tbInfo)
end
