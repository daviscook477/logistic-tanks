local fluid_per_item = settings.startup["logistic-tanks-fluid-per-item"].value
local fluid_per_stack = 500
local stack_size = fluid_per_stack / fluid_per_item

local fluid_equivalent_prefix = "fluid-equivalent-"

-- In order for robots to transport liquid, there must be an item equivalent of each liquid
-- We cannot use barrels directly for two reasons
-- 1. Not all mods that add fluids add a corresponding barrel for each fluid
-- 2. Barrels would allow for setting up requests in logistic chests from logistic tanks and vice-versa
--    e.g. if a provider tank supplied petroleum barrels, a requester chest could request petroleum barrels
-- By using hidden item equivalents to represent the fluids in transit, we can prevent the player from
-- setting requests in logistic chests for the fluids and from supplying the fluids from logistic chests either
local liquids = data.raw.fluid
local item_equivalents = {}
for liquid_name, liquid_prototype in pairs(liquids) do
  table.insert(item_equivalents, {
    type = "item",
    name = fluid_equivalent_prefix..liquid_name,
    stack_size = stack_size,
    icon = liquid_prototype.icon,
    icon_size = liquid_prototype.icon_size,
    icon_mipmaps = liquid_prototype.icon_mipmaps,
    icons = liquid_prototype.icons,
    subgroup = "virtual-signal",
    order = liquid_prototype.order,
    localised_name = liquid_prototype.localised_name or {"logistic-tanks.fluid-name", {"fluid-name."..liquid_name}},
    localised_description = liquid_prototype.localised_description or {"logistic-tanks.fluid-description", {"fluid-name."..liquid_name}},
    -- The item equivalent cannot be hidden from the player despite being a mostly internal detail of how this mod works since hidden items do not show up in combinators
    -- For the most part the item will still remain hidden since no recipe unlocks it
  })
end

data:extend(item_equivalents)