local function isWindows()
    return package.config:sub(1,1) == '\\'
end

local function highlight(string, highlighting)
    local color = isWindows() and '<' or (string.char(27) ..'[93m')
    table.sort(highlighting, function(a, b) return a[2] > b[2] end)
    for _, highlight in ipairs(highlighting) do
        local i, j = table.unpack(highlight)
        string = string:sub(1, i - 1) ..
                color ..
                string:sub(i, j) ..
                (isWindows() and '>' or (string.char(27) .. '[0m')) ..
                string:sub(j + 1)
    end
    return string
end

return highlight