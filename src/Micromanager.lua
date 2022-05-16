local HttpService = game:GetService("HttpService")

local packages = script.Parent.Parent
local Isotope = require(packages:WaitForChild("isotope"))
local Query = require(packages:WaitForChild("query"))

local Micromanager = {}
Micromanager.__index = Micromanager
setmetatable(Micromanager, Isotope)
-- warning, most Roblox devs transform into this class when given a job as a producer
-- this is called Polymorphism
-- the rest of the documentation here won't be much more helpful

function Micromanager:Destroy()
	if self.IsAlive ~= true then return end
	-- print("Micromanager destroy")
	self:Clean()
	self.IsAlive = false
	self.Instance.Transparency = 0.5

	Query.removeKVTag(self.Instance, "MicromanagerId")
	Isotope.Destroy(self)
end

function Micromanager:Clean()
	if self.IsAlive ~= true then return end
	-- print("Update 2")
	for i, inst in ipairs(Query.getKVTagged("MicroBuildId", self.Id)) do
		if Query.getValueFromKey(inst, "MicroBuild") == self.Type then
			inst:Destroy()
		end
	end
end

function Micromanager:Update()
	-- print("Update 1")
	if self.IsAlive ~= true then return end
	-- print("Update 2")
	self:Clean()
	self.Instance.Transparency = 1
	local model = self.Module(self.Instance)
	if model then
		Query.addKVTag(model, "MicroBuild", self.Type)
		Query.addKVTag(model, "MicroBuildId", self.Id)
		for i, part in ipairs(model:GetDescendants()) do
			Query.addKVTag(part, "MicroBuild", self.Type)
			Query.addKVTag(part, "MicroBuildId", self.Id)
		end
	end
end

function Micromanager.new(inst: Instance, moduleInst: Instance)
	if not inst then warn("No instance provided") return end
	if not moduleInst then warn("No module instance provided") return end
	if Query.getValueFromKey(inst, "MicromanagerId") then return end

	local self = Isotope.new()
	setmetatable(self, Micromanager)
	local id = string.gsub(string.gsub(HttpService:GenerateGUID(false), "%a", ""), "%p", "")
	self.Random = Random.new(tonumber(id))
	self.Id = tostring(id)
	Query.addKVTag(inst, "MicromanagerId", self.Id)
	self.IsAlive = true
	self.Instance = inst
	self.Type = string.gsub(moduleInst.Name, "%.micro", "")
	Query.addKVTag(self.Instance, "MicroType", self.Type)
	-- print("Module Instance", moduleInst:GetFullName())
	self.Module = require(moduleInst)
	-- self.Interface = interface
	self._Maid:GiveTask(inst.AttributeChanged:Connect(function()
		self:Update()
	end))

	self._Maid:GiveTask(inst:GetPropertyChangedSignal("Size"):Connect(function()
		self:Update()
	end))
	self._Maid:GiveTask(inst:GetPropertyChangedSignal("CFrame"):Connect(function()
		self:Update()
	end))
	self._Maid:GiveTask(inst.Destroying:Connect(function()
		self:Destroy()
	end))

	self.BindableEvent = Instance.new("BindableEvent", inst)
	self.BindableEvent.Name = "DestroyMicromanager"
	self._Maid:GiveTask(self.BindableEvent)
	self._Maid:GiveTask(self.BindableEvent.Event:Connect(function()
		self:Destroy()
	end))
	self:Update()
	return self
end


return Micromanager