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
			elseif data.class == "Script" or data.class == "LocalScript" or data.class == "ModuleScript" then
				-- Create a new .lua file, and append the classname!
			elseif data.class then
				-- save raw xml
			end  
		end
	end 
end 





if MODE == 'unpack' then 
	print("Unpacking a xml file")
	local data = xml.load(SOURCE)
	lfs.mkdir(TARGET)
	lfs.chdir(TARGET)
	parsexml(data)	

elseif MODE == 'pack' then 

else
	error("Mode " .. MODE .. " is unsupported. unpack and pack are supported")
end 