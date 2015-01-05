PLUGIN.Name = "Sound Options"
PLUGIN.Description = "Enable or disable certain sounds."
PLUGIN._soundstates = PLUGIN._soundstates or {}

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 200, 430 )
	self.derma.checkBoxes = {}
	local soundstates = self._soundstates
	self._soundstates = {}

	local id = 1
	local function AddCheckBox( data )
		local prevData = soundstates[ id ]

		if prevData and prevData.Checked ~= nil then
			data.Checked = prevData.Checked
		elseif data.Checked == nil then
			data.Checked = true
		end

		self._soundstates[ id ] = data

		local checkBox = vgui.Create( "DCheckBoxLabel", container )
		checkBox:SetText( data.Text or "" )
		checkBox:SetChecked( data.Checked )

		local tempid = id
		checkBox.OnChange = function( pnl, bVal )
			self._soundstates[ tempid ].Checked = bVal
		end

		self.derma.checkBoxes[ #self.derma.checkBoxes + 1 ] = checkBox

		id = id + 1
	end

	AddCheckBox( { Text = "Crafting"				, SoundFile = "phx/epicmetal_hard.wav" } )
	AddCheckBox( { Text = "Station docking"			, SoundFile = "devinity2/station/dock.wav" } )
	AddCheckBox( { Text = "Item selling"			, SoundFile = "ambient/levels/labs/coinslot1.wav" } )
	AddCheckBox( { Text = "Button hovering"			, SoundFile = "devinity2/ui/buttons/button_hover.wav" } )
	AddCheckBox( { Text = "Button pressing"			, SoundFile = "devinity2/ui/buttons/button_click1.wav" } )
	AddCheckBox( { Text = "Button releasing"		, SoundFile = "devinity2/ui/buttons/button_click2.wav" } )
	AddCheckBox( { Text = "Station Button clicking"	, SoundFile = "buttons/lightswitch2.wav" } )
	AddCheckBox( { Text = "Scoreboard opening"		, SoundFile = "devinity2/ui/scoreboard_transition_open.wav" } )
	AddCheckBox( { Text = "Scoreboard closing"		, SoundFile = "devinity2/ui/scoreboard_transition_close.wav" } )
	AddCheckBox( { Text = "Pulse cannons"			, SoundName = "CannonFire" } )
	AddCheckBox( { Text = "Lasers"					, SoundName = "LaserFire" } )
	AddCheckBox( { Text = "Missile launches"		, SoundName = "MissileLaunchDV" } )
	AddCheckBox( { Text = "Missile explosions"		, SoundName = "MissileExplodeDV" } )
	AddCheckBox( { Text = "Explosions"				, SoundName = "Explosion" } )
	AddCheckBox( { Text = "Warp disrupters"			, SoundName = "WarpDisrupter" } )
	AddCheckBox( { Text = "Mining lasers"			, SoundName = "MiningLaser" } )
	AddCheckBox( { Text = "NPC deaths"				, SoundName = "NPCDeath" } )
end

function PLUGIN:PanelPerformLayout( container, w, h )
	local i = 0

	for _, v in pairs( self.derma.checkBoxes ) do
		v:SetPos( 0, i )
		v:SetWidth( w )

		i = i + 18
	end
end

DV2P.OFF.AddFunction( "Pre_sound.Play", "SoundOptions1", function( Name, Pos, Level, Pitch, Volume )
	local plugin = DV2P.GetPlugin( "Sound Options" )

	for _, v in pairs( plugin._soundstates ) do
		if v.SoundName and v.SoundName == Name then
			if v.Checked == false then
				return true
			else
				break
			end
		end
	end
end )

DV2P.OFF.AddFunction( "Pre_surface.PlaySound", "SoundOptions2", function( soundfile )
	local plugin = DV2P.GetPlugin( "Sound Options" )

	for _, v in pairs( plugin._soundstates ) do
		if v.SoundFile and v.SoundFile == soundfile then
			if v.Checked == false then
				return true
			else
				break
			end
		end
	end
end )