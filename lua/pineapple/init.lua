local M = {}
M.opts = {}
function M.setup(opts)
    -- basically we wont load anything for now, until we actually need it
    M.opts = opts
    -- require("pineapple.ui.buffer").openWindow()
end

local has_setup = false
function M.actualSetup()
    print(has_setup)
    if has_setup then
        return
    end
    has_setup = true
    require("pineapple.ui.buffer").setup(M.opts)
    require("pineapple.installer").setup(M.opts)
end

return M
