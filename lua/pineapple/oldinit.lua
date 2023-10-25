local M = {}
-- from https://stackoverflow.com/questions/1426954/split-string-in-lua
M.split = function(pString, pPattern)
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
M.installedThemes = {}
M.installFile = nil
M.remaps = {}

M.values = nil
M.bufnr = nil
M.width = nil
M.height = nil
M.getLineAcross = function()
    local line = ""
    for _ = 1, M.width do
        line = line .. "-"
    end
    return line
end
M.getNameAtMiddle = function()
    local line = "~~ Pineapple ~~"
    -- make firstLine centered
    local padding = math.floor((M.width - #line) / 2)
    for _ = 1, padding do
        line = " " .. line
    end
    return line
end

M.globalTopMatter = {
    M.getNameAtMiddle,
    M.getLineAcross,
}

-- the stuff at the top of the screen
M.topMatter = {
    home = {
    }
}

M.exampleCode = nil
M.context = nil
M.ns_id = nil
M.schemeIndex = 1
M.getBuffer = function()
    if M.bufnr == nil then
        error("bufnr is nil, call refreshBuffer() first")
    end
    return M.bufnr
end
M.getNs = function()
    if M.ns_id == nil then
        M.ns_id = vim.api.nvim_create_namespace("pineapple")
    end
    return M.ns_id
end

M.getHighlightName = function(line)
    local name = "_pineapple_" .. line[2] .. "_" .. line[3]
    return name
end
M.useHighlight = function(valIndex, fgName, bgName)
    local name = M.getHighlightName({ "", fgName, bgName })


    local ns = M.getNs()
    local mode = vim.o.background
    if M.values == nil then
        error("values is nil, call setup() first")
    end
    if M.values[valIndex] == nil then
        error("invalid valIndex: " .. valIndex)
    end
    if M.values[valIndex].vimColorSchemes[M.schemeIndex] == nil then
        error("invalid schemeIndex: " .. M.schemeIndex)
    end
    if M.values[valIndex].vimColorSchemes[M.schemeIndex].data[mode] == nil then
        if mode == "dark" then
            mode = "light"
        else
            mode = "dark"
        end
    end
    if M.values[valIndex].vimColorSchemes[M.schemeIndex].data[mode] == nil then
        return {}
    end
    local bg = M.values[valIndex].vimColorSchemes[M.schemeIndex].data[mode][bgName] or "#000000"
    local fg = M.values[valIndex].vimColorSchemes[M.schemeIndex].data[mode][fgName] or "#ffffff"
    vim.api.nvim_set_hl(ns, name, {
        bg = bg,
        foreground = fg,
    })
end

M.addContextHighlights = function()
    if M.context == nil then
        error("context is nil, call setup() first")
    end
    -- for _, v in pairs(namespaces) do
    --     vim.api.nvim_buf_clear_namespace(getBuffer(), v, 0, -1)
    -- end
    if M.values == nil then
        error("values is nil, call setup() first")
    end

    if M.context[1] == "view" then
        local ns = M.getNs()
        vim.api.nvim_win_set_hl_ns(0, ns)
        local highlights = {}
        for i = 1, #M.exampleCode do
            for j = 1, #M.exampleCode[i] do
                highlights[M.exampleCode[i][j][2]] = M.exampleCode[i][j][3]
            end
        end
        for k, v in pairs(highlights) do
            M.useHighlight(M.context[2], k, v)
        end
        local startLine = #M.values[M.context[2]].vimColorSchemes + 6
        for line = 1, #M.exampleCode do
            local acc = 0
            for i = 1, #M.exampleCode[line] do
                if i == #M.exampleCode[line] then
                    vim.api.nvim_buf_add_highlight(M.getBuffer(), ns, M.getHighlightName(M.exampleCode[line][i]),
                        startLine + line - 1,
                        acc, -1)
                else
                    vim.api.nvim_buf_add_highlight(M.getBuffer(), ns, M.getHighlightName(M.exampleCode[line][i]),
                        startLine + line - 1,
                        acc, acc + #M.exampleCode[line][i][1])
                end
                acc = acc + #M.exampleCode[line][i][1]
            end
        end
    end
end
M.getLinesFromContext = function()
    if M.context == nil then
        error("context is nil, call setup() first")
    end

    if M.values == nil then
        error("values is nil, call setup() first")
        return {}
    end
    local lines = {}
    for _, v in pairs(M.globalTopMatter) do
        if type(v) == "function" then
            table.insert(lines, v())
        else
            table.insert(lines, v)
        end
    end
    if M.topMatter[M.context[1]] ~= nil then
        for _, v in pairs(M.topMatter[M.context[1]]) do
            if type(v) == "function" then
                table.insert(lines, v())
            else
                table.insert(lines, v)
            end
        end
    end

    if M.context[1] == "home" then
        for _, v in pairs(M.values) do
            table.insert(lines, "  " .. v.name)
        end
    elseif M.context[1] == "view" then
        table.insert(lines, "  " .. M.values[M.context[2]].name .. " (" .. M.values[M.context[2]].githubUrl .. ")")
        table.insert(lines, "  " .. M.values[M.context[2]].description)
        table.insert(lines, "  Variants:")
        for _, v in pairs(M.values[M.context[2]].vimColorSchemes) do
            table.insert(lines, "    " .. v.name)
        end
        table.insert(lines, "  ")

        local code = ""
        for _, line in pairs(M.exampleCode) do
            local newLine = ""
            for _, word in pairs(line) do
                newLine = newLine .. word[1]
            end
            while #newLine < M.width - 4 do
                newLine = newLine .. " "
            end
            code = code .. newLine .. "\n"
        end
        for _, line in pairs(M.split(code, "\n")) do
            table.insert(lines, line)
        end
    elseif M.context[1] == "installed" then
        local line = #M.globalTopMatter
        local lineToVariant = {}
        for _, v in pairs(M.installedThemes) do
            local installedVariants = {}
            for _, val in pairs(M.values) do
                if val.githubUrl == v then
                    for _, vimColorScheme in pairs(val.vimColorSchemes) do
                        if vimColorScheme.data ~= nil and ((vimColorScheme.data.light ~= nil and vimColorScheme.data.light.vimNumber ~= nil) or (vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.vimNumber ~= nil)) then
                            table.insert(installedVariants, vimColorScheme.name)
                        end
                    end
                end
            end
            line = line + 1
            table.insert(lines, "  " .. v)
            for _, variant in pairs(installedVariants) do
                line = line + 1
                lineToVariant[line] = variant
                table.insert(lines, "    " .. variant)
            end
        end
        M.context[2] = lineToVariant
    end
    return lines
end
M.refreshBuffer = function()
    if M.bufnr == nil then
        M.bufnr = vim.api.nvim_create_buf(false, true)
    end
    local lines = M.getLinesFromContext()
    vim.api.nvim_buf_set_option(M.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(M.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, lines)
    M.addContextHighlights()
    vim.api.nvim_buf_set_option(M.bufnr, "modifiable", false)
end
M.setKeymapsForContext = function()
    for _, v in pairs(M.remaps) do
        vim.keymap.del("n", v, { buffer = true })
    end
    if M.context == nil then
        error("context is nil, call setup() first")
    end
    if M.values == nil then
        error("values is nil, call setup() first")
    end
    vim.keymap.set("n", "q", function()
        vim.cmd("q")
    end, {
        buffer = M.getBuffer(),
    })
    if M.context[1] == "home" then
        vim.keymap.set("n", "<CR>", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            print("colorscheme " .. M.values[line].name)
        end, {
            buffer = M.getBuffer(),
        })

        vim.keymap.set("n", "I", function()
            M.context = {
                "installed",
                "",
            }
            M.refreshBuffer()
            M.setKeymapsForContext()
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "u", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            print(M.values[line].githubUrl)
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "t", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            local s = ""
            for _, v in pairs(M.values[line].vimColorSchemes) do
                -- if v.valid == true then
                s = s .. v.name .. " "
                -- end
            end
            print(s)
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "v", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            M.context = {
                "view",
                line,
            }
            M.schemeIndex = 1
            M.refreshBuffer()
            M.setKeymapsForContext()
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "i", function()
            local line = vim.fn.line(".") - 2
            if line < 1 then
                return
            end
            if M.installFile == nil then
                error("installFile is nil, call setup() first")
            end
            for _, v in pairs(M.installedThemes) do
                if v == M.values[line].githubUrl then
                    print("already installed")
                    return
                end
            end
            local fPath = string.gsub(M.installFile, "%.", "/")
            local fLoc = os.getenv("HOME") .. "/.config/nvim/lua/" .. fPath .. ".lua"
            local f = io.open(fLoc, "w")
            if f == nil then
                fLoc = os.getenv("HOME") .. "/.config/nvim/lua/" .. fPath .. "/init.lua"
                f = io.open(fLoc, "w")
            end
            if f == nil then
                return false
            end
            local s = "return {\n"
            for _, v in pairs(M.installedThemes) do
                s = s .. "    \"" .. v .. "\",\n"
            end
            s = s .. "    \"" .. M.values[line].githubUrl .. "\",\n"
            s = s .. "}\n"
            f:write(s)
            f:close()
        end, {
            buffer = M.getBuffer(),
        })
        M.remaps = {
            "<CR>",
            "i",
            "u",
            "I",
            "t",
            "v",
        }
    elseif M.context[1] == "view" then
        vim.keymap.set("n", "b", function()
            M.context = {
                "home",
                "",
            }
            M.refreshBuffer()
            M.setKeymapsForContext()
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "p", function()
            local line = vim.fn.line(".") - 5
            if line < 1 then
                return
            end
            if line > #M.values[M.context[2]].vimColorSchemes then
                return
            end
            M.schemeIndex = line
            M.refreshBuffer()
            M.setKeymapsForContext()
        end, {
            buffer = M.getBuffer(),
        })
        M.remaps = {
            "b",
            "p"
        }
    elseif M.context[1] == "installed" then
        vim.keymap.set("n", "b", function()
            M.context = {
                "home",
                "",
            }
            M.refreshBuffer()
            M.setKeymapsForContext()
        end, {
            buffer = M.getBuffer(),
        })
        vim.keymap.set("n", "u", function()
            local line = vim.fn.line(".")
            local lineToVariant = M.context[2]
            if lineToVariant[line] == nil then
                return
            end
            vim.cmd("colorscheme " .. lineToVariant[line])
            if M.opts.colorschemeFile == nil then
                error("colorschemeFile was not defined in setup()")
            else
                local file = io.open(os.getenv("HOME") .. "/.config/nvim/" .. M.opts.colorschemeFile, "w")
                if file == nil then
                    error("could not open file: " .. os.getenv("HOME") .. "/.config/nvim/" .. M.opts.colorschemeFile)
                end
                file:write([[vim.cmd("colorscheme ]] .. lineToVariant[line] .. [[")]])
                file:close()
            end
        end, {
            buffer = M.getBuffer(),
        })
        M.remaps = {
            "b",
        }
    end
end
M.opts = {}
M.setup = function(opts)
    M.opts = opts
end
M.actualSetup = function()
    M.exampleCode = require("pineapple.example-code")
    local opts = M.opts
    if opts.installedRegistry == nil then
        opts.installedRegistry = "pineapple-installed"
    end
    M.installFile = opts.installedRegistry
    M.installedThemes = require(M.installFile)
    for i = 1, #M.exampleCode do
        local lineNum = i .. " "
        while #lineNum < 5 do
            lineNum = " " .. lineNum
        end
        M.exampleCode[i][1][1] = " " .. M.exampleCode[i][1][1]
        if i == 3 then
            table.insert(M.exampleCode[i], 1, { lineNum, "CursorLineNrFg", "CursorLineNrBg" })
        else
            table.insert(M.exampleCode[i], 1, { lineNum, "LineNrFg", "LineNrBg" })
        end
    end


    local tempValues = require("pineapple.data")
    M.values = {}
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
            table.insert(M.values, tempVal)
        end
    end
    M.context = { "home", "" }
    for k, _ in pairs(M.values) do
        M.values[k].githubUrl = M.values[k].githubUrl:gsub("https://github.com/", "")
        if M.values[k].name == "vim" or M.values[k].name == "neovim" or M.values[k].name == "nvim" then
            M.values[k].name = M.split(M.values[k].githubUrl, "/")[1]
        end
    end
end
M.use = function(file)
    return require(file)
end

return M
