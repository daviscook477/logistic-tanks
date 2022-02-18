local fns = {}

local name_tank_passive_provider = "logistic-storage-tank-passive-provider"
local name_chest_passive_provider = "logistic-storage-tank-logistic-chest-passive-provider"
local name_tank_requester = "logistic-storage-tank-requester"
local name_chest_requester = "logistic-storage-tank-logistic-chest-requester"
local name_gui_root = "logistic-storage-tank-filter"
local tick_update = 6

local chest_map = {
  [name_tank_passive_provider] = name_chest_passive_provider,
  [name_tank_requester] = name_chest_requester
}

local filters = {{filter = "name", name = name_tank_passive_provider}, {filter = "name", name = name_tank_requester}}

function fns.from_unit_number(unit_number)
  if not unit_number then return end
  unit_number = tonumber(unit_number)
  return global.logistic_storage_tanks[unit_number]
end

function fns.from_entity(entity)
  if not (entity and entity.valid) then return end
  return fns.from_unit_number(entity.unit_number)
end

function fns.find_entity_or_revive_ghost(surface, name, position, radius)
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

function fns.on_entity_created(event)
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
  if entity.name ~= name_tank_passive_provider and entity.name ~= name_tank_requester then return end

  local logistic_storage_tank = {
    unit_number = entity.unit_number,
    main = entity,
    last_item_count = 0,
    fluid_type = nil,
    request_amount = 0,
  }

  global.logistic_storage_tanks[entity.unit_number] = logistic_storage_tank

  logistic_storage_tank.chest = fns.find_entity_or_revive_ghost(entity.surface, name_chest_passive_provider, entity.position)
  if not logistic_storage_tank.chest then
    logistic_storage_tank.chest = entity.surface.create_entity{
      name = chest_map[entity.name],
      force = entity.force,
      position = {entity.position.x, entity.position.y}
    }
  end
  logistic_storage_tank.chest.destructible = false
end
script.on_event(defines.events.on_entity_cloned, fns.on_entity_created, filters)
script.on_event(defines.events.on_built_entity, fns.on_entity_created, filters)
script.on_event(defines.events.on_robot_built_entity, fns.on_entity_created, filters)
script.on_event(defines.events.script_raised_built, fns.on_entity_created, filters)
script.on_event(defines.events.script_raised_revive, fns.on_entity_created, filters)


function fns.destroy_sub(logistic_storage_tank, key)
  if logistic_storage_tank[key] and logistic_storage_tank[key].valid then
    logistic_storage_tank[key].destroy()
    logistic_storage_tank[key] = nil
  end
end

function fns.destroy(logistic_storage_tank)
  fns.destroy_sub(logistic_storage_tank, "main")
  fns.destroy_sub(logistic_storage_tank, "chest")
  global.logistic_storage_tanks[logistic_storage_tank.unit_number] = nil
end

