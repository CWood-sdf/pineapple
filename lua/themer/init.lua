local M = {}
-- from https://stackoverflow.com/questions/1426954/split-string-in-lua
local function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

local remaps = {}
local values = nil
local bufnr = nil
local width = nil
local height = nil
local function getBuffer()
    if bufnr == nil then
        error("bufnr is nil, call refreshBuffer() first")
    end
    return bufnr
end
local context = nil
local ns_id = nil
local schemeIndex = 1
local function getNs()
    if ns_id == nil then
        ns_id = vim.api.nvim_create_namespace("themer")
    end
    return ns_id
end
local function useHighlight(valIndex, fgName, bgName)
    bgName = bgName or "NormalBg"
    local name = fgName

    local ns = getNs()
    local mode = vim.o.background
    if values == nil then
        error("values is nil, call setup() first")
    end
    if values[valIndex] == nil then
        error("invalid valIndex: " .. valIndex)
    end
    if values[valIndex].vimColorSchemes[schemeIndex] == nil then
        error("invalid schemeIndex: " .. schemeIndex)
    end
    if values[valIndex].vimColorSchemes[schemeIndex].data[mode] == nil then
        if mode == "dark" then
            mode = "light"
        else
            mode = "dark"
        end
    end
    if values[valIndex].vimColorSchemes[schemeIndex].data[mode] == nil then
        return {}
    end
    local bg = values[valIndex].vimColorSchemes[schemeIndex].data[mode][bgName] or "#000000"
    local fg = values[valIndex].vimColorSchemes[schemeIndex].data[mode][fgName] or "#ffffff"
    vim.api.nvim_set_hl(ns, "_themer_" .. name, {
        bg = bg,
        foreground = fg,
    })
end

