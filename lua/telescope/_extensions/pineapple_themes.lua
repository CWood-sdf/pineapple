local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

return function(opts)
    -- opts = opts or require("telescope.themes").get_dropdown({})
    local data = require("pineapple.dataManager").getCleanData()
    local variants = {}
    local installed = require("pineapple.installer").getInstalledThemes()
    for _, v in ipairs(installed) do
        local i = 1
        while i < #data and vim.fn.stridx(data[i].githubUrl, v) == -1 do
            i = i + 1
        end
        for _, vimColorScheme in ipairs(data[i].vimColorSchemes) do
            table.insert(variants, vimColorScheme)
        end
    end
    -- print(vim.inspect(variants))
    local variantNames = {}
    for k, _ in pairs(variants) do
        table.insert(variantNames, k)
    end
    local preview = previewers.Previewer:new({
        setup = function(self)
            self.state = {}
        end,
        teardown = function(self)

        end,
        preview_fn = function(self, entry, status)
            local bufnr = status.preview_bufnr
            local win = status.preview_win
            local code = require("pineapple.example-code")
            local lines = {}
            local ns = require('pineapple.ui.buffer').getNsId()
            for _, v in ipairs(code) do
                local line = ""
                for _, s in ipairs(v) do
                    line = line .. s[1]
                end
                table.insert(lines, line)
            end
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            if #lines[1] > vim.api.nvim_win_get_width(win) then
                -- how many extra spaces so that width % #firstLine == 0
                local extraNeeded = (#lines[1] % vim.api.nvim_win_get_width(win) + 6) / 2
                local extra = string.rep(" ", extraNeeded)
                for i = 1, #lines do
                    lines[i] = lines[i] .. extra
                end
                -- vim.api.nvim_buf_set_option(bufnr, "textwidth", #firstLine)
            end
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.api.nvim_win_set_hl_ns(win, ns)
            local colorData = entry.value.data
            local bg = vim.o.background
            if colorData[bg] == nil then
                if bg == "dark" then
                    colorData = colorData.light
                else
                    colorData = colorData.dark
                end
            else
                colorData = colorData[bg]
            end
            require('pineapple.ui.highlightExample')(colorData, require("pineapple.ui.buffer").makeHighlight,
                function(row, colStart, colEnd, hlGroup)
                    vim.api.nvim_buf_add_highlight(bufnr, ns, hlGroup, row, colStart,
                        colEnd)
                end, 0, win)
        end,
        title = function()
            return "Preview"
        end,
        dynamic_title = function(self, entry)
            return ''
        end,
        send_input = function(self, input)
            print(input)
        end,

        scroll_fn = function(self, direction)
            print(direction)
        end,

    })
    pickers
        .new(opts, {
            prompt_title = "Pineapple Themes",
            finder = finders.new_table({
                results = variants,

                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.name,
                        ordinal = entry.name,
                    }
                end,
            }),
            previewer = preview,
            sorter = conf.generic_sorter(opts),
            ---@diagnostic disable-next-line: unused-local
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    -- print(selection.name)
                    require('pineapple.installer').setColorscheme(selection.display)
                    -- require("spaceport.data").cd(selection.value)
                end)
                return true
            end,
        })
        :find()
end
