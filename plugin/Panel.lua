local RunService = game:GetService("RunService")
local KSP = game:GetService("KeyframeSequenceProvider")

local packages = script.Parent.Parent

local Maid = require(packages:WaitForChild("maid"))
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Synthetic = require(packages:WaitForChild("synthetic"))
local Microgen = require(packages:WaitForChild("microgen"))

local studioSettings = settings().Studio

local knownMicros = {}

local Panel = {}
Panel.__index = Panel
setmetatable(Panel, Isotope)

function Panel:Destroy()
	knownMicros = {}
	Microgen.unloadAll()
	Isotope.Destroy(self)
end

function title(self, txt, leftIcon, rightIcon)
	return Synthetic.TextLabel.new{
		LayoutOrder = 0,
		TextSize = 24,
		BackgroundTransparency = 1,
		LeftIcon = leftIcon,
		RightIcon = rightIcon,
		Text = txt,
		TextColor3 = self._Fuse.Computed(self.Theme, function(theme)
			return theme:GetColor(Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Default)
		end),
	}
end

function divider(self, layoutOrder)
	return self._Fuse.new "Frame" {
		Name = "Divider",
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = self._Fuse.Computed(self.Theme, function(theme)
			return theme:GetColor(Enum.StudioStyleGuideColor.DiffLineNum, Enum.StudioStyleGuideModifier.Default)
		end),
	}
end

function actions(self, layoutOrder)
	local actionFrame = self._Fuse.new "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		[self._Fuse.Children] = {
			self._Fuse.new "UIListLayout" {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			},
			Synthetic.TextLabel.new {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				TextSize = 24,
				LeftIcon = "settings",
				Text = "**Actions**"
			},
			divider(self, 2),
		}
	}
	return actionFrame
end

function microList(self, layoutOrder)
	local microList = self._Fuse.new "ScrollingFrame" {
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		ScrollBarThickness = 14,
		ScrollBarImageColor3 = self._Fuse.Computed(self.Theme, function(theme)
			return theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default)
		end),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1,1),
		CanvasSize = UDim2.new(1,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = true,
		BackgroundColor3 = self._Fuse.Computed(self.Theme, function(theme)
			return theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default)
		end),
		[self._Fuse.Children] = {
			self._Fuse.new "UIListLayout" {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			},
			Synthetic.TextLabel.new {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				TextSize = 24,
				LeftIcon = "list",
				Text = "**Micros**"
			},
			
			divider(self, 2),
		}
	}
	local canvas = self._Fuse.new "Frame" {
		Name = "Canvas",
		Parent = microList,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Size = UDim2.new(1,-14,0,0),
		Visible = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		[ColdFusion.Children] = {
			self._Fuse.new "UIListLayout" {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			},
		}
	}
	local function connectMicro(inst)
		if knownMicros[inst] then return end
		knownMicros[inst] = true
		local maid = Maid.new()
		self._Maid:GiveTask(maid)
		local FullName = self._Fuse.Value(inst.Name)
		local FinalText = self._Fuse.Computed(FullName, function(fullName)
			return "<b>"..string.gsub(fullName, "%.micro", "").."</b>"
		end)
		local button = self._Fuse.new "TextButton" {
			Parent = canvas,
			LayoutOrder = 3,
			TextSize = 14,
			AutoButtonColor = true,
			RichText = true,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = self._Fuse.Computed(self.Theme, self.CurrentMicroModule, function(theme, microMod)
				if inst == microMod then
					return theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
				else
					return theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default)
				end
			end):Tween(),
			TextColor3 = self._Fuse.Computed(self.Theme, self.CurrentMicroModule, function(theme, microMod)
				if inst == microMod then
					return theme:GetColor(Enum.StudioStyleGuideColor.ButtonText, Enum.StudioStyleGuideModifier.Selected)
				else
					return theme:GetColor(Enum.StudioStyleGuideColor.ButtonText, Enum.StudioStyleGuideModifier.Default)
				end
			end):Tween(),
			Text = FinalText,
			[self._Fuse.Event "Activated"] = function()
				if self.CurrentMicroModule:Get() == inst then
					self.CurrentMicroModule:Set(nil)
				else
					self.CurrentMicroModule:Set(inst)
				end
			end,
			[ColdFusion.Children] = {
				self._Fuse.new "UIPadding"{
					PaddingBottom = UDim.new(0,3),
					PaddingTop = UDim.new(0,3),
					PaddingLeft = UDim.new(0,5),
					PaddingRight = UDim.new(0,5),
				},
				self._Fuse.new "UICorner" {
					CornerRadius = UDim.new(0,3),
				}
			}
		}
		maid:GiveTask(button)

		maid:GiveTask(inst.Destroying:Connect(function()
			maid:Destroy()
		end))
		maid:GiveTask(inst:GetPropertyChangedSignal("Name"):Connect(function()
			FullName:Set(inst:GetFullName())
		end))
		maid:GiveTask(inst.AncestryChanged:Connect(function()
			FullName:Set(inst:GetFullName())
		end))
	end
	for i, inst in ipairs(game:GetDescendants()) do
		if inst:IsA("ModuleScript") and string.find(inst.Name, "%.micro") then
			connectMicro(inst)
		end
	end
	game.DescendantAdded:Connect(function(inst)
		pcall(function()
			if inst:IsA("ModuleScript")
			and string.find(inst.Name, "%.micro") then
				connectMicro(inst)
			end
		end)
	end)
	return microList
end

function Panel.new(config)
	local self = Isotope.new()
	setmetatable(self, Panel)

	local Parent = self:Import(config.Parent, nil)
	self.Selections = config.Selections or self._Fuse.Value(game.Selection:Get())
	self.CurrentMicroModule = self._Fuse.Value(nil)
	self._Maid:GiveTask(game.Selection.SelectionChanged:Connect(function()
		self.Selections:Set(game.Selection:Get())
	end))

	self.Theme = self._Fuse.Value(studioSettings.Theme)
	self._Maid:GiveTask(studioSettings.ThemeChanged:Connect(function()
		self.Theme:Set(studioSettings.Theme)
	end))
	
	self._Fuse.Computed(self.Selections, self.CurrentMicroModule, function(selections, modInst)
		if not modInst then Microgen.unloadAll() return end
		local modName = string.gsub(modInst.Name, "%.micro", "")
		Microgen.unloadType(modName)
		if not selections then return end
		local matching = {}

		for i, selectedInst in ipairs(selections) do
			local val = Microgen.get(selectedInst)
			if val == modName or val == nil then
				Microgen.set(selectedInst, modName)
				table.insert(matching, selectedInst)
			end
		end
		-- print("Loading", matching)
		for i, match in ipairs(matching) do
			if match:IsA("BasePart") then
				Microgen.load(match, modInst)
			end
		end
	end)

	self._Fuse.new "Frame" {
		Parent = Parent,
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = self._Fuse.Computed(self.Theme, function(theme)
			return theme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground, Enum.StudioStyleGuideModifier.Default)
		end),
		[ColdFusion.Children] = {
			self._Fuse.new "UIListLayout" {
				Padding = UDim.new(0, 5),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			self._Fuse.new "UIPadding"{
				PaddingBottom = UDim.new(0,5),
				PaddingTop = UDim.new(0,5),
				PaddingLeft = UDim.new(0,5),
				PaddingRight = UDim.new(0,5),
			},
			actions(self, 6),
			microList(self, 5),
		},
	}

	return self
end

return Panel