local function addContextHighlights()
    if context == nil then
        error("context is nil, call setup() first")
    end
    -- for _, v in pairs(namespaces) do
    --     vim.api.nvim_buf_clear_namespace(getBuffer(), v, 0, -1)
    -- end
    if values == nil then
        error("values is nil, call setup() first")
    end

    if context[1] == "view" then
        local ns = getNs()
        vim.api.nvim_win_set_hl_ns(0, ns)
        useHighlight(context[2], "vimLineComment")
        useHighlight(context[2], "vimCommand")
        useHighlight(context[2], "vimFunction")
        useHighlight(context[2], "vimParenSep")
        useHighlight(context[2], "vimOperParen")
        useHighlight(context[2], "vimFuncBody")
        useHighlight(context[2], "vimIsCommand")
        useHighlight(context[2], "vimLet")
        useHighlight(context[2], "vimVar")
        useHighlight(context[2], "vimOper")
        useHighlight(context[2], "vimFuncName")
        useHighlight(context[2], "vimFuncVar")
        useHighlight(context[2], "vimString")
        useHighlight(context[2], "vimSubst")
        useHighlight(context[2], "vimNumber")
        useHighlight(context[2], "vimNotFunc")
        local startLine = #values[context[2]].vimColorSchemes + 6
        -- comment line
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLineComment", startLine, 0, -1)
        -- fn line
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimCommand", startLine + 1, 0, 10)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFunction", startLine + 1, 10, 27)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 1, 27, 28)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 1, 28, 36)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 1, 36, 37)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 1, 37, 38)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimIsCommand", startLine + 1, 38, -1)
        -- let raw_color
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 2, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLet", startLine + 2, 4, 7)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 2, 7, 8)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 2, 8, 19)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 2, 19, 20)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 2, 20, 21)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 2, 21, 22)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncName", startLine + 2, 22, 26)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 2, 26, 27)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncVar", startLine + 2, 27, 34)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 2, 34, 36)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 2, 36, 39)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 2, 39, -1)
        -- let red
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 3, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLet", startLine + 3, 4, 7)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 3, 7, 8)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 3, 8, 13)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 3, 13, 14)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 3, 14, 15)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 3, 15, 16)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncName", startLine + 3, 16, 22)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 3, 22, 23)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimSubst", startLine + 3, 23, 33)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 3, 33, 34)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 3, 34, 47)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 3, 47, 59)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 3, 59, 61)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 3, 61, 64)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 3, 64, 66)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 3, 66, 69)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 3, 69, 70)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 3, 70, 72)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 3, 72, 74)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 3, 74, -1)
        -- let green
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 4, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLet", startLine + 4, 4, 7)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 4, 7, 8)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 4, 8, 15)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 4, 15, 16)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 4, 16, 17)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 4, 17, 18)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncName", startLine + 4, 18, 24)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 4, 24, 25)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimSubst", startLine + 4, 25, 35)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 4, 35, 36)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 4, 36, 49)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 4, 49, 65)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 4, 65, 67)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 4, 67, 70)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 4, 70, 72)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 4, 72, 75)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 4, 75, 76)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 4, 76, 78)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 4, 78, 80)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 4, 80, -1)
        -- let blue
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 5, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLet", startLine + 5, 4, 7)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 5, 7, 8)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 5, 8, 14)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 5, 14, 15)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 5, 15, 16)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 5, 16, 17)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncName", startLine + 5, 17, 23)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 5, 23, 24)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimSubst", startLine + 5, 24, 34)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 5, 34, 35)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 5, 35, 48)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 5, 48, 60)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 5, 60, 62)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 5, 62, 65)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 5, 65, 67)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimString", startLine + 5, 67, 70)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 5, 70, 71)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 5, 71, 73)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 5, 73, 75)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 5, 75, -1)
        -- let brightness
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 6, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimLet", startLine + 6, 4, 7)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 6, 7, 8)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 6, 8, 20)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 6, 20, 21)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 6, 21, 22)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 6, 22, 23)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 23, 25)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 25, 33)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 6, 33, 36)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 36, 37)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 37, 38)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 6, 38, 39)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 39, 40)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 40, 41)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 41, 51)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 6, 51, 54)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 54, 55)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 55, 56)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 6, 56, 57)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 57, 58)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 58, 59)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOperParen", startLine + 6, 59, 68)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 6, 68, 71)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimParenSep", startLine + 6, 71, 73)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 6, 73, 76)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 6, 76, -1)
        -- ret
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 7, 0, 4)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNotFunc", startLine + 7, 4, 10)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimFuncBody", startLine + 7, 10, 11)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimVar", startLine + 7, 11, 24)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimOper", startLine + 7, 24, 26)
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimNumber", startLine + 7, 26, -1)

        -- end
        vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_themer_vimCommand", startLine + 8, 0, -1)
        -- yeet
    end
