--偷天决
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local ttMagic = tbTable:GetMagic("TouTianJue_Magic")--创建一个新的神通class

--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function ttMagic:Init()
end

--神通是否可用
function ttMagic:EnableCheck(item)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function ttMagic:TargetCheck(key, t)	
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Item then
		return false
	end
	if t.LingV > 0 and t.def.Name == "Item_SoulPearl" then
		return true
	end
	return false
end

--开始施展神通
function ttMagic:MagicEnter(IDs, IsThing)
	self.targetID = IDs[0]--获取目标信息
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:Lock(self.bind)
  end
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--现在只有偷天诀能施展，其他功法施展都会直接失败。
function ttMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_5_Tu" and self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_4_None" then
      return -1
    end
  end
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >=self.magic.Param1  then
		return 1
	end
	return 0
end

--施展完成/失败 success是否成功
function ttMagic:MagicLeave(success)
	if success == true then
    -- 成功的事件。
    local target = ThingMgr:FindThingByID(self.targetID)
    if target then
      target.Lock:UnLock(self.bind)
    end
    targetLing = target.LingV
    ThingMgr:RemoveThing(target, false, false)
		local practice = self.bind.PropertyMgr.Practice
		if practice ~= nil then
      if practice.Gong.Name == "Gong_4_None" then
        practice.GoldLing = practice.GoldLing + (targetLing*0.5)
        self.bind.PropertyMgr:ModifierProperty("NpcLingMaxValue", 0, 0, targetLing * 0.0125, 0)
      else
        practice.GoldLing = practice.GoldLing + targetLing
        self.bind.PropertyMgr:ModifierProperty("NpcLingMaxValue", 0, 0, targetLing * 0.025, 0)
      end
		end
    CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
  else
    -- 失败的事件。
    world:AddMsg("无法施放此神通！")
	end	
  
end

--存档 如果没有返回空 有就返回Table(KV)
function ttMagic:OnGetSaveData()
	
end

--读档 tbData是存档数据 IDs和IsThing同进入
function ttMagic:OnLoadData(tbData,IDs, IsThing)	
	self.targetID = IDs[0]--获取目标信息
end

function ttMagic:GetGoldLevel(goldling)
  gold_levels = GameDefine.GoldDanLevel
  suit_value = 0
  for ling,level in pairs(gold_levels) do
    if ling > suit_value and goldling > ling then
      suit_value = ling
    end
  end
  return gold_levels[suit_value]
end