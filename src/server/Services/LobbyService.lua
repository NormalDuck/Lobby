local MarketplaceService = game:GetService("MarketplaceService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local LobbyService = Knit.CreateService({
	Name = "LobbyService",
	Client = {
		UserKickedSignal = Knit.CreateSignal(),
		CurrentLobbies = Knit.CreateProperty({}),
	},
})

type Configurations = {
	LobbyOwner: Player,
	PlayersInLobby: table,
	Seed: number,
	MazeSize: number,
	LobbySize: number,
	Visibility: "Private" | "Public" | "Friends",
	IsCreated: boolean,
}

function NumberInRange(number: number, smallest: number, greatest: number): boolean
	if number >= smallest and number <= greatest then
		return true
	else
		return false
	end
end

function LobbyService.Client:EditLobby(Player: Player, Configurations: Configurations)
	local RequestedLobby = self.Server.CurrentLobbies[Player.UserId]
	--[[Sanity Checks]]
	--
	do
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 690608475) then
			if type(Configurations.Seed) == "number" or type(Configurations.Seed) == "nil" then
			else
				print("Seed Failed Sanity Check")
				return
			end
		else
			if type(Configurations.Seed) ~= "nil" and not Configurations.Seed == 0 then
				print("Seed Failed Sanity Check")
				return
			end
		end

		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 690931056) then
			if type(Configurations.LobbySize) == "number" or type(Configurations.LobbySize) == "nil" then
				if not NumberInRange(Configurations.LobbySize, 1, 8) then
					return
				end
			else
				print("Lobby Size Failed Sanity Check")
				return
			end
		else
			if type(Configurations.LobbySize) == "number" or type(Configurations.LobbySize) == "nil" then
				if not NumberInRange(Configurations.LobbySize, 1, 4) then
					print("Lobby Size Failed Sanity Check")
					return
				end
			else
				print("Lobby Size Failed Sanity Check")
				return
			end
		end

		if not NumberInRange(Configurations.MazeSize, 10, 150) then
			return print("Maze Size Failed")
		end
		if
			Configurations.Visibility ~= "Public"
			and Configurations.Visibility ~= "Private"
			and Configurations.Visibility ~= "Friends"
		then
			return print("Invaild statement")
		end
		if RequestedLobby.IsCreated then
			return print("Requested Lobby Cannot edit due to it createed")
		end
	end
	--[[Sanity Checks]]
	--
	if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 690608475) then
		RequestedLobby.Seed = Configurations.Seed
	end
	RequestedLobby.MazeSize = Configurations.MazeSize or 10
	RequestedLobby.LobbySize = Configurations.LobbySize
	RequestedLobby.Visibility = Configurations.Visibility
	self.Server:PushUpdate()
end

function LobbyService.Client:JoinLobby(Player: Player, LobbyOwner: Player): boolean
	local RequestedLobby = self.Server.CurrentLobbies[LobbyOwner.UserId]
	if #RequestedLobby.PlayersInLobby >= RequestedLobby.LobbySize or not RequestedLobby.IsCreated then
		return false
	else
		table.insert(RequestedLobby.PlayersInLobby, Player)
		self.Server:PushUpdate()
		return true
	end
end

function LobbyService.Client:LeaveLobby(Player: Player, LobbyOwner: Player): boolean
	local RequestedLobby = self.Server.CurrentLobbies[LobbyOwner.UserId]
	if RequestedLobby.LobbyOwner == Player then
		return
	end
	if table.find(RequestedLobby.PlayersInLobby, Player) then
		table.remove(RequestedLobby.PlayersInLobby, table.find(RequestedLobby.PlayersInLobby, Player))
		self.Server:PushUpdate()
	end
end

function LobbyService.Client:KickPlayer(Player: Player, OtherPlayer: Player)
	local RequestedLobby = self.Server.CurrentLobbies[Player.UserId]
	if table.find(RequestedLobby.PlayersInLobby, OtherPlayer) and OtherPlayer ~= Player then
		table.remove(RequestedLobby.PlayersInLobby, table.find(RequestedLobby.PlayersInLobby, OtherPlayer))
		self.Server:PushUpdate()
		self.UserKickedSignal:Fire(OtherPlayer)
	end
end

function LobbyService.Client:CreateLobby(Player: Player)
	local RequestedLobby: Configurations = self.Server.CurrentLobbies[Player.UserId]
	if not RequestedLobby.IsCreated then
		RequestedLobby.IsCreated = true
		self.Server:PushUpdate()
	end
end

function LobbyService.Client:DestroyLobby(Player: Player)
	local RequestedLobby: Configurations = self.Server.CurrentLobbies[Player.UserId]
	if RequestedLobby.IsCreated then
		for _, OtherPlayer in RequestedLobby.PlayersInLobby do
			if OtherPlayer ~= Player then
				self:KickPlayer(Player, OtherPlayer)
			end
		end
		RequestedLobby.IsCreated = false
		self.Server:PushUpdate()
	end
end

function LobbyService.Client:StartGame(Player: Player)
	local _MaxTries = 5
	local Tries = 0
	local RequestedLobby: Configurations = self.Server.CurrentLobbies[Player.UserId]
	local AccessCode, PrivateServerId = TeleportService:ReserveServer(16129682787)
	local HashMap = MemoryStoreService:GetSortedMap("MazeInfo")
	HashMap:SetAsync(tostring(PrivateServerId), { MazeSize = RequestedLobby.MazeSize, Seed = RequestedLobby.Seed }, 300)
	local function TeleportPlayer()
		local Success, Error = pcall(function()
			TeleportService:TeleportToPrivateServer(16129682787, AccessCode, RequestedLobby.PlayersInLobby)
		end)
		if not Success and Error and Tries ~= _MaxTries then
			TeleportPlayer()
			Tries += 1
		elseif not Success and Error then
			for _, OtherPlayer: Player in RequestedLobby.PlayersInLobby do
				OtherPlayer:Kick("Please report this issue or retry: " .. Error)
			end
		end
	end

	TeleportPlayer()
end

function LobbyService:KnitInit()
	self.CurrentLobbies = {}
	Players.PlayerAdded:Connect(function(Player)
		self.CurrentLobbies[Player.UserId] = {}
		local PlayerLobby: Configurations = self.CurrentLobbies[Player.UserId]
		PlayerLobby.LobbyOwner = Player
		PlayerLobby.PlayersInLobby = {}
		PlayerLobby.MazeSize = 10
		PlayerLobby.Seed = 0
		PlayerLobby.LobbySize = 1
		PlayerLobby.Visibility = "Private"
		PlayerLobby.IsCreated = false
		table.insert(PlayerLobby.PlayersInLobby, Player)
		self:PushUpdate()
	end)

	Players.PlayerRemoving:Connect(function(Player)
		self.CurrentLobbies[Player.UserId] = nil
	end)
end

function LobbyService:PushUpdate()
	self.Client.CurrentLobbies:Set(self.CurrentLobbies)
end

return LobbyService
