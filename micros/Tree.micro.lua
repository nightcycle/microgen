local InsertService = game:GetService("InsertService")

local micros = script.Parent
local packages = micros.Parent
local math = require(packages:WaitForChild("math"))
local draw = require(packages:WaitForChild("draw"))

local tetraMeshModelId = 9643398531
local tetraModel = InsertService:LoadAsset(tetraMeshModelId)
-- tetraModel.Name = "Tetramodel"
-- tetraModel.Parent = workspace
local tetraMeshPart = tetraModel:FindFirstChildOfClass("MeshPart")

return function(inst: Part)
	local config = inst:GetAttributes()

	-- textures
	config.TrunkMaterial = config.TrunkMaterial or "Wood"
	config.TrunkMaterialVariant = config.TrunkMaterialVariant or ""
	config.TrunkColor = config.TrunkColor or Color3.fromHSV(0.1,0.5,0.5)
	config.LeafTransparency = config.LeafTransparency or 0
	config.LeafColor = config.LeafColor or Color3.fromHSV(0.35, 0.9, 0.6)
	config.LeafMaterial = config.LeafMaterial or "Grass"
	config.LeafMaterialVariant = config.LeafMaterialVariant or ""

	-- appearance
	config.TrunkWidth = config.TrunkWidth or 2
	config.TrunkWidthReduction = config.TrunkWidthReduction or 0.5
	config.TrunkSplits = config.TrunkSplits or 3
	config.TrunkSplitHeightFloor = config.TrunkSplitHeightFloor or 0.2

	config.LeafSize = config.LeafSize or Vector3.new(0.5,8,8)
	config.LeafRange = config.LeafRange or 0.25
	config.LeafVisible = if config.LeafVisible ~= nil then config.LeafVisible else true

	config.RoundedTrunk = if config.RoundedTrunk ~= nil then config.RoundedTrunk else false
	config.Seed = config.Seed or tonumber(config.MicromanagerId or "") or 0

	-- set up
	local rand = Random.new(config.Seed)
	for k, v in pairs(config) do inst:SetAttribute(k, v) end
	local model = Instance.new("Model")
	model.Name = "Tree"

	-- Creating
	local baseCF = inst.CFrame * CFrame.new(0,-inst.Size.Y/2,0)
	local splitAdj = config.TrunkSplitHeightFloor * inst.Size.Y

	local function leaves(branchPart)
		local function leaf()
			local part = Instance.new("Part", model)
			part.Name = "Leaf"
			part.Color = config.LeafColor
			part.Size = branchPart.Size * config.LeafSize * (Vector3.new(1,1,1) + Vector3.new(rand:NextNumber(), rand:NextNumber(), rand:NextNumber())*config.LeafRange)
			part.CFrame = branchPart.CFrame * CFrame.Angles(math.rad(360) * rand:NextNumber(), math.rad(20) * rand:NextNumber(), 0) * CFrame.new(0.25*branchPart.Size.X, 0, 0)
			part.Transparency = config.LeafTransparency
			part.Material = Enum.Material[config.LeafMaterial]
			part.MaterialVariant = config.LeafMaterialVariant
			part.Parent = branchPart
		end
		if config.LeafVisible then
			for i=1, rand:NextInteger(2, 3) do
				leaf()
			end
		end
	end

	local function branch(origin: Vector3, direction: Vector3, width: number)
		local trunk = Instance.new("Part", model)
		trunk.Name = "Trunk"
		trunk.Material = Enum.Material[config.TrunkMaterial]
		trunk.MaterialVariant = config.TrunkMaterialVariant
		trunk.Color = config.TrunkColor
		trunk.Anchored = true
		trunk.Shape = if config.RoundedTrunk then Enum.PartType.Cylinder else Enum.PartType.Block
		trunk.Size = Vector3.new(direction.Magnitude, width, width)
		
		local lV = direction.Unit
		local rV = lV:Cross(Vector3.new(0,1,0))
		rV = if rV == Vector3.new(0,0,0) then Vector3.new(1,0,0) else rV
		local uV = rV:Cross(lV)

		trunk.CFrame = CFrame.fromMatrix(origin + direction * 0.5, rV, uV) * CFrame.Angles(0,math.rad(90), 0)
		return trunk
	end
	local function splitTrunk(origin, trunkDirection, index)
		local splitsRemaining = config.TrunkSplits - index
		local alpha = (index/config.TrunkSplits)
		local width = config.TrunkWidth - config.TrunkWidth * alpha * config.TrunkWidthReduction

		-- print("Ori", origin, "TrunKDir", trunkDirection, "Width", width, "Angle", angle)

		local rotCF = CFrame.fromAxisAngle(trunkDirection.Unit, rand:NextNumber() * math.rad(360))
		local rotVector = rotCF.LookVector
		local instSize = inst.Size
		local offsetV2 = Vector2.new(instSize.X * 0.5 * rotVector.X, instSize.Z * 0.5 * rotVector.Z)
		local angle = (math.rad(90) - math.atan2(splitAdj, offsetV2.Magnitude))*0.5
		-- print("Rot", math.round(math.deg(angle)), "Angle", math.round(math.deg(angle)))
		local len = trunkDirection.Magnitude
		local opp = math.tan(angle) * len
		local newPoint = origin + trunkDirection + rotVector * opp
		local newDirection = (newPoint - origin).Unit * trunkDirection.Magnitude
		newPoint = origin + newDirection
		if splitsRemaining >= 0 then
			local br2 = branch(origin, trunkDirection, width)
			if splitsRemaining == 0 then
				leaves(br2)
			end
			splitTrunk(origin + trunkDirection, trunkDirection, index+1)
			local br1 = branch(origin, newDirection, width)
			if splitsRemaining == 0 then
				leaves(br1)
			end
			splitTrunk(newPoint, newDirection, index+1)
		end
	end
	local firstOffset = inst.CFrame.UpVector * inst.Size.Y * config.TrunkSplitHeightFloor
	branch(baseCF.p, firstOffset, config.TrunkWidth)
	local segmentLength = inst.Size.Y * (1-config.TrunkSplitHeightFloor)/config.TrunkSplits

	splitTrunk(baseCF.p + firstOffset, inst.CFrame.UpVector*segmentLength, 1)

	local partCount = 0
	for i, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			partCount += 1
		end
	end
	-- print("PartCount", partCount)
	model.Parent = inst.Parent
	return model
end