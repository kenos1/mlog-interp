require("parser")
require("interpreter")
local pretty = require("pl.pretty")

local code = [[
print "Mining processor ( variant)"
print "Configuration is in the manager processor, not here."
print "Mining cannot be disabled for a unit type by editing this processor."
op div refreshInterval 25 @ipt
read unitId cell1 0
jump 4 lessThan unitId 4
lookup unit unit unitId
ubind unit
ulocate building core false _ core.x core.y core.found core
jump 4 notEqual core.found true
read coreFullAmount cell1 19
jump 4 lessThan coreFullAmount 1
read oreId cell1 1
lookup item ore oreId
jump 4 equal ore null
read unitId cell1 0
lookup unit unit unitId
read coreLowAmount cell1 20
read coreFullAmount cell1 19
read oreId cell1 1
lookup item ore oreId
sensor core[ore] core ore
op add nextRefresh @second refreshInterval
jump 15 lessThan nextRefresh @second
ubind unit
sensor @unit.mining @unit @mining
jump 23 equal @unit.mining false
sensor @unit.flag @unit @flag
jump 23 notEqual @unit.flag 0
ulocate building storage false _ storage.x storage.y storage.found storage
sensor storage.copper storage @copper
jump 33 lessThan storage.copper 1001
ucontrol itemDrop storage 1e5 0 0 0
ulocate building core false _ core.x core.y core.found core
ucontrol itemDrop core 1e5 0 0 0
ucontrol within core.x core.y 24 nearCore 0
jump 24 equal nearCore false
sensor @unit.firstItem @unit @firstItem
jump 24 strictEqual @unit.firstItem null
jump 23 strictEqual @unit.firstItem ore
sensor coreAmount core @unit.firstItem
jump 48 greaterThanEq coreAmount coreFullAmount
jump 23 greaterThanEq core[ore] coreLowAmount
jump 24 lessThanEq coreAmount coreLowAmount
ucontrol mine ore.x ore.y 0 0 0
ucontrol pathfind core.x core.y 0 0 0
jump 24 greaterThan nextRefresh @second
jump 15 always 0 0
ulocate ore core _ ore ore.x ore.y ore.found _
ucontrol itemDrop @air 100 0 0 0
ucontrol mine ore.x ore.y 0 0 0
ucontrol pathfind ore.x ore.y 0 0 0
jump 24 greaterThan nextRefresh @second
jump 15 always 0 0
]]

local simple = [[
set x -1
jump 4 lessThan x 0
write x cell1 0
end
write 69420 cell1 0
]]

local tokens = TokenizeCode(simple)
--print(pretty.write(tokens))

local ast = ParseCode(tokens)
--print(pretty.write(ast))

--print(simple)
local ctx = CreateContext()

InterpretCode(ctx, ast)

PrintCode(ctx, ast)
PrintContext(ctx)

--local res = ParseCode(TokenizeCode(code))

--print(pretty.write(res))
