vim.cmd("set noswapfile")
-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.repro", ":p")

-- set stdpaths to use .reprocalculator
for _, name in ipairs({ "config", "data", "state", "cache" }) do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

package.path = vim.fn.fnamemodify(".", ":p") .. "/?.lua;" .. package.path
-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath, })
end
vim.opt.runtimepath:prepend(lazypath)
--
-- -- install plugins
-- local plugins = {
--     "folke/tokyonight.nvim",
--     -- add any other plugins here
-- }
-- require("lazy").setup(plugins, {
--     root = root .. "/plugins",
-- })
--
-- vim.cmd.colorscheme("tokyonight")
-- add anything else here
--END

require("lazy").setup({
	{
		dofile(vim.fn.fnamemodify("./lua/stuff/colorscheme.lua", ":p")),
		lazy = false,
	},
})
vim.opt.compatible = false
vim.opt.number = true
vim.opt.laststatus = 2
vim.opt.statusline = "%f"

-- vim.cmd("silent! colorscheme default")

-- Necessary custom settings for some color schemes
vim.g.solarized_termcolors = 256

-- Converts xterm color to hex code if necessary
function ConvertToHex(colorcode)
	-- return colorcode
	if type(colorcode) == "string" and string.sub(colorcode, 1, 1) == "#" then
		return colorcode
	end

	local colormappings = {
		"#000000",
		"#800000",
		"#008000",
		"#808000",
		"#000080",
		"#800080",
		"#008080",
		"#c0c0c0",
		"#808080",
		"#ff0000",
		"#00ff00",
		"#ffff00",
		"#0000ff",
		"#ff00ff",
		"#00ffff",
		"#ffffff",
		"#000000",
		"#00005f",
		"#000087",
		"#0000af",
		"#0000d7",
		"#0000ff",
		"#005f00",
		"#005f5f",
		"#005f87",
		"#005faf",
		"#005fd7",
		"#005fff",
		"#008700",
		"#00875f",
		"#008787",
		"#0087af",
		"#0087d7",
		"#0087ff",
		"#00af00",
		"#00af5f",
		"#00af87",
		"#00afaf",
		"#00afd7",
		"#00afff",
		"#00d700",
		"#00d75f",
		"#00d787",
		"#00d7af",
		"#00d7d7",
		"#00d7ff",
		"#00ff00",
		"#00ff5f",
		"#00ff87",
		"#00ffaf",
		"#00ffd7",
		"#00ffff",
		"#5f0000",
		"#5f005f",
		"#5f0087",
		"#5f00af",
		"#5f00d7",
		"#5f00ff",
		"#5f5f00",
		"#5f5f5f",
		"#5f5f87",
		"#5f5faf",
		"#5f5fd7",
		"#5f5fff",
		"#5f8700",
		"#5f875f",
		"#5f8787",
		"#5f87af",
		"#5f87d7",
		"#5f87ff",
		"#5faf00",
		"#5faf5f",
		"#5faf87",
		"#5fafaf",
		"#5fafd7",
		"#5fafff",
		"#5fd700",
		"#5fd75f",
		"#5fd787",
		"#5fd7af",
		"#5fd7d7",
		"#5fd7ff",
		"#5fff00",
		"#5fff5f",
		"#5fff87",
		"#5fffaf",
		"#5fffd7",
		"#5fffff",
		"#870000",
		"#87005f",
		"#870087",
		"#8700af",
		"#8700d7",
		"#8700ff",
		"#875f00",
		"#875f5f",
		"#875f87",
		"#875faf",
		"#875fd7",
		"#875fff",
		"#878700",
		"#87875f",
		"#878787",
		"#8787af",
		"#8787d7",
		"#8787ff",
		"#87af00",
		"#87af5f",
		"#87af87",
		"#87afaf",
		"#87afd7",
		"#87afff",
		"#87d700",
		"#87d75f",
		"#87d787",
		"#87d7af",
		"#87d7d7",
		"#87d7ff",
		"#87ff00",
		"#87ff5f",
		"#87ff87",
		"#87ffaf",
		"#87ffd7",
		"#87ffff",
		"#af0000",
		"#af005f",
		"#af0087",
		"#af00af",
		"#af00d7",
		"#af00ff",
		"#af5f00",
		"#af5f5f",
		"#af5f87",
		"#af5faf",
		"#af5fd7",
		"#af5fff",
		"#af8700",
		"#af875f",
		"#af8787",
		"#af87af",
		"#af87d7",
		"#af87ff",
		"#afaf00",
		"#afaf5f",
		"#afaf87",
		"#afafaf",
		"#afafd7",
		"#afafff",
		"#afd700",
		"#afd75f",
		"#afd787",
		"#afd7af",
		"#afd7d7",
		"#afd7ff",
		"#afff00",
		"#afff5f",
		"#afff87",
		"#afffaf",
		"#afffd7",
		"#afffff",
		"#d70000",
		"#d7005f",
		"#d70087",
		"#d700af",
		"#d700d7",
		"#d700ff",
		"#d75f00",
		"#d75f5f",
		"#d75f87",
		"#d75faf",
		"#d75fd7",
		"#d75fff",
		"#d78700",
		"#d7875f",
		"#d78787",
		"#d787af",
		"#d787d7",
		"#d787ff",
		"#d7af00",
		"#d7af5f",
		"#d7af87",
		"#d7afaf",
		"#d7afd7",
		"#d7afff",
		"#d7d700",
		"#d7d75f",
		"#d7d787",
		"#d7d7af",
		"#d7d7d7",
		"#d7d7ff",
		"#d7ff00",
		"#d7ff5f",
		"#d7ff87",
		"#d7ffaf",
		"#d7ffd7",
		"#d7ffff",
		"#ff0000",
		"#ff005f",
		"#ff0087",
		"#ff00af",
		"#ff00d7",
		"#ff00ff",
		"#ff5f00",
		"#ff5f5f",
		"#ff5f87",
		"#ff5faf",
		"#ff5fd7",
		"#ff5fff",
		"#ff8700",
		"#ff875f",
		"#ff8787",
		"#ff87af",
		"#ff87d7",
		"#ff87ff",
		"#ffaf00",
		"#ffaf5f",
		"#ffaf87",
		"#ffafaf",
		"#ffafd7",
		"#ffafff",
		"#ffd700",
		"#ffd75f",
		"#ffd787",
		"#ffd7af",
		"#ffd7d7",
		"#ffd7ff",
		"#ffff00",
		"#ffff5f",
		"#ffff87",
		"#ffffaf",
		"#ffffd7",
		"#ffffff",
		"#080808",
		"#121212",
		"#1c1c1c",
		"#262626",
		"#303030",
		"#3a3a3a",
		"#444444",
		"#4e4e4e",
		"#585858",
		"#626262",
		"#6c6c6c",
		"#767676",
		"#808080",
		"#8a8a8a",
		"#949494",
		"#9e9e9e",
		"#a8a8a8",
		"#b2b2b2",
		"#bcbcbc",
		"#c6c6c6",
		"#d0d0d0",
		"#dadada",
		"#e4e4e4",
		"#eeeeee",
	}

	local num = vim.fn.str2nr(colorcode)
	if num == 0 then
		-- print(colorcode)
	end
	return colormappings[vim.fn.str2nr(colorcode) + 1]
