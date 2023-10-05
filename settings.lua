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
  {
    type = "bool-setting",
    name = "logistic-tanks-enable-active-provider",
    setting_type = "startup",
    default_value = false,
    order = "c"
  },
  -- Runtime global
  {
    type = "int-setting",
    name = "logistic-tanks-updates-per-tick",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 100,
    order = "d"
},
})