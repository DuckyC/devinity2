
local VOCOL	 	= table.Copy(MAIN_BLACKCOLOR)

function GM:PlayerStartVoice( ply )
	ply.Talking = true
end

function GM:PlayerEndVoice( ply )
	ply.Talking = nil
end

local W = ScrW()
hook.Add("HUDPaint","_VoiceChatDraw",function()
	local D = 0

	for k,v in pairs( player.GetAll() ) do
		if (v.Talking) then
			local H = 50 + 30*D
			D = D+1
			
			local V = v:VoiceVolume()
			
			VOCOL.g = math.Clamp(200*V,0,255)
			
			DrawDV2Box(W-300,H,280,30,70,VOCOL,MAIN_GUICOLOR,8)
			DrawText( v:Nick(), "Trebuchet18", W-290, H+10, MAIN_TEXTCOLOR )
		end
	end
end)