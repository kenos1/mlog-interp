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
    cells = {}
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

function InterpretCall(context, node)
  if not MlogFunctions[node.value] then
    print(colors.yellow .. "[WARNING] Unimplemented function " .. node.value .. colors.reset)
    return
  end
  MlogFunctions[node.value](context, table.unpack(node.args))
end

function InterpretCode(context, tree)
  tree:foreach(function(node)
    if node.type == NodeTypes.FunctionCall then
      InterpretCall(context, node)
    end
  end)
end
