PLUGIN.Name = "Small Things"

local ShowEffects = CreateClientConVar( "dv2_show_effects", "1" )
local OrgCreateEffect = CreateEffect
cvars.AddChangeCallback( "dv2_show_effects", function()
	if ShowEffects:GetInt() == 1  then
		CreateEffect = OrgCreateEffect
		GAMEMODE.MapEffects = table.Copy(OLDMAPEFFECTS) or {}
	else
		OLDMAPEFFECTS = table.Copy(GAMEMODE.MapEffects) or {}
		CreateEffect = function() end
		GAMEMODE.MapEffects = {}
	end
end)

concommand.Add("dv2_enter", DV2P.EnterGamemode)