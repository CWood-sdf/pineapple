local makeContext = require("pineapple.ui.context.makeContext")

local installedCtx = {
}

local installedThemes = {}

-- local remapLines = {
--     "  x: Uninstall",
--     "  u: Use color scheme",
--
-- }

function installedCtx:filterEntries()
end

---@return Keymap[]
function installedCtx:getKeymaps()
    ---@type Keymap[]
    return {
        {
            key = "u",
            fn = function()
                local line = vim.fn.line(".")
                local i = 3 + #self:getKeymaps()
                for _, v in pairs(installedThemes) do
                    i = i + 1
                    for _, theme in ipairs(v) do
                        i = i + 1
                        if i == line then
                            require("pineapple.installer").setColorscheme(theme)
                            return
                        end
                    end
                end
                print("Not hovering over a colorscheme")
            end,
            desc = "Use color scheme",
            isGroup = false
        },
        {
            key = "x",
            fn = function()
                local line = vim.fn.line(".")
                local i = 3 + #self:getKeymaps()
                for t, v in pairs(installedThemes) do
                    i = i + 1
                    if i == line then
                        require("pineapple.installer").uninstall(t)
                        self:setContext()
                        self.render()
                        return
                    end
                    i = i + #v
                    if i > line then
                        break
                    end
                end
                print("Not hovering over a theme")
            end,
            desc = "Uninstall color scheme",
            isGroup = false
        }

    }
end

function installedCtx:getEntryKey()
    return "I"
end

function installedCtx:addHighlights()
end

function installedCtx:getLines()
    local lines = {}
    -- for _, v in ipairs(remapLines) do
    --     table.insert(lines, v)
    -- end
    for n, v in pairs(installedThemes) do
        table.insert(lines, "  " .. n)
        for _, variant in ipairs(v) do
            table.insert(lines, "    " .. variant)
        end
    end
    return lines
end

function installedCtx:setup()

end

function installedCtx:setContext(_)
    local themes = require("pineapple.installer").getInstalledThemes()
    installedThemes = {}

    local data = require("pineapple.data")
    for _, v in ipairs(themes) do
        local i = 1
        while i < #data and vim.fn.stridx(data[i].githubUrl, v) == -1 do
            i = i + 1
        end
        local variants = {}
        for _, vimColorScheme in ipairs(data[i].vimColorSchemes) do
            table.insert(variants, vimColorScheme.name)
        end
        installedThemes[v] = variants
    end
    return {}
end

function installedCtx:setExitContext(_)
    return {}
end

function installedCtx:getName()
    return "Installed"
end

local M = makeContext.newContext(installedCtx)

return M
