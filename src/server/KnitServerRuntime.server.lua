local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServicesDeep(ServerScriptService.Server.Services)

Knit.Start():andThen(function()
    local MazeService = Knit.GetService("MazeService")
    MazeService:NewMaze{MazeSize = 50, CellSize = 10, Algorithm = "Backtrack", StartingVector = Vector3.new()}:Render()
end)