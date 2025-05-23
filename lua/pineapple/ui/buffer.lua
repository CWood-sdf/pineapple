local M = {}

local bufnr = nil
local width = 0
local height = 0
---@type PineappleContext[]
local contexts = {}
local data = {}
local contextIndex = 1
local keysToUnmap = {}

---@class (exact) PineappleTablineElement
---@field key string
---@field name string
---@field index number
local PineappleTablineElement = {
    key = "",
    name = "",
    index = 0,
}

local tabline = {
    ---@type PineappleTablineElement[]
    permanent = {},
    ---@type PineappleTablineElement[]
    temporary = {},
}

function M.getTabline()
    return tabline
end

local winId = nil
-- local usedHighlights = {}

local function changeContextIndex(index)
    ---@type boolean|table
    local newData = contexts[contextIndex]:setExitContext(data)
    ---@diagnostic disable-next-line: param-type-mismatch
    newData = contexts[index]:setContext(newData)
    if newData ~= false then
        contextIndex = index
        if type(newData) == "table" then
            data = newData
        else
            data = {}
        end
        M.refreshBuffer()
    end
end

function M.getWinNr()
    return winId
end

function M.refreshBuffer()
    local buf = M.getBufNr()
    M.setRemaps()
    local lines = M.getLines()
    vim.api.nvim_set_option_value("modifiable", true, {
        buf = buf,
    })
    vim.api.nvim_set_option_value("buftype", "nofile", {
        buf = buf,
    })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    M.addHighlights()
    vim.api.nvim_set_option_value("modifiable", false, {
        buf = buf,
    })
end

function M.openWindow()
    local offsetX = 8
    local offsetY = 3
    width = vim.o.columns - offsetX * 2
    height = vim.o.lines - offsetY * 2 - 4
    if vim.api.nvim_win_is_valid(winId or -1) then
        vim.api.nvim_set_current_win(winId or -1)
        vim.api.nvim_win_set_buf(winId or -1, M.getBufNr())
    else
        winId = vim.api.nvim_open_win(M.getBufNr(), true, {
            relative = "win",
            width = width,
            height = height,
            row = offsetY,
            col = offsetX,
            style = "minimal",
        })
    end
    M.refreshBuffer()
end

function M.getBufNr()
    if bufnr == nil then
        bufnr = vim.api.nvim_create_buf(false, true)
        keysToUnmap = {}
    end
    if not vim.api.nvim_buf_is_valid(bufnr) then
        keysToUnmap = {}
        bufnr = vim.api.nvim_create_buf(false, true)
    end
    return bufnr
end

function M.getWidth()
    return width
end

function M.getHeight()
    return height
end

local nsId = nil
function M.getNsId()
    if nsId == nil then
        nsId = vim.api.nvim_create_namespace("pineapple")
    end
    return nsId
end

