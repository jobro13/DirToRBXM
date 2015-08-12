DirToRBXM
=========

DirToRBXM is an utility to unpack roblox model files (XML files) to a directory. The directory can also be packed again.

The functionality is as following:

The 'Model' and 'Folder' ClassName will both be exported as a directory. Any Scripts, LocalScripts or ModuleScripts will be exported as .lua files.
A file called '.rbxcnames' is created to keep track of classnames of all files.

Any other ClassName will be exported as a text file. Any scripts in those are not saved.


