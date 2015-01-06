
DV2P.Overrides.DrawTurretSlots = DV2P.Overrides.DrawTurretSlots or DrawTurretSlots

function DrawTurretSlots( Car )
	DV2P.OFF.RunFunction( "Pre_DrawTurretSlots", Car )
	DV2P.Overrides.DrawTurretSlots( Car )
	DV2P.OFF.RunFunction( "Post_DrawTurretSlots", Car )
end