
DV2P.Overrides.DrawTargetHUD = DV2P.Overrides.DrawTargetHUD or DrawTargetHUD

function DrawTargetHUD()
	DV2P.OFF.RunFunction( "Pre_DrawTargetHUD" )
	DV2P.Overrides.DrawTargetHUD()
	DV2P.OFF.RunFunction( "Post_DrawTargetHUD" )
end