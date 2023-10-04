LogisticTankGUI = {}

LogisticTankGUI.name_gui_root = "logistic-storage-tank-filter"

LogisticTankGUI.logistic_storage_tank_request_names = {}
for _, suffix in pairs(LogisticTank.suffixes_request) do
  local logistic_storage_tank_name = LogisticTank.prefix_tank..suffix
  table.insert(LogisticTankGUI.logistic_storage_tank_request_names, logistic_storage_tank_name)
  local logistic_minibuffer_name = LogisticTank.prefix_minibuffer..suffix
  table.insert(LogisticTankGUI.logistic_storage_tank_request_names, logistic_minibuffer_name)
end

function LogisticTankGUI.gui_open(player, logistic_storage_tank)
  LogisticTankGUI.gui_close(player)
  if not logistic_storage_tank then return end

  local gui = player.gui.relative

  local anchor =  {gui=defines.relative_gui_type.storage_tank_gui, position=defines.relative_gui_position.left}
  local container = gui.add{
    type = "frame",
    name = LogisticTankGUI.name_gui_root,
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
    ignored_by_interaction = true
  }
  title_empty.style.horizontally_stretchable = "on"
  title_empty.style.left_margin = 4
  title_empty.style.right_margin = 0
  title_empty.style.height = 24

  local gui_inner = container.add{type="frame", name="gui_inner", direction="vertical", style="b_inner_frame"}
  gui_inner.style.padding = 10

  local gui_flow = gui_inner.add{type="flow", name="gui_flow", direction="horizontal"}
  gui_flow.style.horizontally_stretchable = "on"
  gui_flow.style.vertical_align = "center"

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
  local number = nil
  if logistic_storage_tank.request_amount > 0 then
    number = logistic_storage_tank.request_amount
  end
  local selector = gui_flow.add{
    type="sprite-button",
    name="selector-button",
    sprite="fluid/petroleum-gas",
    number=number,
    tooltip=tooltip,
  }
  local spacer = gui_flow.add{
    type="empty-widget"
  }
  spacer.style.horizontally_stretchable = "on"
  if fluid_count > 0 then
    local button = gui_flow.add{
      type="sprite-button",
      name="flush-button",
      style="tool_button_red",
      sprite="utility/trash",
      tooltip={"logistic-tanks.flush-tooltip", {"fluid-name.petroleum-gas"}},
    }
  end

  LogisticTankGUI.gui_update(player)
end

function LogisticTankGUI.on_gui_elem_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "selector") then return end

  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = LogisticTank.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local main = logistic_storage_tank.main
  if not (main and main.valid) then return LogisticTank.destroy(logistic_storage_tank) end

  local fluid_boxes = main.fluidbox
  local fluid_box = fluid_boxes[1]
  if not fluid_box then
    logistic_storage_tank.fluid_type = event.element.elem_value
  elseif fluid_box.fluid_type ~= event.element.elem_value then
    player.print({"logistic-tanks.cannot-switch-filter"})
  else
    -- filters are already the same - noop
  end
  LogisticTank.update_request(logistic_storage_tank)
end
script.on_event(defines.events.on_gui_elem_changed, LogisticTankGUI.on_gui_elem_changed)

function LogisticTankGUI.on_gui_value_changed(event)
  local player = game.players[event.player_index]
  if not (event.element and event.element.name == "slider") then return end

  local root = player.gui.relative[LogisticTankGUI.name_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local logistic_storage_tank = LogisticTank.from_unit_number(root.tags.unit_number)
  if not logistic_storage_tank then return end

  local value = event.element.slider_value
  if value < 0 then value = 0 end
  if value > 25000 then value = 25000 end
  logistic_storage_tank.request_amount = value
  LogisticTank.update_request(logistic_storage_tank)
end
script.on_event(defines.events.on_gui_value_changed, LogisticTankGUI.on_gui_value_changed)

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
  for _, logistic_storage_tank_request_name in pairs(LogisticTankGUI.logistic_storage_tank_request_names) do
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
    root["gui_inner"]["gui_flow"]["selector-button"].sprite = "fluid/"..logistic_storage_tank.fluid_type
  else
    root["gui_inner"]["gui_flow"]["selector-button"].sprite = nil
  end
  if logistic_storage_tank.request_amount and logistic_storage_tank.request_amount > 0 then
    root["gui_inner"]["gui_flow"]["selector-button"].number = logistic_storage_tank.request_amount
  else
    root["gui_inner"]["gui_flow"]["selector-button"].number = nil
  end
end

return LogisticTankGUI