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

function fns.make_logistic_minibuffer_entity(name, tint)
  local logistic_minibuffer_entity = fns.deepcopy(data.raw["storage-tank"]["minibuffer"])
  logistic_minibuffer_entity.name = "logistic-minibuffer-"..name
  table.insert(logistic_minibuffer_entity.pictures.picture.north.layers, 2, {
    filename = "__logistic-tanks__/graphics/entity/logistic-minibuffer/north-minibuffer-mask.png",
    priority = "extra-high",
    width = 960,
    height = 960,
    scale = 0.5,
    tint = tint,
  })
  table.insert(logistic_minibuffer_entity.pictures.picture.east.layers, 2, {
    filename = "__logistic-tanks__/graphics/entity/logistic-minibuffer/east-minibuffer-mask.png",
    priority = "extra-high",
    width = 960,
    height = 960,
    scale = 0.5,
    tint = tint,
  })
  --logistic_minibuffer_entity.corpse = "logistic-minibuffer-"..name.."-remnants"
  logistic_minibuffer_entity.minable.result = "logistic-minibuffer-"..name
  return logistic_minibuffer_entity
end

function fns.make_logistic_minibuffer(name, tint)
  return {
    fns.make_logistic_minibuffer_entity(name, tint),
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend(fns.make_logistic_minibuffer("active-provider", logistic_tanks.tint_logistic_storage_tank_active_provider))
end
data:extend(fns.make_logistic_minibuffer("passive-provider", logistic_tanks.tint_logistic_minibuffer_passive_provider))
--data:extend(fns.make_logistic_minibuffer("storage", logistic_tanks.tint_logistic_storage_tank_storage))
--data:extend(fns.make_logistic_minibuffer("buffer", logistic_tanks.tint_logistic_storage_tank_buffer))

local logistic_minibuffer_requester = fns.make_logistic_minibuffer("requester", logistic_tanks.tint_logistic_storage_tank_requester)
-- Allow copy/paste requests between requester tanks using the on_entity_settings_pasted event
logistic_minibuffer_requester[1].additional_pastable_entities = { "logistic-storage-tank-requester", "logistic-minibuffer-requester" }
data:extend(logistic_minibuffer_requester)