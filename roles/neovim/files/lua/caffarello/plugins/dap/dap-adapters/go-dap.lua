local M = {}

function M.setup()
  local ok, dap_go = pcall(require, "dap-go")
  if not ok then
    vim.notify("dap-go not found", vim.log.levels.WARN)
    return
  end

  dap_go.setup({
    dap_configurations = {
      {
        type = "go",
        name = "Debug Package",
        request = "launch",
        program = "${fileDirname}",
      },
      {
        type = "go",
        name = "Debug Test",
        request = "launch",
        mode = "test",
        program = "${file}",
      },
      {
        type = "go",
        name = "Debug Test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
      },
    },
    delve = {
      initialize_timeout_sec = 20,
      port = "${port}",
    },
  })
end

return M
