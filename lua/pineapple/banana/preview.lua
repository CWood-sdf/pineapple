local _ = require("banana")
local code = require("pineapple.example-code")
---@param document Banana.Instance
return function(document)
	local cont = document:getElementById("background")
	local self = document:getPrimaryNode()
	---@type PineappleDataElement?
	local colorscheme = self:getData("colorscheme")
	---@type number?
	local themeid = self:getData("themeid")
	if colorscheme == nil or themeid == nil then
		print("Missing colorscheme or themid")
		return
	end
	for _, line in ipairs(code) do
		local l = document:createElement("div")
		for _, token in ipairs(line) do
			local tok = document:createElement("span")
			tok:setTextContent(token[1])
			local bg = colorscheme.vimColorSchemes[themeid].data.dark[token[2]]
			if bg == nil then
				bg = colorscheme.vimColorSchemes[themeid].data.dark["NormalBg"] or "#ffffff"
			end
			tok:setStyleValue("hl-bg", bg)
			local fg = colorscheme.vimColorSchemes[themeid].data.dark[token[4]] or
				colorscheme.vimColorSchemes[themeid].data.dark[token[3]]
			if fg == nil then
				fg = colorscheme.vimColorSchemes[themeid].data.dark["NormalFg"] or "#ffffff"
			end
			tok:setStyleValue("hl-fg", fg)
			l:appendChild(tok)
		end
		cont:appendChild(l)
	end
end
