data:extend({
  {
    type = "technology",
    name = "logistic-fluids",
    icon_size = 256,
    icon = "__logistic-tanks__/graphics/technology/logistic-storage-tank.png",
    effects = {
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-active-provider"},
      { type = "unlock-recipe", recipe = "logistic-storage-tank-passive-provider"},
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-storage"},
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-buffer"},
      { type = "unlock-recipe", recipe = "logistic-storage-tank-requester"},
    },
    prerequisites = { "logistic-system" },
    unit = {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    order = "c-k-e"
  },
  {
    type = "technology",
    name = "logistic-minibuffer",
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
        tint = logistic_tanks.tint_logistic_minibuffer_passive_provider,
      },
      -- Highlights
      {
        icon = "__logistic-tanks__/graphics/icons/logistic-minibuffer/icon-minibuffer-highlights.png",
        icon_size = 144,
        tint = { 1, 1, 1, 0 }
      },
    },
    icon = "__logistic-tanks__/graphics/technology/logistic-storage-tank.png",
    effects = {
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-active-provider"},
      { type = "unlock-recipe", recipe = "logistic-minibuffer-passive-provider"},
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-storage"},
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-buffer"},
      { type = "unlock-recipe", recipe = "logistic-minibuffer-requester"},
    },
    prerequisites = { "logistic-fluids", "minibuffer" },
    unit = {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    order = "c-k-f"
  },
})