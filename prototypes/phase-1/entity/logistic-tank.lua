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
tank_passive_provider.pictures.picture.sheets =
{
  {
    filename = "__base__/graphics/entity/storage-tank/hr-storage-tank.png",
    priority = "extra-high",
    frames = 2,
    width = 219,
    height = 215,
    shift = util.by_pixel(-0.25, 3.75),
    scale = 0.5,
  },
  {
    filename = "__logistic-tanks__/graphics/entity/logistic-tank/hr-storage-tank-tint.png",
    priority = "extra-high",
    frames = 2,
    width = 219,
    height = 215,
    shift = util.by_pixel(-0.25, 3.75),
    scale = 0.5,
    tint = {r=1.0, g=0.318, b=0.435, a=1.0},
  },
  {
    filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
    priority = "extra-high",
    frames = 2,
    width = 146,
    height = 77,
    shift = util.by_pixel(30, 22.5),
    draw_as_shadow = true,
    hr_version =
    {
      filename = "__base__/graphics/entity/storage-tank/hr-storage-tank-shadow.png",
      priority = "extra-high",
      frames = 2,
      width = 291,
      height = 153,
      shift = util.by_pixel(29.75, 22.25),
      scale = 0.5,
      draw_as_shadow = true
    }
  }
}

local tank_requester = fns.deepcopy(tank_passive_provider)
tank_requester.name = "logistic-storage-tank-requester"
tank_requester.pictures.picture.sheets[2].tint = {r=0.42, g=0.69, b=1.0, a=1.0}

local chest_passive_provider = fns.deepcopy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
chest_passive_provider.name = "logistic-storage-tank-logistic-chest-passive-provider"
chest_passive_provider.inventory_size = 51
chest_passive_provider.collision_mask = {}

local chest_requester = fns.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
chest_requester.name = "logistic-storage-tank-logistic-chest-requester"
chest_requester.inventory_size = 51
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
    subgroup = "logistic-network",
    stack_size = 20,
    place_result = "logistic-storage-tank-passive-provider",
  },
  {
    type = "item",
    name = "logistic-storage-tank-requester",
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    icon_size = 64, icon_mipmaps = 4,
    order = "j-a",
    subgroup = "logistic-network",
    stack_size = 20,
    place_result = "logistic-storage-tank-requester",
  },
})