DirToRBXM
=========

DirToRBXM is an utility to unpack roblox model files (XML files) to a directory. The directory can also be packed again.

The functionality is as following:

The Folder ClassName will be exported as a directory. Any Scripts, LocalScripts or ModuleScripts will be exported as .lua files.
(Note that a Model classname is inappropriate here, as it has a PrimaryPart field. Folders must be used!)

Any other ClassName will be exported as a text file. Any scripts in those are not saved.

Any .lua files will get an extra last line: --cname where cname is the classname of the .lua file.
If this --cname line is NOT present or the field is incorrect, a Script will be inserted.



