local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer

local GuiController = Knit.CreateController { Name = "GuiController" }



function GuiController:KnitStart()

end

function GuiController:KnitInit()

end


return GuiController
