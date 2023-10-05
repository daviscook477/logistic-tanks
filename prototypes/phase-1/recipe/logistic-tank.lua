local fns = {}

function fns.make_logistic_storage_tank_recipe(name)
  return {
    type = "recipe",
    name = "logistic-storage-tank-"..name,
    enabled = false,
    ingredients =
    {
      {"storage-tank", 1},
      {"advanced-circuit", 3},
      {"processing-unit", 1}
    },
    result = "logistic-storage-tank-"..name,
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend({
    fns.make_logistic_storage_tank_recipe("active-provider"),
  })
end

data:extend({
  fns.make_logistic_storage_tank_recipe("passive-provider"),
  --fns.make_logistic_storage_tank_recipe("storage"),
  --fns.make_logistic_storage_tank_recipe("buffer"),
  fns.make_logistic_storage_tank_recipe("requester")
})