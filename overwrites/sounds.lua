DV2P.Overrides.sound_Play = DV2P.Overrides.sound_Play or sound.Play
DV2P.Overrides.surface_PlaySound = DV2P.Overrides.surface_PlaySound or surface.PlaySound

sound.Play = function( Name, Pos, Level, Pitch, Volume )
	local pre = DV2P.OFF.RunFunction( "Pre_sound.Play", Name, Pos, Level, Pitch, Volume )
	if pre == true then return end

	DV2P.Overrides.sound_Play( Name, Pos, Level, Pitch, Volume )

	DV2P.OFF.RunFunction( "Post_sound.Play" )
end

surface.PlaySound = function( soundfile )
	local pre = DV2P.OFF.RunFunction( "Pre_surface.PlaySound", soundfile )
	if pre == true then return end

	DV2P.Overrides.surface_PlaySound( soundfile )

	DV2P.OFF.RunFunction( "Post_surface.PlaySound" )
end