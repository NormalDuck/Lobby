--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MazeModel = workspace:WaitForChild("Maze")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Node = {}
local MazeService
Knit.OnStart():andThen(function()
	MazeService = Knit.GetService("MazeService")
end)
Node.__index = Node

type self = {
	X: number;
	Y: number;
	Event: string;
	Visited: boolean;
	Instance: Instance | boolean;
	Walls: {
		Up: boolean;
		Down: boolean;
		Left: boolean;
		Right: boolean;
	}
}
export type Node = typeof(setmetatable({} :: self, Node))

function Node.new(X: number, Y: number, MazeSize: number): Node
	local self = setmetatable({} :: self, Node)
	self.MazeSize = MazeSize
	self.X = X
	self.Y = Y
	self.Visited = false
	self.Event = false
	self._trove = Trove.new()
	self.instance = false
	self.Walls = {Up = true, Down = true, Left = true, Right = true}
	return self
end

function Node:_FindNode(X :number, Y: number): self
	local MazeService = Knit.GetService("MazeService")
	local NewX = self.X + X
	local NewY = self.Y + Y
	if NewX < 1 or NewY < 1 or NewX > self.MazeSize or NewY > self.MazeSize then
		return nil
	end
	return MazeService.Nodes[NewX + (NewY - 1) * self.MazeSize]
end

function Node:FindNeighbors(Filter: "Visited" | "NonVisited", Dictionary: boolean, AllowEvents: boolean): {self} | nil
	local Neighbors = {}
	if Dictionary then
		Neighbors.Up = false
		Neighbors.Down = false
		Neighbors.Left = false
		Neighbors.Right = false
	end
	local Up = self:_FindNode(0, 1)
	local Down = self:_FindNode(0, -1)
	local Left = self:_FindNode(-1, 0)
	local Right = self:_FindNode(1, 0)
	if not AllowEvents and Up then if Up["Event"] then Up = nil end end
	if not AllowEvents and Down then if Down["Event"] then Down = nil end end
	if not AllowEvents and Left then if Left["Event"] then Left = nil end end
	if not AllowEvents and Right then if Right["Event"] then Right = nil end end
	if Up ~= nil then
		if Filter == nil or (Filter == "NonVisited" and not Up.Visited) or (Filter == "Visited" and Up.Visited) then
			if Dictionary then
				Neighbors.Up = Up
			else
				table.insert(Neighbors, Up)
			end
		end
	end

	if Down ~= nil then
		if Filter == nil or (Filter == "NonVisited" and not Down.Visited) or (Filter == "Visited" and Down.Visited) then
			if Dictionary then
				Neighbors.Down = Down
			else
				table.insert(Neighbors, Down)
			end
		end
	end

	if Left ~= nil then
		if Filter == nil or (Filter == "NonVisited" and not Left.Visited) or (Filter == "Visited" and Left.Visited) then
			if Dictionary then
				Neighbors.Left = Left
			else
				table.insert(Neighbors, Left)
			end
		end
	end

	if Right ~= nil then
		if Filter == nil or (Filter == "NonVisited" and not Right.Visited) or (Filter == "Visited" and Right.Visited) then
			if Dictionary then
				Neighbors.Right = Right
			else
				table.insert(Neighbors, Right)
			end
		end
	end

	if #TableUtil.Values(Neighbors) > 0 then
		if Dictionary then
			for Side, Exists in pairs(Neighbors) do
				if not Exists then
					Neighbors[Side] = nil
				end

			end
			return Neighbors
		end
		return Neighbors
	else
		return nil
	end
end

