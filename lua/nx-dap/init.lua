-- pass options via setup function
local options = {
  projectsSourceFile = "angular.json",
  projectsSourceFileDirectory = vim.fn.getcwd(),

  dap = {
    configuation = {
      type = "pwa-node",
      request = "launch",
      name = "Deug NX test",
      program = "${workspaceFolder}/node_modules/@angular/cli/bin/ng",
      cwd = "${workspaceFolder}",
    }
  }
}

local function readProjects()
  local file = io.open(options.projectsSourceFileDirectory .. "/" .. options.projectsSourceFile, "r")
  if not file then return nil end
  content = vim.json.decode(file:read("*a"))
  file:close()
  return content
end

local function findProjectName()
  content = readProjects()
  if not content.projects then
    error("nx-dap: could not read projects")
  end

  currentBufferFileName = vim.fn.expand("%:.")

  for projectKey, projectLocation in pairs(content.projects) do
    if string.find(currentBufferFileName, projectLocation, 0, true) then
      return projectKey
    end
  end
  error("npx-dap: could not find any matching nx project for current buffer")
end

local function buildTestNameArg()
  testName = require("nx-dap.finder").findNearestTestName()
  if not testName or testName == "" then
    return ""
  end

  return "--testNamePattern=" .. '"' .. testName .. '"'

end

local function buildArgs()
  return {
    args = function()
      return {
        "test",
        findProjectName(),
        "--codeCoverage=false",
        "--onlyChanged=false",
        "--skip-nx-cache",
        "--testFile=" .. vim.fn.expand("%:."),
        buildTestNameArg()
      }
    end
  }
end

local function buildDapConfig()
  local config = vim.tbl_deep_extend("force", options.dap.configuation, buildArgs())
  return config
end

local function setup(o)
  if o then
    options = vim.tbl_deep_extend("force", options, o)
  end
  return buildDapConfig()
end

return {
  setup = setup
}
