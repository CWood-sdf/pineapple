local M = {}

local installedThemes = {}
-- this is a string in lua require format
local installFile = nil
-- this is a string in actual file format
local colorSchemeFile = nil
M.setup = function(opts)
    installFile = opts.installedRegistry
    if installFile == nil then
        error("installFile is required")
    end
    installedThemes = require(installFile)
    colorSchemeFile = opts.colorschemeFile
    if colorSchemeFile == nil then
        error("colorSchemeFile is required")
    end
end
M.getInstallFileName = function()
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
M.getInstalledThemes = function()
    return installedThemes
end
M.getInstallFile = function()
    return installFile
end
M.uninstall = function(gitUrl)
    local found = false
    for k, v in pairs(installedThemes) do
        if v == gitUrl then
            table.remove(installedThemes, k)
            found = true
        end
    end
    if not found then
        print("Theme not installed")
        return
    end
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
end
M.install = function(gitUrl)
    for _, v in pairs(installedThemes) do
        if v == gitUrl then
            print("Theme already installed")
            return
        end
    end
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
end

M.setColorscheme = function(colorscheme)
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
    vim.cmd("colorscheme " .. colorscheme)
    local s = "vim.cmd(\"colorscheme " .. colorscheme .. "\")\n"
    f:write(s)
    f:close()
end

return M
