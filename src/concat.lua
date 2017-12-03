local lines = { "#!/usr/bin/luajit" }

local lineNum = 1
local f
local function getDirIO(dirs, mode)
    for _, dir in pairs(dirs) do
        f = io.open(dir, mode)
        if f then
            break
        end
    end
    return f
end

for line in getDirIO({ "./fraction.lua", "./src/fraction.lua" }, "r"):lines() do
    lines[#lines + 1] = line
    lineNum = lineNum + 1
end
lines[#lines] = nil

lineNum = 1
for line in getDirIO({ "./Scheduling.lua", "./src/Scheduling.lua" }, "r"):lines() do
    if lineNum > 1 then
        lines[#lines + 1] = line
    end
    lineNum = lineNum + 1
end

f = getDirIO({ "./Scheduling2.lua", "./src/Scheduling2.lua" }, "w")
for _, line in pairs(lines) do
    f:write(line)
    f:write "\n"
end
f:close()

