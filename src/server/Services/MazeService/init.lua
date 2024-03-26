--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local RemoveTableDupes = require(ReplicatedStorage.Shared.Utils.Essentials).RemoveTableDupes
local OddOrEven = require(ReplicatedStorage.Shared.Utils.Essentials).OddOrEven

local StackModule = require(script.StackModule)
local NodeModule = require(script.NodeModule)
local Constants = require(script.Constants)

export type Configurations = {
	StartingNode: number,
	MazeSize: number,
	WallColor: Color3,
	CellSize: number,
	Material: Enum.Material,
	Thickness: number,
	Height: number,
	StartingVector: Vector3,
	Seed: number,
	Algorithm: "Recursive" | "Prims",
}

local MazeService = Knit.CreateService({
	Name = "MazeService",
	Nodes = { NodeModule.Node },
	Client = {},
	Configurations = {} :: Configurations,
})

local function RemoveWalls(CurrentNode, NextNode)
	local X = CurrentNode.X - NextNode.X
	local Y = CurrentNode.Y - NextNode.Y
	if X == -1 then
		CurrentNode.Walls.Right = false
		NextNode.Walls.Left = false
	end
	if X == 1 then
		CurrentNode.Walls.Left = false
		NextNode.Walls.Right = false
	end
	if Y == 1 then
		CurrentNode.Walls.Down = false
		NextNode.Walls.Up = false
	end
	if Y == -1 then
		CurrentNode.Walls.Up = false
		NextNode.Walls.Down = false
	end
end

