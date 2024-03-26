--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local CameraController = Knit.CreateController({ Name = "CameraController", ActiveTween = false, CameraSpeed = 100 })

local CurrentCamera = workspace.CurrentCamera

export type Override = {
	ForceTweenTime: number,
	DisableTweening: boolean,
	EasingStyle: Enum.EasingStyle,
}

function CameraController:LockToPart(Part: Part, Yields: boolean, EasingStyle: Enum.EasingStyle, Time: number)
	self.ActiveTween = true
	local Solved = false
	if not Player:HasAppearanceLoaded() then
		task.spawn(function()
			while not Player:HasAppearanceLoaded() do
				if Player:HasAppearanceLoaded() then
					break
				end
			end
			CurrentCamera.CameraType = Enum.CameraType.Scriptable
			local Distance = (Part.CFrame.Position - CurrentCamera.CFrame.Position).Magnitude
			local tweenInfo = TweenInfo.new(
				(Time or Distance / self.CameraSpeed),
				(EasingStyle or Enum.EasingStyle.Linear),
				Enum.EasingDirection.InOut
			)
			local Tween = TweenService:Create(CurrentCamera, tweenInfo, { CFrame = Part.CFrame })
			Tween:Play()
			Tween.Completed:Once(function()
				self.ActiveTween = false
				Solved = true
			end)
		end)
	else
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		local Distance = (Part.CFrame.Position - CurrentCamera.CFrame.Position).Magnitude
		local tweenInfo = TweenInfo.new(
			(Time or Distance / self.CameraSpeed),
			(EasingStyle or Enum.EasingStyle.Linear),
			Enum.EasingDirection.InOut
		)
		local Tween = TweenService:Create(CurrentCamera, tweenInfo, { CFrame = Part.CFrame })
		Tween:Play()
		Tween.Completed:Once(function()
			self.ActiveTween = false
			Solved = true
		end)
	end

	if Yields then
		while not Solved do
			task.wait()
			if Solved then
				break
			end
		end
	end
end

function CameraController:Unlock(EasingStyle: Enum.EasingStyle, Time: number)
	task.spawn(function()
		local HumanoidRootPart = Players.LocalPlayer.Character.HumanoidRootPart
		if EasingStyle then
			local Distance = (HumanoidRootPart.CFrame.Position - CurrentCamera.CFrame.Position).Magnitude
			local tweenInfo = TweenInfo.new(
				(Time or Distance / 100),
				(EasingStyle or Enum.EasingStyle.Linear),
				Enum.EasingDirection.InOut
			)
			local Tween = TweenService:Create(
				CurrentCamera,
				tweenInfo,
				{ CFrame = HumanoidRootPart.CFrame - Vector3.new(-10, 0, 0) }
			)
			Tween:Play()
			Tween.Completed:Once(function()
				CurrentCamera.CameraType = Enum.CameraType.Custom
			end)
		else
			CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	end)
end

function CameraController:KnitInit() end

function CameraController:KnitStart() end

return CameraController
