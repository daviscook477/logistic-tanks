local fns = {}

function fns.make_logistic_minibuffer_recipe(name)
  return {
    type = "recipe",
    name = "logistic-minibuffer-"..name,
    enabled = false,
    ingredients =
    {
      {"minibuffer", 1},
      {"advanced-circuit", 3},
      {"processing-unit", 1}
    },
    result = "logistic-minibuffer-"..name,
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend({
    fns.make_logistic_minibuffer_recipe("active-provider"),
  })
end

data:extend({
  fns.make_logistic_minibuffer_recipe("passive-provider"),
  --fns.make_logistic_minibuffer_recipe("storage"),
  --fns.make_logistic_minibuffer_recipe("buffer"),
  fns.make_logistic_minibuffer_recipe("requester")
})