function Node:Render()
	local MazeService = Knit.GetService("MazeService")
	local StartingVector = MazeService.Configurations.StartingVector
	local CellSize = MazeService.Configurations.CellSize
	local Height = MazeService.Configurations.Height
	local Thickness = MazeService.Configurations.Thickness
	local Material = MazeService.Configurations.Material
	local WallColor = MazeService.Configurations.WallColor
	local Model = Instance.new("Model")

	Model.Name = self.X .. ", " .. self.Y

	self.Position = Vector3.new(StartingVector.X + CellSize * self.X, StartingVector.Y - (Height / -2), StartingVector.Z + CellSize * self.Y)

	for Index, Exists in pairs(self.Walls) do
		if not Exists then continue end
		local Wall = Instance.new("Part")
		Wall.Anchored = true
		Wall.Material = Material

		if Index == "Up" then
			Wall.Position = Vector3.new(self.Position.X - CellSize / 2, self.Position.Y, self.Position.Z)
			Wall.Size = Vector3.new(CellSize, Height, Thickness)
		end

		if Index == "Down" then
			Wall.Position = Vector3.new(self.Position.X - CellSize / 2, self.Position.Y, self.Position.Z - CellSize)
			Wall.Size = Vector3.new(CellSize,Height,Thickness)
		end

		if Index == "Left" then
			Wall.Position = Vector3.new(self.Position.X - CellSize, self.Position.Y, self.Position.Z - CellSize / 2)
			Wall.Size = Vector3.new(Thickness,Height,CellSize)
		end

		if Index == "Right" then
			Wall.Position = Vector3.new(self.Position.X, self.Position.Y, self.Position.Z - CellSize / 2)
			Wall.Size = Vector3.new(Thickness,Height,CellSize)
		end
		Wall.Name = Index
		Wall.CanTouch = false
		Wall.CanQuery = false
		Wall.Parent = Model
		Wall.Color = WallColor
	end

	local TopWall = Instance.new("Part")
	TopWall.Transparency = 1
	TopWall.Material = Material
	TopWall.Anchored = true
	TopWall.Size = Vector3.new(CellSize, Thickness, CellSize)
	TopWall.Position = Vector3.new(self.Position.X - CellSize / 2, self.Position.Y + Height / 2, self.Position.Z - CellSize / 2)
	TopWall.Name = "Top"
	TopWall.CanTouch = false
	TopWall.CanQuery = false
	TopWall.Color = WallColor

	local BottomWall = Instance.new("Part")
	BottomWall.Material = Material
	BottomWall.Anchored = true
	BottomWall.Size = Vector3.new(CellSize, Thickness, CellSize)
	BottomWall.Position = Vector3.new(self.Position.X - CellSize / 2, self.Position.Y - Height / 2, self.Position.Z - CellSize / 2)
	BottomWall.Name = "Bottom"
	TopWall.CanTouch = false
	TopWall.CanQuery = false
	TopWall.Color = WallColor

	TopWall.Parent = Model
	BottomWall.Parent = Model
	Model.Parent = MazeModel
	self.instance = Model
end

function Node:ContainsEvent(): boolean
	if self.Event then return self.Event else return false end
end

function Node:WallCount(): number
	local Walls = 0
	for _, Exist in pairs(self.Walls) do
		if Exist then
			Walls += 1
		end
	end
	return Walls
end

function Node:Destroy()
	self._trove:Destroy()
end

return Node
--[[
function NodeClass:IsEdge()
	if self.X == 1 or self.X == self.MazeSize or self.Y == 1 or self.Y == self.MazeSize then return true else return false end
end

function NodeClass:IsDeadEnd()
	local WallCount = TableLength(self.Walls)
	if WallCount == 3 and not self:IsEdge() then return true else return false end
end

function NodeClass:IsCorner()
	if self.X == 1 or self.X == self.MazeSize or self.Y == 1 or self.Y == self.MazeSize then return true else return false end
end

function NodeClass:ContainsEvent()
	if #self.Events == 0 then return true else return false end
end

function NodeClass:FindInstance(Maze)
	return Maze:WaitForChild(self.X .. ", " .. self.Y) or warn("Cannot find instance")
end

function NodeClass:AddEvent(EventName)
	table.insert(self.Events,EventName)
end


return NodeClass
]]