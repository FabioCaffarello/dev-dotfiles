local M = {}

function M.setup()
  local dap = require("dap")

  -- Path to codelldb installed by Mason
  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local codelldb_path = mason_path .. "/packages/codelldb/extension/adapter/codelldb"

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = codelldb_path,
      args = { "--port", "${port}" },
    },
  }

  dap.configurations.rust = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Launch Cargo Debug",
      type = "codelldb",
      request = "launch",
      program = function()
        -- Find project name from Cargo.toml
        local cargo_toml = vim.fn.getcwd() .. "/Cargo.toml"
        if vim.fn.filereadable(cargo_toml) == 1 then
          for line in io.lines(cargo_toml) do
            local name = line:match('^name%s*=%s*"([^"]+)"')
            if name then
              return vim.fn.getcwd() .. "/target/debug/" .. name
            end
          end
        end
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
end

return M
