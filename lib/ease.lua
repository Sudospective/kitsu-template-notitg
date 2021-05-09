--ease.xml
--Orignal by XeroOl
sudo()

local ease

-- make a self-filling table based on a generator function
local function cache(func)
	return setmetatable({}, {
		__index = function(self, k)
			self[k] = func(k)
			return self[k]
		end
	})
end

-- make a function cache its results from previous calls
local function fncache(func)
	local cache = {}
	return function(arg)
		cache[arg] = cache[arg] or func(arg)
		return cache[arg]
	end
end

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local pow = math.pow
local exp = math.exp
local pi = math.pi
local abs = math.abs

function flip(fn)
	return function(x) return 1 - fn(x) end
end
flip = fncache(flip)

function bounce(t) return 4 * t * (1 - t) end
function tri(t) return 1 - abs(2 * t - 1) end
function bell(t) return inOutQuint(tri(t)) end
function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
function tap(t) return 3.5 * t * t * sqrt(1 - t) end
function pulse(t) return t < .5 and tap(t * 2) or -pop(t * 2 - 1) end

function spike(t) return exp(-10 * abs(2 * t - 1)) end
function inverse(t) return t * t * (1 - t) * (1 - t) / (0.5 - t) end

popElastic = cache(function(damp)
	return cache(function(count)
		return function(t)
			return (1000 ^ -(t ^ damp) - 0.001) * sin(count * pi * t)
		end
	end)
end)
tapElastic = cache(function(damp)
	return cache(function(count)
		return function(t)
			return (1000 ^ -((1 - t) ^ damp) - 0.001) * sin(count * pi * (1 - t))
		end
	end)
end)
pulseElastic = cache(function(damp)
	return cache(function(count)
		local tap_e = tapElastic[damp][count]
		local pop_e = popElastic[damp][count]
		return function(t)
			return t > .5 and -pop_e(t * 2 - 1) or tap_e(t * 2)
		end
	end)
end)

impulse = cache(function(damp)
	return function(t)
		t = t ^ damp
		return t * (1000 ^ -t - 0.001) * 18.6
	end
end)

local function instant() return 1 end
local function linear(t) return t end
local function inQuad(t) return t * t end
local function outQuad(t) return -t * (t - 2) end
local function inOutQuad(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 2
	else
		return 1 - 0.5 * (2 - t) ^ 2
	end
end
local function inCubic(t) return t * t * t end
local function outCubic(t) return 1 - (1 - t) ^ 3 end
local function inOutCubic(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 3
	else
		return 1 - 0.5 * (2 - t) ^ 3
	end
end
local function inQuart(t) return t * t * t * t end
local function outQuart(t) return 1 - (1 - t) ^ 4 end
local function inOutQuart(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 4
	else
		return 1 - 0.5 * (2 - t) ^ 4
	end
end
local function inQuint(t) return t ^ 5 end
local function outQuint(t) return 1 - (1 - t) ^ 5 end
local function inOutQuint(t)
	t = t * 2
	if t < 1 then
		return 0.5 * t ^ 5
	else
		return 1 - 0.5 * (2 - t) ^ 5
	end
end
local function inExpo(t) return 1000 ^ (t - 1) - 0.001 end
local function outExpo(t) return 0.999 - 1000 ^ -t end
local function inOutExpo(t)
	t = t * 2
	if t < 1 then
		return 0.5 * 1000 ^ (t - 1) - 0.0005
	else
		return 0.9995 - 0.5 * 1000 ^ (1 - t)
	end
end
local function inCirc(t) return 1 - sqrt(1 - t * t) end
local function outCirc(t) return sqrt(-t * t + 2 * t) end
local function inOutCirc(t)
	t = t * 2
	if t < 1 then
		return 0.5 - 0.5 * sqrt(1 - t * t)
	else
		t = t - 2
		return 0.5 + 0.5 * sqrt(1 - t * t)
	end
end

local function inElastic(t)
	t = t - 1
	return -(pow(2, 10 * t) * sin((t - 0.075) * (2 * pi) / 0.3))
end
local function outElastic(t)
	return pow(2, -10 * t) * sin((t - 0.075) * (2 * pi) / 0.3) + 1
end
local function inOutElastic(t)
	t = t * 2 - 1
	if t < 0 then
		return -0.5 * pow(2, 10 * t) * sin((t - 0.1125) * 2 * pi / 0.45)
	else
		return pow(2, -10 * t) * sin((t - 0.1125) * 2 * pi / 0.45) * 0.5 + 1
	end
end

local function inBack(t) return t * t * (2.70158 * t - 1.70158) end
local function outBack(t)
	t = t - 1
	return (t * t * (2.70158 * t + 1.70158)) + 1
end
local function inOutBack(t)
	t = t * 2
	if t < 1 then
		return 0.5 * (t * t * (3.5864016 * t - 2.5864016))
	else
		t = t - 2
		return 0.5 * (t * t * (3.5864016 * t + 2.5864016) + 2)
	end
end

local function outBounce(t)
	if t < 1 / 2.75 then
		return 7.5625 * t * t
	elseif t < 2 / 2.75 then
		t = t - 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	elseif t < 2.5 / 2.75 then
		t = t - 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	else
		t = t - 2.625 / 2.75
		return 7.5625 * t * t + 0.984375
	end
end
local function inBounce(t) return 1 - outBounce(1 - t) end
local function inOutBounce(t)
	if t < 0.5 then
		return inBounce(t * 2) * 0.5
	else
		return outBounce(t * 2 - 1) * 0.5 + 0.5
	end
end

local function inSine(x)
	return 1 - cos(x * (pi * 0.5))
end

local function outSine(x)
	return sin(x * (pi * 0.5))
end

local function inOutSine(x)
	return 0.5 - 0.5 * cos(x * pi)
end
ease = {
	instant = instant,
	linear = linear,
	insine = inSine,
	outsine = outSine,
	inoutsine = inOutSine,
	inquad = inQuad,
	outquad = outQuad,
	inoutquad = inOutQuad,
	incubic = inCubic,
	outcubic = outCubic,
	inoutcubic = inOutCubic,
	inquart = inQuart,
	outquart = outQuart,
	inoutquart = inOutQuart,
	inquint = inQuint,
	outquint = outQuint,
	inoutquint = inOutQuint,
	inexpo = inExpo,
	outexpo = outExpo,
	inoutexpo = inOutExpo,
	incircle = inCirc,
	outcircle = outCirc,
	inoutcircle = inOutCirc,
	inback = inBack,
	outback = outBack,
	inoutback = inOutBack,
	inelastic = inElastic,
	outelastic = outElastic,
	inoutelastic = inOutElastic,
	inbounce = inBounce,
	outbounce = outBounce,
	inoutbounce = inOutBounce,
}

return ease