local recipes = {}
local targets = {
	["drawer"] = peripheral.find("functionalstorage:storage_controller"),
	["packer"] = peripheral.find("gtceu:mv_packer"),
	["centrifuge"] = peripheral.find("gtceu:mv_centrifuge"),
	["electrolyzer"] = peripheral.find("gtceu:mv_electrolyzer")
}
function AddRecipe(InTarget,InName,InRecipeDescriptor)
	if targets[InTarget] == nil then
		print("Recipe \"" .. InName .. "\" for \"" .. InTarget .. "\" was not added due to invalid Target provided")
		return
	end
	local Recipe = {name=InName, ingredients = {}}
	for i=1, #InRecipeDescriptor do
		table.insert(Recipe.ingredients,InRecipeDescriptor[i])
	end
	if #Recipe.ingredients > 0 then
		if recipes[InTarget] == nil then recipes[InTarget] = {} end
		table.insert(recipes[InTarget],Recipe)
	end
	print("Added recipe \"" .. InName .. "\" for \"" .. InTarget .. "\"")
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
	local invalid = true
	if v ~= nil then
		if getmetatable(v).__name == "peripheral" then
			if getmetatable(v).types.inventory then
				print(k.." - "..peripheral.getType(peripheral.getName(v)).." isEmpty: ".. tostring(IsTargetEmpty(v)))
				invalid = false
			else
				print(k.." - doesnt have an inventory.")
			end
		else
			print(k.." - not a peripheral.")
		end
	else
		print(k.." - invalid peripheral.")
	end
	if invalid then
		targets[k] = nil
		print(k .. " - was removed from active peripheral list.")
	end
end

AddRecipe("packer", "Tiny dusts", {{key = "forge:tiny_dusts", count = 9}})
AddRecipe("packer", "Small dusts", {{key = "forge:tiny_dusts", count = 9}})
AddRecipe("centrifuge", "Rare Earth Dust", {{key = "gtceu:rare_earth_dust", count = 1}})
AddRecipe("electrolyzer", "Phosphate Dust", {{key = "gtceu:phosphate_dust", count = 5}})
AddRecipe("electrolyzer", "Apatite Dust", {{key = "gtceu:apatite_dust", count = 5}})
AddRecipe("foo", "bar", {{key = "minecraft:stone", count = 1}})


