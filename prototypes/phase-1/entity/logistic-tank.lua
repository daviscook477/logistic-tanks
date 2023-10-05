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

local blank = {
  direction_count = 8,
  frame_count = 1,
  filename = "__logistic-tanks__/graphics/blank.png",
  width = 1,
  height = 1,
  priority = "low"
}

local fast_replace_group = "storage-tank"

function fns.make_logistic_storage_tank_entity(name, tint)
  local logistic_tank_storage_entity = fns.deepcopy(data.raw["storage-tank"]["storage-tank"])
  logistic_tank_storage_entity.name = "logistic-storage-tank-"..name
  logistic_tank_storage_entity.pictures.picture.sheets =
  {
    -- Base
    {
      filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
      priority = "extra-high",
      frames = 2,
      width = 110,
      height = 108,
      shift = util.by_pixel(0, 4),
      hr_version = {
        filename = "__base__/graphics/entity/storage-tank/hr-storage-tank.png",
        priority = "extra-high",
        frames = 2,
        width = 219,
        height = 215,
        shift = util.by_pixel(-0.25, 3.75),
        scale = 0.5
      }
    },
    -- Mask
    {
      filename = "__logistic-tanks__/graphics/entity/logistic-tank/storage-tank-mask.png",
      priority = "extra-high",
      frames = 2,
      width = 110,
      height = 108,
      shift = util.by_pixel(0, 4),
      tint = tint,
      hr_version = {
        filename = "__logistic-tanks__/graphics/entity/logistic-tank/hr-storage-tank-mask.png",
        priority = "extra-high",
        frames = 2,
        width = 219,
        height = 215,
        shift = util.by_pixel(-0.25, 3.75),
        tint = tint,
        scale = 0.5
      }
    },
    -- Highlights
    {
      filename = "__logistic-tanks__/graphics/entity/logistic-tank/storage-tank-highlights.png",
      priority = "extra-high",
      frames = 2,
      width = 110,
      height = 108,
      shift = util.by_pixel(0, 4),
      blend_mode = "additive",
      hr_version = {
        filename = "__logistic-tanks__/graphics/entity/logistic-tank/hr-storage-tank-highlights.png",
        priority = "extra-high",
        frames = 2,
        width = 219,
        height = 215,
        shift = util.by_pixel(-0.25, 3.75),
        blend_mode = "additive",
        scale = 0.5
      }
    },
    -- Shadow
    {
      filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
      priority = "extra-high",
      frames = 2,
      width = 146,
      height = 77,
      shift = util.by_pixel(30, 22.5),
      draw_as_shadow = true,
      hr_version = {
        filename = "__base__/graphics/entity/storage-tank/hr-storage-tank-shadow.png",
        priority = "extra-high",
        frames = 2,
        width = 291,
        height = 153,
        shift = util.by_pixel(29.75, 22.25),
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  }
  logistic_tank_storage_entity.corpse = "logistic-storage-tank-"..name.."-remnants"
  logistic_tank_storage_entity.fast_replaceable_group = "storage-tank"
  logistic_tank_storage_entity.minable.result = "logistic-storage-tank-"..name
  return logistic_tank_storage_entity
end

function fns.make_logistic_storage_tank_remnant(name, tint)
  local logistic_storage_tank_remnant = table.deepcopy(data.raw["corpse"]["storage-tank-remnants"])
  logistic_storage_tank_remnant.name = "logistic-storage-tank-"..name.."-remnants"
  logistic_storage_tank_remnant.animation.layers =
  {
    -- Base
    {
      filename = "__base__/graphics/entity/storage-tank/remnants/storage-tank-remnants.png",
      line_length = 1,
      width = 214,
      height = 142,
      frame_count = 1,
      direction_count = 1,
      shift = util.by_pixel(27, 21),
      hr_version = {
        filename = "__base__/graphics/entity/storage-tank/remnants/hr-storage-tank-remnants.png",
        line_length = 1,
        width = 426,
        height = 282,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(27, 21),
        scale = 0.5,
      }
    },
    -- Mask
    {
      filename = "__logistic-tanks__/graphics/entity/logistic-tank/remnants/storage-tank-remnants-mask.png",
      line_length = 1,
      width = 214,
      height = 142,
      frame_count = 1,
      direction_count = 1,
      shift = util.by_pixel(27, 21),
      tint = tint,
      hr_version = {
        filename = "__logistic-tanks__/graphics/entity/logistic-tank/remnants/hr-storage-tank-remnants-mask.png",
        line_length = 1,
        width = 426,
        height = 282,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(27, 21),
        tint = tint,
        scale = 0.5,
      }
    },
    -- Highlights
    {
      filename = "__logistic-tanks__/graphics/entity/logistic-tank/remnants/storage-tank-remnants-highlights.png",
      line_length = 1,
      width = 214,
      height = 142,
      frame_count = 1,
      direction_count = 1,
      shift = util.by_pixel(27, 21),
      blend_mode = "additive",
      hr_version = {
        filename = "__logistic-tanks__/graphics/entity/logistic-tank/remnants/hr-storage-tank-remnants-highlights.png",
        line_length = 1,
        width = 426,
        height = 282,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(27, 21),
        blend_mode = "additive",
        scale = 0.5,
      }
    }
  }
  return logistic_storage_tank_remnant
end

function fns.make_logistic_storage_tank_chest(name)
  local logistic_tank_storage_chest =  fns.deepcopy(data.raw["logistic-container"]["logistic-chest-"..name])
  logistic_tank_storage_chest.name = "logistic-storage-tank-logistic-chest-"..name
  -- 500 fluid per slot * 50 slots = 25k equivalent to storage tank (51 slots is 1 greater than 50 to allow for some slight overflow)
  logistic_tank_storage_chest.inventory_size = 51
  logistic_tank_storage_chest.animation =
  -- not visible
  {
    layers =
    {
      blank
    },
  }
  logistic_tank_storage_chest.selectable_in_game = false
  -- corpse not visible either
  logistic_tank_storage_chest.corpse = nil
  logistic_tank_storage_chest.collision_mask = {}
  -- avoid doubling up on alt mode for both the storage tank and the chest
  table.insert(logistic_tank_storage_chest.flags, "hide-alt-info")
  return logistic_tank_storage_chest
end

function fns.make_logistic_storage_tank(name, tint)
  return {
    fns.make_logistic_storage_tank_remnant(name, tint),
    fns.make_logistic_storage_tank_entity(name, tint),
    fns.make_logistic_storage_tank_chest(name)
  }
end

if settings.startup["logistic-tanks-enable-active-provider"].value then
  data:extend(fns.make_logistic_storage_tank("active-provider", logistic_tanks.tint_logistic_storage_tank_active_provider))
end
data:extend(fns.make_logistic_storage_tank("passive-provider", logistic_tanks.tint_logistic_storage_tank_passive_provider))
--data:extend(fns.make_logistic_storage_tank("storage", logistic_tanks.tint_logistic_storage_tank_storage))
data:extend(fns.make_logistic_storage_tank("buffer", logistic_tanks.tint_logistic_storage_tank_buffer))

local logistic_storage_tank_requester = fns.make_logistic_storage_tank("requester", logistic_tanks.tint_logistic_storage_tank_requester)
-- Allow copy/paste requests between requester tanks using the on_entity_settings_pasted event
logistic_storage_tank_requester[2].additional_pastable_entities = { "logistic-storage-tank-requester", "logistic-storage-tank-buffer", "logistic-minibuffer-requester", "logistic-minibuffer-buffer" }
data:extend(logistic_storage_tank_requester)

data.raw["storage-tank"]["storage-tank"].fast_replaceable_group = fast_replace_group