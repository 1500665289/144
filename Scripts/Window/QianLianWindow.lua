local SimpleWindow = GameMain:GetMod("Windows")--先注册一个新的MOD模块
local tbWindow = SimpleWindow:CreateWindow("QianLianWindow")
local MoreMagic = GameMain:GetMod("MoreMagic")


local g_emFaBaoP = CS.XiaWorld.Fight.g_emFaBaoP
local SLIDERS = {
  atk = "AttackPower",
  recover = "LingRecover",
  maxling = "MaxLing",
  flyspd = "FlySpeed",
  rotspd = "RotSpeed",
  kbadd = "KnockBackAddition",
  kbresist = "KnockBackResistance",
  scale = "Scale",
  tail = "TailLenght",
  atkspd = "AttackRate",
}
local LABELS = {
  AttackPower = "法宝伤害：{0}",
  LingRecover = "法宝回灵：{0}/秒",
  MaxLing = "最大灵气：{0}",
  FlySpeed = "飞行速度：{0}米/秒",
  RotSpeed = "转向速度：{0}度/秒",
  KnockBackAddition = "击退能力：{0}%",
  KnockBackResistance = "击退抵抗：{0}%",
  Scale = "法宝大小：{0}%",
  TailLenght = "拖尾长度：{0}米",
  AttackRate = "攻击间隔：{0}秒",
}

function tbWindow:OnInit()
	self.window.contentPane =  UIPackage.CreateObject("MoreMagic", "QianLianWindow")--载入UI包里的窗口
  self.window.closeButton = self:GetChild("frame"):GetChild("n5")
  self:GetChild("frame").title = "千炼神诀"
  self.enter_btn = self:GetChild("n1")
  self.sliders = {}
  self.labels = {}
  for n,m in pairs(SLIDERS) do
    self.sliders[m] = self:GetChild(n)
    self.labels[m] = self:GetChild(n.."_label")
  end
  self.crystal_label = self:GetChild("crystal")
end

function tbWindow:OnShowUpdate()
  self.window:Center()
  
  --把每个拉条的最大值改为设定好的千炼最大次数减去目标已有的幽淬次数，或者仓库中现有的灵晶数量/50，取更小的一方。
  local avail_num = 0
  if self.caller then
    local target = ThingMgr:FindThingByID(self.caller.targetID)
    if target then
      you = target.YouPower or 0
      avail_num = MoreMagic.qianlian - you
    end
  end
  local ling_crystal_count = World.Warehouse:GetItemCount("Item_LingCrystal") or 0
  self.crystal_label.text = "灵晶数量：".."0/"..ling_crystal_count
  self.slider_max = math.min(avail_num, math.floor(ling_crystal_count/50))
  for _,slider in pairs(self.sliders) do
    slider.max = self.slider_max
    slider.data = self --设置回调要用的数据。
    slider.onChanged:Add(OnChangedCallBack) --添加回调函数。
  end
  
  --设置标签，同时将取得的值放入表里，之后要返还给神通的class。
  self.results = {}
  if self.caller then
    local target = ThingMgr:FindThingByID(self.caller.targetID)
    if target then
      for n,t in pairs(LABELS) do
        local number = target.Fabao:GetProperty(g_emFaBaoP.__CastFrom(n)) or 0
        self.results[n] = number --要存百分比修正前的数。
        if n == "KnockBackAddition" or n == "KnockBackResistance" or n == "Scale" then number = number * 100 end --百分比数的修正。
        self.labels[n].text = string.gsub(t, "{0}", string.format("%.2f", number))
      end
    end
  end
  self.total = 0 --这是储存此次强化次数的字段。
  
  self.enter_btn.onClick:Add(
  function ()
    self:Hide()
  end)
  CS.XiaWorld.MainManager.Instance:Pause(true)
end

function tbWindow:OnShown()

end

function tbWindow:OnUpdate(dt)

end

function tbWindow:OnHide()
  for _,slider in pairs(self.sliders) do --隐藏窗口时清空所有的slider值。
    slider.value = 0
  end
  if self.caller then --并将有用的值返还给caller。
    self.caller:StoreValue(self.results, self.total)
  end
  CS.XiaWorld.MainManager.Instance:Play(0, true)
end

--custom methods.
function tbWindow:SetUpData(caller)
  self.caller = caller
end

function tbWindow:UpdateSliderLabel(name, slider)
if self.caller then
  local target = ThingMgr:FindThingByID(self.caller.targetID)
  if target then
    local base = target.Fabao:GetBaseValue(g_emFaBaoP.__CastFrom(name)) or 0
    local number = target.Fabao:GetProperty(g_emFaBaoP.__CastFrom(name)) or 0
    local di = 1.1
    if name == "AttackRate" then
      di = 0.9
      base = base * -1
    end
    local result = 0
    if MoreMagic.qianlian_current then --如果计算的是当前值，则我们每点拉条能量增加10%当前值。
      result = number * 1.1^math.floor(slider.value)
    else --如果是基础值，则每点增加100%基础值。
      result = number + base * math.floor(slider.value)
    end
    if name == "AttackRate" then
      result = math.max(result, 0.1) --把攻速钳位在0.1上。
    end
    self.results[name] = result --要存百分比修正前的数。
    if name == "KnockBackAddition" or name == "KnockBackResistance" or name == "Scale" then result = result * 100 end --百分比数的修正。
    self.labels[name].text = string.gsub(LABELS[name], "{0}", string.format("%.2f", result))
  end
end
end

--callbacks.
function OnChangedCallBack(context)
  local self = context.sender.data
  local total = 0
  context.sender.value = math.floor(context.sender.value)
  for n,slider in pairs(self.sliders) do
    if self.slider_max == 0 then slider.value = 0 end
    total = total + math.floor(slider.value) --计算总共有多少点强化。
    if slider == context.sender then --对于改变的那个拉条，我们要预测他改变后的数据。
      self:UpdateSliderLabel(n, slider)
    end
  end
  if total > self.slider_max then --如果总和大于可使用的次数，则降低其余slider的值。
    for n,slider in pairs(self.sliders) do
      slider.value = math.max(0, slider.value - 1)
      self:UpdateSliderLabel(n, slider)
    end
  end
  local ling_crystal_count = World.Warehouse:GetItemCount("Item_LingCrystal")
  self.crystal_label.text = "灵晶数量："..(total*50).."/"..ling_crystal_count
  --最后储存强化次数。
  self.total = total
end
