return function(coreGui)
	local module = script.Parent
	local packages = module.Parent
	local Maid = require(packages:WaitForChild("maid"))
	local ColdFusion = require(packages:WaitForChild("coldfusion"))
	local Isotope = require(packages:WaitForChild("isotope"))
	local maid = Maid.new()

	task.spawn(function()
		local Panel = require(module.Panel)
		local Frame = ColdFusion.new "Frame" {
			Parent = coreGui,
			Size = UDim2.fromOffset(350,400),
			Position = UDim2.fromScale(0,0),
		}
		maid:GiveTask(Frame)
		local panel = Panel.new({
			Parent = Frame,
		})
		maid:GiveTask(panel)
	end)
	return function()
		maid:Destroy()
	end
end