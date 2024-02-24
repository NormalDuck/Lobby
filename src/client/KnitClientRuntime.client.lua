--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(StarterPlayerScripts.Client.Controllers)


Knit.Start():andThen(function()
    local CameraController = Knit.GetController("CameraController")
    CameraController:LockToPart(workspace:WaitForChild("Part"), false, Enum.EasingStyle.Linear, 0)
end)