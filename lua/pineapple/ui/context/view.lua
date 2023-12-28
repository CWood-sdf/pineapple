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
	local hasTs, _ = pcall(require, "nvim-treesitter")
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
	highlight(4, 3 + #context[1].name, -1, "Comment")
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

			highlight(line + exampleStartLine - 1, currentRow, endCol, hlGroup)
			currentRow = currentRow + #v[1]
		end
	end
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
	local longestLine = 0
	for i = 1, #exampleCode do
		local lineNum = i .. " "
		while #lineNum < 5 do
			lineNum = " " .. lineNum
		end
		-- put two spaces before everything
		exampleCode[i][1][1] = " " .. exampleCode[i][1][1]
		-- put in line numbers. if it's the "cursor" line, highlight it
		if i == 3 then
			table.insert(exampleCode[i], 1, { lineNum, "CursorLineNrFg", "CursorLineNrBg" })
		else
			table.insert(exampleCode[i], 1, { lineNum, "LineNrFg", "LineNrBg" })
		end
		local lineLen = 0
		for _, v in ipairs(exampleCode[i]) do
			lineLen = #v[1] + lineLen
		end
		if lineLen > longestLine then
			longestLine = lineLen
		end
	end
	longestLine = 10 + longestLine
	for _, l in ipairs(exampleCode) do
		local lineLen = 0
		for _, v in ipairs(l) do
			lineLen = #v[1] + lineLen
		end
		local neededExtra = longestLine - lineLen
		l[#l][1] = l[#l][1] .. string.rep(" ", neededExtra)
	end
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
