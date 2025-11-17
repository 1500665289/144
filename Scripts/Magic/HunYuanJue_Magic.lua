--千炼神诀
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local hyMagic = tbTable:GetMagic("HunYuanJue_Magic")--创建一个新的神通class

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
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Item then
		return false
	end
	if t.IsFaBao then
		return true
	end
	return false
end

--开始施展神通
function hyMagic:MagicEnter(IDs, IsThing)
	self.targetID = IDs[0]--获取目标信息
  local target = ThingMgr:FindThingByID(self.targetID)
  if target then
    target.Lock:Lock(self.bind)
  end
  self:SelectTianCaiDiBao()
end

--神通施展过程中，需要返回值
-- 成功率跟人物心境有关，200心境则满成功率。
--返回值  0继续 1成功并结束 -1失败并结束
function hyMagic:MagicStep(dt, duration)
	self:SetProgress(duration/self.magic.Param1)--设置施展进度 主要用于UI显示 这里使用了参数1作为施法时间
	if duration >= self.magic.Param1 then
    local mind_state = self.bind.Needs:GetNeedValue(CS.XiaWorld.g_emNeedType.MindState)
    local rate = mind_state / 200
    if self.targetID and self.used_itemID and CS.XiaWorld.World.RandomRate(rate) then
      return 1
    else
      return -1
    end
	end
	return 0
end

--施展完成/失败 success是否成功
function hyMagic:MagicLeave(success)
  if success then
  -- 成功的事件。
    local target = ThingMgr:FindThingByID(self.targetID)
    if target then
      target.Lock:UnLock(self.bind)
    end
    local used_item = ThingMgr:FindThingByID(self.used_itemID)
    if used_item then
      used_item.Lock:UnLock(self.bind)
    end
    if target and used_item then
      if used_item.FreeCount > 0 then
        used_item:SubCount(1)
      else
        ThingMgr:RemoveThing(used_item, false, false)
      end
      local convert_element = nil
      if used_item.def.Name == "Item_LingCrystal" then
        convert_element = CS.XiaWorld.g_emElementKind.None
      else
        convert_element = used_item.def.ElementKind
      end
      local fabao_data = target.Fabao
      if fabao_data and convert_element then
        -- 将法宝的属性转变为预先的属性。
        target.m_mElementKind = convert_element
      end
      CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
    end
  else
    -- 失败的事件。
    world:AddMsg("施展神通混元金斗诀失败！")
  end
end

--存档 如果没有返回空 有就返回Table(KV)
function hyMagic:OnGetSaveData()
	return {
    used_itemID = self.used_itemID,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function hyMagic:OnLoadData(tbData,IDs, IsThing)	
  tbData = tbData or {}
	self.targetID = IDs[0]--获取目标信息
  self.used_itemID = tbData.used_itemID or 0
end

function hyMagic:SelectTianCaiDiBao()
	local tbInfo = {
		KC = "Item",
		Line = {StartObj = self.bind},
    Magic = self,
		HeadMsg = "请选择天材地宝或灵晶",
		Apply = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Item, k, map)
        if tbMode.tbInfo.Magic then
          tbMode.tbInfo.Magic.used_itemID = t.ID
          t.Lock:Lock(tbMode.tbInfo.Magic.bind)
        end
			end,
		Check = 
			function(_, map, k, tbMode) 
				local t = tbMode:GetThing(g_emThingType.Item, k, map)
				return t.def.Name == "Item_JinEssence" or t.def.Name == "Item_MuEssence" or t.def.Name == "Item_ShuiEssence" or t.def.Name == "Item_HuoEssence" or t.def.Name == "Item_TuEssence" or t.def.Name == "Item_LingCrystal"
			end,
	}

	world:EnterUILuaMode("TableCtrl", tbInfo)
end
