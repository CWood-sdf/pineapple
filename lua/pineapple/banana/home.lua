local data = require("pineapple.dataManager")
---@param document Banana.Instance
return function(document)
	local els = data.getCleanData()
	local cont = document:getScriptParams().selfNode
	if cont == nil then
		error("idk")
	end
	for _, v in ipairs(els) do
		local div = document:createElement("div")
		local nameNode = document:createElement("div")
		nameNode:appendTextNode(v.name)

		div:appendChild(nameNode)
		local hidden = true
		local first = true
		local items
		nameNode:attachRemap("n", "<CR>", { "line-hover" }, function()
			if first then
				items = document:createElement("div")
				items:addClass("themes")
				for i, t in ipairs(v.vimColorSchemes) do
					local theme = document:createElement("div")
					theme:setTextContent(t.name)
					theme:attachRemap("n", "<CR>", { "line-hover" }, function()
						local previews = document:getElementsByTag("Preview")
						for _, preview in ipairs(previews) do
							preview:remove()
						end

						local preview = document:createElement("Preview")
						preview:setData("colorscheme", v)
						preview:setData("themeid", i)
						local c = vim.api.nvim_win_get_cursor(0)
						preview:setStyleValue("left", "30%")
						preview:setStyleValue("top", c[1] .. "ch")
						cont:appendChild(preview)
						-- previewCont:setStyleValue("padding-top", (c[1] - cont:_boundTop() - 3) .. "ch")
					end)
					items:appendChild(theme)
				end
				items:setStyleValue("display", "none")
				div:appendChild(items)
				first = false
			end
			hidden = not hidden
			if hidden then
				items:setStyleValue("display", "none")
			else
				items:setStyleValue("display", "initial")
			end
		end, {})
		cont:appendChild(div)
	end
end
