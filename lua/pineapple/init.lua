local M = {}
---@class PineappleOptions: PineappleInstallerOptions
M.opts = {}
local has_setup = false
function M.setup(opts)
	-- basically we wont load anything for now, until we actually need it
	M.opts = opts
	if has_setup then
		return
	end
	has_setup = true
	require("pineapple.ui.buffer").setup(M.opts)
	require("pineapple.installer").setup(M.opts)
end

function M.actualSetup() end
vim.api.nvim_create_user_command("Pineapple", function(_)
	if not has_setup then
		error("Pineapple has not been setup yet")
	end
	-- local pineapple = require("pineapple")
	-- do actualSetup bc setup doesn't do anything
	-- pineapple.actualSetup()
	require("pineapple.ui.buffer").openWindow()
end, {})

return M
