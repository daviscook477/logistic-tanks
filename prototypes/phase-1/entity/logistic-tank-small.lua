local fns = {}

function fns.deepcopy(table)
  local new_table = {}
  for k, v in pairs(table) do
    if type(v) == "table" then
      new_table[k] = fns.deepcopy(v)
    else
      new_table[k] = v
    end
  end
  return new_table
end

function fns.make_minibuffer_entity(name, tint)
  local minibuffer_entity = fns.deepcopy(data.raw["storage-tank"]["minibuffer"])
  minibuffer_entity.name = "minibuffer-"..name
  table.insert(minibuffer_entity.pictures.picture.north.layers, 2, {
    filename = "__logistic-tanks__/graphics/entity/logistic-tank-small/north-minibuffer-mask.png",
    priority = "extra-high",
    width = 960,
    height = 960,
    scale = 0.5,
    tint = tint,
  })
  table.insert(minibuffer_entity.pictures.picture.east.layers, 2, {
    filename = "__logistic-tanks__/graphics/entity/logistic-tank-small/east-minibuffer-mask.png",
    priority = "extra-high",
    width = 960,
    height = 960,
    scale = 0.5,
    tint = tint,
  })
  --minibuffer_entity.corpse = "minibuffer-"..name.."-remnants"
  minibuffer_entity.minable.result = "minibuffer-"..name
  return minibuffer_entity
end

function fns.make_minibuffer(name, tint)
  return {
    fns.make_minibuffer_entity(name, tint),
  }
end

--data:extend(fns.make_minibuffer("active-provider", logistic_tanks.tint_logistic_storage_tank_active_provider))
data:extend(fns.make_minibuffer("passive-provider", logistic_tanks.tint_minibuffer_passive_provider))
--data:extend(fns.make_minibuffer("storage", logistic_tanks.tint_logistic_storage_tank_storage))
--data:extend(fns.make_minibuffer("buffer", logistic_tanks.tint_logistic_storage_tank_buffer))

local minibuffer_requester = fns.make_minibuffer("requester", logistic_tanks.tint_logistic_storage_tank_requester)
-- Allow copy/paste requests between requester tanks using the on_entity_settings_pasted event
minibuffer_requester[1].additional_pastable_entities = { "logistic-storage-tank-requester", "minibuffer-requester" }
data:extend(minibuffer_requester)