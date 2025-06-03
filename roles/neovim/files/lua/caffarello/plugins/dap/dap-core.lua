local M = {}

function M.setup()
  local ok, adapters = pcall(require, "caffarello.plugins.dap.dap-adapters")
  if not ok then
    vim.notify("Error on load dap adapters", vim.log.levels.ERROR)
    return
  end
  adapters.py.setup()
end

return M