end
local function getLinesFromContext()
    if context == nil then
        error("context is nil, call setup() first")
    end

    if values == nil then
        error("values is nil, call setup() first")
        return {}
    end
    local lines = {}
    local firstLine = "~~ Themer ~~"
    -- make firstLine centered
    local padding = math.floor((width - #firstLine) / 2)
    for _ = 1, padding do
        firstLine = " " .. firstLine
    end
    table.insert(lines, firstLine)
    local secondLine = ""
    for _ = 1, width do
        secondLine = secondLine .. "-"
    end
    table.insert(lines, secondLine)

    if context[1] == "home" then
        for _, v in pairs(values) do
            table.insert(lines, "  " .. v.name)
        end
    elseif context[1] == "view" then
        table.insert(lines, "  " .. values[context[2]].name .. "(" .. values[context[2]].githubUrl .. ")")
        table.insert(lines, "  " .. values[context[2]].description)
        table.insert(lines, "  Variants:")
        for _, v in pairs(values[context[2]].vimColorSchemes) do
            table.insert(lines, "    " .. v.name)
        end
        table.insert(lines, "  ")
        local code = [[
" Comment
function! IsHexColorLight(hexColor) abort
  let l:raw_color = trim(a:color, '#')
  let l:red = str2nr(substitute(l:raw_color, '(.{2}).{4}', '1', 'g'), 16)
  let l:green = str2nr(substitute(l:raw_color, '.{2}(.{2}).{2}', '1', 'g'), 16)
  let l:blue = str2nr(substitute(l:raw_color, '.{4}(.{2})', '1', 'g'), 16)
  let l:brightness = ((l:red * 299) + (l:green * 587) + (l:blue * 114)) / 1000
  return l:brightness > 155
endfunction
]]
        for _, line in pairs(split(code, "\n")) do
            local newLine = line
            while #newLine < width - 4 do
                newLine = newLine .. " "
            end
            table.insert(lines, "  " .. newLine)
        end
    end
    return lines
end
local function refreshBuffer()
    if bufnr == nil then
        bufnr = vim.api.nvim_create_buf(false, true)
    end
    local lines = getLinesFromContext()
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    addContextHighlights()
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end
local function setKeymapsForContext()
    for _, v in pairs(remaps) do
        vim.keymap.del("n", v, { buffer = true })
    end
    if context == nil then
        error("context is nil, call setup() first")
    end
    if values == nil then
        error("values is nil, call setup() first")
    end
    if context[1] == "home" then
        vim.keymap.set("n", "<CR>", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            print("colorscheme " .. values[line].name)
        end, {
            buffer = getBuffer(),
        })
        vim.keymap.set("n", "u", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            print(values[line].githubUrl)
        end, {
            buffer = getBuffer(),
        })
        vim.keymap.set("n", "t", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            local s = ""
            for _, v in pairs(values[line].vimColorSchemes) do
                -- if v.valid == true then
                s = s .. v.name .. " "
                -- end
            end
            print(s)
        end, {
            buffer = getBuffer(),
        })
        vim.keymap.set("n", "v", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            context = {
                "view",
                line,
            }
            schemeIndex = 1
            refreshBuffer()
            setKeymapsForContext()
        end, {
            buffer = getBuffer(),
        })
        remaps = {
            "<CR>",
            "u",
            "t",
            "v",
        }
    elseif context[1] == "view" then
        vim.keymap.set("n", "b", function()
            context = {
                "home",
                "",
            }
            refreshBuffer()
            setKeymapsForContext()
        end, {
            buffer = getBuffer(),
        })
        vim.keymap.set("n", "p", function()
            local line = vim.fn.line(".") - 5
            if line < 1 then
                return
            end
            print(#values[context[2]].vimColorSchemes)
            if line > #values[context[2]].vimColorSchemes then
                return
            end
            schemeIndex = line
            print(line)
            refreshBuffer()
            setKeymapsForContext()
        end, {
            buffer = getBuffer(),
        })
        remaps = {
            "b",
            "p"
        }
    end
end
M.setup = function(opts)
    local tempValues = require("themer.data")
    values = {}
    for _, v in pairs(tempValues) do
        local canInsert = true
        local tempVal = v
        if v.vimColorSchemes ~= nil then
            local newVimColorSchemes = {}
            for _, vimColorScheme in pairs(v.vimColorSchemes) do
                if vimColorScheme.data ~= nil and ((vimColorScheme.data.light ~= nil and vimColorScheme.data.light.vimNumber ~= nil) or (vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.vimNumber ~= nil)) then
                    table.insert(newVimColorSchemes, vimColorScheme)
                end
            end
            if #newVimColorSchemes == 0 then
                canInsert = false
            end
            tempVal.vimColorSchemes = newVimColorSchemes
        else
            canInsert = false
        end
        if canInsert then
            table.insert(values, tempVal)
        end
    end
    context = { "home", "" }
    for k, _ in pairs(values) do
        values[k].githubUrl = values[k].githubUrl:gsub("https://github.com/", "")
        if values[k].name == "vim" or values[k].name == "neovim" or values[k].name == "nvim" then
            values[k].name = split(values[k].githubUrl, "/")[1]
        end
    end
    vim.api.nvim_create_user_command("Themer", function(cmd_opts)
        local offsetX = 8
        local offsetY = 3
        width = vim.o.columns - offsetX * 2
        height = vim.o.lines - offsetY * 2 - 4
        refreshBuffer()
        vim.api.nvim_open_win(getBuffer(), true, {
            relative = "win",
            width = width,
            height = height,
            row = offsetY,
            col = offsetX,
            style = "minimal",
        })
        setKeymapsForContext()
        addContextHighlights()
    end, {})
end

return M
