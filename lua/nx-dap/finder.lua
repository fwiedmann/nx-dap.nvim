local function isTestFunctionName(node)
  if node:child_count() == 0 then return false end
  local functionName = vim.treesitter.get_node_text(node:child(0), 0)

  if not functionName then
    return false
  end

  if functionName ~= "it" and functionName ~= "test" then
    return false
  end
  return true
end

local function isRequiredNodeType(node)
  if node:type() == "call_expression" then
    return true
  end
  return false
end

local function isTestFunction(node)
  if not isRequiredNodeType(node) then
    return false
  end
  return isTestFunctionName(node)
end

local function extractTestName(node)
  return vim.treesitter.get_node_text(node:child(1):child(1):child(1), 0)
end

local function isLastNode(node)
  if node:type() == "program" then return true else return false end
end

local function findNearestTestName()
  local ts_util = require("nvim-treesitter/ts_utils")
  node = ts_util.get_node_at_cursor(0)

  while not isTestFunction(node) do
    node = node:parent()
    if isLastNode(node) then
      vim.notify("nx-dap: could not get test function")
      return
    end
  end
  return extractTestName(node)
end

return {
  findNearestTestName = findNearestTestName
}
