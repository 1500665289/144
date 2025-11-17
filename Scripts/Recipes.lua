local MoreMagic = GameMain:GetMod("MoreMagic")
MoreMagic.Recipes = MoreMagic.Recipes or {}
local Recipes = MoreMagic.Recipes
local Regex = CS.System.Text.RegularExpressions.Regex
local MAX_COUNT_PER_FRAME = 10


local Infusion_Recipes = {
  [{".*","$n5",".*","$n5",".+:!fs","$n5",".*","$n5",".*"}] = {act = function (it, npc) it.FSItemState = 1 end, pri = 0},
}

local FuMo_Recipes = {
  [{".+",".+",".+",".+",".+:fabao",".+",".+",".+",".+"}] = {mod = "LDModifier_Test", pri = 0},
  
  [{".*",".*",".*",".*",".+:fabao",".*",".*",".*","Item_ShuiEssence"}] = {mod = "LDModifier_InstantFaint", pri = 5},
  [{"Item_HuoEssence:fs",".*","Item_HuoEssence:fs",".*",".+:fabao",".*","Item_HuoEssence:fs",".*","Item_HuoEssence:fs"}] = {mod = "LDModifier_JieCloudCrit", pri = 5},
  
  [{".*",".*",".*","Item_MonsterBlood:fs",".+:fabao","Item_MonsterBlood:fs",".*",".*",".*"}] = {mod = "LDModifier_FBBloodLust", pri = 1},
  [{".*","Item_MonsterBlood:fs",".*",".*",".+:fabao",".*",".*","Item_MonsterBlood:fs",".*"}] = {mod = "LDModifier_FBBloodLust", pri = 1},
  
  [{".*","Item_MonsterBlood:fs",".*",".*",".+:fabao",".*",".*",".*",".*"}] = {mod = "LDModifier_BloodLust", pri = 0},
  [{".*",".*",".*","Item_MonsterBlood:fs",".+:fabao",".*",".*",".*",".*"}] = {mod = "LDModifier_BloodLust", pri = 0},
  [{".*",".*",".*",".*",".+:fabao","Item_MonsterBlood:fs",".*",".*",".*"}] = {mod = "LDModifier_BloodLust", pri = 0},
  [{".*",".*",".*",".*",".+:fabao",".*",".*","Item_MonsterBlood:fs",".*"}] = {mod = "LDModifier_BloodLust", pri = 0},
  
}
local Predicates = {
  fs = function (x) return x.FSItemState > 0 end,
  fabao = function (x) return x.IsFaBao end,
}


--item是XiaWorld.ItemThing类，pattern是字符串。
function Recipes.ItemIsMatch(item, pattern)
  --item可能为-1，如果根本没有物品，则我们将其名称用空字符串来代替。
  local name = ""
  if item ~= -1 then name = item.def.Name or "" end
  --首先我们将输入的模板按照我规定的格式进行分割。
  local array = Regex.Split(pattern, "[:;]")
  local item_name_pattern = array[0]
  if not Regex.IsMatch(name, item_name_pattern) then --优先检测开头的物品名称模板，如果不通过则直接返回假，节约时间。
    return false
  else --如果名称通过，则我们检测冒号后面给出的模板。任意为假则直接返回假，只有全部为真才会返还真。
    if array.Length > 1 then
      for i=1,array.Length-1 do
        local pred_name = array[i]
        local op, pred, args = string.match(pred_name, "(!?)(%w+)(.*)")
        if pred and pred ~= "" then --如果没有标注函数名，我们认为没有设定限制，因此此项就返回真。只有标注了函数名才会继续判定。
          local func = Predicates[pred]
          if not func then --如果找不到对应的预测函数我们也返回假。
            return false
          else --有函数的情况下我们根据对应的运算符来取结果。
            t = {}
            for arg in string.gmatch(args, "%w+") do
              table.insert(t, arg)
            end
            if op == "" and not func(item, table.unpack(t)) then
              return false
            elseif op == "!" and func(item, table.unpack(t)) then
              return false
            end
          end
        end
      end
    end
    return true
  end
end

--items和recipe都是table类，前者元素为ItemThing，后者为String。
function Recipes.RecipeIsMatch(items, recipe)
  --我们需要考虑两个table大小不同时的情况，正确地索引内容。
  local d = #items - #recipe
  local diff = d/2
  for i,p in pairs(recipe) do
    local ind = i+diff
    local it = -1
    if ind > 0 and ind <= #items then it = items[ind] end
    if not Recipes.ItemIsMatch(it, p) then return false end
  end
  return true
end

--items和recipe都是table类，前者元素为ItemThing，后者为String。
function Recipes.ProcessRecipe(items, recipe)
  local d = #items - #recipe
  local diff = d/2
  local ret = {}
  for i,p in pairs(recipe) do
    local m1,m2 = string.match(p, "$(%a+)(%d+)")
    if m1 and m2 then
      if m1 == "n" then
        local ind = tonumber(m2)+diff
        local name = ""
        if ind > 0 and ind <= #items and items[ind] ~= -1 then name = items[ind].def.Name end
        ret[i] = string.gsub(p, "$%a+%d+", name, 1)
      elseif m1 == "i" then
        local ind = tonumber(m2)+diff
        local name = ""
        if ind > 0 and ind <= #items and items[ind] ~= -1 then name = items[ind].def.Name end
        ret[i] = string.gsub(recipe[tonumber(m2)], "[^:]+", name, 1)
      end
    else
      ret[i] = p
    end
  end
  return ret
end

--根据提供的配方类型type寻找满足条件的优先级最高的配方。（可以更新为协程，防止配方过多时的卡帧）
function Recipes.FindRecipe(items, type)
  local matches = {}
  local rec = Infusion_Recipes --不提供type参数时默认用合成配方表。
  if type == "FuMo" then
    rec = FuMo_Recipes
  end
  --遍历选定的配方表，获取所有匹配的配方。（我们提供一个count值，以限制每一帧可以遍历多少个配方。）
  local count = 0
  for r,_ in pairs(rec) do
    local tr = Recipes.ProcessRecipe(items, r)
    if Recipes.RecipeIsMatch(items, tr) then
      table.insert(matches, r)
    end
    count = count + 1
    if count >= MAX_COUNT_PER_FRAME then
      coroutine.yield(nil)
      count = 0
    end
  end
  --寻找优先级最高的那个，并返还。
  local ind = 0
  local highest = -1
  for i,r in pairs(matches) do
    local data = rec[r]
    if data.pri > highest then
      highest = data.pri
      ind = i
    end
  end
  return matches[ind]
end

--物品有可能多于配方必需，因此我们必须剔除那些多余的物品，防止他们被删除。中心的物品也同样要屏蔽，以免删除。
function Recipes.MaskRecipe(ids, recipe)
  local idd = {}
  for i,e in pairs(recipe) do
    if e == ".*" or i == math.ceil(#recipe/2) then idd[i] = -1 else idd[i] = ids[i] end
  end
  return idd
end

function Recipes.GetFuMoEffect(recipe)
  local data = FuMo_Recipes[recipe] or {}
  return data.mod
end

function Recipes.GetInfusionAction(recipe)
  local data = Infusion_Recipes[recipe] or {}
  return data.act
end