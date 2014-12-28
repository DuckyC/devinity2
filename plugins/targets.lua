hook.Add( "HUDPaint", "dv2_target_show", function()
	local lp = LocalPlayer()
	local reg, sid = lp:GetRegion()
	if reg == "Space" then	return	end
	
	for k, v in pairs( player.GetAllInRegion( lp:GetRegion() ) ) do
		if v.PlayerPos then
			local Pos = ( v.PlayerPos - lp.PlayerPos ) + ( v.FloatPos - lp.FloatPos )
			local Dis = DV2P.GetDistance(v, lp)

			if Dis < MAIN_VISIBLE_RANGE and v.Target then
				local tar = v.Target
				
				local TarPos
				
				if not tar.FloatPos then return end

				if tar.PlayerPos then
					TarPos = ( tar.PlayerPos - lp.PlayerPos ) + ( tar.FloatPos - lp.FloatPos )
				else
					TarPos = ( tar.Pos - lp.PlayerPos ) + ( tar.FloatPos - lp.FloatPos )
				end

				local Dis2 = TarPos:Length()

				if Dis2 < MAIN_VISIBLE_RANGE then
					local STarPos = TarPos:ToScreen()
					local SPos = Pos:ToScreen()
					if STarPos.visible and SPos.visible then
						surface.SetDrawColor( 255, 100, 100 )
						surface.DrawLine( SPos.x - 1, SPos.y - 1, STarPos.x, STarPos.y )
						surface.DrawLine( SPos.x + 1, SPos.y - 1, STarPos.x, STarPos.y )
						surface.DrawLine( SPos.x - 1, SPos.y + 1, STarPos.x, STarPos.y )
						surface.DrawLine( SPos.x + 1, SPos.y + 1, STarPos.x, STarPos.y )
					end
				end
			end
		end
	end
end )
