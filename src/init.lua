local CollectionService = game:GetService("CollectionService")

local packages = script.Parent
local Query = require(script.Parent:WaitForChild("query"))
local Micromanager = require(script:WaitForChild("Micromanager"))

local microKey = "Microgen"

local Interface = {}
Interface.__index = Interface

function Interface.load(inst, moduleInst)
	Query.addKVTag(inst, "Loaded", true)

	Micromanager.new(inst, moduleInst)
end

function Interface.unload(inst)
	local bindableEvent = inst:FindFirstChild("DestroyMicromanager")
	if not bindableEvent then return end
	bindableEvent:Fire()
	Query.addKVTag(inst, "Loaded", false)
end

function Interface.unloadType(microType)
	-- print("UNload type")
	for i, inst in ipairs(Query.getKVTagged("MicroType", microType)) do
		Interface.unload(inst)
	end
end

function Interface.unloadAll()
	-- print("Unload all")
	for i, inst in ipairs(Query.getKTagged("Loaded")) do
		Interface.unload(inst)
	end
end

function Interface.isMicro(inst)
	return Query.hasKTag(inst, microKey)
end

function Interface.get(inst)
	return Query.getValueFromKey(inst, microKey)
end

function Interface.set(inst, val)
	Query.addKVTag(inst, "Loaded", false)
	Query.addKVTag(inst, microKey, val)
end

Interface.unloadAll()

return Interface