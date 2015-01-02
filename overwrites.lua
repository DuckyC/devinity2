
DV2P.OFF = DV2P.OFF or {
	functions = {}
}
DV2P.Overrides = DV2P.Overrides or {}

function DV2P.OFF.RunFunction( name, ... )
	local functions = DV2P.OFF.functions[ name ]
	if not functions then return end

	for k, v in pairs( functions ) do
		if v and type( v ) == "function" then
			v( ... )
		end
	end
end

function DV2P.OFF.AddFunction( funcName, id, func )
	DV2P.OFF.functions[ funcName ] = DV2P.OFF.functions[ funcName ] or {}

	DV2P.OFF.functions[ funcName ][ id ] = func
end

function DV2P.OFF.RemoveFunction( funcName, id  )
	if not DV2P.OFF.functions[ funcName ] then return end
	
	DV2P.OFF.functions[ funcName ][ id ] = nil
end

DV2P.OFF.AddFunction( "ReloadBankHUD_MenuAddOption", "WithdrawAllType", function( item, menu ) 
	menu:AddOption( "Withdraw All Type", function()
		for k2,v2 in pairs(LocalPlayer():GetBank()) do
			if v.Data.ID == v2.Data.ID then  RequestRemoveBank(k2) end
		end
	end ):SetColor(MAIN_TEXTCOLOR)
end )

DV2P.OFF.AddFunction( "ReloadBankInventoryHUD_MenuAddOption", "DepositAllType", function( item, menu ) 
	menu:AddOption( "Deposit All Type", function()
		for k2,v2 in pairs(LocalPlayer():GetInventory()) do
			if v.Data.ID == v2.Data.ID then  RequestAddBank(k2) end
		end
	end ):SetColor(MAIN_TEXTCOLOR)
end )

DV2P.OFF.AddFunction( "test", "test2", function( ... ) 
	print( "test2" )
	PrintTable( { ... } )
end )