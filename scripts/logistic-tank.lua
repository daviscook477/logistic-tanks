local LogisticTank = {}

LogisticTank.prefix_tank = "logistic-storage-tank-"
LogisticTank.prefix_chest = "logistic-storage-tank-logistic-chest-"
LogisticTank.suffixes = { "active-provider", "passive-provider", "storage", "buffer", "requester" }
LogisticTank.suffixes_request = { "storage", "buffer", "requester" }

LogisticTank.chest_map = {}
LogisticTank.filters = {}
LogisticTank.logistic_storage_tank_chest_names = {}
for _, suffix in pairs(LogisticTank.suffixes) do
  local logistic_storage_tank_name = LogisticTank.prefix_tank..suffix
  local logistic_storage_tank_chest_name = LogisticTank.prefix_chest..suffix
  LogisticTank.chest_map[logistic_storage_tank_name] =logistic_storage_tank_chest_name
  table.insert(LogisticTank.filters, {
    filter = "name",
    name = logistic_storage_tank_name,
  })
  table.insert(LogisticTank.logistic_storage_tank_chest_names, logistic_storage_tank_chest_name)
end

function string.starts(str, start)
  return string.sub(str, 1 ,string.len(start)) == start
end

function LogisticTank.from_unit_number(unit_number)
  if not unit_number then return end
  unit_number = tonumber(unit_number)
  return global.logistic_storage_tanks[unit_number]
end

function LogisticTank.from_entity(entity)
  if not (entity and entity.valid) then return end
  return LogisticTank.from_unit_number(entity.unit_number)
end

