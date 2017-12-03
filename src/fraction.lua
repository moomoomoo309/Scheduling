--- Represents fractions. Uses exact values if possible, but error will exist in fractions made from floats.
--- @class fraction
local fraction = {}
local metatable

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
    return self.n .. ((self.d ~= 1 and self.n ~= 0) and "/" .. self.d or "")
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
return fraction