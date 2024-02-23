--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddControllersDeep(ReplicatedStorage.Shared.controllers)

Knit.Start():andThen(function()
    
end)