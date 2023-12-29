function PrintL(text,level)
	if type(text) ~= "string" then text = tostring(text) end
	if level == nil or level <= 0 then level = 1 end
	local level_spacer = ""
	if level > 1 then
		for i=1,level-1 do level_spacer = level_spacer .. "  " end
	end
	print(level_spacer .. text)
end
function PrintTable(t,level)
	if type(t) ~= "table" then return end
	if level == nil or level <= 0 then level = 1 end
	PrintL("{",level)
	for k,v in pairs(t) do
		local key = "["..tostring(k).."]"
		local value = tostring(v)
		if type(k) == "string" then key = "[\""..k.."\"]" end
		if type(v) == "string" then value = "\""..v.."\"" end
		PrintL(key.." = ".. value,level+1)
		if type(v) == "table" then
			PrintTable(v,level+1)
		end
	end
	PrintL("}",level)
end

--t = {2,3,4,"test" = {1337,23,63,{353,323,"text data","another text data",{1337, a = {"some","table","data",1,2,3}, b = 42}}}}
--PrintTable(t)