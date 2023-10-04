fluid_equivalent_prefix = "fluid-equivalent-"

Queue = require("scripts/queue")
LogisticTank = require("scripts/logistic-tank")
LogisticTankGUI = require("scripts/logistic-tank-gui")
LogisticTankCopy = require("scripts/logistic-tank-copy")

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

--- The item equivalents used for transporting liquids with logistic robots are an implentation detail and the
--- player should not be able to interact with them - however if a logistic robot carrying one of these item
--- equivalents is mined, the item equivalent it was carrying will end up being visible to the player.
--- When this happens, search through the inventory of the mining player and remove the item equivalent.
function on_player_mined_entity(event)
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
  -- forward the event to on_entity_destroyed
  LogisticTank.on_entity_destroyed(event)
end
--- Only the on_player_mined_entity is relevant for this concern, because on_robot_mined_entity will never be fired
--- since logistic robots are incapable of being marked for deconstruction.
local on_player_mined_entity_filter = fns.deepcopy(LogisticTank.filters)
table.insert(on_player_mined_entity_filter, {filter="robot-with-logistics-interface"})
script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity, on_player_mined_entity_filter)

function on_dolly_moved_entity_id(event)
  local entity = event.moved_entity
  if not (entity and entity.valid) then return end
  if not string.starts(entity.name, LogisticTank.prefix_tank) and not string.starts(entity.name, LogisticTank.prefix_minibuffer) then return end
  local logistic_storage_tank = LogisticTank.from_entity(entity)
  if not logistic_storage_tank then return end
  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end
  LogisticTank.relocate_sub(logistic_storage_tank, "chest", main.position)
end

function on_init(event)
  global.logistic_storage_tanks = {}
  global.logistic_storage_tanks_update_queue = Queue.new()
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_dolly_moved_entity_id)
  end
end
script.on_init(on_init)

function on_load(event)
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_dolly_moved_entity_id)
  end
end
script.on_load(on_load)