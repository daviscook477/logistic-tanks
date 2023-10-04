local LogisticTankCopy = {}

---Converts a logistic tank's settings to a serialized tags format
---@param entity any the logistic tank main entity
---@return table the storable tag representation of this logistic tank's settings
function LogisticTankCopy.serialize(entity)
  local logistic_storage_tank = LogisticTank.from_entity(entity)
  if not logistic_storage_tank then return end
  local tags = {}
  tags.fluid_type = logistic_storage_tank.fluid_type
  tags.request_amount = logistic_storage_tank.request_amount
  return tags
end

---Applies serialized tags to a logistic tank's settings
---@param entity any the logistic tank main entity
---@param tags any storable tag representation of the settings to apply
function LogisticTankCopy.deserialize(entity, tags)
  local logistic_storage_tank = LogisticTank.from_entity(entity)
  if not logistic_storage_tank then return end
  logistic_storage_tank.request_amount = tags.request_amount
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end
  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.name = tags.fluid_type
  elseif fluid_box.name ~= tags.fluid_type then
    -- flying text
  else
    -- filters are already the same - noop
  end
  LogisticTank.update_request(logistic_storage_tank)
end

---Handles copying settings between requester tanks
---@param event EventData.on_entity_settings_pasted Event data
function LogisticTankCopy.on_entity_settings_pasted_self(event)
  if event.source.name ~= LogisticTank.prefix_tank.."requester" and event.source.name ~= LogisticTank.prefix_tank.."requester" then return end
  local tags = LogisticTankCopy.serialize(event.source)
  if tags then
    LogisticTankCopy.deserialize(event.destination, tags)
  end
end

---Handles copying settings between requester tanks and assembly machines
---@param event EventData.on_entity_settings_pasted Event data
function LogisticTankCopy.on_entity_settings_pasted_assembling_machine(event)
  if game.entity_prototypes[event.source.name].type ~= "assembling-machine" then return end
  local recipe = event.source.get_recipe()
  if not (recipe and recipe.ingredients) then return end
  local recipe_prototype = game.recipe_prototypes[recipe.name]
  -- no need to deal with expensive recipe nonsense when iterating ingredients in the LuaRecipe
  local pastes = {}
  for _, ingredient in pairs(recipe.ingredients) do
    if ingredient and ingredient.type == "fluid" then
      local fluid_per_craft = ingredient.amount
      local request_paste_multiplier = recipe_prototype.request_paste_multiplier
      local time_per_craft = recipe_prototype.energy / event.source.crafting_speed
      local paste_amount = math.floor(fluid_per_craft * request_paste_multiplier / time_per_craft)
      table.insert(pastes, {
        paste_type = ingredient.name,
        paste_amount = paste_amount
      })
    end
  end
  -- set the logistic tank filter accordingly
  if not pastes[1] then return end
  local logistic_storage_tank = LogisticTank.from_entity(event.destination)
  if not logistic_storage_tank then return end
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end
  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.fluid_type = pastes[1].paste_type
    logistic_storage_tank.request_amount = pastes[1].paste_amount
  elseif fluid_box.name ~= pastes[1].paste_type then
    -- flying text
    game.print({"logistic-tanks.cannot-switch-filter"})
  else
    -- filters are already the same - noop
    logistic_storage_tank.request_amount = pastes[1].paste_amount
  end
  LogisticTank.update_request(logistic_storage_tank)
end

--- Handles both copying settings between requester tanks and copying
--- from assembly machines to requester tanks
function LogisticTankCopy.on_entity_settings_pasted(event)
  if not (event.source and event.source.valid and event.destination and event.destination.valid) then return end
  if event.destination.name ~= LogisticTank.prefix_tank.."requester" and event.destination.name ~= LogisticTank.prefix_minibuffer.."requester" then return end
  LogisticTankCopy.on_entity_settings_pasted_self(event)
  LogisticTankCopy.on_entity_settings_pasted_assembling_machine(event)
end
script.on_event(defines.events.on_entity_settings_pasted, LogisticTankCopy.on_entity_settings_pasted)

return LogisticTankCopy