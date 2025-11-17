--瀚海灵光咒
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local hwMagic = tbTable:GetMagic("HanHaiLingGuang_Magic")--创建一个新的神通class

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
	return true
end

--开始施展神通
function hwMagic:MagicEnter(IDs, IsThing)
  self:SetProgress(0)
  self.duration = 0
  --不可打断。
  if self.bind.JobEngine.CurJob then
    self.bind.JobEngine.CurJob.CantInterruptJob = true
  end
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--只有太和功法才能使用，其他功法使用都会失败。
function hwMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_1_Shui" then
      return -1
    end
  end
  self.duration = self.duration + dt
	if self.duration >= self.magic.Param1  then
    self.duration = 0
    local disciples = self:GetDisciples()
    if self.bind and self.bind.PropertyMgr.Practice and disciples then
      local requirement = self.magic.Param3 * self.magic.Param1 * self.bind:GetProperty("NpcFight_SpellLingCostAddP") --每次更新的消耗。param3是每秒消耗，乘以更新间隔param1就是这次需要的值，会受到人物术法消耗加成的影响。
      if self.bind.LingV <= requirement then --低于最小施放的灵气则结束。
        print("灵气不足，瀚海灵光咒结束！")
        return -1
      else --灵气足够则开始生效。
        self.bind:AddLing(-requirement) --消耗一次灵气。
        local addition = self.bind:GetProperty("NpcFight_SpellPowerAddP")
        --World.Weather:ClearAllWeather() -- 驱散所有天气。
        for _,disciple in pairs(disciples) do
          disciple:AddLing(disciple.MaxLing * self.magic.Param2 * self.magic.Param1 * addition) -- 每个人每秒回复Param2百分比的的灵气。这个灵气回复值不受任何东西影响，且受到术法威力的加成。
          disciple:AddModifier("Modifier_Target_HanHaiLingGuang", addition) --每次生效都添加一次BUFF, BUFF效果与人物法伤有关。
          if self.bind.PropertyMgr.Practice:CheckIsLearnedEsoteric("Magic_HanHaiLingGuang_1") then --学习瀚海灵光·宁心以后可以恢复心境。
            if disciple.Needs:GetNeedValue(CS.XiaWorld.g_emNeedType.MindState) < 500 then --最大只能回复到500。
              disciple.Needs:AddNeedValue(CS.XiaWorld.g_emNeedType.MindState, self.magic.Param4 * self.magic.Param1 * addition) --Param4是每秒心境回复的基础值。
            end
          end
          if self.bind.PropertyMgr.Practice:CheckIsLearnedEsoteric("Magic_HanHaiLingGuang_2") then --学习瀚海灵光·辉耀以后可以添加反伤BUFF。
            disciple:AddModifier("Modifier_Target_HanHaiLingGuang_HuiYao", addition) --辉耀BUFF的强度也受法伤加成。
          end
        end
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
    duration = self.duration,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function hwMagic:OnLoadData(tbData,IDs, IsThing)
  tbData = tbData or {}
  self.duration = tbData.duration or 0;
end

function hwMagic:GetDisciples()
  --获取所有的友方内门弟子列表，并且除掉雷劫和结丹的。
  local npcs = Map.Things:GetPlayerActiveNpcs()
  local nogt_disciples = {}
  for k,disciple in pairs(npcs) do
    if disciple.IsDisciple then
      local neck = disciple.PropertyMgr.Practice.CurNeck
      local avail = true
      if neck and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Thunder and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.God and neck.Kind ~= CS.XiaWorld.g_emGongBottleNeckType.Gold then
        avail = false
      end
      if avail then
        table.insert(nogt_disciples, disciple)
      end
    end
  end
  return nogt_disciples
end