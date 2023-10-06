local effects_logistic_fluids = {
  { type = "unlock-recipe", recipe = "logistic-storage-tank-passive-provider"},
  --{ type = "unlock-recipe", recipe = "logistic-storage-tank-storage"},
  { type = "unlock-recipe", recipe = "logistic-storage-tank-buffer"},
  { type = "unlock-recipe", recipe = "logistic-storage-tank-requester"},
}

local effects_logistic_minibuffers = {
  { type = "unlock-recipe", recipe = "logistic-minibuffer-passive-provider"},
  --{ type = "unlock-recipe", recipe = "logistic-minibuffer-storage"},
  { type = "unlock-recipe", recipe = "logistic-minibuffer-buffer"},
  { type = "unlock-recipe", recipe = "logistic-minibuffer-requester"},
}

if settings.startup["logistic-tanks-enable-active-provider"].value then
  table.insert(effects_logistic_fluids, { type = "unlock-recipe", recipe = "logistic-storage-tank-active-provider"})
  table.insert(effects_logistic_minibuffers, { type = "unlock-recipe", recipe = "logistic-minibuffer-active-provider"})
end

data:extend({
  {
    type = "technology",
    name = "logistic-fluids",
    icon_size = 256,
    icon = "__logistic-tanks__/graphics/technology/logistic-storage-tank.png",
    effects = effects_logistic_fluids,
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
        icon = "__logistic-tanks__/graphics/technology/minibuffer.png",
        icon_size = 256,
      },
      -- Mask
      {
        icon = "__logistic-tanks__/graphics/technology/minibuffer-mask.png",
        icon_size = 256,
        tint = logistic_tanks.tint_logistic_storage_tank_requester,
      },
    },
    icon = "__logistic-tanks__/graphics/technology/logistic-storage-tank.png",
    effects = effects_logistic_minibuffers,
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

-- the minibuffer technology icon was rendered at a bad resolution so replace it with an upscaled and sharpened version
data.raw.technology["minibuffer"].icon = "__logistic-tanks__/graphics/technology/minibuffer.png"
data.raw.technology["minibuffer"].icon_size = 256