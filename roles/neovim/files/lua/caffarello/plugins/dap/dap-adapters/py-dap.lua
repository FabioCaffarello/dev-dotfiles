local M = {}

function M.setup()
  local dap = require("dap")
  dap.adapters.python = {
    type = "executable",
    command = "python3",
    args = { "-m", "debugpy.adapter" },
  }
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Lançar arquivo atual",
      program = "${file}",
      pythonPath = function()
        return "python3"
      end,
    },
  }
end

return M
