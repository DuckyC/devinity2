function ReloadCraftingInventoryList()
	if (not StationMenu or not StationMenu.Crafting or not StationMenu.Crafting.List) then return end
	
	local A = StationMenu.Crafting.List
	
	A:Clear()
	
	for k,v in pairs(LocalPlayer():GetInventory()) do
		if (v.Data and v.Data.Material) then
			local a = A:Add("MBButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h)
				DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
				
				if (s.Hovered) then DrawMaterialRect(0,0,64,h,MAIN_WHITECOLOR,v.Data.Rarity.Overlay)
				else DrawMaterialRect(0,0,64,h,MAIN_WHITECOLORT,v.Data.Rarity.Overlay) end
				
				if (v.Data.Icon) then DrawMaterialRect(0,0,64,h,MAIN_WHITECOLOR,v.Data.Icon) end
				
				DrawText("x"..v.Quantity,"DefaultSmall",2,h-15,MAIN_WHITECOLOR)
				DrawText("T: "..v.Data.Tech,"DefaultSmall",2,0,MAIN_WHITECOLOR)
			end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end

				for i = 1, 10 do
					menu:AddOption( "Set Slot " .. i, function() StationMenu.Crafting.CraftingList[i] = v.Data end ):SetColor(MAIN_TEXTCOLOR)
				end
				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end
