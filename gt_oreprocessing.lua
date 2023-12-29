local recipes = {}
local targets = {
	["drawer"] = peripheral.find("functionalstorage:storage_controller"),
	["packer"] = peripheral.find("gtceu:mv_packer"),
	["centrifuge"] = peripheral.find("gtceu:mv_centrifuge"),
	["electrolyzer"] = peripheral.find("gtceu:mv_electrolyzer")
}
function AddRecipe(InTarget,InRecipeDescriptor,InStrict)
	InStrict = InStrict or false
	local Recipe = {ingredients = {},strict = InStrict}
	for i=1, #InRecipeDescriptor do
		table.insert(Recipe.ingredients,InRecipeDescriptor[i])
	end
	if #Recipe.ingredients > 0 then
		if recipes[InTarget] == nil then recipes[InTarget] = {} end
		table.insert(recipes[InTarget],Recipe)
	end
end
function IsTargetEmpty(Target)
	if Target == nil or Target.list == nil then return false end
	for k,v in pairs(Target.list()) do
		if v.name ~= "gtceu:programmed_circuit" then
			return false
		end
	end
	return true
end
print("Targets validation:")
for k,v in pairs(targets) do
	if v ~= nil then
		if getmetatable(v).__name == "peripheral" then
			if getmetatable(v).types.inventory then
				print(k.." - "..peripheral.getType(peripheral.getName(v)).." isEmpty: ".. tostring(IsTargetEmpty(v)))
			else
				print(k.." - doesnt have an inventory")
			end
		else
			print(k.." - not a peripheral")
		end
	else
		print(k.." - invalid peripheral")
	end
end