local M = {}
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

function M.timeStartup()
    local startTick = vim.uv.hrtime()
    M.actualSetup()
    local endTick = vim.uv.hrtime()
end

return M
