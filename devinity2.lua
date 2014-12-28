require("luaerror2")
hook.Add("LuaError", "Error receiver", function(is_runtime_error, source_file, source_line, error_string, stack_table)
	print(is_runtime_error, source_file, source_line, error_string) 
	if stack then PrintTable(stack) end 
	return true 
end)

DV2P = {}
local PATH = "lua/menu_plugins/devinity2/"

function DV2P.Include(path, v)
	print( "Loading file '" .. v .. "' ..." )
	CompileString( file.Read(  path..v, "GAME" ) or "print('Included file not found "..v.."')", "BASE_GAMEMODE/" .. v )()
end
function DV2P.IncludeFolder(path)
	local files, dirs = file.Find( path.."/*.lua", "GAME" )
	for k, v in pairs( files ) do DV2P.Include(path.."/", v) end
end

DV2P.Include(PATH, "library.lua")
DV2P.Include(PATH, "plugins.lua")
DV2P.IncludeFolder(PATH.."/plugins/")
DV2P.IncludeFolder(PATH.."/overwrites/")
