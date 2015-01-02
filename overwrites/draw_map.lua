
DV2P.Overrides.OpenMap = DV2P.Overrides.OpenMap or OpenMap

function OpenMap()
	DV2P.OFF.RunFunction( "Pre_OpenMap" )
	DV2P.Overrides.OpenMap()

	if IsValid( MAP_Frame ) then
		DV2P.Overrides.MAP_Frame_Paint = DV2P.Overrides.MAP_Frame_Paint or MAP_Frame.Paint

		print( "override" )
		function MAP_Frame:Paint( w, h )
			DV2P.OFF.RunFunction( "Pre_MAP_Frame_Paint", self, w, h )
			DV2P.Overrides.MAP_Frame_Paint( self, w, h )
			DV2P.OFF.RunFunction( "Post_MAP_Frame_Paint", self, w, h )
		end
	end

	DV2P.OFF.RunFunction( "Post_OpenMap" )
end