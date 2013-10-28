-- DirToRBX --

-- This program uses normal windows (!!) commands to get a list of files and directories (If mac has a kind of "dir" program change the commands in GetDirectoriesInDir and GetFilesInDir)
-- This is done by running the program "dir"
-- dir "a" /b return a list of all files and directories in "a"
-- dir "a" /b /ad returns a list of all DIRECTORIES in "a" (this filter is done by the /ad)
-- dir "a" /b /a-d  reutrns a list of all FILES in "a" (the - means "not" so filter all "not directories" out - the files!)

print("Dir>RBXM started up. You can find a DefaultDir variable in the file: change that to your default project directory to make it easier to run this .lua script")
print("You can also use 4 optional options")
print("lua dirmirror.lua input_directory output_directory output_name classname")
print("The input_directory is the directory where your project is. Example: C:\MyRobloxProject. This can be changed in this file by changing the DefaultDir variable")
print("The output_directory is by default the input_directory. You can also define this output directory: it's the place where the .rbxm file is created.")
print("The output_name marks the name of the output and also the name of the model which is created (the root model).")
print("The classname option can be used to change the classname of the generated objects. By default, this is Script. It can also generate localscripts.")
print("Example use from command bar;")
print("lua dirmirror.lua C:/MyProject C:/Documents/Roblox/Project MyProject LocalScript")

local DefaultDir = "./Test" -- Change this to project file (. is the directory the .lua file is in!!)

local input = {...}

local dir = input[1] or DefaultDir
local output = input[2] or DefaultDir
local output_name = input[3] or "ProjectRBXM"
local classname = input[4] or "Script"

print(input[1], input[2])

local cmd_run = io.popen

local xml_sub = {{"&", "&amp;"}, {">", "&gt;"}, {"<", "&lt;"}, {"\'", "&apos;"}, {"\"", "&quot;"}}  -- QQ why
-- Note: this table here is constructed not as [which_sub] = sub_to, because the & has to be subbed first (to make sure that
-- it doesn't conflict with the & in the other subs!). Like this we can control the sequence.

local model = io.open(output:gsub("/", function() if not got then got = true return "\\" else return "/" end end).. "/"..output_name..".rbxm", "w+")


function GetLines(file) -- Lol dir returns a file... not a string :/
	local list = {}
	for match in file:lines() do
		table.insert(list, match)
	end
	return list
end

s = "\""
function GetDirectoriesInDir(dir) -- returns all directories in dir
local got = false
dirfix = dir:gsub("/", "\\")
print("CMD RUN: ".."dir ".. "\""..dirfix.. "\"".." /b /ad")
	return GetLines(cmd_run("dir ".. "\""..dirfix.. "\"".." /b /ad"))
end

function GetFilesInDir(dir)
dirfix =  dir:gsub("/", "\\")
print("CMD RUN: ".."dir ".. "\""..dirfix.. "\"".." \\b \\a-d")
	return GetLines(cmd_run("dir ".. "\""..dirfix.. "\"".." /b /a-d"))
end

-- Write default header to the model file

function GetModelXML(name)
return [[
<Item class="Model">
		<Properties>
			<CoordinateFrame name="ModelInPrimary">
				<X>0</X>
				<Y>0</Y>
				<Z>0</Z>
				<R00>1</R00>
				<R01>0</R01>
				<R02>0</R02>
				<R10>0</R10>
				<R11>1</R11>
				<R12>0</R12>
				<R20>0</R20>
				<R21>0</R21>
				<R22>1</R22>
			</CoordinateFrame>]] .. "\n<string name=\"Name\">"..name .. "</string>\n"..[[
			<Ref name="PrimaryPart">null</Ref>
		</Properties>
		]]
end

function GetScriptXML(name, source)
local source = source
for i,v in pairs(xml_sub) do -- sub i with v
source = source:gsub(v[1],v[2])
end
return [[<Item class="]]..classname..[[">
			<Properties>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>]].."\n<string name=\"Name\">"..name.."</string>\n"..[[<ProtectedString name="Source">]] ..source..[[
</ProtectedString>
			</Properties>
		</Item>]]
end

model:write([[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
	]])


-- Actual nonsense starts here --

function Recurse(where, dirname)
	print("Searching "..where.. " for directories and .lua files!")
	print("Adding DIR "..dirname .. " to XML")
	model:write(GetModelXML(dirname))
	print("Added succesfully to the xml file")
	local dir_list = GetDirectoriesInDir(where)
		for i,v in pairs(dir_list) do
			Recurse(where.."/"..v, v)
		end
	local file_list = GetFilesInDir(where)
	for i,v in pairs(file_list) do
		if not (v:sub(v:len()-3, v:len()) == ".lua") then -- remove all non lua files
			file_list[i] = nil
		end
	end
	for i,v in pairs(file_list) do
		print("Lua file found: "..where.."/"..v)
		local file = io.open(where.."/"..v, "r")
		local source = file:read("*a")
		local name = v:match("(.*)%.")
		model:write(GetScriptXML(name, source))
		print("Added succesfully to the xml file")
	end
	model:write("\n</Item>")
end

Recurse(DefaultDir, output_name)
model:write("\n</roblox>")
print("Creation complete! You can find the file in: "..output)
io.read()
