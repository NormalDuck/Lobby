local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local React = require(ReplicatedStorage.Packages.React)

local Player = Players.LocalPlayer

local GuiController = Knit.CreateController { Name = "GuiController" }

React.createElement("Frame", {Size = UDim2.fromScale(1, 1)}, {
    
})
function GuiController:KnitStart()

end

function GuiController:KnitInit()

end


return GuiController
