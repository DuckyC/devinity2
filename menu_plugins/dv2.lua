require("interstate")
concommand.Add("dv2_plugins_load", function() 
	RunOnClient([[local f = CompileString( file.Read( "lua/menu_plugins/devinity2/devinity2.lua", "GAME" ) or "print('Missing Devinity2 load file')", "BASE_GAMEMODE" ) f()]])
end)