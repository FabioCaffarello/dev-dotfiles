return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    -- Python
    "mfussenegger/nvim-dap-python",
    -- Go
    "leoluz/nvim-dap-go",
  },
  config = function()
    require("caffarello.plugins.dap.dap-core").setup()
  end,
}
