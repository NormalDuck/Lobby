local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local SafeTeleport = {}

local _ExpirationTime = 60
--[=[
    Teleports a **single player** with the PlaceId provided above. If MaxRetries is nil, it will be 0 retries by default.
    ```lua
    print("hello world!")
    ```
]=]
function SafeTeleport:TeleportPlayer(PlaceId: number, Player: Player, MaxRetries: number, TeleportData: table)
	assert(not RunService:IsStudio(), "[SafeTeleport] cannot perform teleportion inside of studio.")
	assert(PlaceId, "[SafeTeleport] didn't provide place id")
	assert(Player, "[SafeTeleport] didn't provide player")
	local Success, Error = pcall(function()
		TeleportService:Teleport(PlaceId, Player)
	end)
	if not Success and Error then
		if MaxRetries ~= 0 then
			self:TeleportPlayer(PlaceId, Player, MaxRetries - 1)
		end
	end
end

--[[
    Teleports a group of Players to the same server of the place with the given PlaceId. 
    **do not use dictionary tables for Players argument**. Teleport data will be the same for all players.
]]
function SafeTeleport:TeleportPlayers(PlaceId: number, Players: { Player }, MaxRetries: number, TeleportData: table)
	assert(not RunService:IsStudio(), "[SafeTeleport] cannot perform teleportion inside of studio.")
	assert(PlaceId, "[SafeTeleport] didn't provide place id")
	assert(Players, "[SafeTeleport] didn't provide player")
	for _, Player in ipairs(Players) do
		local MemoryStore = MemoryStoreService:GetQueue(Player.UserId)
		MemoryStore:AddAsync(TeleportData)
	end
	local Success, Error = pcall(function()
		TeleportService:TeleportPartyAsync(PlaceId, Players)
	end)
	if not Success and Error then
		if MaxRetries ~= 0 then
			self:TeleportPlayer(PlaceId, Players, MaxRetries - 1)
		end
	end
	TeleportService:TeleportPartyAsync()
end

function SafeTeleport() end

return SafeTeleport
