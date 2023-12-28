local M = {}

---@class (exact) PineappleKeymap
---@field key string
---@field fn? fun()
---@field desc string
---@field isGroup boolean
---@field subKeymaps? PineappleKeymap[]

---@class PineappleContext
---@field hasSetup boolean
---@field data table
---@field subContexts PineappleContext[]
---@field addSubContext fun(self: PineappleContext, context: table)
---@field getSubContexts fun(self: PineappleContext): PineappleContext[]
---@field getKeymaps fun(self: PineappleContext, context: table): PineappleKeymap[]
---@field setContext fun(self: PineappleContext, context: table): table | boolean
---@field setExitContext fun(self: PineappleContext, context: table): table
---@field getLines fun(self: PineappleContext, context: table): string[]
---@field addHighlights fun(self: PineappleContext, context: table, highlight: fun(row, colStart, colEnd, hlGroup: string), makeHighlight: fun(name: string, color: string): string)
---@field getEntryKey fun(self: PineappleContext): string
---@field setup fun(self: PineappleContext, opt: table)
---@field setIndex fun(self: PineappleContext, index: number)
---@field getIndex fun(self: PineappleContext): number
---@field index number
---@field getName fun(self: PineappleContext): string
---@field render fun()
---@field setRender fun(self: PineappleContext, fn: fun())

---@class (exact) PineappleContextInput
---@field getKeymaps fun(self: PineappleContext, context: table): PineappleKeymap[]
---@field getLines fun(self: PineappleContext, context: table): string[]
---@field addHighlights fun(self: PineappleContext, context: table, highlight: fun(row, colStart, colEnd, hlGroup: string), makeHighlight: fun(name: string, color: string): string)
---@field getEntryKey fun(self: PineappleContext): string
---@field setup fun(self: PineappleContext, opt: table)
---@field getName fun(self: PineappleContext): string
---@field setContext fun(self: PineappleContext, context: table): table | boolean
---@field setExitContext fun(self: PineappleContext, context: table): table

---@param opts table
---@return PineappleContext
function M.newContext(opts)
	local expectedKeys = {
		getKeymaps = true,
		getLines = true,
		addHighlights = true,
		setContext = true,
		getEntryKey = true,
		setup = true,
		getName = true,
		setExitContext = true,
	}
	local ret = {
		render = function() end,
		setRender = function(self, fn)
			self.render = fn
			for _, v in pairs(self.subContexts) do
				v:setRender(fn)
			end
		end,
		hasSetup = false,
		data = {},
		subContexts = {},
		index = 0,
		setIndex = function(self, index)
			self.index = index
		end,
		getIndex = function(self)
			return self.index
		end,
		addSubContext = function(self, context)
			table.insert(self.subContexts, context)
		end,
		getSubContexts = function(self)
			return self.subContexts
		end,
		---@diagnostic disable-next-line: unused-local
		getKeymaps = function(self, context)
			return {}
		end,
		---@diagnostic disable-next-line: unused-local
		setContext = function(self, context)
			return {}
		end,
		---@diagnostic disable-next-line: unused-local
		getLines = function(self, context)
			return {}
		end,
		---@diagnostic disable-next-line: unused-local
		addHighlights = function(self, highlight, getHighlightName) end,
		---@diagnostic disable-next-line: unused-local
		getEntryKey = function(self)
			return ""
		end,
	}
	for k, v in pairs(opts) do
		if expectedKeys[k] ~= nil then
			expectedKeys[k] = nil
		end
		if k == "setup" then
			ret["setup"] = function(self, opt)
				if not self.hasSetup then
					v(opt)
					for _, s in ipairs(self.subContexts) do
						s:setup(opt)
					end
					self.hasSetup = true
				end
			end
		else
			ret[k] = v
		end
	end
	for k, _ in pairs(expectedKeys) do
		if expectedKeys[k] ~= nil then
			error("Missing key: " .. k)
		end
	end
	return ret
end

return M
