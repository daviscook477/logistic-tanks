local fns = {}

local fluid_equivalent_prefix = "fluid-equivalent-"

local prefix_tank = "logistic-storage-tank-"
local prefix_chest = "logistic-storage-tank-logistic-chest-"
local suffixes = { "active-provider", "passive-provider", "storage", "buffer", "requester" }
local suffixes_request = { "storage", "buffer", "requester" }
local name_gui_root = "logistic-storage-tank-filter"

local chest_map = {}
local filters = {}
local logistic_storage_tank_chest_names = {}
for _, suffix in pairs(suffixes) do
  local logistic_storage_tank_name = prefix_tank..suffix
  local logistic_storage_tank_chest_name = prefix_chest..suffix
  chest_map[logistic_storage_tank_name] =logistic_storage_tank_chest_name
  table.insert(filters, {
    filter = "name",
    name = logistic_storage_tank_name,
  })
  table.insert(logistic_storage_tank_chest_names, logistic_storage_tank_chest_name)
end

local logistic_storage_tank_request_names = {}
for _, suffix in pairs(suffixes_request) do
  local logistic_storage_tank_name = prefix_tank..suffix
  table.insert(logistic_storage_tank_request_names, logistic_storage_tank_name)
end

function string.starts(str, start)
  return string.sub(str, 1 ,string.len(start)) == start
end

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
  if not string.starts(entity.name, prefix_tank) then return end

  local logistic_storage_tank = {
    unit_number = entity.unit_number,
    main = entity,
    last_item_count = 0,
    fluid_type = nil,
    request_amount = 0,
  }

  global.logistic_storage_tanks[entity.unit_number] = logistic_storage_tank

  logistic_storage_tank.chest = fns.find_entity_or_revive_ghost(entity.surface, logistic_storage_tank_chest_names, entity.position)
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
  if not string.starts(entity.name, prefix_tank) then return end

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

function fns.on_tick(event)
  for _, logistic_storage_tank in pairs(global.logistic_storage_tanks) do
    if (event.tick + logistic_storage_tank.unit_number) % 60 == 0 then
      fns.equalize_inventory(logistic_storage_tank)
    end
  end
end
script.on_event(defines.events.on_tick, fns.on_tick)

--- The item equivalents used for transporting liquids with logistic robots are an implentation detail and the
--- player should not be able to interact with them - however if a logistic robot carrying one of these item
--- equivalents is mined, the item equivalent it was carrying will end up being visible to the player.
--- When this happens, search through the inventory of the mining player and remove the item equivalent.
function fns.on_player_mined_entity(event)
  -- clear the inventory of any item equivalents
  local player = game.players[event.player_index]
  local main_inventory = player.get_main_inventory()
  if not (main_inventory and main_inventory.valid) then return end
  for i = 1, #main_inventory do
    local item_stack = main_inventory[i]
    if item_stack.valid_for_read and string.starts(item_stack.name, fluid_equivalent_prefix) then
      main_inventory.remove(item_stack.name)
    end
  end
end
--- Only the on_player_mined_entity is relevant for this concern, because on_robot_mined_entity will never be fired
--- since logistic robots are incapable of being marked for deconstruction.
script.on_event(defines.events.on_player_mined_entity, fns.on_player_mined_entity, {{filter="robot-with-logistics-interface"}})

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
      chest.set_request_slot({name = fluid_equivalent_prefix..logistic_storage_tank.fluid_type, count = logistic_storage_tank.request_amount/50} , 1)
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
  elseif logistic_storage_tank.fluid_type ~= fluid_box.name then
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
  if player and event.entity and event.entity.valid and string.starts(event.entity.name, prefix_tank) then
    fns.gui_close(player)
  end
end
script.on_event(defines.events.on_gui_closed, fns.on_gui_closed)

function fns.on_gui_opened(event)
  local player = game.players[event.player_index]
  if not (player and event.entity and event.entity.valid) then return end
  for _, logistic_storage_tank_request_name in pairs(logistic_storage_tank_request_names) do
    if event.entity.name == logistic_storage_tank_request_name then
      fns.gui_open(player, fns.from_entity(event.entity))
    end
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

