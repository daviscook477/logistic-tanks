local fluid_equivalent_prefix = "fluid-equivalent-"

-- In order for robots to transport liquid, there must be an item equivalent of each liquid
local liquids = data.raw.fluid
local item_equivalents = {}
for liquid_name, liquid_prototype in pairs(liquids) do
  table.insert(item_equivalents, {
    type = "item",
    name = fluid_equivalent_prefix..liquid_name,
    stack_size = 10,
    icon = liquid_prototype.icon,
    icon_size = liquid_prototype.icon_size,
    icon_mipmaps = liquid_prototype.icon_mipmaps,
    icons = liquid_prototype.icons,
    order = liquid_prototype.order,
    localised_name = liquid_prototype.localised_name,
    localised_description = liquid_prototype.localised_description,
    -- The item equivalent should not be visible to the player since it is strictly an internal detail of how this mod works
    flags = {"hidden", "only-in-cursor"} 
  })
end

data:extend(item_equivalents)