local MoreMagic = GameMain:GetMod("MoreMagic")
MoreMagic.Utils = MoreMagic.Utils or {}
local Utils = MoreMagic.Utils


--附魔效果描述。
local DESC = {
  LDModifier_Test = "六丁神火附魔测试。",
  LDModifier_BloodLust = "【灵气渴望】\n此法宝使用妖族的鲜血附魔，装备者每次攻击都能够吸取敌方一定比例的当前灵气用于回复自身。",
  LDModifier_FBBloodLust = "【灵气窃取】\n此法宝使用强大妖族的鲜血附魔，每次与敌方法宝碰撞时都能够窃取敌方法宝的灵气值。",
  LDModifier_InstantFaint = "【灵魂震颤】\n如果你的目标灵气低于50%，则有几率直接将目标击晕。",
  LDModifier_JieCloudCrit = "【逆天】\n攻击劫云时有几率直接将劫云的当前灵气减半。",
}

function Utils.PrintList(l)
  local s = "{"
  for i=1,#l do
    local e = tostring(l[i])
    s = s .. e .. ", "
  end
  s = s .. "}"
  print(s)
end

function Utils.Iterator(t, i)
  return function ()
    i = i + 1
    if i <= #t then return i, t[i] else return 0, nil end
  end
end

function Utils.GetPatternMatrix(n)
  local n = n or -1
  local d = MoreMagic.radius*2 + 1
  local ret = {}
  for i=1,d*d,1 do
    ret[i] = n
  end
  return ret
end

function Utils.RegisterLiuDingEffect(target, effect)
  local cur_layer = world:GetFlag(target, MoreMagic.liuding_flag)
  local max_layer = world:GetFlag(target, MoreMagic.liuding_maxlayer_flag) + 1
  if cur_layer < max_layer then --双保险。在此也判断一次现有层数是不是多于最大层数。
    local flag_id = MoreMagic.Events.FlagIDs[effect] or 0
    world:SetFlag(target, MoreMagic.liuding_flag, cur_layer + 1) -- 为附魔层数FLAG增加一层。
    world:SetFlag(target, flag_id, 1) --点亮效果flag。
    local desc =  target:GetDesc() or ""
    target.m_sDesc = "[color=#ff9900][b][size=12]【神火附魔】\n[/size][/b][/color]" .. "[color=#99ccff]" .. DESC[effect] .. "[/color]\n\n" .. desc --最后修改描述体现已经附魔的事实。
  end
end

function Utils.MoreEventCapableRegister(e_better, e_normal, f_better, f_normal, data)
  local has_ext = GameMain:GetMod("MoreEvents").IsExist
  if has_ext then
    CS.MoreEvents.EventManager.AddEvent(e_better, data, f_better)
  else
    GameMain:GetMod("_Event"):RegisterEvent(e_normal, f_normal, data)
  end
end

function Utils.UseFulu()
  local npc = me.npcObj
  local s,e = string.find(it.m_sDesc, "\n\n")
  local magic = ""
  if e then
    magic = string.sub(it.m_sDesc, e+1)
  end
  local def = PracticeMgr:GetMagicDef(magic)
  if def and def.ClassName then
    world:CastMagic(npc, magic)
  else
    local bntData = CS.NpcMagicBnt.GetBntData(magic, npc)
    bntData.DoAct(npc)
  end
  local quality = it:GetQuality()
  if quality > 0.1 then
    it:SetQuality(quality - 0.1)
    return false --false表示不会消耗物品，true表示每次使用会消耗一个。
  else
    return true
  end
end