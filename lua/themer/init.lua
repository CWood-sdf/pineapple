local M = {}

local values = nil
M.setup = function(opts)
    values = require("themer.data")
    vim.api.nvim_create_user_command("Themer", function(opts)
        print("Themer")
    end, {
    })
end

return M
