--己土归元经
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local hwMagic = tbTable:GetMagic("JiTuGuiYuan_Magic")--创建一个新的神通class

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function hwMagic:Init()
  self.durations = self.durations or {}
end

--神通是否可用
function hwMagic:EnableCheck(item)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function hwMagic:TargetCheck(key, t)	
	return true
end

--开始施展神通
function hwMagic:MagicEnter(IDs, IsThing)
  self:SetProgress(0)
  self.durations[self.bind.ID] = 0
  --不可打断。
  if self.bind.JobEngine.CurJob then
    self.bind.JobEngine.CurJob.CantInterruptJob = true
  end
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--只有葵花功法才能使用，其他功法使用都会失败。
function hwMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_5_Tu" then
      return -1
    end
  end
  self.durations[self.bind.ID] = (self.durations[self.bind.ID] or 0) + dt
	if self.durations[self.bind.ID] >= self.magic.Param1  then
    self.durations[self.bind.ID] = 0
    if self.bind and self.bind.PropertyMgr then
      self.bind.PropertyMgr:ModifierProperty("NpcFight_ShieldConversionRateAddP", 0.01, 0, 0, 0) -- 增加护盾强度。
      self.bind.PropertyMgr:ModifierProperty("NpcLingMaxValue", 0, 0, -1, 0) -- 降低灵气最大值。
      if self.bind.PropertyMgr.Practice:CheckIsLearnedEsoteric("Magic_JiTuGuiYuan_1") then --如果习得归尘。
        self.bind.PropertyMgr:ModifierProperty("NpcFight_ShieldResistanceToShui", 0.001, 0, 0, 0) --每次增加千分之一水属性抗性。
      end
    end
	end
	return 0
end

--施展完成/失败 success是否成功
function hwMagic:MagicLeave(success)
  
end

--存档 如果没有返回空 有就返回Table(KV)
function hwMagic:OnGetSaveData()
	return {
    durations = self.durations,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function hwMagic:OnLoadData(tbData,IDs, IsThing)
  tbData = tbData or {}
  self.durations = tbData.durations or {}
end