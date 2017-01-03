-- Layout Engine

local utils = require 'see.utils'
local layout = {}

function layout.layout(items, entries_per_row, slack, total_width, sep, indent, ordered)
    if not sep then sep = '' end
    if not indent then indent = '' end
    if not total_width then total_width = 80 end
    if not slack then slack = 1.2 end
    total_width = total_width + slack
    if not entries_per_row then entries_per_row = 6 end
    -- layout items into items_per_row grid whose final size is width
    local width_per_entry = math.floor(total_width / entries_per_row)
    -- items can be rearranged, so this is an optimal packing problem
    local items = utils.map(tostring, items)
    local items_to_entries = {}
    for _, item in ipairs(items) do
        local entries = math.ceil(#item / width_per_entry)
        local current_slack = (entries - #item/width_per_entry) * width_per_entry
        if current_slack < slack then
            entries = entries + 1
        end
        items_to_entries[item] = entries
    end
    -- Greedy approximation, this is delta-epsilon good
    local grid = {}
    for _, item in ipairs(items) do
        if not ordered then
            -- go through each row and see if it can fit, if not, overflow
            for i = 1, 1e9 do
                -- overflow
                if not grid[i] then
                    grid[i] = {item}
                    break
                end
                local row = grid[i]
                -- find the total width of this row
                local width = utils.reduce(function(a, b) return a + items_to_entries[b] end, row, 0)
                if width + items_to_entries[item] <= entries_per_row then
                    table.insert(row, item)
                    break
                end
            end
        else
            if not grid[#grid] then
                grid[1] = {item}
            else
                local row = grid[#grid]
                -- find the total width of this row
                local width = utils.reduce(function(a, b) return a + items_to_entries[b] end, row, 0)
                if width + items_to_entries[item] <= entries_per_row then
                    table.insert(row, item)
                else
                    table.insert(grid, {item})
                end
            end
        end
    end
    local output = ''
    for i, row in ipairs(grid) do
        for _, item in ipairs(row) do
            local entries = items_to_entries[item]
            local rest = entries * width_per_entry - #item + #sep * (entries - 1)
            local separator = (_ >= #row and ((i < #grid and sep) or '')) or (sep .. (' '):rep(rest))
            output = output .. item .. separator
        end
        output = output .. ((i < #grid and '\n' .. indent) or '')
    end
    return output
end

return layout