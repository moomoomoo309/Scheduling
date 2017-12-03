#!/usr/bin/luajit
--- Represents fractions. Uses exact values if possible, but error will exist in fractions made from floats.
--- @class fraction
local fraction = {}
local metatable

local integersSupported = tonumber(_VERSION:sub(-1)) >= 3 or tonumber(_VERSION:sub(-3,-3)) > 5
local function intWrapper(num)
    return integersSupported and math.tointeger(num) or num
end

--- Returns the Greatest Common Factor of the given operands.
--- @tparam a number The first operand.
--- @tparam b number The second operand.
--- @error If a or b are not numbers.
--- @treturn number The Greatest Common Factor of the given operands.
local function gcf(a, b)
    a = a < 0 and -a or a
    b = b < 0 and -b or b
    if b == 0 then
        return a
    end
    return gcf(b, a % b)
end

--- Returns the Least Common Multiple of the given operands.
--- @tparam a number The first operand.
--- @tparam b number The second operand.
--- @treturn number The Least Common Multiple of the given operands.
local function lcm(a, b)
    return a * b / gcf(a, b)
end


--- Creates a new fraction.
--- @tparam n number The numerator of the fraction.
--- @tparam d number The denominator of the fraction.
--- @tparam doNotSimplify boolean|nil Whether the fraction should be automatically simplified or not.
--- @treturn fraction A fraction with the given numerator and denominator, simplified if doNotSimplify is false or nil.
function fraction.new(n, d, doNotSimplify)
    if type(n) == "string" and d == nil then
        local nNumber = tonumber(n)
        if nNumber then
            n = nNumber
            d = 1
        else
            local slashIndex = n:find("/", nil, true)
            assert(slashIndex, ("Tried to load fraction from string \"%s\", but was malformed."):format(n))
            d = tonumber(n:sub(slashIndex + 1))
            n = tonumber(n:sub(1, slashIndex - 1))
        end
    end
    return setmetatable(doNotSimplify and { n = n or 1, d = d or 1, type = "fraction" } or fraction.simplify { n = n or 1, d = d or 1, type = "fraction" }, metatable)
end

--- Creates a fraction given a number.
--- @tparam number number|fraction The number to convert.
--- @error If number is not a number or fraction.
--- @treturn fraction A fraction within 1e-7 of the given number.
function fraction.of(number)
    if type(number) == "table" and number.type == "fraction" then
        return number
    end
    assert(type(number) == "number", ("Number expected, got %s."):format(type(number) == "table" and number.type or type(number)))
    local mult = 1
    while number % 1 > 1e-7 do
        number = number * 10
        mult = mult * 10
    end
    return fraction.new(number * mult, mult)
end

--- Returns a new fraction which is the most simplified form of the given fraction.
--- @error If self is not a fraction.
--- @treturn fraction The most simple fraction that can be made from the given fraction.
function fraction:simplify()
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if self.n == 0 then
        return self
    end
    local gcf = gcf(self.n, self.d)
    return fraction.new(self.n / gcf, self.d / gcf, true)
end

