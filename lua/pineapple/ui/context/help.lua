local makeContext = require("pineapple.ui.context.makeContext")

local helpCtx = {}

local helpText = {
	{
		{
			"  The bar at the top of the screen shows all the available screens that can be entered from the current one. The key to enter that screen is shown in the parentheses",
		},
	},
	{},
	{
		{
			"  Some screens have their own remaps. These are shown as the first few lines in the screen",
		},
	},
	{
		{
			"  The remaps follow the format: ",
		},
	},
	{
		{
			"    <key>",
			"Operator",
		},
		{ ": <description>" },
	},
	{},
	{
		{ "  Some remaps are composed of two keys. These are shown as: " },
	},
	{
		{
			"    <key1>",
			"Operator",
		},
		{ ": <description of key 1>  ...<description of second key>: " },
		{ "<key2>", "Constant" },
	},
	{
		{
			"   An example of the compound remap is on the home screen for filtering entries, there are lots of possible filters, and each filter remap begins with f, and is followed by some filter subkey",
		},
	},
}

function helpCtx:filterEntries() end

---@return PineappleKeymap[]
function helpCtx:getKeymaps()
	---@type PineappleKeymap[]
	local ret = {}
	return ret
end

function helpCtx:getEntryKey()
	return "?"
end

---@param context table
---@param highlight  fun(row, colStart, colEnd, hlGroup: string)
---@param makeHighlight fun(name: string, fg: string, bg: string): string
function helpCtx:addHighlights(context, highlight, makeHighlight)
	local row = 3
	-- highlight(0, 0, -1, "String")
	for _, line in ipairs(helpText) do
		local col = 0
		for _, part in ipairs(line) do
			if part[2] ~= nil then
				highlight(row, col, col + #part[1], part[2])
			end
			col = col + #part[1]
		end
		row = row + 1
	end
	--
end

function helpCtx:getLines(_)
	local ret = {}
	for _, line in ipairs(helpText) do
		local str = ""
		for _, part in ipairs(line) do
			str = str .. part[1]
		end
		table.insert(ret, str)
	end

	return ret
end

function helpCtx:setup() end

function helpCtx:setContext(_)
	return {
		{},
	}
end

function helpCtx:setExitContext(_)
	return {
		{},
	}
end

function helpCtx:getName()
	return "Help"
end

local M = makeContext.newContext(helpCtx)

return M
