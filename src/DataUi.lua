--!strict

local DataUi = {}
DataUi.__index = DataUi

export type DataUi = typeof(setmetatable(
	{} :: {
		key: any,
		container: GuiObject,
		childrenContainer: GuiObject?,
		keyLabel: TextLabel,
		valueLabel: TextLabel,
		children: {
			[any]: DataUi,
		},
		headerButton: TextButton,
	},
	DataUi
))

function DataUi.new(parent: Instance, key: any, value: any, trackedTables: { [any]: boolean }?): DataUi
	local container: GuiObject
	if trackedTables then
		local frame = Instance.new("Frame")
		frame.Name = key
		frame.Size = UDim2.fromOffset(0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.XY
		frame.BackgroundTransparency = 1
		container = frame
	else
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = key
		scrollingFrame.Size = UDim2.fromScale(1, 1)
		scrollingFrame.AutomaticSize = Enum.AutomaticSize.None
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.CanvasSize = UDim2.new()
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
		scrollingFrame.ScrollBarThickness = 1
		scrollingFrame.ScrollBarImageColor3 = Color3.fromHSV(0, 0, 1)
		scrollingFrame.ScrollBarImageTransparency = 0
		container = scrollingFrame
	end

	local outerLayout = Instance.new("UIListLayout")
	outerLayout.Name = "outerLayout"
	outerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	outerLayout.FillDirection = Enum.FillDirection.Vertical
	outerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	outerLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	outerLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	outerLayout.Parent = container

	local header = Instance.new("Frame")
	header.Name = "header"
	header.AutomaticSize = Enum.AutomaticSize.X
	header.Size = UDim2.fromOffset(0, 24)
	header.BackgroundTransparency = 1
	header.Parent = container

	local headerLayout = Instance.new("UIListLayout")
	headerLayout.Name = "headerLayout"
	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	headerLayout.FillDirection = Enum.FillDirection.Horizontal
	headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	headerLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	headerLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
	headerLayout.Padding = UDim.new(0, 8)
	headerLayout.Parent = header

	local headerButton = Instance.new("TextButton")
	headerButton.Size = UDim2.fromScale(1, 1)
	headerButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	headerButton.Text = ""
	headerButton.TextSize = 24
	headerButton.Font = Enum.Font.BuilderSans
	headerButton.TextColor3 = Color3.fromHSV(0, 0, 1)
	headerButton.BackgroundTransparency = 1
	headerButton.LayoutOrder = -1
	headerButton.Parent = header

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "keyLabel"
	keyLabel.TextSize = 9
	keyLabel.TextScaled = false
	keyLabel.TextColor3 = Color3.fromHSV(0, 0, 1)
	keyLabel.AutomaticSize = Enum.AutomaticSize.XY
	keyLabel.Size = UDim2.fromOffset(0, 0)
	keyLabel.BackgroundTransparency = 1
	keyLabel.TextXAlignment = Enum.TextXAlignment.Left
	keyLabel.Parent = header

	local valueLabel = keyLabel:Clone()
	valueLabel.Name = "valueLabel"
	valueLabel.LayoutOrder = 3
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = header

	local valueLabelFlexItem = Instance.new("UIFlexItem")
	valueLabelFlexItem.FlexMode = Enum.UIFlexMode.Fill
	valueLabelFlexItem.Parent = valueLabel

	local headerPadding = Instance.new("UIPadding")
	headerPadding.Name = "headerPadding"
	headerPadding.PaddingRight = UDim.new(0, 8)
	headerPadding.Parent = header

	local self: DataUi = setmetatable({
		key = key,
		container = container :: GuiObject,
		keyLabel = keyLabel,
		valueLabel = valueLabel,
		headerButton = headerButton,
		children = {},
	}, DataUi)

	headerButton.Activated:Connect(function()
		local childrenContainer = self:_getChildrenContainer()
		childrenContainer.Visible = not childrenContainer.Visible
	end)

	self:Update(value, trackedTables or {})

	container.Parent = parent

	return self
end

function DataUi._getChildrenContainer(self: DataUi): GuiObject
	if self.childrenContainer then
		return self.childrenContainer
	end

	local childrenContainer = Instance.new("Frame")
	childrenContainer.Name = "childrenContainer"
	childrenContainer.BorderSizePixel = 0
	childrenContainer.BackgroundColor3 = Color3.fromHSV(0, 0, 1)
	childrenContainer.BackgroundTransparency = 0.9
	childrenContainer.AutomaticSize = Enum.AutomaticSize.XY
	childrenContainer.Size = UDim2.fromOffset(0, 0)
	childrenContainer.LayoutOrder = 2
	childrenContainer.Visible = false
	childrenContainer.Parent = self.container

	local innerPadding = Instance.new("UIPadding")
	innerPadding.Name = "innerPadding"
	innerPadding.PaddingLeft = UDim.new(0, 16)
	innerPadding.Parent = childrenContainer

	local innerLayout = Instance.new("UIListLayout")
	innerLayout.Name = "innerLayout"
	innerLayout.Name = "outerLayout"
	innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	innerLayout.FillDirection = Enum.FillDirection.Vertical
	innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	innerLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	innerLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	innerLayout.SortOrder = Enum.SortOrder.Name
	innerLayout.Parent = childrenContainer

	innerLayout.Parent = childrenContainer

	self.childrenContainer = childrenContainer
	return childrenContainer
end

local function doesTableHaveDebugImpl(t: any): boolean
	local success, value = pcall(function()
		local f = t["_debug"]
		return type(f) == "function"
	end)

	return success and value
end

function DataUi.Update(self: DataUi, value: any, trackedTables: { [any]: boolean })
	local isValueAlreadyTracked = false
	local renderValue = value
	local renderType = typeof(value)
	if typeof(value) == "table" then
		isValueAlreadyTracked = trackedTables[value]
		trackedTables[value] = true

		if doesTableHaveDebugImpl(value) then
			renderValue, renderType = value:_debug()
		end
	end

	self.headerButton.Text = ""

	self.keyLabel.Text =
		`{if typeof(self.key) == "string" then `"{self.key}":` else `[{tostring(self.key)}]:`} {renderType or typeof(
			value
		)}`
	if isValueAlreadyTracked then
		self.valueLabel.Text = "cycle_cetected"
		self.valueLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
	else
		self.valueLabel.Text = tostring(renderValue)
		self.valueLabel.TextColor3 = Color3.fromHSV(0, 0, 1)
	end

	if typeof(renderValue) ~= "table" or isValueAlreadyTracked then
		for _, v in self.children do
			v:Destroy()
		end
		self.children = {}

		if self.childrenContainer then
			self.childrenContainer.Visible = false
		end

		return
	end

	self.headerButton.Text = if self.childrenContainer and self.childrenContainer.Visible then "-" else "+"

	if not (self.childrenContainer and self.childrenContainer.Visible) then
		return
	end

	for childKey, childDataUi in self.children do
		local newChildValue = renderValue[childKey]
		local child = self.children[childKey]
		if newChildValue == nil then
			child:Destroy()
			self.children[childKey] = nil
			continue
		end

		child:Update(newChildValue, trackedTables)
	end

	local childrenContainer = self:_getChildrenContainer()
	for childKey, childValue in renderValue do
		if self.children[childKey] then
			continue
		end

		self.children[childKey] = DataUi.new(childrenContainer, childKey, childValue, trackedTables)
	end
end

function DataUi.Destroy(self: DataUi)
	self.container:Destroy()
end

return DataUi
