local M = {}

function M.setup()
  local ok, adapters = pcall(require, "caffarello.plugins.dap.dap-adapters")
  if not ok then
    vim.notify("Error on load dap adapters", vim.log.levels.ERROR)
    return
  end

  -- Setup all adapters
  adapters.py.setup()
  adapters.go.setup()
  adapters.rust.setup()
  adapters.node.setup()

  -- Setup DAP UI
  local dap = require("dap")
  local dapui = require("dapui")

  dapui.setup()

  -- Setup virtual text
  require("nvim-dap-virtual-text").setup()

  -- Auto open/close DAP UI
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  -- Keymaps for DAP
  local keymap = vim.keymap
  keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
  keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Continue" })
  keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "Step Into" })
  keymap.set("n", "<leader>do", "<cmd>DapStepOver<CR>", { desc = "Step Over" })
  keymap.set("n", "<leader>dO", "<cmd>DapStepOut<CR>", { desc = "Step Out" })
  keymap.set("n", "<leader>dr", "<cmd>DapToggleRepl<CR>", { desc = "Toggle REPL" })
  keymap.set("n", "<leader>dl", "<cmd>DapShowLog<CR>", { desc = "Show Log" })
  keymap.set("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "Terminate" })
  keymap.set("n", "<leader>du", function()
    dapui.toggle()
  end, { desc = "Toggle DAP UI" })

  -- Conditional breakpoint
  keymap.set("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "Conditional Breakpoint" })
end

return M
