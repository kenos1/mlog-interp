local pretty = require("pl.pretty")

function DebugPrint(table)
  print(pretty.write(table))
end
