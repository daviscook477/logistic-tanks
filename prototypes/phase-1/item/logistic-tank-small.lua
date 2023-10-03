local fns = {}

function fns.make_minibuffer_item(name, order, tint)
  return {
    type = "item",
    name = "minibuffer-"..name,
    icons =
    {
      -- Base
      {
        icon = "__extra-storage-tank-minibuffer__/graphics/icons/icon-minibuffer.png",
        icon_size = 144,
      },
      -- Mask
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-tank-small/icon-minibuffer-mask.png",
        icon_size = 144,
        tint = tint,
      },
    },
    order = "d[minibuffer]-"..order.."["..name.."]",
    subgroup = "logistic-network",
    stack_size = 50,
    place_result = "minibuffer-"..name,
  }
end

data:extend({
  --fns.make_logistic_storage_tank_item("active-provider", "c", logistic_tanks.tint_logistic_storage_tank_active_provider),
  fns.make_minibuffer_item("passive-provider", "c", logistic_tanks.tint_minibuffer_passive_provider ),
  --fns.make_logistic_storage_tank_item("storage", "c", logistic_tanks.tint_logistic_storage_tank_storage),
  --fns.make_logistic_storage_tank_item("buffer", "d", logistic_tanks.tint_logistic_storage_tank_buffer),
  fns.make_minibuffer_item("requester", "e", logistic_tanks.tint_logistic_storage_tank_requester)
})