end

-- convert full 32 bit number to hex code
function GetFullColorHex(number)
	local hex = vim.fn.printf("#%06x", number)
	return hex
end

-- Get the color group name of the syn ID
function GetColorGroupName(synID)
	local name = vim.fn.synIDattr(synID, "name")
	if name == "" then
		name = "NormalFg"
	end
	return name
end

-- Get the color group value of the syn ID
function GetColorValue(synID)
	local color = vim.fn.synIDattr(vim.fn.synIDtrans(synID), "fg#")
	if color == "" then
		color = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg#")
	end
	return ConvertToHex(color)
end

-- Get some color values that are not picked up by GetColorValues
function GetExtraColorValues()
	return {}
end

-- Get the last line # of the entire file
function GetLastLine()
	return vim.fn.line("$")
end

-- Get the last column # of the given line
function GetLastCol(line)
	vim.fn.cursor(line, 1)
	return vim.fn.col("$")
end

-- Get color values of all words in the file + some more
function GetColorValues()
	local lastline = GetLastLine()

	local currentline = 1

	local values = {}
	while currentline <= lastline do
		local lastcol = GetLastCol(currentline)
		local currentcol = 1
		while currentcol <= lastcol do
			vim.fn.cursor(currentline, currentcol)

			local synID = vim.fn.synID(vim.fn.line(".") or 1, vim.fn.col(".") or 1, 1)
			if synID ~= 0 then
				values[GetColorGroupName(synID)] = GetColorValue(synID)
			else
			end

			currentcol = currentcol + 1
		end
		currentline = currentline + 1
	end

	for k, v in pairs(GetExtraColorValues()) do
		if values[k] == nil then
			values[k] = v
		end
	end

	return values
