local M = {}

function M.setup()
  local dap = require("dap")

  -- Path to js-debug-adapter installed by Mason
  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local js_debug_path = mason_path .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

  -- Adapter for Node.js
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = { js_debug_path, "${port}" },
    },
  }

  -- Configurations for JavaScript/TypeScript
  local js_based_languages = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

  for _, lang in ipairs(js_based_languages) do
    dap.configurations[lang] = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Nx Project",
        runtimeExecutable = "npx",
        runtimeArgs = function()
          local project = vim.fn.input("Nx project name: ")
          return { "nx", "serve", project, "--configuration=development" }
        end,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
      },
    }
  end
end

return M
