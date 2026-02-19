--!strict

local RunService = game:GetService("RunService")

local DataUi = require(script.DataUi)

local DebugUi = {}

function DebugUi.observe(name: string, data: any): () -> ()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = `DebugUi - {name}`
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

	local container = Instance.new("Frame")
	container.Name = "container"
	container.BackgroundColor3 = Color3.fromHSV(0, 0, 0)
	container.BorderSizePixel = 0
	container.AutomaticSize = Enum.AutomaticSize.XY
	container.Parent = screenGui

	Instance.new("UIDragDetector", container)

	local dataUi = DataUi.new(container, name, data, {})
	local connection = RunService.PreRender:Connect(function()
		dataUi:Update(data, {})
	end)

	return function()
		connection:Disconnect()
		dataUi:Destroy()
		screenGui:Destroy()
	end
end

return DebugUi
