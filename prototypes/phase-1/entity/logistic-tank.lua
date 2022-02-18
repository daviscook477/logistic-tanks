local fns = {}

function fns.deepcopy(table)
  local new_table = {}
  for k, v in pairs(table) do
    if type(v) == "table" then
      new_table[k] = fns.deepcopy(v)
    else
      new_table[k] = v
    end
  end
  return new_table
end

local tank_passive_provider = fns.deepcopy(data.raw["storage-tank"]["storage-tank"])
tank_passive_provider.name = "logistic-storage-tank-passive-provider"

local tank_requester = fns.deepcopy(data.raw["storage-tank"]["storage-tank"])
tank_requester.name = "logistic-storage-tank-requester"

local chest_passive_provider = fns.deepcopy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
chest_passive_provider.name = "logistic-storage-tank-logistic-chest-passive-provider"
chest_passive_provider.collision_mask = {}

local chest_requester = fns.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
chest_requester.name = "logistic-storage-tank-logistic-chest-requester"
chest_requester.collision_mask = {}

data:extend({
  tank_passive_provider,
  tank_requester,
  chest_passive_provider,
  chest_requester,
  {
    type = "item",
    name = "logistic-storage-tank-passive-provider",
    icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
    icon_size = 64, icon_mipmaps = 4,
    order = "j-a",
    subgroup = "rocket-logistics",
    stack_size = 20,
    place_result = "logistic-storage-tank-passive-provider",
  },
  {
    type = "item",
    name = "logistic-storage-tank-requester",
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    icon_size = 64, icon_mipmaps = 4,
    order = "j-a",
    subgroup = "rocket-logistics",
    stack_size = 20,
    place_result = "logistic-storage-tank-requester",
  },
})