function fns.on_entity_destroyed(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name ~= name_tank_passive_provider and entity.name ~= name_tank_requester then return end

  fns.destroy(fns.from_entity(entity))
end
script.on_event(defines.events.on_entity_died, fns.on_entity_destroyed, filters)
script.on_event(defines.events.on_robot_mined_entity, fns.on_entity_destroyed, filters)
script.on_event(defines.events.on_player_mined_entity, fns.on_entity_destroyed, filters)
script.on_event(defines.events.script_raised_destroy, fns.on_entity_destroyed, filters)

function fns.equalize_inventory(logistic_storage_tank)
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return fns.destroy(logistic_storage_tank) end
  local chest = logistic_storage_tank.chest
  if not (chest and chest.valid) then return fns.destroy(logistic_storage_tank) end
  
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
    item_count = inventory.get_item_count(logistic_storage_tank.fluid_type .. "-barrel")
  end

  local delta_item_count = item_count - logistic_storage_tank.last_item_count
  if delta_item_count ~= 0 then
    fluid_count = fluid_count + (delta_item_count * 50)
    if fluid_count <= 0 then
      fluid_boxes[1] = nil
    elseif fluid_box then
      fluid_box.amount = fluid_count
      fluid_boxes[1] = fluid_box
    elseif logistic_storage_tank.fluid_type then
      fluid_boxes[1] = {
        name = logistic_storage_tank.fluid_type,
        amount = fluid_count
      }
    end
  end
  local delta = math.floor(fluid_count / 50) - item_count
  if delta > 0 then
    inventory.insert({ name = logistic_storage_tank.fluid_type .. "-barrel", count = delta })
  elseif delta < 0 then
    inventory.remove({ name = logistic_storage_tank.fluid_type .. "-barrel", count = -delta })
  end
  logistic_storage_tank.last_item_count = item_count + delta
end

function fns.on_tick()
  for _, logistic_storage_tank in pairs(global.logistic_storage_tanks) do
    fns.equalize_inventory(logistic_storage_tank)
  end
end
script.on_nth_tick(tick_update, fns.on_tick)

function fns.on_init(event)
  global.logistic_storage_tanks = {}
end
script.on_init(fns.on_init)

function fns.gui_open(player, logistic_storage_tank)
  fns.gui_close(player)
  if not logistic_storage_tank then return end

  local gui = player.gui.relative

  local anchor =  {gui=defines.relative_gui_type.storage_tank_gui, position=defines.relative_gui_position.left}
  local container = gui.add{
    type = "frame",
    name = name_gui_root,
    direction="vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what delivery cannon this gui is displaying/controls
    tags = {
      unit_number = logistic_storage_tank.unit_number
    }
  }

  local title_flow = container.add{type = "flow", "title-flow", direction = "horizontal"}
  title_flow.add{type = "label", name = "title-label", style = "frame_title", caption = {"logistic-tanks.relative-window-title"}, ignored_by_interaction = true}
  local title_empty = title_flow.add{
    type = "empty-widget",
    style = "draggable_space",
    ignored_by_interaction = true
  }
  title_empty.style.horizontally_stretchable = "on"
  title_empty.style.left_margin = 4
  title_empty.style.right_margin = 0
  title_empty.style.height = 24

  local gui_inner = container.add{type="frame", name="gui_inner", direction="vertical", style="b_inner_frame"}
  gui_inner.style.padding = 10
  gui_inner.style.horizontally_stretchable = "on"

  local selector = gui_inner.add{type="choose-elem-button", name="selector", elem_type="fluid"}

  local slider = gui_inner.add{type="slider", name="slider", minimum_value = 0, maximum_value = 25000, value = 2500, value_step = 2500, discrete_slider = true, style="notched_slider"}

  fns.gui_update(player)
end

function fns.update_request(logistic_storage_tank)
  if not logistic_storage_tank then return end

  local chest = logistic_storage_tank.chest
  if not (chest and chest.valid) then return fns.destroy(logistic_storage_tank) end

  local logistic_point = chest.get_logistic_point(defines.logistic_member_index.logistic_container)
  if not logistic_point then return end
  if logistic_point.mode == defines.logistic_mode.storage then
    
  elseif logistic_point.mode == defines.logistic_mode.requester or logistic_point.mode == defines.logistic_mode.buffer then
    if logistic_storage_tank.fluid_type and logistic_storage_tank.request_amount > 0 then
      chest.set_request_slot({name = logistic_storage_tank.fluid_type.."-barrel", count = logistic_storage_tank.request_amount/50} , 1)
    else
      chest.clear_request_slot(1)
    end
  end
end

function fns.on_gui_elem_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "selector") then return end

  local root = player.gui.relative[name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = fns.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local main = logistic_storage_tank.main
  if not (main and main.valid) then return fns.destroy(logistic_storage_tank) end

  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.fluid_type = event.element.elem_value
  elseif logistic_storage_tank.fluid_type ~= main.fluid_box.name then
    player.print({"logistic-tanks.cannot-switch-filter"})
  end
  fns.update_request(logistic_storage_tank)
end
script.on_event(defines.events.on_gui_elem_changed, fns.on_gui_elem_changed)

function fns.on_gui_value_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "slider") then return end

  local root = player.gui.relative[name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = fns.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local value = event.element.slider_value
  if value < 0 then value = 0 end
  if value > 25000 then value = 25000 end
  logistic_storage_tank.request_amount = value
  fns.update_request(logistic_storage_tank)
end
script.on_event(defines.events.on_gui_value_changed, fns.on_gui_value_changed)

function fns.gui_close(player)
  if player.gui.relative[name_gui_root] then
    player.gui.relative[name_gui_root].destroy()
  end
end

function fns.on_gui_closed(event)
  local player = game.players[event.player_index]
  if player and event.entity and (event.entity.name == name_tank_passive_provider or event.entity.name == name_tank_requester) then
    fns.gui_close(player)
  end
end
script.on_event(defines.events.on_gui_closed, fns.on_gui_closed)

function fns.on_gui_opened(event)
  local player = game.players[event.player_index]
  if player and event.entity and event.entity.name == name_tank_requester then
    fns.gui_open(player, fns.from_entity(event.entity))
  end
end
script.on_event(defines.events.on_gui_opened, fns.on_gui_opened)

function fns.gui_update(player)
  local root = player.gui.relative[name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = fns.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  root["gui_inner"]["selector"].elem_value = logistic_storage_tank.fluid_type
  root["gui_inner"]["slider"].slider_value = logistic_storage_tank.request_amount
end

