--万法归藏
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local ttMagic = tbTable:GetMagic("WanFaGuiCang_Magic")--创建一个新的神通class
local MoreMagic = GameMain:GetMod("MoreMagic")

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
	if t.def.Name == "Item_SpellPaper" or t.def.Name == "Item_SpellPaperLv2" or t.def.Name == "Item_SpellPaperLv3" then --三种符纸的任意一个都行
		return true
	end
	return false
end

--开始施展神通
function ttMagic:MagicEnter(IDs, IsThing)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_4_None" then
      return
    end
  end
  local fuzhi = ThingMgr:FindThingByID(IDs[0])
  if fuzhi then fuzhi:SubCount(1) end
  local fulu = CS.XiaWorld.ItemRandomMachine.RandomItem("Item_MagicSpell", nil, 2, 2, 1, 1)
  self.targetID = fulu.ID
	local magics = self.bind.PropertyMgr.Practice.Magics
  local wnd = GameMain:GetMod("Windows"):GetWindow("MM_SelectWindow")
  wnd:SetUpData({title = "请选择神通", magics = magics, 
    Act = function (magic)
      self.select_magic = magic
    end,
  })
  wnd:Show()
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--现在只有偷天诀能施展，其他功法施展都会直接失败。
function ttMagic:MagicStep(dt, duration)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_4_None" then
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
  if success and self.targetID and self.select_magic then
    local fulu = ThingMgr:FindThingByID(self.targetID)
    local magic = PracticeMgr:GetMagicDef(self.select_magic)
    if fulu and magic then
      fulu:SetName((magic.DisplayName or "") .. (fulu:GetName() or ""))
      fulu.m_sDesc = "包含了" .. (magic.DisplayName or "") .. "神通的符箓。\n\n" .. self.select_magic
      Map:DropItem(fulu, self.bind.Key)
    end
  else
    print("failed!")
  end
end

--存档 如果没有返回空 有就返回Table(KV)
function ttMagic:OnGetSaveData()
	return {
    targetID = self.targetID,
    select_magic = self.select_magic,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function ttMagic:OnLoadData(tbData,IDs, IsThing)	
  tbData = tbData or {}
  self.targetID = tbData.targetID or 0
  self.select_magic = tbData.select_magic
end
