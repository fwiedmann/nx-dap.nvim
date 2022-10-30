# nx-dap.nvim

`nx-dap` provides a [nvim-dap](https://github.com/mfussenegger/nvim-dap) configuration for debugging jest tests in nx mono repositories.

Before each debug session, `nx-dap` will

- try to find the name of the project in which the current jest file is located and
- try to fetch the name of the nearest test.
  The location of the cursor is used as the starting point.
  The used function names to find a test: `is` or `test`

Error behavior:

- Project name not found: `nx-dap` will stop and exit.
- Test name not found: `nx-dap` will start all tests defined in the test file.

## Setup

Install with Packer:

```lua
 use "fwiedmann/nx-dap.nvim"
```

Extend your nvim-dap typescript configuration:

```lua
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local status_nx_dap_ok, nxdap = pcall(require, "nx-dap")
if not status_nx_dap_ok then
  return
end

dap.configuration.typescript = {
  nxdap.setup()
}
```

### Options

The default options:

```lua
{
  -- the file which contains the projects definitions, in some projects it will be the workspace.json
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
```

Pass your updated options to the setup function:

```lua
  nxdap.setup({
    dap = {
      configuation = {
        type = "other-adapter-name"
      }
    }
  })
```

### My personal configuration

Due to the configuration of nvim-dap and it's adapter can be tricky I provide my current working configuration with all required dependencies.

Install dependencies:

```lua
  use { "mfussenegger/nvim-dap", version = "0.3.0" }
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use { "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" } }
  use {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npm run compile"
  }
 use "fwiedmann/nx-dap.nvim"
```

Configure nvim-dap:

```lua
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local dap_vscode_status_ok, dap_vscode = pcall(require, "dap-vscode-js")
if not dap_vscode_status_ok then
  return
end

local status_nx_dap_ok, nxdap = pcall(require, "nx-dap")
if not status_nx_dap_ok then
  return
end

dap_vscode.setup({
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  -- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
  -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Lauch Chrome",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}"
    },
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach Chrome",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}"
    },
    nxdap.setup()
  }
end
```
