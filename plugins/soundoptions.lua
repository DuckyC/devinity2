PLUGIN.Name = "Sound Options"
PLUGIN.Description = "Enable or disable certain sounds."

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 200, 430 )
	self.derma.checkBoxes = {}

	local function AddCheckBox( data )
		local checkBox = vgui.Create( "DCheckBoxLabel", container )
		checkBox:SetText( data.Text or "" )
		checkBox:SetChecked( data.Checked or true )
		checkBox.SoundName = data.SoundName or nil
		checkBox.SoundFile = data.SoundFile or nil

		table.insert( self.derma.checkBoxes, checkBox )
	end

	AddCheckBox( { Text = "Crafting", SoundFile = "phx/epicmetal_hard.wav" } )
	AddCheckBox( { Text = "Pulse cannons", SoundName = "CannonFire" } )
	AddCheckBox( { Text = "Lasers", SoundName = "LaserFire" } )
	AddCheckBox( { Text = "Missile launches", SoundName = "MissileLaunchDV" } )
	AddCheckBox( { Text = "Missile explosions", SoundName = "MissileExplodeDV" } )
	AddCheckBox( { Text = "Explosions", SoundName = "Explosion" } )
	AddCheckBox( { Text = "NPC deaths", SoundName = "NPCDeath" } )
	AddCheckBox( { Text = "Warp disrupters", SoundName = "WarpDisrupter" } )
	AddCheckBox( { Text = "Mining lasers", SoundName = "MiningLaser" } )
end

function PLUGIN:PanelPerformLayout( container, w, h )
	local i = 0

	for _, v in pairs( self.derma.checkBoxes ) do
		v:SetPos( 0, i )
		v:SetWidth( w )

		i = i + 18
	end
end

local _PLUGIN = PLUGIN
DV2P.OFF.AddFunction( "Pre_sound.Play", "SoundOptions1", function( Name, Pos, Level, Pitch, Volume )
	for _, v in pairs( _PLUGIN.derma ) do
		if v.SoundName and v.SoundName == Name then
			return v:GetChecked()
		end
	end
end )

DV2P.OFF.AddFunction( "Pre_surface.PlaySound", "SoundOptions2", function( soundfile )
	for _, v in pairs( _PLUGIN.derma ) do
		if v.SoundFile and v.SoundFile == soundfile then
			return v:GetChecked()
		end
	end
end )