--化物同命大法
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local hwMagic = tbTable:GetMagic("HuaWuTongMing_Magic")--创建一个新的神通class
local MoreMagic = GameMain:GetMod("MoreMagic")

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function hwMagic:Init()
end

--神通是否可用
function hwMagic:EnableCheck(item)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function hwMagic:TargetCheck(key, t)	
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Item then
		return false
	end
	if t.Rate == 12 then
		return true
	end
	return false
end

--开始施展神通
function hwMagic:MagicEnter(IDs, IsThing)
	self.targetID = IDs[0]--获取目标信息
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:Lock(self.bind)
  end
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--根据MoreMagic那边的设定来判定是否需要做成功判定。如果需要，则成功率跟幽淬次数有关。
function hwMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_9_Mu" and self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_4_None" then
      return -1
    end
  end
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >=self.magic.Param1 then
    local rate = 0
    if self.targetID then
      local target = ThingMgr:FindThingByID(self.targetID)
      rate = 12 / CS.System.Math.Pow(target.YouPower + 1, 0.8) --反比例函数，幽淬次数越高几率越低。
    end
		if self.targetID and (MoreMagic.huawu or CS.XiaWorld.World.RandomRate(rate)) then
      return 1
    else
      return -1
    end
	end
	return 0
end

--施展完成/失败 success是否成功
function hwMagic:MagicLeave(success)
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:UnLock(self.bind)
  end
	if success == true then
    -- 成功的事件。
    if target then
      self.bind:AddMaxAge((target.Rate - 1) * 10 * target.Count)
      target.Rate = 1
    end
    CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
  else
    -- 失败的事件。
    world:AddMsg("施展神通化物同命大法失败！")
    if target then
      target.YouPower = 0
    end
	end
end

--存档 如果没有返回空 有就返回Table(KV)
function hwMagic:OnGetSaveData()

end

--读档 tbData是存档数据 IDs和IsThing同进入
function hwMagic:OnLoadData(tbData, IDs, IsThing)	
	self.targetID = IDs[0]--获取目标信息
end