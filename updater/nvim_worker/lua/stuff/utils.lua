local M = {}
function M.IsHexColorLight(color)
    local rawColor = vim.fn.trim(color, "#") or ""

    local red = vim.fn.str2nr(vim.fn.substitute(rawColor, "\\(.\\{2\\}\\).\\{4\\}", "\\1", "g") or "", 16)
    local green = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{2\\}\\(.\\{2\\}\\).\\{2\\}", "\\1", "g") or "", 16)
    local blue = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{4\\}\\(.\\{2\\}\\)", "\\1", "g") or "", 16)

    local brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000

    return brightness > 155
end

-- Returns true if the color hex value is dark
function M.IsHexColorDark(color)
    local islight = M.IsHexColorLight(color)
    if islight then
        return false
    else
        return true
    end
end

function IsHexColorLight(color)
    local rawColor = vim.fn.trim(color, "#") or ""

    local red = vim.fn.str2nr(vim.fn.substitute(rawColor, "\\(.\\{2\\}\\).\\{4\\}", "\\1", "g") or "", 16)
    local green = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{2\\}\\(.\\{2\\}\\).\\{2\\}", "\\1", "g") or "", 16)
    local blue = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{4\\}\\(.\\{2\\}\\)", "\\1", "g") or "", 16)

    local brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000

    return brightness > 155
end

-- Returns true if the color hex value is dark
function IsHexColorDark(color)
    local islight = IsHexColorLight(color)
    if islight then
        return false
    else
        return true
    end
end

return M
