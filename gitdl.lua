args = {...}
local gitraw_url = "https://raw.githubusercontent.com/ahito/cc/"
local filename = ""
local branch = "main"
if #args == 1 then
	filename = args[1]
elseif #args == 2 then
	branch = args[1]
	filename = args[2]
else
	print("Usage:")
	print("gitdl <filename>")
	print("gitdl <branch> <filename>")
	
	error()
end

local url = gitraw_url..branch.."/"..filename
print(url)
local request = http.get(url)
if request ~= nil and request.getResponseCode() == 200 then
	file = fs.open(filename,"w")
	file.write(request.readAll())
	file.close()
	print("File '"..filename.."' loaded.\n")
else
	print("Failed")
end