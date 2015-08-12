require 'luaXml'
lfs = require 'lfs'

local args = {...}

local MODE = args[1] 
local SOURCE = args[2]
local TARGET = args[3]

local function parsexml(input)
	for index, data in pairs(input) do
		if data.class then 
			if data.class == "Folder" then 
				-- Create a new directory
				local Properties = xml.find(data, 'Properties')
				if Properties then 
					local Name = xml.find(Properties, "string", "name", "Name")
					if Name then 
						-- Create dir;
						local Name = Name[1]
						print("Adding a folder: " .. Name)
						lfs.mkdir(Name)
						lfs.chdir(Name)
						parsexml(data)
						lfs.chdir('..')
					end
				end 
			elseif data.class == "Script" or data.class == "LocalScript" or data.class == "ModuleScript" then
				-- Create a new .lua file, and append the classname!
				local Properties = xml.find(data, 'Properties')
				if Properties then 
					local Name = xml.find(Properties, 'string', 'name', 'Name')[1]
					print("Adding a " .. data.class .. ": " .. Name)
					local Source = xml.find(Properties, 'ProtectedString')[1]
					local file = io.open(Name..".lua", "w+")
					file:write(Source .. "\n--cname="..data.class)
					file:flush()
					file:close()
					lfs.mkdir(Name.."_")
					lfs.chdir(Name.."_")
					parsexml(data)
					lfs.chdir("..")
					-- More elgant is, besides checking for
					-- The empty directory, to return a value...
					local got_file = false;
					for file in lfs.dir(Name.."_") do
						if file ~= "." and file ~= ".." then 
							got_file = true 
							break 
						end 
					end 
					if not got_file then 
						lfs.rmdir(Name.."_")
					end 
					
				end 
			elseif data.class then
				local Properties = xml.find(data, 'Properties')
				if Properties then 
					local Name = xml.find(Properties, 'string', 'name', 'Name')
					if Name then 
						print("Adding raw class: " .. data.class .. ": " .. Name[1])
						local file = io.open(Name[1]..'.xml', 'w+')
						file:write(tostring(data))
						file:flush()
						file:close()
					end 
				end 
			end  
		end
	end 
end 

local function createfolder(name, root)
	local new = root:append("Item")
	new.class = "Folder"
	local properties = new:append("Properties")
	local n = properties:append("string")
	n.name = "Name"
	n[1] = name 
	return new 
end 

local function createscript(name, location, data)
	local cname = data:match("%-%-cname=(%w+)$") or "Script"
	local new = location:append("Item")
	new.class = cname 
	local properties = new:append("Properties")
	local disabled = properties:append("bool")
	disabled.name = "Disabled"
	disabled[1] = "false"
	local Content = properties:append("Content")
	Content.name = "LinkedSource"
	Content:append("null")[1] = ""
	local namep  = properties:append("string")
	namep.name = "Name"
	namep[1] = name:gsub(".lua", "")
	local ps = properties:append("ProtectedString")
	ps.name = "Source"
	ps[1] = data 
	return new 
end 



local function parsedir(path, data_carrier)
	-- filenames to be processed later;
	local fstack = {} 
	-- pointers: 
	local fpointers = {} 

	local function parse(rpath, filename)
		local attributes,err = lfs.attributes(rpath)
	
		if attributes.mode == "directory" then 
			-- Make a folder
			if filename:match("_$") then 
				-- This must be put inside a script, skip
				if fpointers[filename:sub(1,filename:len()-1)..".lua"] then 
					local location = fpointers[filename:sub(1,filename:len()-1)..".lua"]
					parsedir(rpath, location)
				else 
					-- process later on
					fstack[filename] = true
				end  
			else 
				local location = createfolder(filename, data_carrier)
				parsedir(rpath, location)
			end 
		elseif attributes.mode == 'file' then 
			if rpath:match('%.lua$') then 
				local script = io.open(rpath)
				local data = script:read("*a")
				createscript(filename, data_carrier, data)
			elseif rpath:match('%.xml$') then
				local data = xml.load(rpath)
				table.insert(data_carrier, data)
			end
		end

	end 


	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then 
			local rpath = path .. "/"..file 
			parse(rpath, file)
		end 
	end 

	for file in pairs(fstack) do 
		parse(path.."/"..file, file)
	end 
end



if MODE == 'unpack' then 
	print("Unpacking a xml file")
	local data = xml.load(SOURCE)
	lfs.mkdir(TARGET)
	lfs.chdir(TARGET)
	parsexml(data)	

elseif MODE == 'pack' then 
	local new = xml.new("roblox");
	new["xmlns:xmime"]="http://www.w3.org/2005/05/xmlmime"
    new["version"]="4"
    new["xsi:noNameSpaceSchemaLocation"]="http://www.roblox.com/roblox.xsd"
    new["xmlns:xsi"]="http://www.w3.org/2001/XMLSchema-instance"
    parsedir(SOURCE, new)
    local file = io.open(TARGET, "w+")
    file:write(tostring(new))
    file:flush()
    file:close()
else
	error("Mode " .. MODE .. " is unsupported. unpack and pack are supported")
end 