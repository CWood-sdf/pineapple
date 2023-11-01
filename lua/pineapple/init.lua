local M = {}
---@class PineappleOptions: PineappleInstallerOptions
M.opts = {}
function M.setup(opts)
    -- basically we wont load anything for now, until we actually need it
    M.opts = opts
end

local has_setup = false
function M.actualSetup()
    if has_setup then
        return
    end
    has_setup = true
    require("pineapple.ui.buffer").setup(M.opts)
    require("pineapple.installer").setup(M.opts)
end

return M