end

-- Returns true if the color hex value is light
function IsHexColorLight(color)
	local rawColor = vim.fn.trim(color, "#") or ""

	local red = vim.fn.str2nr(vim.fn.substitute(rawColor, "\\(.\\{2\\}\\).\\{4\\}", "\\1", "g") or "", 16)
	local green = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{2\\}\\(.\\{2\\}\\).\\{2\\}", "\\1", "g") or "", 16)
	local blue = vim.fn.str2nr(vim.fn.substitute(rawColor, ".\\{4\\}\\(.\\{2\\}\\)", "\\1", "g") or "", 16)

	local brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000

	return brightness > 155
end

-- Returns true if the color hex value is dark
function IsHexColorDark(color)
	local islight = IsHexColorLight(color)
	if islight then
		return false
	else
		return true
	end
end

-- Sets up colorscheme config through trial and error
function SetUpColorScheme(colorscheme)
	vim.opt.termguicolors = true
	vim.cmd("colorscheme " .. colorscheme)
	-- local background = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg#')
	-- local foreground = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg#')
	-- if background == "" or foreground == "" then
	--     vim.opt.termguicolors = false
	--     vim.cmd('colorscheme ' .. colorscheme)
	--     background = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg#')
	--     foreground = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg#')
	-- end
	--
	-- if background == "" or foreground == "" then
	--     vim.opt.termguicolors = false
	--     vim.cmd('colorscheme ' .. colorscheme)
	-- end
end

-- Gets all color values of the current file and stores them in a file as JSON
function WriteColorValues(filename, colorscheme, background)
	pcall(function()
		SetUpColorScheme(colorscheme)
		-- if trim(execute('colorscheme')) == 'default'
		--     return 0 .' '
		-- end

		local synIdFg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "fg#")
		local synIdBg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#")

		local background2 = ConvertToHex(synIdFg)
		local foreground = ConvertToHex(synIdBg)

		local iscolorschemedark = true
		-- vim.fn.timer_start(100, function()
		-- 	print(filename, colorscheme, background)

		-- end)
		if background2 ~= "" then
			iscolorschemedark = IsHexColorLight(background2)
		elseif foreground ~= "" then
			iscolorschemedark = IsHexColorLight(foreground)
		end

		local data = {}
		if (iscolorschemedark and background == "light") or (not iscolorschemedark and background == "dark") then
			data = GetColorValues()
		else
		end

		local encodeddata = vim.fn.json_encode(data)
		vim.fn.writefile({ encodeddata }, filename)
	end)
end
