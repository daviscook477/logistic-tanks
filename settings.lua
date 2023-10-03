data:extend({
  -- Startup
  {
    type = "int-setting",
    name = "logistic-tanks-fluid-per-item",
    setting_type = "startup",
    default_value = 50,
    minimum_value = 10,
    maximum_value = 500,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "logistic-tanks-robots-require-barrel",
    setting_type = "startup",
    default_value = true,
    order = "b"
  },
})