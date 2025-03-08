require("parser")
require("interpreter")
local pretty = require("pl.pretty")

local code = [[
lookup unit unit:2:6 unitIndex:1:4
jump 4 notEqual unit:2:6 0
set unitIndex:1:4 0
end
ubind unit:2:6
jump 11 notEqual @unit firstUnit:3:4
set firstUnit:3:4 null
write count:4:4 cell1 unitIndex:1:4
set count:4:4 0
op add unitIndex:1:4 unitIndex:1:4 1
end
op strictEqual &t0 firstUnit:3:4 null
jump 14 equal &t0 0
set firstUnit:3:4 @unit
op add count:4:4 count:4:4 1
]]

local simple = [[
ubind @fortress
ucontrol move 50 50
]]

local tokens = TokenizeCode(simple)
--print(pretty.write(tokens))

local ast = ParseCode(tokens)
--print(pretty.write(ast))

--print(simple)
local ctx = CreateContext()

DebugCode(ctx, ast)

--local res = ParseCode(TokenizeCode(code))

--print(pretty.write(res))
