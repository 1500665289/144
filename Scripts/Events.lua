local MoreMagic = GameMain:GetMod("MoreMagic")
MoreMagic.Events = MoreMagic.Events or {}
local Events = MoreMagic.Events


Events.FlagIDs = {
  LDModifier_Test = 15800,
  LDModifier_BloodLust = 15801,
  LDModifier_FBBloodLust = 15802,
  LDModifier_InstantFaint = 15803,
  LDModifier_JieCloudCrit = 15804,
}
local TARGET_ESOS = {"Gong4_LvUpEsoterica_XinJin", "Gong4_LvUpEsoterica_YiMu", "Gong4_LvUpEsoterica_GuiShui", "Gong4_LvUpEsoterica_DingHuo", "Gong4_LvUpEsoterica_JiTu", "Gong4_Esoterica_11", "Gong4_Esoterica_8", "Gong4_Esoterica_12", "Gong4_Esoterica_10", "Gong4_Esoterica_9"}

function Events.EquipUpdate(data, thing, objs)
  local equip_item = objs[0]
  local equip_type = objs[1]
  local num = world:GetFlag(equip_item, data.flagID)
  if num ~= 0 then
    if equip_type == 1 then --装备事件
      thing:AddModifier(data.modifier, num)
    elseif equip_type == 3 then --脱下事件
      thing:RemoveModifier(data.modifier)
    end
  end
end

function Events.HandleYuQingLearn(data, thing, objs)
  if thing and thing.PropertyMgr and thing.PropertyMgr.Practice and thing.PropertyMgr.Practice.Gong and thing.PropertyMgr.Practice.Gong.Name == "Gong_4_None" then
    local learnt = objs[0]
    local learning_target = false
    for _,name in pairs(TARGET_ESOS) do
      if name == learnt then
        learning_target = true
        break
      end
    end
    local practice = thing.PropertyMgr.Practice
    if learning_target then
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_XinJin") and practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_YiMu") and practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_GuiShui") and practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_DingHuo") and practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_JiTu") then
        thing:DoDeath() -- 五个元神全学就献祭#手动滑稽。
      end
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_XinJin") and practice:CheckIsLearnedEsoteric("Gong4_Esoterica_11") then --丙辛合水。
        thing:AddModifier("Modifier_BingXin")
      end
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_YiMu") and practice:CheckIsLearnedEsoteric("Gong4_Esoterica_8") then --庚乙合金。
        thing:AddModifier("Modifier_GengYi")
      end
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_GuiShui") and practice:CheckIsLearnedEsoteric("Gong4_Esoterica_12") then --戊癸合火。
        thing:AddModifier("Modifier_WuGui")
      end
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_DingHuo") and practice:CheckIsLearnedEsoteric("Gong4_Esoterica_10") then --壬丁合木。
        thing:AddModifier("Modifier_RenDing")
      end
      if practice:CheckIsLearnedEsoteric("Gong4_LvUpEsoterica_JiTu") and practice:CheckIsLearnedEsoteric("Gong4_Esoterica_9") then --甲己合土。
        thing:AddModifier("Modifier_JiaJi")
      end
    end
  end
end

function Events.HandleGetRandomTalk_TongXinJue(sender, e)
  local tags = e.Tags
  local player = e.Player
  local target = e.Target
  --对话的玩家是太上忘情道功法并且已学同心诀。
  if player and player.PropertyMgr and player.PropertyMgr.Practice and player.PropertyMgr.Practice.Gong and player.PropertyMgr.Practice.Gong.Name == "Gong_7_Huo" and player.PropertyMgr.Practice:CheckIsLearnedEsoteric("Gong7_Esoterica_3") then
    local target_seed = target.JiangHuSeed
    local target_data = CS.XiaWorld.JianghuMgr.Instance:GetKnowNpcData(target_seed)
    if target_data then
      local chushi_score = player.PropertyMgr.SkillData:GetSkillEvaluate(CS.XiaWorld.g_emNpcSkillType.SocialContact).x
      if math.random(100) <= chushi_score then
        target_data.hlock = 1
        target_data.favour = target_data.favour + 80
      end
    end
  end
end