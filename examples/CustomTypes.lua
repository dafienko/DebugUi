--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DebugUi = require(ReplicatedStorage.DebugUi)

local MySimpleType = {}
MySimpleType.__index = MySimpleType

type MySimpleType = typeof(setmetatable(
	{} :: {
		name: string,
	},
	MySimpleType
))

function MySimpleType.new(name: string): MySimpleType
	return setmetatable({
		name = name,
	}, MySimpleType)
end

function MySimpleType._debug(self: MySimpleType)
	return self.name, "MySimpleType"
end

local MyCustomPair = {}
MyCustomPair.__index = MyCustomPair

type MyCustomPair<T> = typeof(setmetatable(
	{} :: {
		first: T,
		second: T,
	},
	MyCustomPair
))

function MyCustomPair.new<T>(a: T, b: T): MyCustomPair<T>
	return setmetatable({
		first = a,
		second = b,
	}, MyCustomPair)
end

function MyCustomPair._debug<T>(self: MyCustomPair<T>)
	return `<{self.first}, {self.second}>`, `MyCustomPair<{typeof(self.first)}>`
end

DebugUi.observe("Tables", {
	simpleType = MySimpleType.new("Hello!"),
	numberPair = MyCustomPair.new(1, 2),
	stringPair = MyCustomPair.new("one", "two"),
})

return nil