--- Adds two fractions together.
--- @type other number|fraction
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of the two fractions added together.
function fraction:add(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if type(other) == "table" and other.type == "fraction" then
        local newSelf, newOther = self:makeLikeDenominator(other)
        return fraction.new(newSelf.n + newOther.n, newSelf.d)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Subtracts other from self.
--- @type other number|fraction
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of other subtracted from self.
function fraction:subtract(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if type(other) == "table" and other.type == "fraction" then
        local newSelf, newOther = self:makeLikeDenominator(other)
        return fraction.new(newSelf.n - newOther.n, newSelf.d)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Multiplies self with other.
--- @type other number|fraction
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of other subtracted from self.
function fraction:multiply(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if type(other) == "table" and other.type == "fraction" then
        return fraction.new(self.n * other.n, self.d * other.d)
    elseif type(other) == "number" then
        return fraction.new(self.n * other, self.d)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Divides other from self.
--- @type other number|fraction
--- @error If other or self are not a fractions or numbers.
--- @treturn fraction A new fraction that is the result of self divided by other.
function fraction:divide(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    assert(self.d ~= 0 and other.d ~= 0, ("Cannot divide by 0!"))
    if type(other) == "table" and other.type == "fraction" then
        return fraction.new(self.n * other.d, self.d * other.n)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Gets the modulus of self and other.
--- @type other number|fraction
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the modulus of self and other.
function fraction:mod(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if type(other) == "table" and other.type == "fraction" then
        local newSelf, newOther = self:makeLikeDenominator(other)
        return fraction.new(newSelf.n % newOther.n, newSelf.d)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Multiplies the given fraction by -1.
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of self multiplied by -1.
function fraction:unaryMinus()
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return fraction.new(-math.abs(self.n), math.abs(self.d), true)
end

--- Multiplies the given fraction by -1 if negative, or by 1 otherwise.
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of self multiplied by -1 if negative, or by 1 otherwise.
function fraction:unaryPlus()
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return fraction.new(math.abs(self.n), math.abs(self.d), true)
end

fraction.abs = fraction.unaryPlus

--- Raises self to the power of other.
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn fraction A new fraction that is the result of self raised to the power of others.
function fraction:pow(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    if type(other) == "table" and other.type == "fraction" then
        return fraction.new(self.n ^ other.n, self.d ^ other.d)
    end
    error(("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
end

--- Returns if self is less than other.
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn boolean If self is less than other.
function fraction:lessThan(other)
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    return (type(self) == "table" and self.type == "fraction" and self.n / self.d or self) < (type(other) == "table" and other.type == "fraction" and other.n / other.d or other)
end

--- Returns if self is less than or equal to other.
--- @error If other is not a fraction or number, or if self is not a fraction.
--- @treturn boolean If self is less than or equal to other.
function fraction:lessThanEquals(other)
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    return (type(self) == "table" and self.type == "fraction" and self.n / self.d or self) <= (type(other) == "table" and other.type == "fraction" and other.n / other.d or other)
end

--- Returns self and other with like denominators.
function fraction:makeLikeDenominator(other)
    assert(self.d ~= 0 and other.d ~= 0, ("Cannot divide by 0!"))
    local newD = lcm(self.d, other.d)
    local thisMult, thatMult = newD / self.d, newD / other.d
    return fraction.new(self.n * thisMult, newD, true), fraction.new(other.n * thatMult, newD, true)
end

--- Converts self to a string.
--- @treturn string Self as a string.
function fraction:tostring()
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return intWrapper(self.n) .. ((self.d ~= 1 and self.n ~= 0) and "/" .. intWrapper(self.d) or "")
end

--- Returns if self and other are equal.
--- @type other number|fraction
--- @error If other is not a number or fraction, or if self is not a fraction.
function fraction:equals(other)
    other = type(other) == "number" and fraction.of(other) or other
    self = type(self) == "number" and fraction.of(self) or self
    assert((type(other) == "table" and other.type == "fraction") or type(other) == "number", ("Fraction or number expected, got %s."):format(type(other) == "table" and other.type or type(other)))
    assert((type(self) == "table" and self.type == "fraction") or type(self) == "number", ("Fraction or number expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.n == other.n and self.d == other.d
end

--- Concatenates self and other.
--- @return Self and other as strings concatenated together.
function fraction:concat(other)
    return tostring(self) .. tostring(other)
end

--- Converts self to a number.
--- @treturn number Self, as a number.
function fraction:tonumber()
    assert(type(self) == "table" and self.type == "fraction", ("Fraction expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.n / self.d
end

metatable = {
    __add = fraction.add,
    __sub = fraction.subtract,
    __mod = fraction.mod,
    __unm = fraction.unaryMinus,
    __mul = fraction.multiply,
    __div = fraction.divide,
    __pow = fraction.pow,
    __eq = fraction.equals,
    __lt = fraction.lessThan,
    __le = fraction.lessThanEquals,
    __tostring = fraction.tostring,
    __index = fraction,
}

fraction = setmetatable(fraction, { __call = function(_, n, d, doNotSimplify) return fraction.new(n, d, doNotSimplify) end })

local fraction = require "fraction"
local processes, thickBoxes, justify

--- Local function used by left and right pad. Returns the pad string needed.
local function _getPad(str, len, padChar)
    padChar = padChar or " "
    str = str or ""
    local strLen = #str
    local numChars = 0
    if len > strLen then
        numChars = len - strLen
    end
    return padChar:rep(math.floor(numChars / #padChar)) .. padChar:sub(0, numChars % #padChar)
end

--- Pads a string to the given length by prepending padChar to the beginning.
local function leftPad(str, len, padChar)
    return _getPad(str, len, padChar) .. str
end

--- Pads a string to the given length by appending padChar to the end.
local function rightPad(str, len, padChar)
    return str .. _getPad(str, len, padChar)
end

--- Pads a string to the given length by appending padChar to either side.
local function centerPad(str, len, padChar, leftJustify)
    local pad = _getPad(str, len, padChar)
    local shortPad, longPad = pad:sub(1, math.floor(#pad / 2)), pad:sub(math.floor(#pad / 2) + 1)
    return (leftJustify and shortPad or longPad) .. str .. (leftJustify and longPad or shortPad)
end

--- Pads a string to the given length by appending padChar to either side, rounding down on the left and up on the right.
local function centerPadLeft(str, len, padChar)
    return centerPad(str, len, padChar, true)
end

--- Pads a string to the given length by appending padChar to either side, rounding up on the left and down on the right.
local function centerPadRight(str, len, padChar)
    return centerPad(str, len, padChar, false)
end

--- Returns the Greatest Common Factor of the given operands.
--- @tparam a number The first operand.
--- @tparam b number The second operand.
--- @error If a or b are not numbers.
--- @treturn number The Greatest Common Factor of the given operands.
local function gcf(a, b)
    a = a < 0 and -a or a
    b = b < 0 and -b or b
    if b == 0 then
        return a
    end
    return gcf(b, a % b)
end

--- Returns the Least Common Multiple of the given operands.
--- @tparam a number The first operand.
--- @tparam b number The second operand.
--- @treturn number The Least Common Multiple of the given operands.
local function LCM(a, b)
    return a * b / gcf(a, b)
end

local function lcm(tbl)
    local last
    for _, v in pairs(tbl) do
        last = last == nil and v or LCM(last, v)
    end
    return last
end

--- Returns the schedule as a box-formatted string.
local function formatFinishedSchedule(processes, finishedSchedule, startTime, stopTime)
    local columnLengths = {}
    local text = { { "Processes" } }
    --Put the process names in front.
    for i = 1, #processes do
        text[i + 1] = { "J" .. i }
    end
    local timeStep = 1
    local lastTime

    --Figure out what the largest increment of time you can go by is.
    for _, event in pairs(finishedSchedule) do
        local atIndex = event:find("@", 2, true)
        local time = fraction(event:sub(atIndex + 1))
        if lastTime ~= nil then
            local timeDelta = time - lastTime
            if timeDelta > fraction(0) then
                local timeLcm = LCM(timeStep, timeDelta.d)
                timeStep = timeStep > timeLcm and timeStep or timeLcm
            end
        end
        lastTime = time
    end
    timeStep = fraction(1, timeStep)


    --Parse out the schedule and put the resulting characters in text.
    for _, event in pairs(finishedSchedule) do
        local firstChar = event:sub(1, 1)
        local atIndex = event:find("@", 2, true)
        local processNum, time = tonumber(event:sub(2, atIndex - 1)), fraction(event:sub(atIndex + 1))
        local row = ((time - startTime) / timeStep):tonumber() + 2
        if firstChar == ")" then
            text[processNum + 1][row] = text[processNum + 1][row] and
                    ")" .. text[processNum + 1][row] or ")"
        elseif firstChar == "(" then
            text[processNum + 1][row] = text[processNum + 1][row] and
                    text[processNum + 1][row] .. "(" or "("
        elseif firstChar == "s" then
            if event:sub(2, 2) == "x" then
                text[1][row] = "X"
            else
                text[1][row] = "J" .. processNum
            end
        end
    end

    local colSpans = {}
    --Get the column lengths so the table looks right.
    for i = 1, #text do
        for i2 = 1, ((stopTime - startTime) / timeStep):tonumber() + 2 do
            text[i][i2] = text[i][i2] or "" --Put the empty string in there by default so table.concat works right.
            if i == 1 and text[i][i2] == "" then
                text[i][i2] = "\b"
                colSpans[#colSpans + 1] = i2
            end
            columnLengths[i2] = math.max(columnLengths[i2] or 0, #text[i][i2])
        end
    end

    local timeLine
    do
        local tmpOutput = {}
        for i = 1, #text[1] do
            local timeText = i == 1 and "Time" or tostring(startTime + timeStep * (i - 2))
            columnLengths[i] = math.max(columnLengths[i] or 0, #timeText)
            tmpOutput[#tmpOutput + 1] = justify(timeText, columnLengths[i] or 0)
        end
        timeLine = (thickBoxes and "┃" or "│") .. table.concat(tmpOutput, thickBoxes and "┃" or "│") .. (thickBoxes and "┃" or "│")
    end

    local output = {}
    --Do the process line
    do
        local colSpanIndex = 1
        local tmpOutput = {}
        for i2 = 1, #text[1] do
            if colSpans[colSpanIndex] == i2 then
                colSpanIndex = colSpanIndex + 1
                tmpOutput[#tmpOutput] = justify(text[1][i2 - 1], (columnLengths[i2 - 1] or 0) + (columnLengths[i2] or 0) + 1)
            else
                tmpOutput[#tmpOutput + 1] = justify(text[1][i2], columnLengths[i2] or 0)
            end
        end
        output[#output + 1] = (thickBoxes and "┃" or "│") .. table.concat(tmpOutput, thickBoxes and "┃" or "│") .. (thickBoxes and "┃" or "│")
    end

    --Do the middle rows
    for i = 2, #text do
        local tmpOutput = {}
        for i2 = 1, #text[i] do
            tmpOutput[#tmpOutput + 1] = justify(text[i][i2], columnLengths[i2] or 0)
        end
        output[#output + 1] = (thickBoxes and "┃" or "│") .. table.concat(tmpOutput, thickBoxes and "┃" or "│") .. (thickBoxes and "┃" or "│")
    end
    --Do the top, separating, and bottom lines
    local topLine = { thickBoxes and "┏" or "┌" }
    local secondLine = { thickBoxes and "┣" or "├" }
    local fourthLine = { thickBoxes and "┣" or "├" }
    local bottomLine = { thickBoxes and "┗" or "└" }
    for i = 1, #columnLengths do
        local lines = (thickBoxes and "━" or "─"):rep(columnLengths[i])
        topLine[#topLine + 1] = lines
        secondLine[#secondLine + 1] = lines
        fourthLine[#fourthLine + 1] = lines
        bottomLine[#bottomLine + 1] = lines
        if i ~= #columnLengths then
            topLine[#topLine + 1] = thickBoxes and "┳" or "┬"
            secondLine[#secondLine + 1] = thickBoxes and "╋" or "┼"
            fourthLine[#fourthLine + 1] = thickBoxes and "╋" or "┼"
            bottomLine[#bottomLine + 1] = thickBoxes and "┻" or "┴"
        end
    end

    local processLine = output[1]
    processLine = processLine:gsub((thickBoxes and "┃" or "│") .. "\b", "  ")
    do
        local len = 1
        local lastIndex = 1
        for i = 1, #topLine do
            if topLine[i] == (thickBoxes and "┳" or "┬") then
                len = len + 1
                if colSpans[lastIndex] == len then
                    lastIndex = lastIndex + 1
                    topLine[i] = (thickBoxes and "━" or "─")
                    secondLine[i] = thickBoxes and "┳" or "┬"
                end
            end
        end
    end
    table.remove(output, 1)
    --Return the formatted box.
    return table.concat(topLine) .. (thickBoxes and "┓\n" or "┐\n") ..
            processLine .. "\n" ..
            table.concat(secondLine) .. (thickBoxes and "┫\n" or "┤\n") ..
            timeLine .. "\n" ..
            table.concat(fourthLine) .. (thickBoxes and "┫\n" or "┤\n") ..
            table.concat(output, "\n") .. "\n" ..
            table.concat(bottomLine) .. (thickBoxes and "┛" or "┘")
end

--- Schedules the given processes using the given algorithm from startTime to stopTime.
--- @tparam algorithm function A function which takes the processes and the current time, and returns the index of the function to schedule at that time.
local function schedule(processes, algorithm, startTime, stopTime)
    local log = {}
    local finishedSchedule = {}
    local lastScheduleTime = {}
    local feasible = true
    local time = startTime
    while stopTime >= time do
        local scheduledProcess
        --Start processes, get deadlines of processes
        for i, process in pairs(processes) do
            if lastScheduleTime[i] and lastScheduleTime[i] + process.deadline == time then
                if process.scheduled then
                    feasible = false
                end
                log[#log + 1] = (process.scheduled and "[%s] Process %d's deadline was missed!" or "[%s] Process %d's deadline was met."):format(tostring(time), i)
                finishedSchedule[#finishedSchedule + 1] = ")" .. i .. "@" .. tostring(time)
            end
            if time - process.start >= fraction(0) and (time - process.start) % process.period == fraction(0) then
                log[#log + 1] = ("[%s] Process %d queued."):format(tostring(time), i)
                process.scheduled = true
                finishedSchedule[#finishedSchedule + 1] = "(" .. i .. "@" .. tostring(time)
                lastScheduleTime[i] = time
            end
        end
        --Schedule processes
        local index = algorithm(processes, time)

        if index then
            scheduledProcess = processes[index]
            finishedSchedule[#finishedSchedule + 1] = "s" .. index .. "@" .. tostring(time)
            scheduledProcess.scheduled = false
            time = time + processes[index].execution
        else
            finishedSchedule[#finishedSchedule + 1] = "sx@" .. tostring(time)
            local nextTime
            for _, process in pairs(processes) do
                local _nextTime = (time - process.start) % process.deadline
                nextTime = (_nextTime > fraction(0) and (nextTime == nil or nextTime > _nextTime)) and _nextTime or nextTime
            end
            time = time + nextTime
        end
    end
    return formatFinishedSchedule(processes, finishedSchedule, startTime, stopTime), log, feasible
end

-- Scheduling algorithms go below here.
-- Scheduling algorithms should take the form of a function which takes in processes and time and returns an index to the function to schedule.

local function earliestDeadlineFirst(processes, time)
    local remainingTime = fraction(1e9) --If your time is longer than this...
    local index
    for i, process in pairs(processes) do
        if process.scheduled and time - process.start >= fraction(0) then
            local remTime = (time - process.start) % process.deadline
            if remTime < remainingTime then
                remainingTime = remTime
                index = i
            end
        end
    end
    return index
end

local function deadlineMonotonic(processes, _)
    local minDeadline = fraction(1e9)
    local index
    for i, process in pairs(processes) do
        if process.scheduled and process.deadline < minDeadline then
            minDeadline = process.deadline
            index = i
        end
    end
    return index
end





local function feasibilityTests(processes)
    local test1Sum, test2Sum = fraction(0), fraction(0)
    local sum1Terms, sum2Terms = {}, {}
    for _, process in pairs(processes) do
        test1Sum = test1Sum + process.execution / process.period
        sum1Terms[#sum1Terms + 1] = { process.execution, process.period }
        test2Sum = test2Sum + process.execution / process.deadline
        sum2Terms[#sum2Terms + 1] = { process.execution, process.deadline }
    end
    return test1Sum > fraction(1), test2Sum <= fraction(1), test1Sum, test2Sum, sum1Terms, sum2Terms
end

local function makePrettySum(terms, sum)
    local output = {}
    for _, v in pairs(terms) do
        output[#output + 1] = tostring(v[1] / v[2])
    end
    return table.concat(output, " + ") .. " = " .. tostring(sum) .. (sum <= fraction(1) and " <= 1" or " > 1")
end

local function getTimeInterval(processes)
    local maxS = fraction(-1)
    local pList = {}
    for _, process in pairs(processes) do
        maxS = process.start > maxS and process.start or maxS
        pList[#pList + 1] = process.period:tonumber()
    end
    local L = lcm(pList)
    return fraction(0), fraction.of(maxS + 2 * L), fraction.of(maxS + L)
end

local names = {
    [earliestDeadlineFirst] = "Earliest Deadline First",
    [deadlineMonotonic] = "Deadline Monotonic"
}

-- This is the only part of the program you need to edit to input values and change the output!
--- start is s_i, deadline is d_i, and period is p_i.
processes = {
    { start = fraction(0), deadline = fraction(3), period = fraction(4), execution = fraction(1, 2) },
    { start = fraction(2), deadline = fraction(3), period = fraction(4), execution = fraction(1) },
    { start = fraction(2), deadline = fraction(2), period = fraction(3), execution = fraction(1, 2) },
    { start = fraction(1), deadline = fraction(3), period = fraction(3), execution = fraction(1) },
}
thickBoxes = true --Whether thick or thin lines should be used to draw the table.
justify = centerPadLeft --Can be leftPad, rightPad, centerPadLeft, or centerPadRight.
local algorithm = earliestDeadlineFirst --Can be either earliestDeadlineFirst or deadlineMonotonic, though more may be added.
--You don't need to edit anything after this!

local infeasible, feasible, test1Sum, test2Sum, sum1Terms, sum2Terms = feasibilityTests(processes)
print "Performing feasibility tests...\n"
print(makePrettySum(sum1Terms, test1Sum))
print(infeasible and "The given processes are infeasible.\n" or "The first test was inconclusive.\n")
print(makePrettySum(sum2Terms, test2Sum))
print(feasible and "The given processes are feasible." or "The second test was inconclusive.")
if not infeasible and not feasible then
    print "\nCreating schedule...\n"
    local start, stop, _ = getTimeInterval(processes)
    local sched, log, feasible = schedule(processes, algorithm, start, stop)
    print(("The schedule is %sfeasible."):format(feasible and "" or "in"))
    print(("%s scheduling algorithm being used."):format(names[algorithm]))
    print "\nSchedule:"
    print(sched)
    print "\nLog:"
    print(table.concat(log, "\n"))
end
