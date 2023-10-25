local M = {}

local bufnr = nil
local width = 0
local height = 0
local context = require('pineapple.ui.context')
M.refreshBuffer = function()
    local buf = M.getBufNr()
    local lines = context.getLines()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    context.addHighlights(buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
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


M.getBufNr = function()
    if M.bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr or -1) then
        M.bufnr = vim.api.nvim_create_buf(false, true)
    end
    return M.bufnr
end

M.getWidth = function()
    return width
end
M.getHeight = function()
    return height
end
local contexts = {}
local data = {}
local contextIndex = 1
local keysToUnmap = {}

local nsId = nil
local function getNsId()
    if nsId == nil then
        nsId = vim.api.nvim_create_namespace("pineapple")
    end
    return nsId
end

function M.setContext()
    data = contexts[contextIndex]:setContext(data)
end

function M.setup()
    local home = require("pineapple.ui.context.home")
    local installed = require("pineapple.ui.context.installed")
    contexts = {
        home,
        installed,
    }
    M.setContext()
    local opts = {
        buffer = M.getBufNr(),
    }
    for k, v in pairs(contexts) do
        v:setup()
        local entry = v:getEntryKey()
        vim.keymap.set("n", entry,
            function()
                contextIndex = k
                M.setContext()
            end, opts)
    end
    M.createWindow()
end

function M.getLines()
    return contexts[contextIndex]:getLines(data)
end

function M.addHighlights()
    contexts[contextIndex]:addHighlights(data, M.getBufNr(), getNsId())
end

function M.setRemaps()

end

return M

