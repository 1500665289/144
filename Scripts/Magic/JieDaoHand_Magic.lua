--截道天通手
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local jdMagic = tbTable:GetMagic("JieDaoHand_Magic")--创建一个新的神通class

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function jdMagic:Init()
end

--神通是否可用
function jdMagic:EnableCheck(npc)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function jdMagic:TargetCheck(key, t)	
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Npc then
		return false
	end
	if t.Race.RaceType == CS.XiaWorld.g_emNpcRaceType.Animal and t.IsEliteEnemy and t.IsLingering and t.LuaHelper:GetGRank() >= 3 then
		return true
	end
  --if t.IsDisciple then
  --  return true
  --end
	return false
end

--开始施展神通
function jdMagic:MagicEnter(IDs, IsThing)
	self.targetId = IDs[0]--获取目标信息
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:Lock(self.bind)
  end
end

--神通施展过程中，需要返回值
-- 成功率跟
--返回值  0继续 1成功并结束 -1失败并结束
function jdMagic:MagicStep(dt, duration)
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >= self.magic.Param1  then
    local mind_state = self.bind.Needs:GetNeedValue(CS.XiaWorld.g_emNeedType.MindState)
    local gold_level = 0
    local practice = self.bind.PropertyMgr.Practice
    if practice then
      gold_level = 10 - practice.GoldLevel
    end
    local rate = mind_state / 1000 + gold_level / 10
    if CS.XiaWorld.World.RandomRate(rate) then
      return 1
    else
      return -1
    end
	end
	return 0
end

--施展完成/失败 success是否成功
function jdMagic:MagicLeave(success)
  local target = ThingMgr:FindThingByID(self.targetId)
  if target then
    target.Lock:UnLock(self.bind)
  end
  if target then
    -- 成功的事件。
    if success then
      local drop_dan = ItemRandomMachine.RandomItem("Item_SoulPearl", nil, 0, 12, -1.0, 1)
      if drop_dan ~= nil then
      -- 掉落与目标最大灵气值匹配的玄牝珠
        drop_dan:AddLing(target.MaxLing)
        Map:DropItem(drop_dan, self.bind.Key, true, true, true, true, 0, false)
      end
    -- 失败的事件。
    else
      world:AddMsg("施展神通截道天通手失败！")
    end
    -- 无论成功与否都发生的事件。
    -- 立即消除目标。
    ThingMgr:RemoveThing(target, false, false)
  end
end

--存档 如果没有返回空 有就返回Table(KV)
function jdMagic:OnGetSaveData()
	
end

--读档 tbData是存档数据 IDs和IsThing同进入
function jdMagic:OnLoadData(tbData,IDs, IsThing)	
	self.targetId = IDs[0]--获取目标信息
end
