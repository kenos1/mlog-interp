local simplex = require("simplex")
List = require("pl.List")

-- All mlog `op` functions
--
-- List:
-- op add result 0 0
-- op sub result 0 0
-- op mul result 0 0
-- op div result 0 0
-- op idiv result 0 0
-- op mod result 0 0
-- op pow result 0 0
-- op equal result 0 0
-- op notEqual result 0 0
-- op land result 0 0
-- op lessThan result 0 0
-- op lessThanEq result 0 0
-- op greaterThan result 0 0
-- op greaterThanEq result 0 0
-- op strictEqual result 0 0
-- op shl result 0 0
-- op shr result 0 0
-- op or result 0 0
-- op and result 0 0
-- op xor result 0 0
-- op not result 0 0
-- op max result 0 0
-- op min result 0 0
-- op angle result 0 0
-- op angleDiff result 0 0
-- op len result 0 0
-- op noise result 0 0
-- op abs result 0 0
-- op log result 0 0
-- op log10 result 0 0
-- op floor result 0 0
-- op ceil result 0 0
-- op sqrt result 0 0
-- op rand result 0 0
-- op sin result 0 0
-- op cos result 0 0
-- op tan result 0 0
-- op asin result 0 0
-- op acos result 0 0
-- op atan result 0 0
MlogOperations = {
  add           = function(lhs, rhs) return lhs + rhs end,
  sub           = function(lhs, rhs) return lhs - rhs end,
  mul           = function(lhs, rhs) return lhs * rhs end,
  div           = function(lhs, rhs) return lhs / rhs end,
  idiv          = function(lhs, rhs) return lhs // rhs end,
  mod           = function(lhs, rhs) return lhs % rhs end,
  pow           = function(lhs, rhs) return lhs ^ rhs end,
  equal         = function(lhs, rhs) return lhs == rhs end,
  notEqual      = function(lhs, rhs) return lhs ~= rhs end,
  -- Logical AND
  land          = function(lhs, rhs) return lhs and rhs end,
  lessThan      = function(lhs, rhs) return lhs < rhs end,
  lessThanEq    = function(lhs, rhs) return lhs <= rhs end,
  greaterThan   = function(lhs, rhs) return lhs > rhs end,
  greaterThanEq = function(lhs, rhs) return lhs >= rhs end,
  strictEqual   = function(lhs, rhs)
    if type(lhs) ~= type(rhs) then
      return false
    end
    return lhs == rhs
  end,
  -- Bitwise shift left
  shl           = function(lhs, rhs) return lhs << rhs end,
  -- Bitwise shift right
  shr           = function(lhs, rhs) return lhs >> rhs end,
  -- Bitwise OR
  ["or"]        = function(lhs, rhs) return lhs | rhs end,
  -- Bitwise AND
  ["and"]       = function(lhs, rhs) return lhs & rhs end,
  -- Bitwise XOR
  xor           = function(lhs, rhs) return lhs ~ rhs end,
  -- Bitwise NOT (also named flip in the UI)
  ["not"]       = function(val) return ~val end,
  max           = math.max,
  min           = math.min,
  -- Angle of vector
  angle         = function(x, y) return math.atan(y, x) end,
  -- angleDiff = UNIMPLEMENTED
  -- Length of vector
  len           = function(x, y) return math.sqrt((x * x) + (y * y)) end,
  noise         = simplex.Noise2D,
  abs           = math.abs,
  -- Natural log (ln)
  log           = function(val) return math.log(val) end,
  log10         = function(val) return math.log(val, 10) end,
  floor         = math.floor,
  celi          = math.ceil,
  sqrt          = math.sqrt,
  rand          = function(val) return math.random() * val end,
  sin           = math.sin,
  cos           = math.cos,
  tan           = math.tan,
  asin          = math.asin,
  acos          = math.acos,
  atan          = function(val) return math.atan(val) end
}

function GetValueFromContext(context, node)
  if node.type == NodeTypes.Variable then
    return context.memory[node.value]
  end

  return node.value
end

MlogFunctions = {
  -- set varName varValue
  set = function(context, varName, varValue)
    context.memory[varName.value] = GetValueFromContext(context, varValue)
  end,

  -- op operationName outName lhs rhs
  op = function(context, operationName, outName, lhs, rhs)
    context.memory[outName.value] = MlogOperations[operationName.value](GetValueFromContext(context, lhs),
      GetValueFromContext(context, rhs))
  end,

  print = function(context, text)
    context.buffer = context.buffer .. GetValueFromContext(context, text)
  end,

  printFlush = function(context, message)
    context.messages[message.value] = context.buffer
    context.buffer = ""
  end,

  read = function(context, value, cell, index)
    context.memory[value.value] = context.cells[cell.value][index.value]
  end,

  write = function(context, value, cell, index)
    if not context.cells[cell.value] then
      context.cells[cell.value] = {}
    end
    context.cells[cell.value][index.value] = GetValueFromContext(context, value)
  end,

  jump = function(context, line, operationName, lhs, rhs)
    local condition = false
    if operationName.value == "always" then
      condition = true
    else
      condition = MlogOperations[operationName.value](GetValueFromContext(context, lhs), GetValueFromContext(context, rhs))
    end
    if condition then
      context.counter = line.value
    end
  end,

  ["end"] = function(context)
    context.stopped = true
  end
}
