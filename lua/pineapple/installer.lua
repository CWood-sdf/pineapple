local M = {}

local installedThemes = {}
-- this is a string in lua require format
local installFile = nil
-- this is a string in actual file format
local colorSchemeFile = nil

---@class (exact) PineappleInstallerOptions
---@field installedRegistry string
---@field colorschemeFile string
---@field colorschemeSet? fun(scheme: string): string
M.opts = {}

local hasSetup = false
---@param opts PineappleInstallerOptions
function M.setup(opts)
    if hasSetup then
        return
    end
    M.opts = opts
    hasSetup = true
    installFile = opts.installedRegistry
    if installFile == nil then
        error("installedRegistry is required")
    end
    installedThemes = require(installFile)
    if installedThemes == nil then
        installedThemes = {}
        local file = io.open(M.getInstallFileName(), "w")
        if file == nil then
            error("Could not open file: " .. M.getInstallFileName())
            return
        end
        file:write("return {}")
        file:close()
    end
    colorSchemeFile = opts.colorschemeFile
    if colorSchemeFile == nil then
        error("colorschemeFile is required")
    end
end

function M.getInstallFileName()
    if installFile == nil then
        error("setup is required")
    end
    local fPath = string.gsub(installFile, "%.", "/")
    local fLoc = ""
    if jit.os == "Windows" then
        fLoc = os.getenv("USERPROFILE") .. "AppData\\Local\\nvim\\lua\\" .. fPath .. ".lua"
    else
        fLoc = os.getenv("HOME") .. "/.config/nvim/lua/" .. fPath .. ".lua"
    end
    return fLoc
end

function M.getInstalledThemes()
    return installedThemes
end

function M.getInstallFile()
    return installFile
end

function M.uninstall(gitUrl)
    local found = false
    for k, v in pairs(installedThemes) do
        if v == gitUrl then
            table.remove(installedThemes, k)
            found = true
        end
    end
    if not found then
        error("Theme not installed")
        return
    end
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleUninstallPre",
        data = { gitUrl },
    })
    local fLoc = M.getInstallFileName()
    local f = io.open(fLoc, "w")
    if f == nil then
        error("Could not open file: " .. fLoc)
    end
    local s = "return {\n"
    for _, v in pairs(installedThemes) do
        s = s .. string.format("    \"%s\",\n", v)
    end
    s = s .. "}"
    f:write(s)
    f:close()
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleUninstallPost",
        data = { gitUrl },
    })
end

function M.install(gitUrl)
    for _, v in pairs(installedThemes) do
        if v == gitUrl then
            error("Theme already installed")
            return
        end
    end
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleInstallPre",
        data = { gitUrl },
    })
    local fLoc = M.getInstallFileName()
    local f = io.open(fLoc, "w")
    if f == nil then
        error("Could not open file: " .. fLoc)
    end
    local s = "return {\n"
    for _, v in pairs(installedThemes) do
        s = s .. string.format("    \"%s\",\n", v)
    end
    s = s .. string.format("    \"%s\",\n", gitUrl)
    s = s .. "}"
    f:write(s)
    f:close()
    table.insert(installedThemes, gitUrl)
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleInstallPost",
        data = { gitUrl },
    })
end

function M.setColorscheme(colorscheme)
    if colorSchemeFile == nil then
        error("setup is required")
    end
    local fPath = ""
    if jit.os == "Windows" then
        fPath = os.getenv("USERPROFILE") .. "AppData\\Local\\nvim\\" .. colorSchemeFile
    else
        fPath = os.getenv("HOME") .. "/.config/nvim/" .. colorSchemeFile
    end
    local f = io.open(fPath, "w")
    if f == nil then
        error("Could not open file: " .. fPath)
    end
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleColorschemePre",
        data = { colorscheme },
    })
    vim.cmd("colorscheme " .. colorscheme)
    local s = "vim.cmd(\"colorscheme " .. colorscheme .. "\")\n"
    if M.opts.colorschemeSet ~= nil then
        s = M.opts.colorschemeSet(colorscheme)
    end
    f:write(s)
    f:close()
    vim.api.nvim_exec_autocmds("User", {
        pattern = "PineappleColorschemePost",
        data = { colorscheme },
    })
end

return M
