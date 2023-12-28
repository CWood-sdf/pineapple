local makeContext = require("pineapple.ui.context.makeContext")

local helpCtx = {}

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

function helpCtx:addHighlights(_, _, _) end

function helpCtx:getLines(_)
	local ret = {
		"Currently no help available, please submit a PR!",
	}

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
