local packages = script.Parent.Parent

return function(microgen, inst: Part)



	local config = inst:GetAttributes()
	config.TrunkWidth = config.TrunkWidth or 2
	config.TrunkMaterial = config.TrunkMaterial or "Wood"
	config.TrunkMaterialVariant = config.TrunkMaterialVariant or nil
	config.TrunkColor = config.TrunkColor or Color3.fromHSV(0.1,0.5,0.5)
	config.LeafColor = config.LeafColor or Color3.fromHSV(0.35, 0.9, 0.6)
	config.LeafMaterial = config.LeafMaterial or "Grass"
	config.LeafVariant = config.LeafVariant or nil
	config.LeafCount = config.LeafCount or 3
	config.LeafFloor = config.LeafFloor or 0.4
	config.TreeAngle = config.TreeAngle or 30
	config.Segments = config.Segments or 6
	config.Gravity = config.Gravity or 1
	config.SplitChance = config.SplitChance or 0.25
	config.Seed = config.Seed or tonumber(config.MicromanagerId or "") or 0
	local rand = Random.new(config.Seed)

	for k, v in pairs(config) do inst:SetAttribute(k, v) end

	local model = Instance.new("Model")
	model.Name = "Tree"

	local treeHeight = inst.Size.Y
	local treeWidth = math.min(inst.Size.X, inst.Size.Z)
	local trunkHeight = treeHeight--math.clamp(treeHeight - treeWidth*0.5, 0.5, treeHeight)
	local leafDiameter = treeHeight - treeHeight*config.LeafFloor

	local rootCF = inst.CFrame * CFrame.new(0,-inst.Size.Y/2,0)

	local function newTrunk(startCF, index: number)
		local position = startCF.p
		local trunkLength = trunkHeight / config.Segments

		-- local lV = -startCF.LookVector

		local widthWeight = 1-((index-1)/config.Segments)
		local xAngle = math.rad(config.TreeAngle * rand:NextNumber() - config.TreeAngle*0.5)*2
		local yAngle = math.rad(config.TreeAngle * rand:NextNumber() - config.TreeAngle*0.5)*2
		local cf = startCF * CFrame.Angles(xAngle,yAngle,0)
		local gravityLV = -((position + startCF.LookVector - Vector3.new(0,config.Gravity*(1-widthWeight),0)) - position).Unit
		local rV = gravityLV:Cross(inst.CFrame.LookVector)
		local uV = gravityLV:Cross(rV)
		cf = CFrame.fromMatrix(position, rV, uV) * CFrame.Angles(xAngle, yAngle, 0)

		local finalTarget = position - cf.LookVector * trunkLength

		local trunk = Instance.new("Part", model)
		trunk.Anchored = true
		trunk.Name = "Trunk"
		trunk.Shape = "Cylinder"
		trunk.Color = config.TrunkColor
		trunk.Material = Enum.Material[config.TrunkMaterial]
		trunk.Size = Vector3.new(trunkLength, config.TrunkWidth*widthWeight, config.TrunkWidth*widthWeight)
		trunk.CFrame = CFrame.new(position, finalTarget) * CFrame.Angles(0,math.rad(90),0) * CFrame.new(trunkLength/2,0,0)
		trunk.Parent = model

		local trunkJoint = Instance.new("Part", model)
		trunkJoint.Name = "TrunkJoint"
		trunkJoint.Shape = "Ball"
		trunkJoint.Color = config.TrunkColor
		trunkJoint.Material = Enum.Material[config.TrunkMaterial]
		trunkJoint.Size = Vector3.new(1,1,1) * config.TrunkWidth*widthWeight
		trunkJoint.CFrame = CFrame.new(finalTarget)
		trunkJoint.Parent = model
		
		if config.Segments > index then
			newTrunk(CFrame.fromMatrix(finalTarget, rV, uV), index + 1)
			if config.SplitChance > rand:NextNumber() then
				newTrunk(CFrame.fromMatrix(finalTarget, rV, uV), index + 1)
			end
		end

	end

	local trunkJoint = Instance.new("Part", model)
	trunkJoint.Name = "StartJoint"
	trunkJoint.Shape = "Ball"
	trunkJoint.Color = config.TrunkColor
	trunkJoint.Material = Enum.Material[config.TrunkMaterial]
	trunkJoint.Size = Vector3.new(1,1,1) * config.TrunkWidth
	trunkJoint.CFrame = rootCF
	trunkJoint.Parent = model

	newTrunk(rootCF*CFrame.Angles(math.rad(-90),0,0), 1)

	local centerCF = inst.CFrame * CFrame.new(0,inst.Size.Y/2, 0) * CFrame.new(0,-leafDiameter/2,0)
	for i=1, config.LeafCount do
		local x = rand:NextNumber() * leafDiameter * 0.5 * if rand:NextNumber() < 0.5 then 1 else -1
		local y = rand:NextNumber() * leafDiameter * 0.5 * if rand:NextNumber() < 0.5 then 1 else -1
		local z = rand:NextNumber() * leafDiameter * 0.5 * if rand:NextNumber() < 0.5 then 1 else -1
		local size = Vector3.new(leafDiameter - math.abs(x), leafDiameter - math.abs(y), leafDiameter - math.abs(z))
		local leafPart =  Instance.new("Part", model)
		leafPart.Name = "Leaf"
		leafPart.Color = config.LeafColor
		leafPart.Material = config.LeafMaterial
		leafPart.CFrame = centerCF *  CFrame.new(x*0.5,y*0.5,z*0.5)
		leafPart.Shape = Enum.PartType.Ball
		leafPart.Size = size
	end
	
	model.Parent = inst.Parent
	
	return model
end