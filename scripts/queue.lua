-- Queue implementation backed by a doubly-linked-list
local Queue = {}

function Queue.new ()
  return { size = 0 }
end

function Queue.size (list)
  return list.size
end

function Queue.is_empty (list)
  return Queue.size(list) <= 0
end

function Queue.push_left (list, value)
  local node = {value=value}
  if not list.head or not list.tail then
    list.head = node
    list.tail = node
  else
    node.next = list.head
    list.head.prev = node
    list.head = node
  end
  list.size = list.size + 1
end

function Queue.push_right (list, value)
  local node = {value=value}
  if not list.head or not list.tail then
    list.head = node
    list.tail = node
  else
    node.prev = list.tail
    list.tail.next = node
    list.tail = node
  end
  list.size = list.size + 1
end

function Queue.pop_left (list)
  local first = list.head
  if not first then return end

  list.head = list.head.next
  first.next = nil
  list.head.prev = nil
  list.size = list.size - 1
  return first.value
end

function Queue.head (list)
  return list.head
end

function Queue.pop_right (list)
  local last = list.tail
  if not last then return end

  list.tail = list.tail.prev
  last.prev = nil
  list.tail.next = nil
  list.size = list.size - 1
  return last.value
end

function Queue.tail (list)
  return list.tail
end

function Queue.remove (list, node)
  local before = node.prev
  local after = node.next
  list.size = list.size - 1
  node.next = nil
  node.prev = nil
  if before and after then
    before.next = after
    after.prev = before
  elseif before and not after then
    before.next = nil
    list.tail = before
  elseif not before and after then
    after.prev = nil
    list.head = after
  else
    list.head = nil
    list.tail = nil
  end
end

return Queue