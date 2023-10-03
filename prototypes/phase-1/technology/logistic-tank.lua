data:extend({
  {
    type = "technology",
    name = "logistic-fluids",
    icon_size = 256,
    icon_mipmaps = 4,
    icon = "__base__/graphics/technology/logistic-system.png",
    effects = {
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-active-provider"},
      { type = "unlock-recipe", recipe = "logistic-storage-tank-passive-provider"},
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-storage"},
      --{ type = "unlock-recipe", recipe = "logistic-storage-tank-buffer"},
      { type = "unlock-recipe", recipe = "logistic-storage-tank-requester"},
    },
    prerequisites = { "utility-science-pack","logistic-robotics" },
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
  }
})