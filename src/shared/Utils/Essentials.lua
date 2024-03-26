--!native
local Essentials = {}
local RenderStepped = game:GetService("RunService").Heartbeat

function Essentials.QuickWait(n: number)
	local startTime = os.clock()
	local currentTime = os.clock()
	while os.clock() - startTime <= n do
		if os.clock() - currentTime >= 0.01 then
			RenderStepped:Wait()
			currentTime = os.clock()
		end
	end
end

function Essentials.RemoveTableDupes(t: table)
	local hash = {}
	local res = {}
	for _, v in ipairs(t) do
		if not hash[v] then
			res[#res + 1] = v
			hash[v] = true
		end
	end
	return res
end

function Essentials.DictLength(t: table): number
	local n = 0

	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

function Essentials.OddOrEven(n: number): "Odd" | "Even"
	if n % 2 == 0 then
		return "Even"
	else
		return "Odd"
	end
end

return Essentials
