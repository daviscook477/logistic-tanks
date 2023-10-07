if not global.logistic_storage_tanks_update_queue then return end

local queue = global.logistic_storage_tanks_update_queue
if queue.head then
  local current = queue.head
  -- walk through the previous links and set them all to nil since these items are all before the head of the queue
  while current.prev do
    local temp = current.prev
    current.prev = nil
    current = temp
  end
end

if queue.tail then
  local current = queue.tail
  -- walk through the next links and set them all to nil since these items are all after the tail of the queue
  while current.next do
    local temp = current.next
    current.next = nil
    current = temp
  end
end