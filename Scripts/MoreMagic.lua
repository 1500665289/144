--默认的神通难度设定。
--这个值true是化物同命可以无限吸，没有成功率计算。
local INFINITE_HUAWU = false
--这个值是千炼神诀可以最多使用的次数，用幽淬次数表示。
local QIANLIAN_NUMBER = 10
--这个值为true则千炼增长方式为当前值，false则为基础值。
local QIANLIAN_CURRENT = false





--以下内容请不要修改。
local MoreMagic = GameMain:NewMod("MoreMagic")
local LIUDING_RADIUS = 1 --六丁神火最大可判定的风水镇物阵的范围，默认为1。最终区间就是3x3。
local LIUDING_FLAG = 157342 --六丁神火的附魔FLAG，每个被六丁附魔的物品都有这个FLAG，此FLAG的数量代表附魔次数。
local LIUDING_MAXLAYER_FLAG = 15733 --六丁神火的附魔层数FLAG。所有物品都默认为1（即可附魔次数=flag数量+1）。

local problematic_mods = {"Gong4_Esoterica_3", "Gong10_Esoterica_8", "Gong10_LvUpEsoterica_5", "Gong9_LvUpEsoterica_4"}
local save_modifiers = {"modifier_beishui", "modifier_jiaji", "modifier_gengyi", "modifier_rending", "modifier_wugui"}

function MoreMagic:OnInit()
  self.huawu = INFINITE_HUAWU
  self.qianlian = QIANLIAN_NUMBER
  self.qianlian_current = QIANLIAN_CURRENT
  self.radius = LIUDING_RADIUS
  self.liuding_flag = LIUDING_FLAG
  self.liuding_maxlayer_flag = LIUDING_MAXLAYER_FLAG
  
  --把风水天眼通添加成风水鉴定的二层升华。
  self.AddUpdateGong("Gong1_b2", "Gong1_b2_0", true)
  
  --把驱夜诀添加成驱云决的二层升华。
  self.AddUpdateGong("Gong10_a1", "Gong10_a1_1", false)
  
  --把极天化神界加入风月幻境的升华最后。
  self.AddUpdateGong("Gong7_c1", "Gong7_c1_N", false)
  --把太上不忘情加入心印诀的第二层升华。
  self.AddUpdateGong("Gong7_b2", "Gong7_b2_N", true)
  
  --把真·万法归藏加入万法归藏的最后。
  self.AddUpdateGong("Gong4_c3", "Gong4_c3_N", false)
  --把破阵诀加入太虚神雷的二层升华。
  self.AddUpdateGong("Gong4_d5", "Gong4_d5_1", true)
  --把五个元神加入到对应的秘籍最后。
  self.AddUpdateGong("Gong4_d7", "Gong4_d7_N", false)
  self.AddUpdateGong("Gong4_d8", "Gong4_d8_N", false)
  self.AddUpdateGong("Gong4_d9", "Gong4_d9_N", false)
  self.AddUpdateGong("Gong4_d10", "Gong4_d10_N", false)
  self.AddUpdateGong("Gong4_d11", "Gong4_d11_N", false)
  
  --寿元上限提升10倍。
  local maxage = CS.XiaWorld.PropertyMgr.Instance:GetDef("MaxAge")
  maxage.MaxValue = maxage.MaxValue * 10
  --术法冷却时间的下限改为1%。
  local cooldown = CS.XiaWorld.PropertyMgr.Instance:GetDef("NpcFight_SpellCoolDownAddP")
  cooldown.MinValue = -0.99
  cooldown.MaxValue = 9999
  --所有原版addp类的术法冷却吟唱都有问题，所以我得把他们全部改掉。。。
  for _, name in pairs(problematic_mods) do
    local mod = CS.XiaWorld.ModifierMgr.Instance:GetDef(name)
    if mod and mod.Properties then
      for _,prop in pairs(mod.Properties) do
        if prop.Name == "NpcFight_SpellCoolDownAddP" then
          prop.AddP = prop.AddP * -1 --原版功法的降CD秘籍符号全部反了。
        end
      end
    end
  end
  
  --由于原版的modifier接口的存档读档不能用，我们把东西存这里。先初始化。
  for _,name in pairs(save_modifiers) do
    self[name] = self[name] or {}
  end
