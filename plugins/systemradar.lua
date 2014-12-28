local ownfaction = LocalPlayer():GetFaction()
local OtherColor = Color(255,0,0)

local function DrawRadarPlayer(faction, ply, y)
	local Class, ID = DV2P.GetLocalSystemPos(ply)
	surface.SetFont("DefaultSmall")

	local w1, h1 = surface.GetTextSize( faction )
	DrawText(ply:GetName() .." | "..Class.." "..ID, "DefaultSmall", 202, y, MAIN_TEXTCOLOR)
	faction = (faction != "") and faction or "None"
	
	local w2, h2 = surface.GetTextSize( faction )
	DrawText(faction, "DefaultSmall", 202-w2-5, y, (ownfaction == faction) and MAIN_TEXTCOLOR or OtherColor)

	if input.IsMouseInBox(202-w2-5,y,w1+w2+5,h2) then
		//print(ply:GetName())
	end
end
hook.Add("HUDPaint", "Devinty2SystemRadar", function()
	
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
