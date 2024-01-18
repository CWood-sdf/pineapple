return function(colorData, makeHighlight, highlight, startLine, win)
    local hasTs, _ = pcall(require, "nvim-treesitter")
    local exampleCode = require("pineapple.example-code")
    local exapleCodeCopy = {}
    for _, v in ipairs(exampleCode) do
        local line = {}
        for _, s in ipairs(v) do
            table.insert(line, { s[1], s[2], s[3], s[4] })
        end
        table.insert(exapleCodeCopy, line)
    end
    exampleCode = exapleCodeCopy
    local firstLine = ""
    for _, v in ipairs(exampleCode[1]) do
        firstLine = firstLine .. v[1]
    end
    if #firstLine > vim.api.nvim_win_get_width(win) then
        -- how many extra spaces so that width % #firstLine == 0
        local extraNeeded = #firstLine % vim.api.nvim_win_get_width(win)
        local extra = string.rep(" ", extraNeeded * 2)
        for i = 1, #exampleCode do
            table.insert(exampleCode[i], { extra, "vimFuncBody", "NormalBg", "vimFuncBody" })
        end
        -- vim.api.nvim_buf_set_option(bufnr, "textwidth", #firstLine)
    end
    for line, l in ipairs(exampleCode) do
        local currentRow = 0
        for k, v in ipairs(l) do
            local hlSpot = 2
            if hasTs then
                hlSpot = 4
            end
            if colorData[v[hlSpot]] == nil then
                hlSpot = 2
            end
            local hlGroup = makeHighlight(v[hlSpot] .. "_" .. v[3], colorData[v[hlSpot]], colorData[v[3]])
            local endCol = currentRow + #v[1]
            if k == #l then
                endCol = -1
            end

            highlight(line + startLine - 1, currentRow, endCol, hlGroup)
            currentRow = currentRow + #v[1]
        end
    end
end
