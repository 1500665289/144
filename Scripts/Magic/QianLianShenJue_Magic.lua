--千炼神诀
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local qlMagic = tbTable:GetMagic("QianLianShenJue_Magic")--创建一个新的神通class
local MoreMagic = GameMain:GetMod("MoreMagic")


local g_emFaBaoP = CS.XiaWorld.Fight.g_emFaBaoP

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function qlMagic:Init()
end

--神通是否可用
function qlMagic:EnableCheck(npc)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
--只能对幽淬次数小于10次的法宝使用。
function qlMagic:TargetCheck(key, t)	
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Item then
		return false
	end
	if t.IsFaBao and t.YouPower < MoreMagic.qianlian then
		return true
	end
	return false
end

--开始施展神通。
function qlMagic:MagicEnter(IDs, IsThing)
	self.targetID = IDs[0]--获取目标信息
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:Lock(self.bind)
  end
  local qianlian = GameMain:GetMod("Windows"):GetWindow("QianLianWindow")
  qianlian:SetUpData(self)
  qianlian:Show()
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--不再有成功率判定。
function qlMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_2_Mu" then
      return -1
    end
  end
  if not self.results then --等待窗口处的选择。
    self:SetProgress(0)
    return 0
  end
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >= self.magic.Param1  then
    if self.targetID and self.results and self.total then
      return 1
    else
      return -1
    end
	end
	return 0
end

--施展完成/失败 success是否成功
function qlMagic:MagicLeave(success)
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:UnLock(self.bind)
    -- 成功的事件。
    if success then
      local fabao_data = target.Fabao
      if fabao_data and self.results and self.total then --如果所有数据都正常。
        for n,result in pairs(self.results) do
          fabao_data:SetProperty(g_emFaBaoP.__CastFrom(n), result)
        end
        --删除使用掉的灵晶。
        local items = Map.Things:FindItems(nil, 9999, self.total * 50, "Item_LingCrystal", 0, nil, 0, 9999, nil, true, true)
        for _,item in pairs(items) do
          local diff = math.min(self.total*50, item.FreeCount)
          item:SubCount(diff)
        end
      end
      CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
      target.YouPower = target.YouPower + self.total
    else
      -- 失败的事件。
      world:AddMsg("施展神通千炼神诀失败！")
    end
    -- 无论成功与否都发生的事件。
  end
end

--存档 如果没有返回空 有就返回Table(KV)
function qlMagic:OnGetSaveData()
	return {
    selected = self.selected,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function qlMagic:OnLoadData(tbData,IDs, IsThing)	
  tbData = tbData or {}
  self.targetID = IDs[0]--获取目标信息
  self.selected = tbData.selected
end

--custom methods.
--使用窗口需要的回调函数，储存有用的值。
function qlMagic:StoreValue(results, total)
  self.results = results
  self.total = total
end
