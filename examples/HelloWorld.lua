--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DebugUi = require(ReplicatedStorage.DebugUi)

local data = {
    number = 1
}

task.spawn(function() 
    while task.wait(1) do 
        data.number += 1
    end
end)

return DebugUi.observe("Hello, world!", data)
