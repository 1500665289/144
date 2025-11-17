--六丁神火
local tbTable = GameMain:GetMod("MagicHelper")--获取神通模块 这里不要动
local tbMagic = tbTable:GetMagic("LiuDingShenHuo_Magic")--创建一个新的神通class
local MoreMagic = GameMain:GetMod("MoreMagic")


--注意-
--神通脚本运行的时候有两个固定变量
--self.bind 执行神通的npcObj
--self.magic 当前神通的数据，也就是定义在xml里的数据

function tbMagic:Init()
end

--神通是否可用
function tbMagic:EnableCheck(item)
	return true
end


--目标合法检测 首先会通过magic的SelectTarget过滤，然后再通过这里过滤
--IDs是一个List<int> 如果目标是非对象，里面的值就是地点key，如果目标是物体，值就是对象ID，否则为nil
--IsThing 目标类型是否为物体
function tbMagic:TargetCheck(key, t)
	if t == nil or t.ThingType ~= CS.XiaWorld.g_emThingType.Building then
		return false
	end
  --仅能对置物台上物品作用。武器或法宝就进行附魔，而普通物品则进行合成。
  if t.def.Name == "Building_ItemShelf" and t.Bag.m_lisItems.Count > 0 then
    return true
  end
  return false
end

--开始施展神通
--获取方形范围内放在置物台上的风水镇物们。现在支持3x3的范围。
function tbMagic:MagicEnter(IDs, IsThing)
  if self.bind and self.bind.PropertyMgr.Practice and self.bind.PropertyMgr.Practice.Gong then
    if self.bind.PropertyMgr.Practice.Gong.Name ~= "Gong_6_Huo" then
      self.exit = true
      return
    end
  end
  
  local shelf = ThingMgr:FindThingByID(IDs[0])
  self.targetID = shelf.Bag.m_lisItems[0].ID
  local target = shelf.Bag.m_lisItems[0]
  
  self.type = "Infusion"
  if target.IsFaBao then
    self.type = "FuMo"
  elseif target.def.Parent == "WeaponBase" then
    self.type = "Weapon"
  end
  
  --附魔功能下检测物品是否已经达到附魔上限，否就继续，是就退出。
  if self.target_type == "FuMo" then
    local cur_layer = world:GetFlag(target, MoreMagic.liuding_flag)
    local max_layer = world:GetFlag(target, MoreMagic.liuding_maxlayer_flag) + 1
    if cur_layer >= max_layer then
      self.exit = true
      return
    end
  end
  
  local pos = GridMgr:Key2P(shelf.Key)
	local keys = GridMgr:GetRectGrid(pos[0] - MoreMagic.radius, pos[1] - MoreMagic.radius, pos[0] + MoreMagic.radius, pos[1] + MoreMagic.radius)
  self.items = {}
  self.ids = {}
  for i,k in pairs(keys) do
    local sh = Map.Things:GetThingAtGrid(k, g_emThingType.Building)
    if sh and sh.Bag.m_lisItems.Count > 0 then
      local item = sh.Bag.m_lisItems[0]
      self.items[i+1] = item
      self.ids[i+1] = item.ID
    else
      self.items[i+1] = -1 --如果用nil填充的话#运算符会出错，因此我们用-1来填充。
      self.ids[i+1] = -1
    end
  end
  self.duration = 0
  self.coroutine = coroutine.create(MoreMagic.Recipes.FindRecipe)
  self.iterator = MoreMagic.Utils.Iterator(self.ids, self.duration)
end

--神通施展过程中，需要返回值
--返回值  0继续 1成功并结束 -1失败并结束
--现在只有九转金丹直指能施展，其他功法施展都会直接失败。
function tbMagic:MagicStep(dt, duration)
  if self.exit then return -1 end
  
  if not self.match then --首先在没有match的时候我们需要寻找match.
    if self.coroutine and coroutine.status(self.coroutine) == "suspended" then --只有协程能跑的时候我们才跑。
      _, self.match = coroutine.resume(self.coroutine, self.items, self.type)
      print(self.match)
      self.duration = duration --调整self.duration到现在的时间，下面才能正确计算。
      self.total = #self.ids + 5 + self.duration --此次施展总共需要的时间。
      return 0 --无论此帧找到与否，我们都结束运行，将接下来的工作交给下一帧进行。
    else --如果协程不见了或者跑完了都没找到match，返回失败值。
      return -1
    end
  else --找到了我们继续下一步。
    if self.duration < math.floor(duration) then
      self.duration = math.floor(duration)
      local ind, id = self.iterator()
      if id then
        local thing = ThingMgr:FindThingByID(id)
        if thing then
          thing.Lock:Lock(self.bind)
          world:PlayEffect(90025, thing.Key, self.total - duration)
          CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
        end
      end
    end
    self:SetProgress(duration/self.total)--设置施展进度 主要用于UI显示
    if duration >= self.total then
      return 1
    end
    return 0
  end
end

--施展完成/失败 success是否成功
function tbMagic:MagicLeave(success)
  if success then --成功则解除锁定，并且添加效果。
    local target = ThingMgr:FindThingByID(self.targetID)
    if target then
      target.Lock:UnLock(self.bind) --我们要解除目标物品的锁定状态。
      --首先，我们要进行屏蔽，以免接下来的代码删除了多余的物品。
      local ids = MoreMagic.Recipes.MaskRecipe(self.ids, self.match)
      for _,id in pairs(ids) do
        local thing = ThingMgr:FindThingByID(id)
        if thing then
          thing.Lock:UnLock(self.bind)
          local bag = ThingMgr:FindThingByID(thing.InWhoseBag)
          if bag then --将置物台上的物品先丢地上再删除。
            bag.Bag:DropAll()
            bag.View:SendViewMessage("RemoveItem", nil)
            ThingMgr:RemoveThing(thing, true)
          end
        end
      end
      CS.GameWatch.Instance:PlayUIAudio("Sound/ding")
      if self.type == "FuMo" then --目标是法宝则增加对应附魔。
        print("六丁神火为法宝附魔！")
        MoreMagic.Utils.RegisterLiuDingEffect(target, MoreMagic.Recipes.GetFuMoEffect(self.match))
      elseif self.type == "Infusion" then
        local act = MoreMagic.Recipes.GetInfusionAction(self.match)
        if act then
          print("六丁神火合成物品！")
          act(target, self.bind)
        end
      end
    end
  else --失败则什么都不用做。
    print("六丁神火失败！")
  end
end

--存档 如果没有返回空 有就返回Table(KV)
function tbMagic:OnGetSaveData()
	return {
    targetID = self.targetID,
    type = self.type,
    duration = self.duration,
    ids = self.ids,
    match = self.match,
    total = self.total,
  }
end

--读档 tbData是存档数据 IDs和IsThing同进入
function tbMagic:OnLoadData(tbData,IDs, IsThing)
	tbData = tbData or {}
  self.targetID = tbData.targetID or -1
  self.type = tbData.type or "Infusion"
  self.duration = tbData.duration or 0
  self.ids = tbData.ids or {}
  self.match = tbData.match
  self.total = tbData.total or 0
  if not self.match then
    self.items = {}
    for i,id in pairs(self.ids) do
      local item = ThingMgr:FindThingByID(id)
      if item then
        self.items[i] = item
      else
        self.items[i] = -1
      end
    end
    self.coroutine = coroutine.create(MoreMagic.Recipes.FindRecipe)
  end
  self.iterator = MoreMagic.Utils.Iterator(self.ids, self.duration)
end
