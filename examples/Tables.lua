--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DebugUi = require(ReplicatedStorage.DebugUi)

local data = {
    MyTable = {
        Number = 123,
        Boolean = false,
        String = "hello",
        Array = {1, 2, 3, 4, 5},
        NestedTable = {
            A = 1,
            B = 2,
            Three = "three"
        }
    },
    MyTable2 = {
        true, true, true, false, true, "hello" :: any
    }
}

DebugUi.observe("Tables", data)

return nil