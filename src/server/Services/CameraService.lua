local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CameraService = Knit.CreateService {
    Name = "CameraService",
    Client = {UseCamera = Signal.new()},
}

function CameraService:LockToPart()
    
end

function CameraService:KnitStart()
    
end


function CameraService:KnitInit()
    
end


return CameraService
