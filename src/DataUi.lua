--!strict 

local DataUi = {}
DataUi.__index = DataUi

export type DataUi = typeof(setmetatable({} :: {
    key: any,
    container: GuiObject,
    childrenContainer: GuiObject?,
    keyLabel: TextLabel,
    valueLabel: TextLabel,
    children: {
        [any]: DataUi,
    },
    headerButton: TextButton,
}, DataUi))

function DataUi.new(parent: Instance, key: any, value: any): DataUi
    local container = Instance.new("Frame")
    container.Name = key
    container.Size = UDim2.fromOffset(0, 0)
    container.AutomaticSize = Enum.AutomaticSize.XY
    container.BackgroundTransparency = 1

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
    headerButton.BackgroundTransparency  = 1
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
        children = {}
    }, DataUi)

    self:_updateHeaderButton()
    headerButton.Activated:Connect(function() 
        self:_onHeaderButton()
    end)
    self:Update(value)

    container.Parent = parent

    return self
end

function DataUi._updateHeaderButton(self: DataUi)
    if not self.childrenContainer or next(self.children) == nil then 
        self.headerButton.Text = ""
        return
    end

    self.headerButton.Text = if self.childrenContainer.Visible then "-" else "+"
end

function DataUi._onHeaderButton(self: DataUi)
    if not self.childrenContainer then 
        return 
    end

    if next(self.children) == nil then
        return 
    end

    self.childrenContainer.Visible = not self.childrenContainer.Visible
    self:_updateHeaderButton()
end

function DataUi._getChildrenContainer(self: DataUi): GuiObject
    if self.childrenContainer then 
        return self.childrenContainer
    end

    local childrenContainer = Instance.new("Frame")
    childrenContainer.Name = "childrenContainer"
    childrenContainer.BorderSizePixel = 0
    childrenContainer.BackgroundColor3 = Color3.fromHSV(0, 0, 1)
    childrenContainer.BackgroundTransparency = .9
    childrenContainer.AutomaticSize = Enum.AutomaticSize.XY
    childrenContainer.Size = UDim2.fromOffset(0, 0)
    childrenContainer.LayoutOrder = 2
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

function DataUi.Update(self: DataUi, value: any)
    task.defer(self._updateHeaderButton, self)

    self.keyLabel.Text = `{if typeof(self.key) == "string" then `"{self.key}":` else `[{tostring(self.key)}]:`} {typeof(value)}`
    self.valueLabel.Text = tostring(value)

    if typeof(value) ~= "table" then 
        for _, v in self.children do 
            v:Destroy()
        end
        self.children = {}

        if self.childrenContainer then 
            self.childrenContainer.Visible = false 
        end

        return
    end

    for childKey, childDataUi in self.children do 
        local newChildValue = value[childKey]
        local child = self.children[childKey]
        if newChildValue == nil then 
            child:Destroy()
            self.children[childKey] = nil
            continue
        end

        child:Update(newChildValue)
    end

    local childrenContainer = self:_getChildrenContainer()
    for childKey, childValue in value do 
        if self.children[childKey] then 
            continue
        end

        self.children[childKey] = DataUi.new(childrenContainer, childKey, childValue)
    end
end

function DataUi.Destroy(self: DataUi)
    self.container:Destroy()
end

return DataUi