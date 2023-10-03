local fns = {}

function fns.make_minibuffer_recipe(name)
  return {
    type = "recipe",
    name = "minibuffer-"..name,
    enabled = false,
    ingredients =
    {
      {"minibuffer", 1},
      {"advanced-circuit", 3},
      {"processing-unit", 1}
    },
    result = "minibuffer-"..name,
  }
end

data:extend({
  --fns.make_minibuffer_recipe("active-provider"),
  fns.make_minibuffer_recipe("passive-provider"),
  --fns.make_minibuffer_recipe("storage"),
  --fns.make_minibuffer_recipe("buffer"),
  fns.make_minibuffer_recipe("requester")
})