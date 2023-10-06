LogisticTankGUI = {}

LogisticTankGUI.name_gui_root = "logistic-storage-tank-filter"

LogisticTankGUI.logistic_storage_tank_filtered_names = {}
for _, suffix in pairs(LogisticTank.suffixes_filtered) do
  local logistic_storage_tank_name = LogisticTank.prefix_tank..suffix
  table.insert(LogisticTankGUI.logistic_storage_tank_filtered_names, logistic_storage_tank_name)
  local logistic_minibuffer_name = LogisticTank.prefix_minibuffer..suffix
  table.insert(LogisticTankGUI.logistic_storage_tank_filtered_names, logistic_minibuffer_name)
end

-- tanks that can have requests copy/pasted
LogisticTankGUI.logistic_storage_tank_request_names = { LogisticTank.prefix_tank.."requester", LogisticTank.prefix_minibuffer.."requester", LogisticTank.prefix_tank.."buffer", LogisticTank.prefix_minibuffer.."buffer" }
-- tanks that have the request from buffers setting
LogisticTankGUI.logistic_storage_tank_requester_names = { LogisticTank.prefix_tank.."requester", LogisticTank.prefix_minibuffer.."requester" }

local fns = {}

function fns.table_contains(table, target)
  for _, item in pairs(table) do
    if item == target then return true end
  end
  return false
end

function LogisticTankGUI.gui_open(player, logistic_storage_tank)
  LogisticTankGUI.gui_close(player)
  if not logistic_storage_tank then return end
  if not (player.opened and player.opened.valid) then return end

  local gui = player.gui.relative

  local anchor =  {gui=defines.relative_gui_type.storage_tank_gui, position=defines.relative_gui_position.left}
  local container = gui.add{
    type = "frame",
    name = LogisticTankGUI.name_gui_root,
    direction="vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what logistic tank this gui is displaying/controls
    tags = {
      unit_number = logistic_storage_tank.unit_number
    }
  }

  local title_flow = container.add{type = "flow", name = "title-flow", direction = "horizontal"}
  title_flow.add{type = "label", name = "title-label", style = "frame_title", caption = {"gui-logistic.title-request"}, ignored_by_interaction = true}
  local title_empty = title_flow.add{
    type = "empty-widget",
    ignored_by_interaction = true
  }
  title_empty.style.horizontally_stretchable = "on"
  title_empty.style.left_margin = 4
  title_empty.style.right_margin = 0
  title_empty.style.height = 24

  local gui_inner = container.add{type="frame", name="gui_inner", direction="vertical", style="item_and_count_select_background"}
  gui_inner.style.padding = 10
  gui_inner.style.width = 320

  local gui_flow = gui_inner.add{type="flow", name="gui_flow", direction="horizontal"}
  gui_flow.style.horizontally_stretchable = "on"
  gui_flow.style.vertical_align = "center"
  gui_flow.style.bottom_padding = 10

  local fluid_count = 0
  local main = logistic_storage_tank.main
  if main and main.valid then
    local fluid_box = main.fluidbox[1]
    if fluid_box then
      fluid_count = fluid_count + fluid_box.amount
    end
  end
  fluid_count = math.floor(fluid_count)
  local tooltip = nil
  if logistic_storage_tank.fluid_type then
    tooltip={"logistic-tanks.filter-tooltip", {"fluid-name."..logistic_storage_tank.fluid_type}, {"description.logistic-request-tooltip-satisfaction"}, fluid_count, logistic_storage_tank.request_amount}
  end
  local selector = gui_flow.add{
    type="choose-elem-button",
    name="logistic-storage-tank-selector-button",
    elem_type="fluid",
    sprite="fluid/petroleum-gas",
    tooltip=tooltip,
  }
  local spacer = gui_flow.add{
    type="empty-widget"
  }
  spacer.style.horizontally_stretchable = "on"
  if fluid_count > 0 then
    local button = gui_flow.add{
      type="sprite-button",
      name="logistic-storage-tank-flush-button",
      style="tool_button_red",
      sprite="utility/trash",
      tooltip={"logistic-tanks.flush-tooltip", {"fluid-name.petroleum-gas"}},
    }
  end

  local gui_flow_2 = gui_inner.add{type="flow", name="gui_flow_2", direction="horizontal", style = "player_input_horizontal_flow"}
  gui_flow_2.style.horizontally_stretchable = "on"
  gui_flow_2.style.vertical_align = "center"

  local max = game.entity_prototypes[player.opened.name].fluid_capacity
  local slider = gui_flow_2.add{
    type="slider", 
    name="logistic-storage-tank-slider", 
    minimum_value = 0, 
    maximum_value = max,
    discrete_slider = true, 
    value_step = max / 5,
    style = "notched_slider",
  }
  slider.style.horizontally_stretchable = "on"

  local textentry = gui_flow_2.add{
    type="textfield",
    name="logistic-storage-tank-textfield",
    numeric = true,
    style = "slider_value_textfield",
  }
  local confirm_button = gui_flow_2.add{
    type="sprite-button",
    name="logistic-storage-tank-confirm-button",
    style="item_and_count_select_confirm",
    sprite="utility/confirm_slot",
  }

  if logistic_storage_tank.main and logistic_storage_tank.main.valid and fns.table_contains(LogisticTankGUI.logistic_storage_tank_requester_names, logistic_storage_tank.main.name) and logistic_storage_tank.chest and logistic_storage_tank.chest.valid then
    local gui_flow_3 = gui_inner.add{type="flow", name="gui_flow_3", direction="horizontal", style = "horizontal_flow"}
    gui_flow_3.style.horizontally_stretchable = "on"
    gui_flow_3.style.vertical_align = "center"

    local checkbox = gui_flow_3.add{
      type="checkbox",
      name="logistic-storage-tank-checkbox",
      style="checkbox",
      state = logistic_storage_tank.chest.request_from_buffers,
      caption = {"gui-logistic.request-from-buffer-chests"}
    }
    checkbox.style.left_margin = 0
  end

  LogisticTankGUI.gui_update(player)
