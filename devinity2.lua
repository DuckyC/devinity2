require("luaerror2")
hook.Add("LuaError", "Error receiver", function(is_runtime_error, source_file, source_line, error_string, stack_table)
	
	local mainCol = Color( 231, 219, 115 )
	MsgC( mainCol, "[", Color( 255, 150, 0 ), "LuaError2", mainCol, "] ",
		Color( 150, 255, 100 ), source_file, mainCol, ":", Color( 255, 100, 100 ), source_line,
		mainCol, ": ", Color( 255, 100, 255 ), error_string, "\n" )
	
	if stack_table then
		for k, v in pairs( stack_table ) do
			local indent = ""
			for i = 1, k do indent = indent .. " " end

			local name = v.name
			if name == "" then name = "unknown" end
			MsgC( mainCol, indent, Color( 255, 150, 0 ), k, mainCol, ". ",
				Color( 255, 100, 255 ), name, mainCol, " - ",
				Color( 150, 255, 100 ), v.short_src, mainCol, ":",
				Color( 255, 100, 100 ), v.currentline, "\n" )
		end
	end

	return true 
end)

DV2P = DV2P or {}
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
DV2P.IncludeFolder(PATH.."/overwrites/")
DV2P.IncludeFolder(PATH.."/plugins/")