local function setSubContextToArray(context)
    local subContexts = context:getSubContexts()
    for _, subContext in ipairs(subContexts) do
        table.insert(contexts, subContext)
        subContext:setIndex(#contexts)
        setSubContextToArray(subContext)
    end
end

local function refreshEntryKeys()
    local remapOpts = {
        buffer = M.getBufNr(),
    }
    for _, v in ipairs(tabline.permanent) do
        vim.keymap.set("n", v.key, function()
            changeContextIndex(v.index)
            M.refreshBuffer()
        end, remapOpts)
    end
end

local hasSetup = false
function M.setup(opts)
    if hasSetup then
        return
    end
    hasSetup = true
    local home = require("pineapple.ui.context.home")
    local installed = require("pineapple.ui.context.installed")
    local help = require("pineapple.ui.context.help")
    contexts = {
        home,
        installed,
        help,
    }
    local remapOpts = {
        buffer = M.getBufNr(),
    }
    for k, v in pairs(contexts) do
        contexts[k]:setup(opts)
        v:setIndex(k)
        v:setRender(M.refreshBuffer)
        local entry = v:getEntryKey()
        vim.keymap.set("n", entry, function()
            changeContextIndex(k)
            M.refreshBuffer()
        end, remapOpts)
        table.insert(tabline.permanent, { key = entry, name = v:getName(), index = k })
    end

    for _, v in pairs(contexts) do
        setSubContextToArray(v)
    end
end

local function centerString(str)
    local padding = math.floor((width - #str) / 2)
    return string.rep(" ", padding) .. str
end
local tabNameWidth = 20
local tablineStart = 2
function M.getLines()
    local topLines = {}
    table.insert(topLines, centerString("~~ Pineapple ~~"))
    local secondLine = "  "
    local len = 0
    for _, v in ipairs(tabline.permanent) do
        secondLine = secondLine .. v.name .. " (" .. v.key .. ") "
        while (#secondLine - tablineStart) % tabNameWidth ~= 0 do
            secondLine = secondLine .. " "
        end
        len = len + 1
    end
    for _, v in ipairs(tabline.temporary) do
        secondLine = secondLine .. v.name .. " (" .. v.key .. ") "
        while (#secondLine - tablineStart) % tabNameWidth ~= 0 do
            secondLine = secondLine .. " "
        end
    end
    table.insert(topLines, secondLine)
    table.insert(topLines, string.rep("-", width))
    local keymaps = contexts[contextIndex]:getKeymaps(data)
    for _, kmp in ipairs(keymaps) do
        local line = "  " .. kmp.key .. ": " .. kmp.desc
        if kmp.isGroup then
            for _, sub in ipairs(kmp.subKeymaps) do
                line = line .. "  ..." .. sub.desc .. ": " .. sub.key
            end
        end
        table.insert(topLines, line)
    end

    local lines = contexts[contextIndex]:getLines(data)

    local ret = {}
    for _, line in ipairs(topLines) do
        table.insert(ret, line)
    end
    for _, line in ipairs(lines) do
        table.insert(ret, line)
    end
    return ret
end

function M.highlight(row, colStart, colEnd, hlGroup)
    vim.api.nvim_buf_add_highlight(M.getBufNr(), M.getNsId(), hlGroup, row, colStart, colEnd)
end

function M.makeHighlight(name, fg, bg)
    name = "_pineapple_" .. name
    vim.api.nvim_set_hl(M.getNsId(), name, {
        bg = bg,
        foreground = fg,
    })
    return name
end

-- local hlType = "Visual"
-- function M.yeet(h)
--     hlType = h
--     M.refreshBuffer()
-- end

local tablineInactiveHl = "CursorLine"
local tablineActiveHl = "Visual"
local keyHl = "Operator"

function M.addHighlights()
    if winId == nil or not vim.api.nvim_win_is_valid(winId) then
        return
    end
    local keymaps = contexts[contextIndex]:getKeymaps(data)
    local line = 3
    vim.api.nvim_win_set_hl_ns(winId, M.getNsId())
    for _, kmp in ipairs(keymaps) do
        if kmp.isGroup then
            M.highlight(line, 2, 3, "Operator")
            local col = 5
            col = #kmp.desc + col
            for _, sub in ipairs(kmp.subKeymaps) do
                col = col + 5 + #sub.desc + 2
                M.highlight(line, col, col + 1, "Constant")
                col = col + 1
            end
        else
            M.highlight(line, 2, 3, "Operator")
        end
        line = line + 1
    end
    contexts[contextIndex]:addHighlights(data, M.highlight, M.makeHighlight)
    local line2 = vim.api.nvim_buf_get_lines(M.getBufNr(), 1, 2, false)[1]
    local i = tablineStart - 1
    local tablineIndex = 1
    while i < #line2 - 2 do
        local tablineEntry = {}
        if tablineIndex > #tabline.permanent then
            tablineEntry = tabline.temporary[tablineIndex - #tabline.permanent]
        else
            tablineEntry = tabline.permanent[tablineIndex]
        end

        local tablineActive = tablineEntry.index == contextIndex
        local hlType = ""
        if tablineActive then
            hlType = tablineActiveHl
        else
            hlType = tablineInactiveHl
        end
        vim.api.nvim_buf_add_highlight(M.getBufNr(), M.getNsId(), hlType, 1, i, i + tabNameWidth - 1)
        vim.api.nvim_buf_add_highlight(
            M.getBufNr(),
            M.getNsId(),
            keyHl,
            1,
            i + #tablineEntry.name + 2,
            i + #tablineEntry.name + 5
        )
        i = i + tabNameWidth
        tablineIndex = tablineIndex + 1
    end
end

function M.setRemaps()
    local buf = M.getBufNr()
    for k, _ in pairs(keysToUnmap) do
        local ok, _ = pcall(vim.api.nvim_buf_del_keymap, buf, "n", k)
        if not ok then
            keysToUnmap = {}
            refreshEntryKeys()
        end
    end
    tabline.temporary = {}
    keysToUnmap = {}
    local opts = {
        buffer = M.getBufNr(),
    }
    local keymaps = contexts[contextIndex]:getKeymaps(data)
    for _, keymap in ipairs(keymaps) do
        if keymap.isGroup then
            local baseKey = keymap.key
            local baseDesc = keymap.desc .. " "
            for _, sub in ipairs(keymap.subKeymaps) do
                if sub.isGroup then
                    error("Can not nest pineapple keymap groups more than 2 layers deep")
                end
                opts.desc = baseDesc .. sub.desc
                if sub.fn ~= nil then
                    vim.keymap.set("n", baseKey .. sub.key, sub.fn, opts)
                end
                keysToUnmap[baseKey .. sub.key] = true
                opts.desc = nil
            end
        else
            opts.desc = keymap.desc
            if keymap.fn ~= nil then
                vim.keymap.set("n", keymap.key, keymap.fn, opts)
            end
            keysToUnmap[keymap.key] = true
            opts.desc = nil
        end
    end
    for _, subCtx in ipairs(contexts[contextIndex]:getSubContexts()) do
        local entry = subCtx:getEntryKey()
        local function fn()
            changeContextIndex(subCtx:getIndex())
            M.refreshBuffer()
        end
        vim.keymap.set("n", entry, fn, opts)
        keysToUnmap[entry] = true

        table.insert(tabline.temporary, { key = entry, name = subCtx:getName(), index = subCtx:getIndex() })
        -- tempKeysToContext[entry] = subCtx:getName()
    end

    local found = false
    for _, v in ipairs(tabline.permanent) do
        if v.key == contexts[contextIndex]:getEntryKey() then
            found = true
            break
        end
    end

    if not found then
        table.insert(tabline.temporary, {
            key = contexts[contextIndex]:getEntryKey(),
            name = contexts[contextIndex]:getName(),
            index = contexts[contextIndex]:getIndex(),
        })
    end
end

return M
