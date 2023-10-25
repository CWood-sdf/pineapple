local M = {}
M.opts = {}
function M.setup(opts)
    -- basically we wont load anything for now, until we actually need it
    M.opts = opts
    -- require("pineapple.ui.buffer").openWindow()
end

function M.actualSetup()
    require("pineapple.ui.buffer").setup(M.opts)
    require("pineapple.installer").setup(M.opts)
end

return M
