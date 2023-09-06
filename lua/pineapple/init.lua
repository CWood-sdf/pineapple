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

local exampleCode = {
    {
        { "\" Returns true if the color hex value is light", "vimLineComment" },
    },
    {
        { "function",          "vimCommand" },
        { "! IsHexColorLight", "vimFunction" },
        { "(",                 "vimParenSep" },
        { "color",             "vimOperParen" },
        { ")",                 "vimParenSep" },
        { " ",                 "vimFuncBody" },
        { "abort",             "vimIsCommand" },
    },
    {
        { "  ",          "vimFuncBody" },
        { "let",         "vimLet" },
        { " ",           "vimFuncBody" },
        { "l:raw_color", "vimVar" },
        { " ",           "vimFuncBody" },
        { "=",           "vimOper" },
        { " ",           "vimFuncBody" },
        { "trim",        "vimFuncName" },
        { "(",           "vimParenSep" },
        { "a:color",     "vimFuncVar" },
        { ", ",          "vimOperParen" },
        { "'#'",         "vimString" },
        { ")",           "vimParenSep" },
    },
    {
    },
    {
        { "  ",            "vimFuncBody" },
        { "let",           "vimLet" },
        { " ",             "vimFuncBody" },
        { "l:red",         "vimVar" },
        { " ",             "vimFuncBody" },
        { "=",             "vimOper" },
        { " ",             "vimFuncBody" },
        { "str2nr",        "vimFuncName" },
        { "(",             "vimParenSep" },
        { "substitute",    "vimSubst" },
        { "(",             "vimParenSep" },
        { "l:raw_color, ", "vimOperParen" },
        { "'(.{2}).{4}'",  "vimString" },
        { ", ",            "vimOperParen" },
        { "'1'",           "vimString" },
        { ", ",            "vimOperParen" },
        { "'g'",           "vimString" },
        { ")",             "vimParenSep" },
        { ", ",            "vimFuncBody" },
        { "16",            "vimNumber" },
        { ")",             "vimParenSep" },
    },
    {
        { "  ",               "vimFuncBody" },
        { "let",              "vimLet" },
        { " ",                "vimFuncBody" },
        { "l:green",          "vimVar" },
        { " ",                "vimFuncBody" },
        { "=",                "vimOper" },
        { " ",                "vimFuncBody" },
        { "str2nr",           "vimFuncName" },
        { "(",                "vimParenSep" },
        { "substitute",       "vimSubst" },
        { "(",                "vimParenSep" },
        { "l:raw_color, ",    "vimOperParen" },
        { "'.{2}(.{2}).{2}'", "vimString" },
        { ", ",               "vimOperParen" },
        { "'1'",              "vimString" },
        { ", ",               "vimOperParen" },
        { "'g'",              "vimString" },
        { ")",                "vimParenSep" },
        { ", ",               "vimFuncBody" },
        { "16",               "vimNumber" },
        { ")",                "vimParenSep" },
    },
    {
        { "  ",            "vimFuncBody" },
        { "let",           "vimLet" },
        { " ",             "vimFuncBody" },
        { "l:blue",        "vimVar" },
        { " ",             "vimFuncBody" },
        { "=",             "vimOper" },
        { " ",             "vimFuncBody" },
        { "str2nr",        "vimFuncName" },
        { "(",             "vimParenSep" },
        { "substitute",    "vimSubst" },
        { "(",             "vimParenSep" },
        { "l:raw_color, ", "vimOperParen" },
        { "'.{4}(.{2})'",  "vimString" },
        { ", ",            "vimOperParen" },
        { "'1'",           "vimString" },
        { ", ",            "vimOperParen" },
        { "'g'",           "vimString" },
        { ")",             "vimParenSep" },
        { ", ",            "vimFuncBody" },
        { "16",            "vimNumber" },
        { ")",             "vimParenSep" },
    },
    {
    },
    {
        { "  ",           "vimFuncBody" },
        { "let",          "vimLet" },
        { " ",            "vimFuncBody" },
        { "l:brightness", "vimVar" },
        { " ",            "vimFuncBody" },
        { "=",            "vimOper" },
        { " ",            "vimFuncBody" },
        { "((",           "vimParenSep" },
        { "l:red * ",     "vimOperParen" },
        { "299",          "vimNumber" },
        { ")",            "vimParenSep" },
        { " ",            "vimOperParen" },
        { "+",            "vimOper" },
        { " ",            "vimOperParen" },
        { "(",            "vimParenSep" },
        { "l:green * ",   "vimOperParen" },
        { "587",          "vimNumber" },
        { ")",            "vimParenSep" },
        { " ",            "vimOperParen" },
        { "+",            "vimOper" },
        { " ",            "vimOperParen" },
        { "(",            "vimParenSep" },
        { "l:blue * ",    "vimOperParen" },
        { "114",          "vimNumber" },
        { "))",           "vimParenSep" },
        { " / ",          "vimFuncBody" },
        { "1000",         "vimNumber" },
    },
    {
    },
    {
        { "  ",           "vimFuncBody" },
        { "return",       "vimNotFunc" },
        { " ",            "vimFuncBody" },
        { "l:brightness", "vimVar" },
        { " ",            "vimFuncBody" },
        { ">",            "vimOper" },
        { " ",            "vimFuncBody" },
        { "155",          "vimNumber" },
    },
    {
        { "endfunction", "vimCommand" },
    },

}
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
        ns_id = vim.api.nvim_create_namespace("pineapple")
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
    vim.api.nvim_set_hl(ns, "_pineapple_" .. name, {
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
        local highlights = {}
        for i = 1, #exampleCode do
            for j = 1, #exampleCode[i] do
                highlights[#exampleCode[i][j][2]] = true
            end
        end
        for k, _ in pairs(highlights) do
            useHighlight(context[2], k)
        end
        local startLine = #values[context[2]].vimColorSchemes + 6
        for line = 1, #exampleCode do
            local acc = 0
            for i = 1, #exampleCode[line] do
                if i == #exampleCode[line][i] then
                    vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_pineapple_" .. exampleCode[line][i][2],
                        startLine + line - 1,
                        acc, -1)
                else
                    vim.api.nvim_buf_add_highlight(getBuffer(), ns, "_pineapple_" .. exampleCode[line][i][2],
                        startLine + line - 1,
                        acc, acc + #exampleCode[line][i][1])
                end
                acc = acc + #exampleCode[line][i][1]
            end
        end
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
    local firstLine = "~~ Pineapple ~~"
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

        local code = ""
        for _, line in pairs(exampleCode) do
            local newLine = ""
            for _, word in pairs(line) do
                newLine = newLine .. word[1]
            end
            code = code .. newLine .. "\n"
        end
        --         local code = [[
        -- " Comment
        -- function! IsHexColorLight(hexColor) abort
        --   let l:raw_color = trim(a:color, '#')
        --   let l:red = str2nr(substitute(l:raw_color, '(.{2}).{4}', '1', 'g'), 16)
        --   let l:green = str2nr(substitute(l:raw_color, '.{2}(.{2}).{2}', '1', 'g'), 16)
        --   let l:blue = str2nr(substitute(l:raw_color, '.{4}(.{2})', '1', 'g'), 16)
        --   let l:brightness = ((l:red * 299) + (l:green * 587) + (l:blue * 114)) / 1000
        --   return l:brightness > 155
        -- endfunction
        -- ]]
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
    local tempValues = require("pineapple.data")
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
    vim.api.nvim_create_user_command("Pineapple", function(cmd_opts)
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
