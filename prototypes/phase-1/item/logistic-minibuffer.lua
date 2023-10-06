local fns = {}

function fns.make_logistic_minibuffer_item(name, order, tint)
  return {
    type = "item",
    name = "logistic-minibuffer-"..name,
    icons =
    {
      -- Base
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer.png",
        icon_size = 64,
      },
      -- Mask
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer-mask.png",
        icon_size = 64,
        tint = tint,
      },
      -- Highlights
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer-highlights.png",
        icon_size = 64,
        tint = { 1, 1, 1, 0 }
      },
    },
    order = "d[minibuffer]-"..order.."["..name.."]",
    subgroup = "logistic-network",
    stack_size = 50,
    place_result = "logistic-minibuffer-"..name,
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend({
    fns.make_logistic_minibuffer_item("active-provider", "c", logistic_tanks.tint_logistic_storage_tank_active_provider),
  })
end

data:extend({
  fns.make_logistic_minibuffer_item("passive-provider", "c", logistic_tanks.tint_logistic_minibuffer_passive_provider ),
  --fns.make_logistic_minibuffer_item("storage", "c", logistic_tanks.tint_logistic_storage_tank_storage),
  fns.make_logistic_minibuffer_item("buffer", "d", logistic_tanks.tint_logistic_storage_tank_buffer),
  fns.make_logistic_minibuffer_item("requester", "e", logistic_tanks.tint_logistic_storage_tank_requester)
})

-- the minibuffer item icon was rendered at a bad resolution so replace it with a downscaled and sharpened version
data.raw.item["minibuffer"].icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer.png"
data.raw.item["minibuffer"].icon_size = 64