local M = {}

---@type boolean
local hasSetup = false
local function setup()
    if hasSetup then
        return
    end
    hasSetup = true
    require("pineapple").actualSetup()
end

---@return string[]
--- Returns a list of the github urls of the installed themes
function M.getInstalledThemes()
    setup()
    return require("pineapple.installer").getInstalledThemes()
end

---@param gitUrl string
--- Uninstalls the specified github url
function M.uninstall(gitUrl)
    setup()
    require("pineapple.installer").uninstall(gitUrl)
end

---@param gitUrl string
--- Installs the specified github url
function M.install(gitUrl)
    setup()
    require("pineapple.installer").install(gitUrl)
end

---@param colorscheme string
--- Sets and saves the colorscheme to the specified colorscheme
function M.setColorscheme(colorscheme)
    setup()
    require("pineapple.installer").setColorscheme(colorscheme)
end

---@return PineappleColorScheme[]
function M.getInstalledColorData()
    setup()
    local installedThemes = M.getInstalledThemes()
    local data = require("pineapple.dataManager").getCleanData()
    local ret = {}
    for _, v in pairs(data) do
        for _, installedTheme in pairs(installedThemes) do
            if v.githubUrl == installedTheme then
                table.insert(ret, v)
                break
            end
        end
    end
    return ret
end

---@return PineappleDataElement[]
function M.getAllData()
    setup()
    return require("pineapple.dataManager").getCleanData()
end

return M
