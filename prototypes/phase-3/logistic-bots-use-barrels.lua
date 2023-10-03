local fns = {}

function fns.table_contains(table, target)
  for _, item in pairs(table) do
    if item == target then return true end
  end
  return false
end

function fns.add_barrel(recipe_prototype)
  if recipe_prototype.normal and recipe_prototype.expensive then
    table.insert(recipe_prototype.normal, { "empty-barrel", 1 })
    table.insert(recipe_prototype.expensive, { "empty-barrel", 2 })
  elseif recipe_prototype.normal then
    table.insert(recipe_prototype.normal, { "empty-barrel", 1 })
  elseif recipe_prototype.expensive then
    table.insert(recipe_prototype.expensive, { "empty-barrel", 1 })
  else
    table.insert(recipe_prototype.ingredients, { "empty-barrel", 1 })
  end
end

-- Logistic bots should have barrels in their recipe since they can now carry liquids directly
-- Search all recipes for ones that produce logistic robots in order to support modded robots
local logistic_robots = data.raw["logistic-robot"]
local logistic_robot_names = {}
for logistic_robot_name, logistic_robot_prototype in pairs(logistic_robots) do
  table.insert(logistic_robot_names, logistic_robot_name)
end

local recipes  = data.raw.recipe
for _, recipe_prototype in pairs(recipes) do
  if recipe_prototype.result then
    if fns.table_contains(logistic_robot_names, recipe_prototype.result) then
      fns.add_barrel(recipe_prototype)
    end
  elseif recipe_prototype.results then
    local added_barrel = false
    for _, result in pairs(recipe_prototype.results) do
      if (not added_barrel) and fns.table_contains(logistic_robot_names, result) then
        fns.add_barrel(recipe_prototype)
        added_barrel = true
      end
    end
  end
end