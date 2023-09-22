local M = {}
local bufnr = nil
local width = 0
local height = 0
local context = require('context')
M.refreshBuffer = function()
    if M.bufnr == nil then
        M.bufnr = vim.api.nvim_create_buf(false, true)
    end
    local lines = context.getLines()
    vim.api.nvim_buf_set_option(M.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(M.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, lines)
    context.addHighlights()
    vim.api.nvim_buf_set_option(M.bufnr, "modifiable", false)
end

M.createWindow = function()
    local offsetX = 8
    local offsetY = 3
    width = vim.o.columns - offsetX * 2
    height = vim.o.lines - offsetY * 2 - 4
    M.refreshBuffer()
    vim.api.nvim_open_win(M.getBuffer(), true, {
        relative = "win",
        width = width,
        height = height,
        row = offsetY,
        col = offsetX,
        style = "minimal",
    })
end
M.setSize = function()

end

M.getBufNr = function()

end

M.setWidth = function()

end
M.setHeight = function()

end
M.getWidth = function()

end
M.getHeight = function()

end

return M

