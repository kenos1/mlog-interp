require("mlogfunctions")
require("parser")
local pretty = require("pl.pretty")
local colors = require("colors")
List = require("pl.List")

function CreateContext()
  return {
    memory = {},
    messages = {},
    buffer = "",
    cells = {},
    counter = 1,
    stopped = false
  }
end

function PrintContext(context)
  print(colors.onmagenta .. colors.black .. " Variables " .. colors.reset)
  for varName, val in pairs(context.memory) do
    print(colors.magenta .. varName .. colors.reset .. " -> " .. val .. colors.dim .. " [" .. type(val) .. "]" .. colors.reset)
  end

  print(colors.ongreen .. colors.black .. " Message Blocks " .. colors.reset)
  for msgName, content in pairs(context.messages) do
    print(colors.green .. msgName .. colors.reset .. " -> " .. content)
  end

  print(colors.oncyan .. colors.black .. " Memory Cells " .. colors.reset)
  for memName, content in pairs(context.cells) do
    print(colors.cyan .. memName .. colors.reset .. " " .. pretty.write(content))
  end
end

function PrintCode(context, tree)
  tree:foreach(function(node)
    print(FormatLine(node))
  end)
end

function FormatLine(node)
  if node.type == NodeTypes.FunctionCall then
    local buffer = colors.cyan .. node.value .. colors.reset
    if node.args then
      buffer = buffer .. " " .. node.args:map(FormatLine):join(" ")
    end
    return buffer
  elseif node.type == NodeTypes.Variable then
    return colors.magenta .. node.value .. colors.reset
  elseif node.type == NodeTypes.Number then
    return colors.red .. node.value .. colors.reset
  end
  return node.value
end

function InterpretCall(context, node)
  if not MlogFunctions[node.value] then
    print(colors.yellow .. "[WARNING] Unimplemented function " .. node.value .. colors.reset)
    return
  end
  MlogFunctions[node.value](context, table.unpack(node.args))
end

function InterpretCodeOnce(context, tree)
  local node = tree[context.counter]
  if node.type == NodeTypes.FunctionCall then
    InterpretCall(context, node)
  end
  context.counter = context.counter + 1
end

function InterpretCode(context, tree)
  while not context.stopped do
    InterpretCodeOnce(context, tree)
  end
end
