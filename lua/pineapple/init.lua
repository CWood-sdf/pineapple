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
        { "\" Returns true if the color hex value is light", "vimLineComment", "NormalBg" },
    },
    {
        { "function",          "vimCommand",   "NormalBg" },
        { "! IsHexColorLight", "vimFunction",  "NormalBg" },
        { "(",                 "vimParenSep",  "NormalBg" },
        { "color",             "vimOperParen", "NormalBg" },
        { ")",                 "vimParenSep",  "NormalBg" },
        { " ",                 "vimFuncBody",  "NormalBg" },
        { "abort",             "vimIsCommand", "NormalBg" },
    },
    {
        { "  ",          "vimFuncBody",  "NormalBg" },
        { "let",         "vimLet",       "NormalBg" },
        { " ",           "vimFuncBody",  "NormalBg" },
        { "l:raw_color", "vimVar",       "NormalBg" },
        { " ",           "vimFuncBody",  "NormalBg" },
        { "=",           "vimOper",      "NormalBg" },
        { " ",           "vimFuncBody",  "NormalBg" },
        { "trim",        "vimFuncName",  "NormalBg" },
        { "(",           "vimParenSep",  "NormalBg" },
        { "a:color",     "vimFuncVar",   "NormalBg" },
        { ", ",          "vimOperParen", "NormalBg" },
        { "'#'",         "vimString",    "NormalBg" },
        { ")",           "vimParenSep",  "NormalBg" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg" },
    },
    {
        { "  ",            "vimFuncBody",  "NormalBg" },
        { "let",           "vimLet",       "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "l:red",         "vimVar",       "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "=",             "vimOper",      "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "str2nr",        "vimFuncName",  "NormalBg" },
        { "(",             "vimParenSep",  "NormalBg" },
        { "substitute",    "vimSubst",     "NormalBg" },
        { "(",             "vimParenSep",  "NormalBg" },
        { "l:raw_color, ", "vimOperParen", "NormalBg" },
        { "'(.{2}).{4}'",  "vimString",    "NormalBg" },
        { ", ",            "vimOperParen", "NormalBg" },
        { "'1'",           "vimString",    "NormalBg" },
        { ", ",            "vimOperParen", "NormalBg" },
        { "'g'",           "vimString",    "NormalBg" },
        { ")",             "vimParenSep",  "NormalBg" },
        { ", ",            "vimFuncBody",  "NormalBg" },
        { "16",            "vimNumber",    "NormalBg" },
        { ")",             "vimParenSep",  "NormalBg" },
    },
    {
        { "  ",               "vimFuncBody",  "NormalBg" },
        { "let",              "vimLet",       "NormalBg" },
        { " ",                "vimFuncBody",  "NormalBg" },
        { "l:green",          "vimVar",       "NormalBg" },
        { " ",                "vimFuncBody",  "NormalBg" },
        { "=",                "vimOper",      "NormalBg" },
        { " ",                "vimFuncBody",  "NormalBg" },
        { "str2nr",           "vimFuncName",  "NormalBg" },
        { "(",                "vimParenSep",  "NormalBg" },
        { "substitute",       "vimSubst",     "NormalBg" },
        { "(",                "vimParenSep",  "NormalBg" },
        { "l:raw_color, ",    "vimOperParen", "NormalBg" },
        { "'.{2}(.{2}).{2}'", "vimString",    "NormalBg" },
        { ", ",               "vimOperParen", "NormalBg" },
        { "'1'",              "vimString",    "NormalBg" },
        { ", ",               "vimOperParen", "NormalBg" },
        { "'g'",              "vimString",    "NormalBg" },
        { ")",                "vimParenSep",  "NormalBg" },
        { ", ",               "vimFuncBody",  "NormalBg" },
        { "16",               "vimNumber",    "NormalBg" },
        { ")",                "vimParenSep",  "NormalBg" },
    },
    {
        { "  ",            "vimFuncBody",  "NormalBg" },
        { "let",           "vimLet",       "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "l:blue",        "vimVar",       "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "=",             "vimOper",      "NormalBg" },
        { " ",             "vimFuncBody",  "NormalBg" },
        { "str2nr",        "vimFuncName",  "NormalBg" },
        { "(",             "vimParenSep",  "NormalBg" },
        { "substitute",    "vimSubst",     "NormalBg" },
        { "(",             "vimParenSep",  "NormalBg" },
        { "l:raw_color, ", "vimOperParen", "NormalBg" },
        { "'.{4}(.{2})'",  "vimString",    "NormalBg" },
        { ", ",            "vimOperParen", "NormalBg" },
        { "'1'",           "vimString",    "NormalBg" },
        { ", ",            "vimOperParen", "NormalBg" },
        { "'g'",           "vimString",    "NormalBg" },
        { ")",             "vimParenSep",  "NormalBg" },
        { ", ",            "vimFuncBody",  "NormalBg" },
        { "16",            "vimNumber",    "NormalBg" },
        { ")",             "vimParenSep",  "NormalBg" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg" },
    },
    {
        { "  ",           "vimFuncBody",  "NormalBg" },
        { "let",          "vimLet",       "NormalBg" },
        { " ",            "vimFuncBody",  "NormalBg" },
        { "l:brightness", "vimVar",       "NormalBg" },
        { " ",            "vimFuncBody",  "NormalBg" },
        { "=",            "vimOper",      "NormalBg" },
        { " ",            "vimFuncBody",  "NormalBg" },
        { "((",           "vimParenSep",  "NormalBg" },
        { "l:red * ",     "vimOperParen", "NormalBg" },
        { "299",          "vimNumber",    "NormalBg" },
        { ")",            "vimParenSep",  "NormalBg" },
        { " ",            "vimOperParen", "NormalBg" },
        { "+",            "vimOper",      "NormalBg" },
        { " ",            "vimOperParen", "NormalBg" },
        { "(",            "vimParenSep",  "NormalBg" },
        { "l:green * ",   "vimOperParen", "NormalBg" },
        { "587",          "vimNumber",    "NormalBg" },
        { ")",            "vimParenSep",  "NormalBg" },
        { " ",            "vimOperParen", "NormalBg" },
        { "+",            "vimOper",      "NormalBg" },
        { " ",            "vimOperParen", "NormalBg" },
        { "(",            "vimParenSep",  "NormalBg" },
        { "l:blue * ",    "vimOperParen", "NormalBg" },
        { "114",          "vimNumber",    "NormalBg" },
        { "))",           "vimParenSep",  "NormalBg" },
        { " / ",          "vimFuncBody",  "NormalBg" },
        { "1000",         "vimNumber",    "NormalBg" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg" },
    },
    {
        { "  ",           "vimFuncBody", "NormalBg" },
        { "return",       "vimNotFunc",  "NormalBg" },
        { " ",            "vimFuncBody", "NormalBg" },
        { "l:brightness", "vimVar",      "NormalBg" },
        { " ",            "vimFuncBody", "NormalBg" },
        { ">",            "vimOper",     "NormalBg" },
        { " ",            "vimFuncBody", "NormalBg" },
        { "155",          "vimNumber",   "NormalBg" },
    },
    {
        { "endfunction", "vimCommand", "NormalBg" },
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

local function getHighlightName(line)
    local name = "_pineapple_" .. line[2] .. "_" .. line[3]
    return name
end
local function useHighlight(valIndex, fgName, bgName)
    local name = getHighlightName({ "", fgName, bgName })


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
    vim.api.nvim_set_hl(ns, name, {
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
                highlights[exampleCode[i][j][2]] = exampleCode[i][j][3]
            end
        end
        for k, v in pairs(highlights) do
            useHighlight(context[2], k, v)
        end
        local startLine = #values[context[2]].vimColorSchemes + 6
        for line = 1, #exampleCode do
            local acc = 0
            for i = 1, #exampleCode[line] do
                if i == #exampleCode[line] then
                    vim.api.nvim_buf_add_highlight(getBuffer(), ns, getHighlightName(exampleCode[line][i]),
                        startLine + line - 1,
                        acc, -1)
                else
                    vim.api.nvim_buf_add_highlight(getBuffer(), ns, getHighlightName(exampleCode[line][i]),
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
        table.insert(lines, "  " .. values[context[2]].name .. " (" .. values[context[2]].githubUrl .. ")")
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
            while #newLine < width - 4 do
                newLine = newLine .. " "
            end
            code = code .. newLine .. "\n"
        end
        for _, line in pairs(split(code, "\n")) do
            table.insert(lines, line)
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
            if line > #values[context[2]].vimColorSchemes then
                return
            end
            schemeIndex = line
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
    for i = 1, #exampleCode do
        local lineNum = i .. " "
        while #lineNum < 5 do
            lineNum = " " .. lineNum
        end
        exampleCode[i][1][1] = " " .. exampleCode[i][1][1]
        if i == 3 then
            table.insert(exampleCode[i], 1, { lineNum, "CursorLineNrFg", "CursorLineNrBg" })
        else
            table.insert(exampleCode[i], 1, { lineNum, "LineNrFg", "LineNrBg" })
        end
    end


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
