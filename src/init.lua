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
	container.AutomaticSize = Enum.AutomaticSize.None
	container.Size = UDim2.fromOffset(300, 400)
	container.Parent = screenGui

	local heading = Instance.new("TextLabel", container)
	heading.Size = UDim2.new(1, 0, 0, 26)
	heading.Position = UDim2.fromOffset(0, -heading.Size.Y.Offset)
	heading.TextScaled = true
	heading.Text = `DebugUi - {name}`
	heading.BorderSizePixel = 0
	heading.BackgroundColor3 = Color3.fromHSV(0, 0, 1)
	heading.TextColor3 = Color3.new()
	heading.Font = Enum.Font.SourceSansBold
	heading.TextXAlignment = Enum.TextXAlignment.Left

	local headingPadding = Instance.new("UIPadding", heading)
	headingPadding.PaddingLeft = UDim.new(0, 4)
	headingPadding.PaddingTop = UDim.new(0, 4)
	headingPadding.PaddingBottom = UDim.new(0, 4)

	local padding = Instance.new("UIPadding", container)
	padding.PaddingTop = UDim.new(0, heading.AbsoluteSize.Y)

	local resizeHandle = Instance.new("ImageButton", container)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.Position = UDim2.fromScale(1, 1)
	resizeHandle.AnchorPoint = Vector2.one / 2
	resizeHandle.Size = UDim2.fromOffset(16, 16)
	resizeHandle.ZIndex = 999
	resizeHandle.BackgroundColor3 = Color3.fromHSV(0, 0, 1)

	local resizeHandleDragDetector = Instance.new("UIDragDetector", resizeHandle)
	resizeHandleDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
	resizeHandleDragDetector.DragContinue:Connect(function(pos)
		local size = pos - container.AbsolutePosition
		container.Size = UDim2.fromOffset(size.X, size.Y)
	end)

	Instance.new("UIDragDetector", container)

	local dataUi = DataUi.new(container, name, data)
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
