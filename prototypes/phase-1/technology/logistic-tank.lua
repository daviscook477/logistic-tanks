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
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-active-provider"},
      { type = "unlock-recipe", recipe = "logistic-minibuffer-passive-provider"},
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-storage"},
      --{ type = "unlock-recipe", recipe = "logistic-minibuffer-buffer"},
      { type = "unlock-recipe", recipe = "logistic-minibuffer-requester"},
    },
    prerequisites = { "logistic-system", "minibuffer" },
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