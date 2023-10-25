local M = {}

---@class (exact) Keymap
---@field key string
---@field fn fun()
---@field desc string

---@class Context
---@field hasSetup boolean
---@field data table
---@field subContexts Context[]
---@field addSubContext fun(self: Context, context: table)
---@field getSubContexts fun(self: Context): Context[]
---@field setKeymaps fun(self: Context, context: table)
---@field getKeymaps fun(self: Context, context: table): Keymap[]
---@field setContext fun(self: Context, context: table): table | boolean
---@field setExitContext fun(self: Context, context: table): table
---@field getLines fun(self: Context, context: table): string[]
---@field addHighlights fun(self: Context, context: table, highlight: fun(row, colStart, colEnd, hlGroup: string), makeHighlight: fun(name: string, color: string): string)
---@field getEntryKey fun(self: Context): string
---@field setup fun(self: Context, opt: table)
---@field setIndex fun(self: Context, index: number)
---@field getIndex fun(self: Context): number
---@field index number
---@field getName fun(self: Context): string
---@field render fun()
---@field setRender fun(self: Context, fn: fun())


---@class (exact) ContextInput
---@field getKeymaps fun(self: Context, context: table): Keymap[]
---@field getLines fun(self: Context, context: table): string[]
---@field addHighlights fun(self: Context, context: table, highlight: fun(row, colStart, colEnd, hlGroup: string), makeHighlight: fun(name: string, color: string): string)
---@field getEntryKey fun(self: Context): string
---@field setup fun(self: Context, opt: table)
---@field getName fun(self: Context): string
---@field setContext fun(self: Context, context: table): table | boolean
---@field setExitContext fun(self: Context, context: table): table

---@param opts table
---@return Context
function M.newContext(opts)
    local expectedKeys = {
        getKeymaps = true,
        getLines = true,
        addHighlights = true,
        setContext = true,
        getEntryKey = true,
        setup = true,
        getName = true,
        setExitContext = true,
    }
    local ret = {
        render = function()
        end,
        setRender = function(self, fn)
            self.render = fn;
            for _, v in pairs(self.subContexts) do
                v:setRender(fn)
            end
        end,
        hasSetup = false,
        data = {},
        subContexts = {},
        index = 0,
        setIndex = function(self, index)
            self.index = index
        end,
        getIndex = function(self)
            return self.index
        end,
        addSubContext = function(self, context)
            table.insert(self.subContexts, context)
        end,
        getSubContexts = function(self)
            return self.subContexts
        end,
        setKeymaps = function(self, context)
            local keymaps = self:getKeymaps(context)
            for _, keymap in ipairs(keymaps) do
                vim.api.nvim_set_keymap("n", unpack(keymap))
            end
        end,
        ---@diagnostic disable-next-line: unused-local
        getKeymaps = function(self, context)
            return {}
        end,
        ---@diagnostic disable-next-line: unused-local
        setContext = function(self, context)
            return {}
        end,
        ---@diagnostic disable-next-line: unused-local
        getLines = function(self, context)
            return {}
        end,
        ---@diagnostic disable-next-line: unused-local
        addHighlights = function(self, highlight, getHighlightName)
        end,
        ---@diagnostic disable-next-line: unused-local
        getEntryKey = function(self)
            return ""
        end,
    }
    for k, v in pairs(opts) do
        if expectedKeys[k] ~= nil then
            expectedKeys[k] = nil
        end
        if k == "setup" then
            ret["setup"] = function(self, opt)
                if not self.hasSetup then
                    v(opt)
                    for _, s in ipairs(self.subContexts) do
                        s:setup(opt)
                    end
                    self.hasSetup = true
                end
            end
        else
            ret[k] = v
        end
    end
    for k, _ in pairs(expectedKeys) do
        if expectedKeys[k] ~= nil then
            error("Missing key: " .. k)
        end
    end
    return ret
end

return M
