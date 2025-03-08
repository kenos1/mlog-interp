local stringx = require "pl.stringx"
local List = require "pl.List"

NodeTypes = {
  FunctionCall = "FunctionCall",
  Constant = "Constant",
  Variable = "Variable",
  Number = "Number",
  String = "String",
  Label = "Label",
  Comment = "Comment"
}

--- @param code string
--- @return string[][]
function TokenizeCode(code)
  local lines = stringx.splitlines(code)
  local tokenedLines = List(lines):map(TokenizeLine)

  return tokenedLines
end

--- @param line string
function TokenizeLine(line)
  local tokens = List()
  local currentToken = ""
  local inString = false

  (line .. " "):gsub(".", function(character)
    if not inString and character == " " then
        tokens:append(currentToken)
        currentToken = ""
    elseif not inString and character == [["]] then
        tokens:append(currentToken)
        currentToken = [["]]
        inString = true
    elseif inString and character == [["]] then
      currentToken = currentToken .. character
      tokens:append(currentToken)
      currentToken = ""
      inString = false
    else
      currentToken = currentToken .. character
    end
  end)

  return tokens:filter(function(token) return token ~= "" end)
end

function ParseKeyword(token)
  local number = tonumber(token)
  if number then
    return {
      type = NodeTypes.Number,
      value = number
    }
  elseif stringx.startswith(token, "@") then
    return {
      type = NodeTypes.Constant,
      value = stringx.lstrip(token, "@")
    }
  elseif stringx.startswith(token, "\"") and stringx.endswith(token, "\"") then
    return {
      type = NodeTypes.String,
      value = stringx.strip(token, "\"")
    }
  end

  return {
    type = NodeTypes.Variable,
    value = token
  }
end

--- @param tokens string[]
function ParseLine(tokens)
  if tokens[1] == "#" then
    return {
      type = NodeTypes.Comment
    }
  elseif stringx.endswith(tokens[1], ":") then
    return {
      type = NodeTypes.Label,
      value = stringx.rstrip(tokens[1], ":")
    }
  end

  return {
    type = NodeTypes.FunctionCall,
    value = tokens[1],
    args = List(tokens):slice(2):map(ParseKeyword)
  }
end

--- @param tokens string[][]
function ParseCode(tokens)
  return List(tokens):map(ParseLine)
end
