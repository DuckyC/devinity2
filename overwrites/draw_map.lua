
DV2P.Overrides.OpenMap = DV2P.Overrides.OpenMap or OpenMap

function OpenMap()
	DV2P.OFF.RunFunction( "Pre_OpenMap" )
	DV2P.Overrides.OpenMap()
	DV2P.OFF.RunFunction( "Post_OpenMap" )
end