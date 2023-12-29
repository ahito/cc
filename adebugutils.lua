function printL(text,level)
	if type(text) ~= "string" then text = tostring(text) end
	if level == nil or level <= 0 then level = 1 end
	local level_spacer = ""
	for i=1,level do level_spacer = level_spacer .. "  " end
	print(level_spacer .. text)
end
function PrintTable(t,level)
	if type(t) ~= "table" then return end
	if level == nil or level <= 0 then level = 1 end
	printL("{",level-1)
	for k,v in pairs(t) do
		printL(k.." = ".. tostring(v),level)
		if type(v) == "table" then
			PrintTable(v,level)
		end
	end
	printL("}",level-1)
end