local _ = require("banana")
---@param document Banana.Instance
return function(document)
	local topline = document:getElementById("topline")
	local linestr = string.rep("-", topline:getWidth())
	topline:setTextContent(linestr)

	local remapels = document:querySelectorAll("#tabline > div")
	for _, v in ipairs(remapels) do
		local child = document:createElement("span")
		child:addClass("keycode")
		child:setTextContent(" (" .. v:getAttribute("remap") .. ")")
		v:appendChild(child)
	end


	local cont = document:getElementById("cont")
	local tablines = document:querySelectorAll("#tabline > div")

	for _, v in ipairs(tablines) do
		document:body():attachRemap("n", v:getAttribute("remap") or "A", {}, function()
			document:loadNmlTo("pineapple/" .. v:getAttribute("page"), cont, true, true)
			local els = document:getElementsByClassName("selected")
			for _, el in ipairs(els) do
				el:removeClass("selected")
			end
			v:addClass("selected")
		end, {})
	end

	document:loadNmlTo("pineapple/home", cont, true, true)
end