end

function MoreMagic:OnEnter()
  --为六丁神火已有的modifier注册事件。由于事件不保存，因此每次读档都要注册一次。因此就不在生成装备那里注册，在这里注册。
  local script = GameMain:GetMod("_ModifierScript")
  for m,f in pairs(self.Events.FlagIDs) do
    local modifier = script:GetModifier(m)
    if modifier then modifier:Register() end --注册每个modifier自己的事件。
    GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.EquipUpdate, self.Events.EquipUpdate, {flagID = f, modifier = m}) --注册装备事件。装备物品可以添加效果FLAG对应的BUFF。
  end
  --注册紫微洞玄的事件。
  local ziwei = script:GetModifier("modifier_ziweidongxuan")
  ziwei:Register()
  --注册瀚海灵光辉耀事件。
  local huiyao = script:GetModifier("modifier_hanhailingguang_huiyao")
  huiyao:Register()
  --注册玉清学习秘籍事件。
  GameMain:GetMod("_Event"):RegisterEvent(g_emEvent.LearnEsoterica, self.Events.HandleYuQingLearn, "yuqing")
  
  --注册全局事件。比如太上最新的秘籍超凡同心诀需要的内容。
   CS.MoreEvents.EventManager.AddEvent("OnGetRandomTalk", "tongxinjue", self.Events.HandleGetRandomTalk_TongXinJue)
end

function MoreMagic:OnSetHotKey()

end

function MoreMagic:OnHotKey(ID,state)

end

function MoreMagic:OnStep(dt)

end

function MoreMagic:OnLeave()
  local script = GameMain:GetMod("_ModifierScript")
  for m,f in pairs(self.Events.FlagIDs) do
    local modifier = script:GetModifier(m)
    if modifier then modifier:Unregister() end --反注册每个modifier自己的事件，因为使用MoreEvents模块的附魔需要如此，否则出错。
  end
  --反注册紫微洞玄的事件。
  local ziwei = script:GetModifier("modifier_ziweidongxuan")
  ziwei:Unregister()
  --反注册瀚海灵光辉耀事件。
  local huiyao = script:GetModifier("modifier_hanhailingguang_huiyao")
  huiyao:Unregister()
  
  --反注册全局事件。
   CS.MoreEvents.EventManager.RemoveEvent("OnGetRandomTalk", "tongxinjue")
end

function MoreMagic:OnSave()
  --由于modifier不能存档数据，所以我们存到这里来。
  local ret = {}
  for _, name in pairs(save_modifiers) do
    ret[name] = self[name]
  end
  return ret
end

function MoreMagic:OnLoad(tbLoad)
  tbLoad = tbLoad or {}
  for _,name in pairs(save_modifiers) do
    self[name] = tbLoad[name] or {}
  end
end

function MoreMagic.GetPrivateField(obj, member_name)
  local member = obj:GetType():GetField(member_name, CS.System.Reflection.BindingFlags.NonPublic | CS.System.Reflection.BindingFlags.Instance)
  if member and obj then
    return member:GetValue(obj)
  else
    return nil
  end
end

function MoreMagic.SetPrivateField(obj, member_name, value)
  local member = obj:GetType():GetField(member_name, CS.System.Reflection.BindingFlags.NonPublic | CS.System.Reflection.BindingFlags.Instance)
  if member and obj then
    member:SetValue(obj, value)
  end
end

function MoreMagic.AddUpdateGong(target, name, start)
  local gong = PracticeMgr.SkillTree:GetDef(target)
  if gong then
    local layers = gong.Layers
    if not layers then
      gong.Layers = {name}
    elseif not layers:Contains(name) then
      if start then
        gong.Layers:Insert(0, name)
      else
        gong.Layers:Add(name)
      end
    end
  end
end