require("adebugutils")
term.clear()
term.setCursorPos(1,1)
local recipes = {}
local drawer = peripheral.find("functionalstorage:storage_controller")
if drawer == nil then 
	error("No \"functionalstorage:storage_controller\" found in network.") 
end
local targets = {
	["packer"] = peripheral.find("gtceu:mv_packer"),
	["centrifuge"] = peripheral.find("gtceu:mv_centrifuge"),
	["electrolyzer"] = peripheral.find("gtceu:mv_electrolyzer")
}
local status = {
	["last_jobs"] = {}
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
function IsValidTarget(Target)
	if 
		Target == nil
		or type(Target) ~= "table"
		or getmetatable(Target).__name ~= "peripheral" 
		or getmetatable(Target).types == nil 
		or not getmetatable(Target).types.inventory 
	then 
		return false 
	end
	for k,v in pairs(Target.list()) do
		if v.name ~= "gtceu:programmed_circuit" then
			return false
		end
	end
	return true
end
function MoveItemsToTarget(Target,Ingredients,Multiplier)
	--has to return true on successful transfer
	--{slot = item_slot, count = item_short.count}

	if Target == nil then return false end
	if #Ingredients == 0 then return false end

	for k,v in pairs(Ingredients) do
		drawer.pushItems(peripheral.getName(Target),v.slot,v.count*Multiplier)
	end
	return true
end
function DisplayStatus()
	term.clear()
	term.setCursorPos(1,1)
	PrintTable(status)
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

-- RECIPES DECLARATION
AddRecipe("packer", "tiny dusts compression", {{key = "forge:tiny_dusts", count = 9}})
AddRecipe("packer", "small dusts compression", {{key = "forge:tiny_dusts", count = 9}})

AddRecipe("centrifuge", "Rare Earth Dust processing", {{key = "gtceu:rare_earth_dust", count = 1}})
AddRecipe("centrifuge", "Tricalcium Phosphate Dust processing", {{key = "gtceu:tricalcium_phosphate_dust", count = 5}})

AddRecipe("electrolyzer", "Phosphate Dust processing", {{key = "forge:dusts/phosphate", count = 5}})
AddRecipe("electrolyzer", "Apatite Dust processing", {{key = "gtceu:apatite_dust", count = 5}})
AddRecipe("electrolyzer", "Rock Salt Dust processing", {{key = "gtceu:rock_salt_dust", count = 2}})
--AddRecipe("foo", "bar", {{key = "minecraft:stone", count = 1}})

sleep(1)

while true do

	-- iterating target recipe groups
	for target_alias, target_recipes in pairs(recipes) do
		local target = targets[target_alias]
		if IsValidTarget(target) then 
		-- iterating recipes
			for recipe_n, recipe in pairs(target_recipes) do
				local ingredient_slots = {}
				local has_all_ingredients = true
				local multiplier = 64
				
				--iterating ingredients
				for ingredient_n,ingredient in pairs(recipe.ingredients) do
					local ingredient_slot_info = nil
					
					-- iterating drawer slots
					for item_slot, item_short in pairs(drawer.list()) do
						if item_short.count > ingredient.count then 
							if item_short.name == ingredient.key  then
								ingredient_slot_info = {slot = item_slot, count = item_short.count}
								break
							else
								local item_long = drawer.getItemDetail(item_slot)
								if item_long.tags[ingredient.key] ~= nil then
									ingredient_slot_info = {slot = item_slot, count = item_short.count}
									break
								end
							end
						end
					end
					if ingredient_slot_info == nil then 
						has_all_ingredients = false 
						break 
					end
					--Descriptive `multiplier` calculations:
					--local clamped_count = math.min(ingredient_slot_info.count,64)
					--local ingredient_max_multiplier = math.floor(clamped_count/ingredient.count)
					--multiplier = math.min(ingredient_max_multiplier,multiplier)
					--Short `multiplier` calculations:
					multiplier = math.min(multiplier,math.floor(math.min(ingredient_slot_info.count,64)/ingredient.count))
					table.insert(ingredient_slots,ingredient_slot_info)
				end
				if has_all_ingredients then
					local result = MoveItemsToTarget(target,ingredient_slots,multiplier)
					if result then
						status.last_jobs[target_alias] = recipe.name
					end
					break
				end
			end
		end
	end	
	DisplayStatus()
	sleep(1)
end
