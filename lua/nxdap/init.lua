-- pass options via setup function
local options = {
  -- TODO maybe get this also via ENV
  projectsSourceFile = "angular.json",
  projectsSourceFileDirectory = vim.fn.getcwd()
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

return {
  test = findProjectName
}
