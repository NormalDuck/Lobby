--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddControllersDeep(StarterPlayer.DeathStyle)

Knit.Start():andThen(function()
    
end)