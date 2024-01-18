local exampleCode = {
    {
        { '" Returns true if the color hex value is light', "vimLineComment", "NormalBg", "@comment" },
    },
    {
        { "function",        "vimCommand",   "NormalBg", "@keyword.function" },
        { "! ",              "vimFunction",  "NormalBg", "@punctuation.special" },
        { "IsHexColorLight", "vimFunction",  "NormalBg", "@function" },
        { "(",               "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "color",           "vimOperParen", "NormalBg", "@parameter" },
        { ")",               "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { " ",               "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "abort",           "vimIsCommand", "NormalBg", "vimIsCommand" },
    },
    {
        { "  ",        "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "let",       "vimLet",       "NormalBg", "@keyword" },
        { " ",         "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "l:",        "vimVar",       "NormalBg", "@namespace" },
        { "raw_color", "vimVar",       "NormalBg", "@variable" },
        { " ",         "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "=",         "vimOper",      "NormalBg", "@operator" },
        { " ",         "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "trim",      "vimFuncName",  "NormalBg", "@function.call" },
        { "(",         "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "a:",        "vimFuncVar",   "NormalBg", "@namespace" },
        { "color",     "vimFuncVar",   "NormalBg", "@variable" },
        { ", ",        "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'#'",       "vimString",    "NormalBg", "@string" },
        { ")",         "vimParenSep",  "NormalBg", "@punctuation.bracket" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg", "vimFuncBody" },
    },
    {
        { "  ",           "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "let",          "vimLet",       "NormalBg", "@keyword" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "l:",           "vimVar",       "NormalBg", "@namespace" },
        { "red",          "vimVar",       "NormalBg", "@variable" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "=",            "vimOper",      "NormalBg", "@operator" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "str2nr",       "vimFuncName",  "NormalBg", "@function.call" },
        { "(",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "substitute",   "vimSubst",     "NormalBg", "@function.call" },
        { "(",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",           "vimOperParen", "NormalBg", "@namespace" },
        { "raw_color",    "vimOperParen", "NormalBg", "@variable" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'(.{2}).{4}'", "vimString",    "NormalBg", "@string" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'1'",          "vimString",    "NormalBg", "@string" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'g'",          "vimString",    "NormalBg", "@string" },
        { ")",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { ", ",           "vimFuncBody",  "NormalBg", "@punctuation.delimiter" },
        { "16",           "vimNumber",    "NormalBg", "@number" },
        { ")",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
    },
    {
        { "  ",               "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "let",              "vimLet",       "NormalBg", "@keyword" },
        { " ",                "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "l:",               "vimVar",       "NormalBg", "@namespace" },
        { "green",            "vimVar",       "NormalBg", "@variable" },
        { " ",                "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "=",                "vimOper",      "NormalBg", "@operator" },
        { " ",                "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "str2nr",           "vimFuncName",  "NormalBg", "@function.call" },
        { "(",                "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "substitute",       "vimSubst",     "NormalBg", "@function.call" },
        { "(",                "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",               "vimOperParen", "NormalBg", "@namespace" },
        { "raw_color",        "vimOperParen", "NormalBg", "@variable" },
        { ", ",               "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'.{2}(.{2}).{2}'", "vimString",    "NormalBg", "@string" },
        { ", ",               "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'1'",              "vimString",    "NormalBg", "@string" },
        { ", ",               "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'g'",              "vimString",    "NormalBg", "@string" },
        { ")",                "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { ", ",               "vimFuncBody",  "NormalBg", "@punctuation.delimiter" },
        { "16",               "vimNumber",    "NormalBg", "@number" },
        { ")",                "vimParenSep",  "NormalBg", "@punctuation.bracket" },
    },
    {
        { "  ",           "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "let",          "vimLet",       "NormalBg", "@keyword" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "l:",           "vimVar",       "NormalBg", "@namespace" },
        { "blue",         "vimVar",       "NormalBg", "@variable" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "=",            "vimOper",      "NormalBg", "@operator" },
        { " ",            "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "str2nr",       "vimFuncName",  "NormalBg", "@function.call" },
        { "(",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "substitute",   "vimSubst",     "NormalBg", "@function.call" },
        { "(",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",           "vimOperParen", "NormalBg", "@namespace" },
        { "raw_color",    "vimOperParen", "NormalBg", "@variable" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'.{4}(.{2})'", "vimString",    "NormalBg", "@string" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'1'",          "vimString",    "NormalBg", "@string" },
        { ", ",           "vimOperParen", "NormalBg", "@punctuation.delimiter" },
        { "'g'",          "vimString",    "NormalBg", "@string" },
        { ")",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { ", ",           "vimFuncBody",  "NormalBg", "@punctuation.delimiter" },
        { "16",           "vimNumber",    "NormalBg", "@number" },
        { ")",            "vimParenSep",  "NormalBg", "@punctuation.bracket" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg", "vimFuncBody" },
    },
    {
        { "  ",         "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "let",        "vimLet",       "NormalBg", "@keyword" },
        { " ",          "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "l:",         "vimVar",       "NormalBg", "@namespace" },
        { "brightness", "vimVar",       "NormalBg", "@variable" },
        { " ",          "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "=",          "vimOper",      "NormalBg", "@operator" },
        { " ",          "vimFuncBody",  "NormalBg", "vimFuncBody" },
        { "((",         "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",         "vimOperParen", "NormalBg", "@namespace" },
        { "red",        "vimOperParen", "NormalBg", "@variable" },
        { " * ",        "vimOperParen", "NormalBg", "@operator" },
        { "299",        "vimNumber",    "NormalBg", "@number" },
        { ")",          "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { " ",          "vimOperParen", "NormalBg", "vimFuncBody" },
        { "+",          "vimOper",      "NormalBg", "@operator" },
        { " ",          "vimOperParen", "NormalBg", "vimFuncBody" },
        { "(",          "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",         "vimOperParen", "NormalBg", "@namespace" },
        { "green",      "vimOperParen", "NormalBg", "@variable" },
        { " * ",        "vimOperParen", "NormalBg", "@operator" },
        { "587",        "vimNumber",    "NormalBg", "@number" },
        { ")",          "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { " ",          "vimOperParen", "NormalBg", "vimFuncBody" },
        { "+",          "vimOper",      "NormalBg", "@operator" },
        { " ",          "vimOperParen", "NormalBg", "vimFuncBody" },
        { "(",          "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { "l:",         "vimOperParen", "NormalBg", "@namespace" },
        { "blue",       "vimOperParen", "NormalBg", "@variable" },
        { " * ",        "vimOperParen", "NormalBg", "@operator" },
        { "114",        "vimNumber",    "NormalBg", "@number" },
        { "))",         "vimParenSep",  "NormalBg", "@punctuation.bracket" },
        { " / ",        "vimOperParen", "NormalBg", "@operator" },
        { "1000",       "vimNumber",    "NormalBg", "@number" },
    },
    {
        { "  ", "vimFuncBody", "NormalBg", "vimFuncBody" },
    },
    {
        { "  ",         "vimFuncBody", "NormalBg", "vimFuncBody" },
        { "return",     "vimNotFunc",  "NormalBg", "@keyword" },
        { " ",          "vimFuncBody", "NormalBg", "vimFuncBody" },
        { "l:",         "vimVar",      "NormalBg", "@namespace" },
        { "brightness", "vimVar",      "NormalBg", "@variable" },
        { " ",          "vimFuncBody", "NormalBg", "vimFuncBody" },
        { ">",          "vimOper",     "NormalBg", "@operator" },
        { " ",          "vimFuncBody", "NormalBg", "vimFuncBody" },
        { "155",        "vimNumber",   "NormalBg", "@number" },
    },
    {
        { "endfunction", "vimCommand", "NormalBg", "@keyword.function" },
    },
}



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

return exampleCode
