local fns = {}

function fns.make_logistic_storage_tank_item(name, order, tint)
  return {
    type = "item",
    name = "logistic-storage-tank-"..name,
    icons =
    {
      -- Base
      {
        icon = "__base__/graphics/icons/storage-tank.png",
        icon_size = 64,
        icon_mipmaps = 4,
      },
      -- Mask
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-tank/storage-tank-icon-mask.png",
        icon_size = 64,
        icon_mipmaps = 4,
        tint = tint,
      },
      -- Highlights
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-tank/storage-tank-icon-highlights.png",
        icon_size = 64,
        icon_mipmaps = 4,
        tint = { 1, 1, 1, 0 }
      },
    },
    order = "c[tank]-"..order.."["..name.."]",
    subgroup = "logistic-network",
    stack_size = 20,
    place_result = "logistic-storage-tank-"..name,
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend({
    fns.make_logistic_storage_tank_item("active-provider", "c", logistic_tanks.tint_logistic_storage_tank_active_provider),
  })
end

data:extend({
  fns.make_logistic_storage_tank_item("passive-provider", "c", logistic_tanks.tint_logistic_storage_tank_passive_provider),
  --fns.make_logistic_storage_tank_item("storage", "c", logistic_tanks.tint_logistic_storage_tank_storage),
  fns.make_logistic_storage_tank_item("buffer", "d", logistic_tanks.tint_logistic_storage_tank_buffer),
  fns.make_logistic_storage_tank_item("requester", "e", logistic_tanks.tint_logistic_storage_tank_requester)
})