function MazeService:NewMaze(Configurations: Configurations)
	local function CreateBoard(BoardWidth, BoardHeight)
		local Index = 1
		for y = 1, BoardWidth do
			for x = 1, BoardHeight do
				local NewNode = NodeModule.new(x, y, BoardWidth)
				table.insert(self.Nodes, NewNode)
				Index += 1
				--Removing walls is intended to remove extra instances that overlap
				if x ~= BoardWidth then
					NewNode.Walls.Right = false
				end
				if y ~= BoardWidth then
					NewNode.Walls.Up = false
				end
				--
			end
		end
	end

	self.Configurations.MazeSize = Configurations.MazeSize or Constants.MazeSize
	self.Configurations.StartingNode = Configurations.StartingNode or Constants.StartingNode
	self.Configurations.StartingVector = Configurations.StartingVector or Constants.StartingVector
	self.Configurations.Thickness = Configurations.Thickness or Constants.Thickness
	self.Configurations.Height = Configurations.Height or Constants.Height
	self.Configurations.Seed = Configurations.Seed or Constants.Seed
	self.Configurations.WallColor = Configurations.WallColor or Constants.WallColor
	self.Configurations.CellSize = Configurations.CellSize or Constants.CellSize
	self.Configurations.Material = Configurations.Material or Constants.Material
	self.Configurations.Algorithm = Configurations.Algorithm or Constants.Algorithm
	self.Seed = Random.new(self.Configurations.Seed)

	local function CreateRoom(Size: number)
		local calls = 0
		assert(tonumber(Size), "Please pass down a number")
		local SelectedNode: NodeModule.Node = self.Nodes[self.Seed:NextInteger(1, #self.Nodes)]
		local VaildNode = false
		while true do
			local NodesInRoom = {} :: NodeModule.Node
			local FalseSignal = false
			local BreakSignal = false

			for y = 0, Size - 1 do
				for x = 0, Size - 1 do
					local Node: NodeModule.Node = SelectedNode:_FindNode(x, y)
					table.insert(NodesInRoom, Node)
					if Node and Node then
						if Node.Visited or Node.Visited then
							FalseSignal = true
						end
					else
						FalseSignal = true
					end
				end
			end
			if FalseSignal then
				SelectedNode = self.Nodes[self.Seed:NextInteger(1, #self.Nodes)]
				continue
			end
			for _, Node: NodeModule.Node in ipairs(NodesInRoom) do
				local ReplacementIndex = table.find(self.Nodes, Node)
				Node.Visited = true
				Node.Event = "Room" .. Size
				if SelectedNode.Y - Node.Y ~= 0 then
					Node.Walls.Down = false
				else
					Node.Walls.Down = true
				end
				if SelectedNode.X - Node.X ~= 0 then
					Node.Walls.Left = false
				else
					Node.Walls.Left = true
				end
				self.Nodes[ReplacementIndex] = Node
			end
			local ReplacementIndex = table.find(self.Nodes, SelectedNode)
			SelectedNode.Walls.Left = false
			SelectedNode.Visited = true
			self.Nodes[ReplacementIndex] = SelectedNode
			BreakSignal = true
			if BreakSignal then
				break
			end
			task.wait()
		end
	end
	CreateBoard(self.Configurations.MazeSize, self.Configurations.MazeSize)

	if self.Configurations.Algorithm == "Backtrack" then
		local Stack = StackModule.new(self.Configurations.MazeSize * self.Configurations.MazeSize)
		local CurrentNode = Stack:Push(self.Nodes[self.Configurations.StartingNode])
		CurrentNode.Visited = true
		self.Nodes[#self.Nodes].Walls.Up = false --Exit
		while not Stack:IsEmpty() do
			CurrentNode = Stack:Pop()
			local Neighbors = CurrentNode:FindNeighbors("NonVisited")
			if Neighbors ~= nil then
				local NextNode = Neighbors[self.Seed:NextInteger(1, #Neighbors)]
				Stack:Push(CurrentNode)
				RemoveWalls(CurrentNode, NextNode)
				NextNode.Visited = true
				Stack:Push(NextNode)
			end
		end
		Stack:Destroy()
	end

	if self.Configurations.Algorithm == "Prims" then
		local Frontier = {}
		self.Nodes[self.Configurations.StartingNode].Visited = true
		Frontier = TableUtil.Extend(Frontier, self.Nodes[self.Configurations.StartingNode]:FindNeighbors("NonVisited"))
		self.Nodes[#self.Nodes].Walls.Up = false --Exit
		while not TableUtil.IsEmpty(Frontier) do
			local CurrentNode = Frontier[self.Seed:NextInteger(1, #Frontier)]
			local Neighbors = CurrentNode:FindNeighbors("NonVisited")
			CurrentNode.Visited = true
			if Neighbors ~= nil then
				Frontier = TableUtil.Extend(Frontier, CurrentNode:FindNeighbors("NonVisited"))
				Frontier = RemoveTableDupes(Frontier)
			end
			RemoveWalls(
				CurrentNode:FindNeighbors("Visited")[self.Seed:NextInteger(1, #CurrentNode:FindNeighbors("Visited"))],
				CurrentNode
			)
			table.remove(Frontier, table.find(Frontier, CurrentNode))
		end
	end

	local Possible3Walls = {}
	for _, Node in ipairs(self.Nodes) do
		local Neighbors = Node:FindNeighbors("Visited", true)
		local PossibleWalls = Node:WallCount()
		for Side, OtherNode in pairs(Neighbors) do
			if Side == "Down" and OtherNode.Walls.Up and not Node.Walls.Down then
				PossibleWalls += 1
			end
			if Side == "Up" and OtherNode.Walls.Down and not Node.Walls.Up then
				PossibleWalls += 1
			end
			if Side == "Left" and OtherNode.Walls.Right and not Node.Walls.Left then
				PossibleWalls += 1
			end
			if Side == "Right" and OtherNode.Walls.Left and not Node.Walls.Right then
				PossibleWalls += 1
			end
		end
		if PossibleWalls == 3 then
			table.insert(Possible3Walls, Node)
		end
	end

	for _, Node in ipairs(Possible3Walls) do
		local Neighbors = Node:FindNeighbors("Visited", true)
		for Side, OtherNode in pairs(Neighbors) do
			if Side == "Down" and OtherNode.Walls.Up and not Node.Walls.Down then
				OtherNode.Walls.Up = false
				Node.Walls.Down = true
			end
			if Side == "Up" and OtherNode.Walls.Down and not Node.Walls.Up then
				OtherNode.Walls.Down = false
				Node.Walls.Up = true
			end
			if Side == "Left" and OtherNode.Walls.Right and not Node.Walls.Left then
				OtherNode.Walls.Right = false
				Node.Walls.Left = true
			end
			if Side == "Right" and OtherNode.Walls.Left and not Node.Walls.Right then
				OtherNode.Walls.Left = false
				Node.Walls.Right = true
			end
		end
	end
	return MazeService
end

function MazeService:_MarkEvents()
	local AvailableNodes: number = #self.Nodes

	local _Events = {
		QuestGiver1 = 1,
		QuestGiver2 = 1,
		QuestGiver3 = 1,
		QuestGiver4 = 1,

		Exit = 1,
		Spawn = 1,
	}

	local _EventPercentages = setmetatable({
		Empty = 90,
		Paintings = 10,
	}, {
		__div = function(Table, _AvailableNodes)
			local TranslatedTable = TableUtil.Copy(Table)
			for EventName, EventPercent in pairs(TranslatedTable) do
				TranslatedTable[EventName] = math.round((EventPercent / 100) * _AvailableNodes)
			end
			return TranslatedTable
		end,
	})

	for EventName, MaximumAllowed in pairs(_Events) do
		for i = 1, MaximumAllowed do
			local RandomInteger = self.Seed:NextInteger(1, #self.Nodes)
			local Node = self.Nodes[RandomInteger]
			if not Node:ContainsEvent() then
				AvailableNodes -= 1
				Node.Event = EventName
				continue
			end
			while Node:ContainsEvent() do
				RandomInteger = self.Seed:NextInteger(1, #self.Nodes)
				Node = self.Nodes[RandomInteger]
				if not Node:ContainsEvent() then
					AvailableNodes -= 1
					Node.Event = EventName
					break
				end
			end
		end
	end

	_EventPercentages = _EventPercentages / AvailableNodes

	for EventName, MaximumAllowed in pairs(_EventPercentages) do
		for i = 1, MaximumAllowed do
			local RandomInteger = self.Seed:NextInteger(1, #self.Nodes)
			local Node = self.Nodes[RandomInteger]
			if not Node:ContainsEvent() then
				AvailableNodes -= 1
				Node.Event = EventName
				continue
			end
			while Node:ContainsEvent() do
				RandomInteger = self.Seed:NextInteger(1, #self.Nodes)
				Node = self.Nodes[RandomInteger]
				if not Node:ContainsEvent() then
					AvailableNodes -= 1
					Node.Event = EventName
					break
				end
			end
		end
	end
end

function MazeService:Render()
	local Hallways = 0
	local Deadends = 0
	local Edge = 0
	local None = 0
	for i, Node in self.Nodes do
		Node:Render()
		if Node:WallCount() == 0 then
			None += 1
		end
		if Node:WallCount() == 1 then
			Edge += 1
		end
		if Node:WallCount() == 2 then
			Hallways += 1
		end
		if Node:WallCount() == 3 then
			Deadends += 1
		end
	end
end

function MazeService:KnitInit() end

function MazeService:KnitStart() end

return MazeService
