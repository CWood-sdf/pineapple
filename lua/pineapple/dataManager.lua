---@class (exact) PineappleColorSchemeElement
---@field [string] string

---@class (exact) PineappleColorScheme
---@field backgrounds ("light" | "dark")[]
---@field name string
---@field data { light: PineappleColorSchemeElement?, dark: PineappleColorSchemeElement? }

---@class (exact) PineappleDataElement
---@field name string
---@field githubUrl string
---@field description string
---@field stargazersCount integer
---@field vimColorSchemes PineappleColorScheme[]

---@type table
local M = {}

---@type PineappleDataElement[]
local dataCache = {}

local hasSetup = false
local function setup()
	if hasSetup then
		return
	end
	hasSetup = true
	local ok, orgData = pcall(require, "pineapple.data")
	-- print(ok)
	local values = {}
	for _, v in pairs(orgData) do
		local canInsert = true
		local tempVal = v
		if v.vimColorSchemes ~= nil then
			local newVimColorSchemes = {}
			for _, vimColorScheme in pairs(v.vimColorSchemes) do
				if
					vimColorScheme.data ~= nil
					and (
						(vimColorScheme.data.light ~= nil and vimColorScheme.data.light["@keyword"] ~= nil)
						or (vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark["@keyword"] ~= nil)
					)
				then
					if vimColorScheme.data.light ~= nil and vimColorScheme.data.light.LineNrBg == "#000000" then
						vimColorScheme.data.light.LineNrBg = vimColorScheme.data.light.NormalBg
					end
					if vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.LineNrBg == "#000000" then
						vimColorScheme.data.dark.LineNrBg = vimColorScheme.data.dark.NormalBg
					end
					if vimColorScheme.data.light ~= nil and vimColorScheme.data.light.CursorLineNrBg == "#000000" then
						vimColorScheme.data.light.CursorLineNrBg = vimColorScheme.data.light.NormalBg
					end
					if vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.CursorLineNrBg == "#000000" then
						vimColorScheme.data.dark.CursorLineNrBg = vimColorScheme.data.dark.NormalBg
					end
					table.insert(newVimColorSchemes, vimColorScheme)
				end
			end
			if #newVimColorSchemes == 0 then
				canInsert = false
			end
			tempVal.vimColorSchemes = newVimColorSchemes
		else
			canInsert = false
		end
		if canInsert then
			-- print("dskfa")
			table.insert(values, tempVal)
		end
	end
	dataCache = values
end

---@return PineappleDataElement[]
function M.getCleanData()
	setup()
	return dataCache
end

return M
