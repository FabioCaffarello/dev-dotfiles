local py = require("caffarello.plugins.dap.dap-adapters.py-dap")
local go = require("caffarello.plugins.dap.dap-adapters.go-dap")
local rust = require("caffarello.plugins.dap.dap-adapters.rust-dap")
local node = require("caffarello.plugins.dap.dap-adapters.node-dap")

return {
  py = py,
  go = go,
  rust = rust,
  node = node,
}
