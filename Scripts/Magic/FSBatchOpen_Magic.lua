--风水天眼通
local tbTable = GameMain:GetMod("MagicHelper")
local tbMagic = tbTable:GetMagic("FSBatchOpen_Magic")
local MoreMagic = GameMain:GetMod("MoreMagic")


function tbMagic:Init()
end

function tbMagic:TargetCheck(k, t)
	return true
end

function tbMagic:MagicEnter(IDs, IsThing)
	local items = ThingMgr:GetThingList(g_emThingType.Item)
  local fengshuiIDs = {}
  for k,v in pairs(items) do
    if v.FSItemState == 1 then
      table.insert(fengshuiIDs, v.ID)
    end
  end
  self.targetIDs = fengshuiIDs
end

function tbMagic:MagicStep(dt, duration)--返回值  0继续 1成功并结束 -1失败并结束		
  if #self.targetIDs == 0 then
    return -1
  elseif not self.iterator then
    self.iterator = MoreMagic.Utils.Iterator(self.targetIDs, math.floor(duration/dt) - 1)
  else
    local i, id = self.iterator()
    if id then
      local item = ThingMgr:FindThingByID(id)
      if item then
        self:SetProgress(i/#self.targetIDs)
        item.FSItemState = 2
        world:PlayEffect(100006, item.Pos)
      end
    else
      return 1
    end
  end
	return 0
end

function tbMagic:MagicLeave(success)

end

function tbMagic:OnGetSaveData()
	return {
    targetIDs = self.targetIDs,
  }
end

function tbMagic:OnLoadData(tbData,IDs, IsThing)	
	tbData = tbData or {}
  self.targetIDs = tbData.targetIDs or {}
end
