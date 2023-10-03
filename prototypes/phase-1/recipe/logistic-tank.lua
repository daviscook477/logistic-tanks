local fns = {}

function fns.make_logistic_storage_tank_recipe(name)
  return {
    type = "recipe",
    name = "logistic-storage-tank-"..name,
    enabled = false,
    ingredients =
    {
      {"storage-tank", 1},
      {"electronic-circuit", 3},
      {"advanced-circuit", 1}
    },
    result = "logistic-storage-tank-"..name,
  }
end

data:extend({
  fns.make_logistic_storage_tank_recipe("active-provider"),
  fns.make_logistic_storage_tank_recipe("passive-provider"),
  fns.make_logistic_storage_tank_recipe("storage"),
  fns.make_logistic_storage_tank_recipe("buffer"),
  fns.make_logistic_storage_tank_recipe("requester")
})