end

function LogisticTankGUI.on_gui_value_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "logistic-storage-tank-slider") then return end

  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  root["gui_inner"]["gui_flow_2"]["logistic-storage-tank-textfield"].text = tostring(event.element.slider_value)
end
script.on_event(defines.events.on_gui_value_changed, LogisticTankGUI.on_gui_value_changed)

function LogisticTankGUI.on_gui_checked_state_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "logistic-storage-tank-checkbox") then return end

  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = LogisticTank.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local chest = logistic_storage_tank.chest
  if not (chest and chest.valid) then return end

  chest.request_from_buffers = event.element.state
end
script.on_event(defines.events.on_gui_checked_state_changed, LogisticTankGUI.on_gui_checked_state_changed)

function LogisticTankGUI.on_gui_click(event)
  local player = game.players[event.player_index]
  if not event.element then return end
  
  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = LogisticTank.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end

  if not (player.opened and player.opened.valid) then return end

  if event.element.name == "logistic-storage-tank-confirm-button" then
    -- perform an equalize in case fluid was already delivered to the internal logistic chest but wasn't reflected in the tank yet
    -- we don't want to be able to set the filter to a different fluid if this has happened since that would cause us to lose fluid
    LogisticTank.equalize_inventory(logistic_storage_tank)

    local amount = tonumber(root["gui_inner"]["gui_flow_2"]["logistic-storage-tank-textfield"].text)
    amount = math.min(amount, game.entity_prototypes[player.opened.name].fluid_capacity)

    local fluid_boxes = main.fluidbox
    local fluid_box = fluid_boxes[1]
    if not fluid_box then
      logistic_storage_tank.fluid_type = root["gui_inner"]["gui_flow"]["logistic-storage-tank-selector-button"].elem_value
      logistic_storage_tank.request_amount = amount
    elseif fluid_box.name ~= root["gui_inner"]["gui_flow"]["logistic-storage-tank-selector-button"].elem_value then
      player.print({"logistic-tanks.cannot-switch-filter"})
    else
      -- filters are already the same - noop
      logistic_storage_tank.request_amount = amount
    end
    LogisticTank.update_request(logistic_storage_tank)
  elseif event.element.name == "logistic-storage-tank-flush-button" then
    local fluid_boxes = main.fluidbox
    local fluid_box = fluid_boxes[1]
    if fluid_box then
      fluid_boxes[1] = nil
    end
    local chest = logistic_storage_tank.chest
    if chest and chest.valid then
      local inventory = chest.get_inventory(defines.inventory.chest)
      inventory.clear()
    end
    logistic_storage_tank.fluid_type = nil
    logistic_storage_tank.request_amount = 0
    LogisticTank.update_request(logistic_storage_tank)
    LogisticTankGUI.gui_update(player)
  end
end
script.on_event(defines.events.on_gui_click, LogisticTankGUI.on_gui_click)

function LogisticTankGUI.gui_close(player)
  if player.gui.relative[LogisticTankGUI.name_gui_root] then
    player.gui.relative[LogisticTankGUI.name_gui_root].destroy()
  end
end

function LogisticTankGUI.on_gui_closed(event)
  local player = game.players[event.player_index]
  if player and event.entity and event.entity.valid and (string.starts(event.entity.name, LogisticTank.prefix_tank) or string.starts(event.entity.name, LogisticTank.prefix_minibuffer)) then
    LogisticTankGUI.gui_close(player)
  end
end
script.on_event(defines.events.on_gui_closed, LogisticTankGUI.on_gui_closed)

function LogisticTankGUI.on_gui_opened(event)
  local player = game.players[event.player_index]
  if not (player and event.entity and event.entity.valid) then return end
  for _, logistic_storage_tank_request_name in pairs(LogisticTankGUI.logistic_storage_tank_filtered_names) do
    if event.entity.name == logistic_storage_tank_request_name then
      LogisticTankGUI.gui_open(player, LogisticTank.from_entity(event.entity))
    end
  end
end
script.on_event(defines.events.on_gui_opened, LogisticTankGUI.on_gui_opened)

function LogisticTankGUI.gui_update(player)
  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = LogisticTank.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  if logistic_storage_tank.fluid_type then
    root["gui_inner"]["gui_flow"]["logistic-storage-tank-selector-button"].elem_value = logistic_storage_tank.fluid_type
    if root["gui_inner"]["gui_flow"]["logistic-storage-tank-flush-button"] then
      root["gui_inner"]["gui_flow"]["logistic-storage-tank-flush-button"].tooltip = {"logistic-tanks.flush-tooltip", {"fluid-name."..logistic_storage_tank.fluid_type}}
    end
  else
    root["gui_inner"]["gui_flow"]["logistic-storage-tank-selector-button"].elem_value = nil
    if root["gui_inner"]["gui_flow"]["logistic-storage-tank-flush-button"] then
      root["gui_inner"]["gui_flow"]["logistic-storage-tank-flush-button"].tooltip = ""
    end
  end
  root["gui_inner"]["gui_flow_2"]["logistic-storage-tank-slider"].slider_value = logistic_storage_tank.request_amount
  root["gui_inner"]["gui_flow_2"]["logistic-storage-tank-textfield"].text = tostring(logistic_storage_tank.request_amount)
end

return LogisticTankGUI