function LogisticTank.find_entity_or_revive_ghost(surface, name, position, radius)
  local entities = surface.find_entities_filtered{
    name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entities[1] then return entities[1] end

  local entity_ghosts = surface.find_entities_filtered{
    ghost_name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entity_ghosts[1] then
    local _, entity = entity_ghosts[1].revive({})
    if entity then return entity end
  end
end

function LogisticTank.on_entity_created(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if event.created_entity and event.created_entity.valid then
    entity = event.created_entity
  end
  if event.destination and event.destination.valid then
    entity = event.destination
  end
  
  if not entity then return end
  if not string.starts(entity.name, LogisticTank.prefix_tank) then return end

  local logistic_storage_tank = {
    unit_number = entity.unit_number,
    main = entity,
    last_item_count = 0,
    fluid_type = nil,
    request_amount = 0,
  }

  global.logistic_storage_tanks[entity.unit_number] = logistic_storage_tank

  logistic_storage_tank.chest = LogisticTank.find_entity_or_revive_ghost(entity.surface, LogisticTank.logistic_storage_tank_chest_names, entity.position)
  if not logistic_storage_tank.chest then
    logistic_storage_tank.chest = entity.surface.create_entity{
      name = LogisticTank.chest_map[entity.name],
      force = entity.force,
      position = {entity.position.x, entity.position.y}
    }
  end
  logistic_storage_tank.chest.destructible = false
end
script.on_event(defines.events.on_entity_cloned, LogisticTank.on_entity_created, LogisticTank.filters)
script.on_event(defines.events.on_built_entity, LogisticTank.on_entity_created, LogisticTank.filters)
script.on_event(defines.events.on_robot_built_entity, LogisticTank.on_entity_created, LogisticTank.filters)
script.on_event(defines.events.script_raised_built, LogisticTank.on_entity_created, LogisticTank.filters)
script.on_event(defines.events.script_raised_revive, LogisticTank.on_entity_created, LogisticTank.filters)


function LogisticTank.destroy_sub(logistic_storage_tank, key)
  if logistic_storage_tank[key] and logistic_storage_tank[key].valid then
    logistic_storage_tank[key].destroy()
    logistic_storage_tank[key] = nil
  end
end

function LogisticTank.destroy(logistic_storage_tank)
  LogisticTank.destroy_sub(logistic_storage_tank, "main")
  LogisticTank.destroy_sub(logistic_storage_tank, "chest")
  global.logistic_storage_tanks[logistic_storage_tank.unit_number] = nil
end

function LogisticTank.on_entity_destroyed(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if not string.starts(entity.name, LogisticTank.prefix_tank) then return end

  LogisticTank.destroy(LogisticTank.from_entity(entity))
end
script.on_event(defines.events.on_entity_died, LogisticTank.on_entity_destroyed, LogisticTank.filters)
script.on_event(defines.events.on_robot_mined_entity, LogisticTank.on_entity_destroyed, LogisticTank.filters)
script.on_event(defines.events.on_player_mined_entity, LogisticTank.on_entity_destroyed, LogisticTank.filters)
script.on_event(defines.events.script_raised_destroy, LogisticTank.on_entity_destroyed, LogisticTank.filters)

function LogisticTank.update_request(logistic_storage_tank)
  if not logistic_storage_tank then return end

  local chest = logistic_storage_tank.chest
  if not (chest and chest.valid) then return LogisticTank.destroy(logistic_storage_tank) end

  local logistic_point = chest.get_logistic_point(defines.logistic_member_index.logistic_container)
  if not logistic_point then return end
  if logistic_point.mode == defines.logistic_mode.storage then
    
  elseif logistic_point.mode == defines.logistic_mode.requester or logistic_point.mode == defines.logistic_mode.buffer then
    if logistic_storage_tank.fluid_type and logistic_storage_tank.request_amount > 0 then
      chest.set_request_slot({name = fluid_equivalent_prefix..logistic_storage_tank.fluid_type, count = logistic_storage_tank.request_amount/50} , 1)
    else
      chest.clear_request_slot(1)
    end
  end
end


function LogisticTank.equalize_inventory(logistic_storage_tank)
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end
  local chest = logistic_storage_tank.chest
  if not (chest and chest.valid) then return LogisticTank.destroy(logistic_storage_tank) end
  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  local fluid_count = 0
  if fluid_box then
    fluid_count = fluid_count + fluid_box.amount
    logistic_storage_tank.fluid_type = fluid_box.name
  end
  local inventory = chest.get_inventory(defines.inventory.chest)
  local item_count = 0
  if logistic_storage_tank.fluid_type then
    item_count = inventory.get_item_count(fluid_equivalent_prefix..logistic_storage_tank.fluid_type)
  end
  local equivalent_item_count = item_count * 50

  local total_count = fluid_count + equivalent_item_count
  local average_count = total_count / 2

  local new_item_count = math.floor(average_count / 50)
  local new_equivalent_item_count = new_item_count * 50
  local new_fluid_count = total_count - new_equivalent_item_count
  if fluid_box then
    if new_fluid_count > 0 then
      fluid_box.amount = new_fluid_count
      fluid_boxes[1] = fluid_box
    else
      fluid_boxes[1] = nil
    end
  elseif logistic_storage_tank.fluid_type then
    if new_fluid_count > 0 then
      fluid_boxes[1] = {
        name = logistic_storage_tank.fluid_type,
        amount = new_fluid_count
      }
    else
      fluid_boxes[1] = nil
    end
  else
    return
  end

  local delta_item_count = new_item_count - item_count
  if delta_item_count > 0 then
    inventory.insert({ name = fluid_equivalent_prefix..logistic_storage_tank.fluid_type, count = delta_item_count })
  elseif delta_item_count < 0 then
    inventory.remove({ name = fluid_equivalent_prefix..logistic_storage_tank.fluid_type, count = -delta_item_count })
  end
end

function LogisticTank.on_tick(event)
  for _, logistic_storage_tank in pairs(global.logistic_storage_tanks) do
    if (event.tick + logistic_storage_tank.unit_number) % 60 == 0 then
      LogisticTank.equalize_inventory(logistic_storage_tank)
    end
  end
end
script.on_event(defines.events.on_tick, LogisticTank.on_tick)

function LogisticTank.on_init(event)
  global.logistic_storage_tanks = {}
end
script.on_init(LogisticTank.on_init)

return LogisticTank