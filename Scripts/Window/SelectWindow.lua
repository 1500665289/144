local SimpleWindow = GameMain:GetMod("Windows")--先注册一个新的MOD模块
local tbWindow = SimpleWindow:CreateWindow("MM_SelectWindow")
local MoreMagic = GameMain:GetMod("MoreMagic")


function tbWindow:OnInit()
	self.window.contentPane =  UIPackage.CreateObject("MoreMagic", "SelectWindow")--载入UI包里的窗口
  self.window.closeButton = self:GetChild("frame"):GetChild("n5")
  self.enter = self:GetChild("enter")
  self.list = self:GetChild("list")
end

function tbWindow:OnShowUpdate()
  self.window:Center()
  self.list:RemoveChildrenToPool()
  if self.data then
    self:GetChild("frame").title = self.data.title
    for _,name in pairs(self.data.magics) do
      local magic = PracticeMgr:GetMagicDef(name)
      if magic then
        local cur_item = self.list:AddItemFromPool()
        cur_item.name = magic.Name or ""
        cur_item.icon = magic.Icon or ""
        cur_item.title = magic.DisplayName or ""
        cur_item.tooltips = magic.Desc or ""
      end
    end
  end
  self.enter.onClick:Add(
  function ()
    local s = self.list.selectedIndex
    local magic = self.data.magics[s]
    self.data.Act(magic)
    self:Hide()
  end)
  CS.XiaWorld.MainManager.Instance:Pause(true)
end

function tbWindow:OnShown()

end

function tbWindow:OnUpdate(dt)

end

function tbWindow:OnHide()
  CS.XiaWorld.MainManager.Instance:Play(0, true)
end

--custom methods.
function tbWindow:SetUpData(data)
  self.data = data
end
