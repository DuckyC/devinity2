local UnknownFaction = Color(150,150,150,255)
local OwnFaction = Color(0, 200, 0)
local EnemyFaction = Color(255,0,0)

local function DrawRadarPlayer(faction, ply, y)
	local Class, ID = DV2P.GetLocalSystemPos(ply)
	local ownfaction = LocalPlayer():GetFaction()
	surface.SetFont("DefaultSmall")

	local w1, h1 = surface.GetTextSize( ply:GetName() .." | "..Class.." "..ID)
	DrawText(ply:GetName() .." | "..Class.." "..ID, "DefaultSmall", 202, y, MAIN_TEXTCOLOR)
	faction = (faction != "") and faction or "None"
	
	local col = (ownfaction == faction) and OwnFaction or UnknownFaction

	local w2, h2 = surface.GetTextSize( faction )
	DrawText(faction, "DefaultSmall", 202-w2-5, y, col)

	if input.IsMouseInBox(202-w2-5,y,w1+w2+5,h2) and (input.MousePress(MOUSE_LEFT,"OpenPlayerinfo_"..ply:GetName())) then
		DV2P.ShowPlayerInfo(ply)
	end
end
hook.Add("HUDPaint", "Devinty2SystemRadar", function()
	local ownfaction = LocalPlayer():GetFaction()
	local factions = {}
	for k, v in pairs( player.GetAllInRegion( LocalPlayer():GetRegion() ) ) do 
		local fac = v:GetFaction()
		factions[fac] = factions[fac] or {}
		factions[fac][#factions[fac]+1] = v
	end

	local y = 150
	if factions[ownfaction] then
		for _, ply in pairs( factions[ownfaction] ) do 
			 DrawRadarPlayer(ownfaction, ply, y)
			y = y + 15
		end
	end
	for faction, players in pairs( factions ) do 
		if faction == ownfaction then continue end
		for _, ply in pairs( players ) do 
			 DrawRadarPlayer(faction, ply, y)
			y = y + 15
		end
	end
end)
