-- The player should be able to copy/paste from all assembly machines to the requester tank
local assembling_machines = data.raw["assembling-machine"]
for _, assembling_machine_prototype in pairs(assembling_machines) do
  assembling_machine_prototype.additional_pastable_entities = assembling_machine_prototype.additional_pastable_entities or {}
  table.insert(assembling_machine_prototype.additional_pastable_entities, "logistic-storage-tank-requester")
  table.insert(assembling_machine_prototype.additional_pastable_entities, "logistic-minibuffer-requester")
end