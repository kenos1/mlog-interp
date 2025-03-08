require("mlogfunctions")
require("parser")
local pretty = require("pl.pretty")
local colors = require("colors")
List = require("pl.List")
local stringx = require("pl.stringx")

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
  print(colors.onyellow .. colors.black .. " Constants " .. colors.reset)
  for constName, func in pairs(MlogConstants) do
    print(colors.yellow .. constName .. colors.reset .. " -> " .. func(context))
  end
  print(colors.onmagenta .. colors.black .. " Variables " .. colors.reset)
  for varName, val in pairs(context.memory) do
    local display = val
    if type(val) == "boolean" then
      if (val) then
        display = "true"
      else
        display = "false"
      end
    elseif type(val) == "nil" then
      display = "null"
    end
    print(colors.magenta .. varName .. colors.reset .. " -> " .. display .. colors.dim .. " [" .. type(val) .. "]" .. colors.reset)
  end

  print(colors.ongreen .. colors.black .. " Message Blocks " .. colors.reset)
  for msgName, content in pairs(context.messages) do
    print(colors.green .. msgName .. colors.reset .. " -> " .. content)
  end

  print(colors.oncyan .. colors.black .. " Memory Cells " .. colors.reset)
  for memName, content in pairs(context.cells) do
    print(colors.cyan .. memName .. colors.reset .. " " .. pretty.write(content))
  end

  print()
end

function PrintCode(context, tree)
  local maxLineNumWidth = tostring(tree:len()):len()
  local line = 0
  tree:foreach(function(node)
    local lineNum = " | "
    line = line + 1
    if context.counter == line then
      lineNum = "-->"
    end
    lineNum = stringx.rjust(tostring(line), maxLineNumWidth, " ") .. lineNum
    print(colors.dim .. lineNum .. colors.reset ..FormatNode(node))
  end)
end

function FormatNode(node)
  if node.type == NodeTypes.FunctionCall then
    local buffer = colors.cyan .. node.value .. colors.reset
    if node.args then
      buffer = buffer .. " " .. node.args:map(FormatNode):join(" ")
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

function DebugCode(context, tree)
  while not context.stopped do
    PrintCode(context, tree)
    PrintContext(context)
    print("Press [ENTER] to take another step.")
    local _ = io.read()
    InterpretCodeOnce(context, tree)
  end
end
