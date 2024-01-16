require("adebugutils")
term.clear()
term.setCursorPos(1,1)
local recipes = {}
local me = peripheral.find("meBridge")
if me == nil then 
	error("No \"meBridge\" found in network.") 
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
	--	drawer.pushItems(peripheral.getName(Target),v.slot,v.count*Multiplier)
		me.exportItemToPeripheral({fingerpring = v.slot, amount = v.count*Multiplier}, peripheral.getName(Target))
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
				print(k.." - "..peripheral.getType(peripheral.getName(v)).." isEmpty: ".. tostring(IsValidTarget(v)))
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
AddRecipe("packer", "small dusts compression", {{key = "forge:small_dusts", count = 4}})

AddRecipe("centrifuge", "Rare Earth Dust processing", {{key = "gtceu:rare_earth_dust", count = 1}})
AddRecipe("centrifuge", "Metal Mixture Dust processing", {{key = "gtceu:metal_mixture_dust", count = 1}})
AddRecipe("centrifuge", "Tricalcium Phosphate Dust processing", {{key = "gtceu:tricalcium_phosphate_dust", count = 5}})
AddRecipe("centrifuge", "Vanadium Magnetite Dust processing", {{key = "gtceu:vanadium_magnetite_dust", count = 2}})
AddRecipe("centrifuge", "Pitchblende Dust processing", {{key = "gtceu:pitchblende_dust", count = 5}})
AddRecipe("centrifuge", "Stone Dust processing", {{key = "gtceu:stone_dust", count = 1}})

AddRecipe("electrolyzer", "Phosphate Dust processing", {{key = "forge:dusts/phosphate", count = 5}})
AddRecipe("electrolyzer", "Apatite Dust processing", {{key = "gtceu:apatite_dust", count = 9}})
AddRecipe("electrolyzer", "Rock Salt Dust processing", {{key = "gtceu:rock_salt_dust", count = 2}})
AddRecipe("electrolyzer", "Bastnasine Dust processing", {{key = "gtceu:bastnasite_dust", count = 6}})
AddRecipe("electrolyzer", "Pyrolusite Dust processing", {{key = "gtceu:pyrolusite_dust", count = 3}})
AddRecipe("electrolyzer", "Tantalite Dust processing", {{key = "gtceu:tantalite_dust", count = 9}})
AddRecipe("electrolyzer", "Bauxite Dust processing", {{key = "gtceu:bauxite_dust", count = 15}})
AddRecipe("electrolyzer", "Grossular Dust processing", {{key = "gtceu:grossular_dust", count = 20}})
AddRecipe("electrolyzer", "Potassium Feldspar Dust processing", {{key = "gtceu:potassium_feldspar_dust", count = 11}})
AddRecipe("electrolyzer", "Barite Dust processing", {{key = "gtceu:barite_dust", count = 6}})
AddRecipe("electrolyzer", "Magnesia Dust processing", {{key = "gtceu:magnesia_dust", count = 2}})


sleep(1)
local timer = 0
local me_items = nil
--local lookup_table = nil
while true do
	timer = os.epoch([[utc]])
	--drawer_content = drawer.list()
	me_items = me.listItems()
	status.iterations = 0
	-- iterating target recipe groups
	for target_alias, target_recipes in pairs(recipes) do
		local target = targets[target_alias]
		local call_status, call_result = pcall(IsValidTarget,target)
		if call_status and call_result then 
			status.last_jobs[target_alias] = nil
			-- iterating recipes
			for recipe_n, recipe in pairs(target_recipes) do
				local ingredient_slots = {}
				local has_all_ingredients = true
				local multiplier = 64
				
				--iterating ingredients
				for ingredient_n,ingredient in pairs(recipe.ingredients) do
					local ingredient_slot_info = nil
					
					for item_i,item in pairs(me_items) do
						status.iterations = status.iterations + 1
						if item.amount >= ingredient.count then 
							if item.name == ingredient.key then
								ingredient_slot_info = {slot = item.fingerpring, count = item_short.count}
								break
							end
							for tag_i, tag in pairs(item.tags)		
								if string.sub(tag,16) == ingredient.key then
									ingredient_slot_info = {slot = item.fingerpring, count = item_short.count}
									break
								end
							end
						end
					end
					-- iterating drawer slots
					--for item_slot, item_short in pairs(drawer_content) do
					--	status.iterations = status.iterations + 1
					--	if item_short.count >= ingredient.count then 
					--		if item_short.name == ingredient.key  then
					--			ingredient_slot_info = {slot = item_slot, count = item_short.count}
					--			break
					--		end
					--		--if lookup_table[item_short.name] == nil then
					--		--	lookup_table[item_short.name] = {}
					--		--	lookup_table[item_short.name].tags = drawer.getItemDetail(item_slot).tags
					--		--end
					--		--if lookup_table[item_short.name].tags[ingredient.key] ~= nil then
					--		--	ingredient_slot_info = {slot = item_slot, count = item_short.count}
					--		--	break
					--		--end
					--	end
					--end
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
					ingredient_slot_info.count = ingredient.count
					table.insert(ingredient_slots,ingredient_slot_info)
				end
				if has_all_ingredients then
					local result = MoveItemsToTarget(target,ingredient_slots,multiplier)
					if result then
						status.last_jobs[target_alias] = {name = recipe.name, mul = multiplier}
					end
					break
				end
			end
		end
	end	
	status.cycle_time = (os.epoch([[utc]]) - timer)/1000
	DisplayStatus()
	sleep(0)
end
