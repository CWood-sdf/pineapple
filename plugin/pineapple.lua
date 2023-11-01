vim.api.nvim_create_user_command("Pineapple", function(_)
    local pineapple = require("pineapple")
    -- do actualSetup bc setup doesn't do anything
    pineapple.actualSetup()
    require('pineapple.ui.buffer').openWindow()
end, {})
