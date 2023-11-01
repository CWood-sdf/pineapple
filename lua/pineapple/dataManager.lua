---@class (exact) PineappleColorSchemeElement
---@field CursorLineBg string
---@field CursorFg string
---@field CursorBg string
---@field NormalFg string
---@field vimFuncVar string
---@field vimNotFunc string
---@field vimLineComment string
---@field vimFunction string
---@field vimNumber string
---@field LineNrFg string
---@field vimFuncName string
---@field StatusLineBg string
---@field NormalBg string
---@field vimCommand string
---@field vimLet string
---@field vimString string
---@field vimOperParen string
---@field vimFuncBody string
---@field CursorLineNrBg string
---@field StatusLineFg string
---@field CursorLineFg string
---@field LineNrBg string
---@field vimVar string
---@field vimParenSep string
---@field vimOper string
---@field vimIsCommand string
---@field vimSubst string
---@field CursorLineNrFg string

---@class (exact) PineappleColorScheme
---@field backgrounds ("light" | "dark")[]
---@field name string
---@field data { light: PineappleColorSchemeElement?, dark: PineappleColorSchemeElement? }


---@class (exact) PineappleDataElement
---@field id integer
---@field name string
---@field githubUrl string
---@field isLua boolean
---@field isVim boolean
---@field description string
---@field license string
---@field stargazersCount integer
---@field vimColorSchemes PineappleColorScheme[]


---@type table
local M = {}

---@type PineappleDataElement[]
local dataCache = {}


local hasSetup = false
local function setup()
    if hasSetup then
        return
    end
    hasSetup = true
    local orgData = require("pineapple.data")
    local values = {}
    for _, v in pairs(orgData) do
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
    dataCache = values
end

---@return PineappleDataElement[]
function M.getCleanData()
    setup()
    return dataCache
end

return M
