local fns = {}

function fns.make_logistic_minibuffer_item(name, order, tint)
  return {
    type = "item",
    name = "logistic-minibuffer-"..name,
    icons =
    {
      -- Base
      {
        icon = "__extra-storage-tank-minibuffer__/graphics/icons/icon-minibuffer.png",
        icon_size = 144,
      },
      -- Mask
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer-mask.png",
        icon_size = 144,
        tint = tint,
      },
      -- Highlights
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer-highlights.png",
        icon_size = 144,
        tint = { 1, 1, 1, 0 }
      },
    },
    order = "d[minibuffer]-"..order.."["..name.."]",
    subgroup = "logistic-network",
    stack_size = 50,
    place_result = "logistic-minibuffer-"..name,
  }
end

data:extend({
  --fns.make_logistic_minibuffer_item("active-provider", "c", logistic_tanks.tint_logistic_storage_tank_active_provider),
  fns.make_logistic_minibuffer_item("passive-provider", "c", logistic_tanks.tint_logistic_minibuffer_passive_provider ),
  --fns.make_logistic_minibuffer_item("storage", "c", logistic_tanks.tint_logistic_storage_tank_storage),
  --fns.make_logistic_minibuffer_item("buffer", "d", logistic_tanks.tint_logistic_storage_tank_buffer),
  fns.make_logistic_minibuffer_item("requester", "e", logistic_tanks.tint_logistic_storage_tank_requester)
})