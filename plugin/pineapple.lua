vim.api.nvim_create_user_command("Pineapple", function(_)
    local pineapple = require("pineapple")
    pineapple.actualSetup()
    local offsetX = 8
    local offsetY = 3
    pineapple.width = vim.o.columns - offsetX * 2
    pineapple.height = vim.o.lines - offsetY * 2 - 4
    pineapple.refreshBuffer()
    vim.api.nvim_open_win(pineapple.getBuffer(), true, {
        relative = "win",
        width = pineapple.width,
        height = pineapple.height,
        row = offsetY,
        col = offsetX,
        style = "minimal",
    })
    pineapple.setKeymapsForContext()
    pineapple.addContextHighlights()
end, {})
