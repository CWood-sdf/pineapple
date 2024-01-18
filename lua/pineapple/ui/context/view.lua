local makeContext = require("pineapple.ui.context.makeContext")

local viewCtx = {}

-- local remapLines = {
--     "  p: Preview",
-- }
local exampleStartLine = 0
local colorschemeIndex = 1

local exampleCode = {}
function viewCtx:filterEntries() end

---@return PineappleKeymap[]
function viewCtx:getKeymaps(context)
    ---@type PineappleKeymap[]
    return {
        {
            key = "p",
            fn = function()
                local line = vim.fn.line(".")
                local index = line + #context[1].vimColorSchemes - exampleStartLine + 1
                if index < 1 or index > #context[1].vimColorSchemes then
                    print("Not hovering over a colorscheme")
                    return
                end
                colorschemeIndex = index
                self.render()
            end,
            desc = "Preview",
            isGroup = false,
        },
        {
            key = "i",
            desc = "Install",
            fn = function()
                local githubUrl = context[1].githubUrl
                require('pineapple.installer').install(githubUrl)
            end,
            isGroup = false,
        },
    }
end

function viewCtx:getEntryKey()
    return "v"
end

---@param context table
---@param highlight  fun(row, colStart, colEnd, hlGroup: string)
---@param makeHighlight fun(name: string, fg: string, bg: string): string
function viewCtx:addHighlights(context, highlight, makeHighlight)
    local colorData = context[1].vimColorSchemes[colorschemeIndex].data
    if colorData[vim.o.background] == nil then
        if vim.o.background == "dark" then
            colorData = colorData.light
        else
            colorData = colorData.dark
        end
    else
        colorData = colorData[vim.o.background]
    end
    -- make the github url less readable bc it's kinda uneccessary
    highlight(3 + #self:getKeymaps(context), 3 + #context[1].name, -1, "Comment")
    require('pineapple.ui.highlightExample')(colorData, makeHighlight, highlight, exampleStartLine,
        require('pineapple.ui.buffer').getWinNr())
end

function viewCtx:getLines(context)
    local ret = {}
    -- for _, v in ipairs(remapLines) do
    --     table.insert(ret, v)
    -- end
    table.insert(ret, context[1].name .. " (" .. context[1].githubUrl .. ")")
    table.insert(ret, context[1].description)
    table.insert(ret, "Stars: " .. context[1].stargazersCount)
    table.insert(ret, "Color schemes: ")
    for _, v in pairs(context[1].vimColorSchemes) do
        table.insert(ret, "    " .. v.name)
    end

    for i, _ in ipairs(ret) do
        ret[i] = "  " .. ret[i]
    end
    table.insert(ret, "")

    exampleStartLine = #ret + 3 + #self:getKeymaps()
    for _, v in pairs(exampleCode) do
        local line = ""
        for _, s in pairs(v) do
            line = line .. s[1]
        end
        table.insert(ret, line)
    end

    return ret
end

function viewCtx:setup()
    exampleCode = require("pineapple.example-code")
end

function viewCtx:setContext(context)
    if vim.fn.line(".") <= #require("pineapple.ui.context.home"):getKeymaps({}) + 3 then
        print("Must be over a theme")
        return false
    end
    colorschemeIndex = 1
    return context
end

function viewCtx:setExitContext(_)
    return {}
end

function viewCtx:getName()
    return "Preview"
end

local M = makeContext.newContext(viewCtx)

return M
