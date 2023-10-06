local LogisticTankCopy = {}

local fns = {}

function fns.table_contains(table, target)
  for _, item in pairs(table) do
    if item == target then return true end
  end
  return false
end

---Converts a logistic tank's settings to a serialized tags format
---@param entity any the logistic tank main entity
---@return table the storable tag representation of this logistic tank's settings
function LogisticTankCopy.serialize(entity)
  local logistic_storage_tank = LogisticTank.from_entity(entity)
  if not logistic_storage_tank then return end
  local tags = {}
  tags.fluid_type = logistic_storage_tank.fluid_type
  tags.request_amount = logistic_storage_tank.request_amount

  -- request from buffers is only available on actual requester tanks
  if logistic_storage_tank.chest and logistic_storage_tank.chest.valid and logistic_storage_tank.main and logistic_storage_tank.main.valid and fns.table_contains(LogisticTankGUI.logistic_storage_tank_requester_names, logistic_storage_tank.main.name) then
    tags.request_from_buffers = logistic_storage_tank.chest.request_from_buffers
  end

  return tags
end

---Applies serialized tags to a logistic tank's settings
---@param entity any the logistic tank main entity
---@param tags any storable tag representation of the settings to apply
function LogisticTankCopy.deserialize(entity, tags)
  local logistic_storage_tank = LogisticTank.from_entity(entity)
  if not logistic_storage_tank then return end
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end

  local amount = tags.request_amount
  amount = math.min(amount, game.entity_prototypes[entity.name].fluid_capacity)

  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.fluid_type = tags.fluid_type
    logistic_storage_tank.request_amount = amount
  elseif fluid_box.name ~= tags.fluid_type then
    -- flying text
    game.print({"logistic-tanks.cannot-switch-filter"})
  else
    -- filters are already the same - noop
    logistic_storage_tank.request_amount = amount
  end
  LogisticTank.update_request(logistic_storage_tank)

  -- request from buffers is only available on actual requester tanks
  if logistic_storage_tank.chest and logistic_storage_tank.chest.valid and fns.table_contains(LogisticTankGUI.logistic_storage_tank_requester_names, main.name) then
    logistic_storage_tank.chest.request_from_buffers = tags.request_from_buffers or false
  end
end

---Handles copying settings between requester tanks
---@param event EventData.on_entity_settings_pasted Event data
function LogisticTankCopy.on_entity_settings_pasted_self(event)
  if not fns.table_contains(LogisticTankGUI.logistic_storage_tank_request_names, event.source.name) then return end
  local tags = LogisticTankCopy.serialize(event.source)
  if tags then
    local logistic_storage_tank = LogisticTank.from_entity(event.destination)
    if not logistic_storage_tank then return end

    -- perform an equalize in case fluid was already delivered to the internal logistic chest but wasn't reflected in the tank yet
    -- we don't want to be able to set the filter to a different fluid if this has happened since that would cause us to lose fluid
    LogisticTank.equalize_inventory(logistic_storage_tank)

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

  -- perform an equalize in case fluid was already delivered to the internal logistic chest but wasn't reflected in the tank yet
  -- we don't want to be able to set the filter to a different fluid if this has happened since that would cause us to lose fluid
  LogisticTank.equalize_inventory(logistic_storage_tank)

  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end

  -- clamp the request at maximum by the capacity of the requester tank
  local amount = pastes[1].paste_amount
  amount = math.min(amount, game.entity_prototypes[event.destination.name].fluid_capacity)

  -- clamp the request at minimum by 1
  amount = math.max(amount, 1)

  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.fluid_type = pastes[1].paste_type
    logistic_storage_tank.request_amount = amount
  elseif fluid_box.name ~= pastes[1].paste_type then
    -- flying text
    game.print({"logistic-tanks.cannot-switch-filter"})
  else
    -- filters are already the same - noop
    logistic_storage_tank.request_amount = amount
  end
  LogisticTank.update_request(logistic_storage_tank)
end

---Handles saving the settings of a requester tank to the blueprint when it is constructed
---@param event EventData.on_player_setup_blueprint Event data
function LogisticTankCopy.on_player_setup_blueprint(event)
  local player_index = event.player_index
  if not (player_index and game.get_player(player_index) and game.get_player(player_index).connected) then return end
  local player = game.get_player(player_index)

  -- this setup code and checks is a workaround for the fact that the event doesn't specify the blueprint on the event
  -- and the player.blueprint_to_setup isn't actually set in the case of copy/paste or blueprint library or select new contents
  local blueprint = nil
  if player and player.blueprint_to_setup and player.blueprint_to_setup.valid_for_read then blueprint = player.blueprint_to_setup
  elseif player and player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint then blueprint = player.cursor_stack end
  if not (blueprint and blueprint.is_blueprint_setup()) then return end

  local mapping = event.mapping.get()
  local blueprint_entities = blueprint.get_blueprint_entities()
  if blueprint_entities then
    for _, blueprint_entity in pairs(blueprint_entities) do
      if fns.table_contains(LogisticTankGUI.logistic_storage_tank_request_names, blueprint_entity.name) then
        local entity = mapping[blueprint_entity.entity_number]
        if entity then
          local tags = LogisticTankCopy.serialize(entity)
          if tags then
            blueprint.set_blueprint_entity_tags(blueprint_entity.entity_number, tags)
          end
        end
      end
    end
  end
end
script.on_event(defines.events.on_player_setup_blueprint, LogisticTankCopy.on_player_setup_blueprint)

---Handles both copying settings between requester tanks and copying
---from assembly machines to requester tanks
function LogisticTankCopy.on_entity_settings_pasted(event)
  if not (event.source and event.source.valid and event.destination and event.destination.valid) then return end
  if not fns.table_contains(LogisticTankGUI.logistic_storage_tank_request_names, event.destination.name) then return end
  LogisticTankCopy.on_entity_settings_pasted_self(event)
  LogisticTankCopy.on_entity_settings_pasted_assembling_machine(event)
end
script.on_event(defines.events.on_entity_settings_pasted, LogisticTankCopy.on_entity_settings_pasted)

return LogisticTankCopy