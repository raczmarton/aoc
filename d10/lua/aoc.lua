
function GetMap(path)

    local f = io.open(path, "r")
    if f == nil then
        return
    end
    local map = {}
    local line_count = 0
    for line in f:lines() do
        if line == nil then
            return map
        end
        local num_line = {}
        local idx = 0
        for c in line:gmatch "." do
            num_line[idx] = tonumber(c)
            idx = idx + 1
        end
        map[line_count] = num_line
        line_count = line_count + 1
    end
    f:close()
    return map
end

function CheckNeighbors(part1, map, i, j, reached)
    local val = map[i][j]
    local score = 0
    if val == 0 and part1 then
        reached = {}
    end
    if val == 9 then
        if part1 then
            for _, v in pairs(reached) do
                if v[1] == i and v[2] == j then
                    return 0
                end
            end
            table.insert(reached, {i, j})
        end
        return 1
    end
    for y = i - 1, i + 1 do
        if y ~= i and map ~= nil and map[y] ~= nil and map[y][j] ~= nil and map[y][j] == (val + 1) then
            score = score + CheckNeighbors(part1, map, y, j, reached)
        end
    end
    for x = j - 1, j + 1 do
        if x ~= j and map ~= nil and map[i] ~= nil and map[i][x] ~= nil and map[i][x] == (val + 1) then
            score = score + CheckNeighbors(part1, map, i, x, reached)
        end
    end
    return score
end

function Run(path, part1)
    local map = GetMap(path)
    if map == nil then
        return
    end
    local count = 0
    for i, row in pairs(map) do
        for j, val in pairs(row) do
            if (val == 0) then
                local score = CheckNeighbors(part1, map, i, j)
                count = count + score
            end
        end
    end
    print(count)
end

Run("input", true)
Run("input", false)
