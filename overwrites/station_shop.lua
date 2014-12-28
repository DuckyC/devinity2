
local Black		= Color(0,0,0,255)
local Zero		= Vector(0,0,0)
local Comma 	= string.Comma

function ReloadShopInventoryList()
	if (!StationMenu or !StationMenu.List2) then return end
	
	StationMenu.List2:Clear()
	
	for k,v in pairs(LocalPlayer():GetInventory()) do
		if (v.Data) then
			local a = StationMenu.List2:Add("DButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h) DrawItemIcon(0,0,w,h,v.Data,v.Quantity,s) end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
				menu:AddOption( "Sell", function() RequestSellItem(k,1) end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Sell stack", function() RequestSellItem(k,v.Quantity) end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Sell All Type", function()
					for k2,v2 in pairs(LocalPlayer():GetInventory()) do
						if v2.Data.ID == v.Data.ID then RequestSellItem(k2,v2.Quantity) end
					end
				end ):SetColor(MAIN_TEXTCOLOR)
				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end

function ReloadShopSaleList()
	if (!StationMenu or !StationMenu.ShopList) then return end
	
	local lp 		= LocalPlayer()
	
	local StationID 	= lp:GetDocked()
	local Reg,SystemID 	= lp:GetRegion()
	
	local SaleList = GetStationSaleList(SystemID,StationID)
	
	StationMenu.ShopList:Clear()
	
	for k,v in pairs(SaleList) do
		if (v.Data) then
			local a = StationMenu.ShopList:Add("DButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h)
				DrawItemIcon(0,0,w,h,v.Data,1,s)
			end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
				menu:AddOption( "Buy", function() RequestBuyItem(k,1) end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Buy 10", function() RequestBuyItem(k,10) end ):SetColor(MAIN_TEXTCOLOR)
				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end

function OpenStation_Shop(StationMenu)
	local W = StationMenu:GetWide()
	local H = StationMenu:GetTall()
	
	if (!StationMenu.Shop) then 
		StationMenu.Shop = vgui.Create("MBFrame",StationMenu)
		StationMenu.Shop:SetPos(320,H/2-300)
		StationMenu.Shop:SetSize(W-430,600)
		StationMenu.Shop:SetTitle("")
		StationMenu.Shop:SetVisible(false)
		StationMenu.Shop:ShowCloseButton(false)
		StationMenu.Shop.Paint = function(s,w,h) 
			DrawRect(0,0,w,h,Black)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
			
			DrawText("Shop","DVText",5,1,MAIN_TEXTCOLOR)
			DrawText("Inventory","DVText",w/2+5,1,MAIN_TEXTCOLOR)
			DrawText("Galactic Currency Silver: "..Comma(LocalPlayer():GetMoney()),"DefaultSmall",70,5,MAIN_TEXTCOLOR)
			
			DrawText("Ships","DVText",5,h-225,MAIN_TEXTCOLOR)
		end
		
		table.insert(StationMenu.SubMenues,StationMenu.Shop)
		
		local MW,MH = StationMenu.Shop:GetWide(),StationMenu.Shop:GetTall()
		
		--Inventory
		StationMenu.Pane = vgui.Create("DScrollPanel",StationMenu.Shop)
		StationMenu.Pane:SetPos(MW/2,20)
		StationMenu.Pane:SetSize(MW/2-5,MH-25)
		StationMenu.Pane.Paint = function(s,w,h)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		end
		
		StationMenu.Pane.VBar.Paint = function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.Pane.VBar.btnGrip.Paint = function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.Pane.VBar.btnDown.Paint = function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.Pane.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DIconLayout",StationMenu.Pane)
		l:SetSize(StationMenu.Pane:GetWide()-10,StationMenu.Pane:GetTall()-10)
		l:SetPos(5,5)
		l:SetSpaceY(5)
		l:SetSpaceX(5)

		StationMenu.List2 = l
		
		--Shop
		StationMenu.Pane2 = vgui.Create("DScrollPanel",StationMenu.Shop)
		StationMenu.Pane2:SetPos(5,20)
		StationMenu.Pane2:SetSize(MW/2-10,MH-250)
		StationMenu.Pane2.Paint = function(s,w,h)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		end
		
		StationMenu.Pane2.VBar.Paint = function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.Pane2.VBar.btnGrip.Paint = function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.Pane2.VBar.btnDown.Paint = function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.Pane2.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DIconLayout",StationMenu.Pane2)
		l:SetSize(StationMenu.Pane2:GetWide()-10,StationMenu.Pane2:GetTall()-10)
		l:SetPos(5,5)
		l:SetSpaceY(5)
		l:SetSpaceX(5)

		StationMenu.ShopList = l
		
		--Ships
		StationMenu.Pane3 = vgui.Create("DScrollPanel",StationMenu.Shop)
		StationMenu.Pane3:SetPos(5,MH-200)
		StationMenu.Pane3:SetSize(MW/2-10,195)
		StationMenu.Pane3.Paint = function(s,w,h)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		end
		
		StationMenu.Pane3.VBar.Paint = function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.Pane3.VBar.btnGrip.Paint = function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.Pane3.VBar.btnDown.Paint = function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.Pane3.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DListLayout",StationMenu.Pane3)
		l:SetSize(StationMenu.Pane3:GetWide()-10,StationMenu.Pane3:GetTall()-10)
		l:SetPos(5,5)

		for k,v in pairs(GetShipList()) do
			if (v) then
				local a = l:Add("DPanel")
				a:SetTall(100)
				a:SetText("")
				a.Data = v
				a.Paint = function(s,w,h)
					DrawOutlinedRect(0,0,w,h-5,MAIN_GUICOLOR)
					
					if (LocalPlayer():GetShip() == v.Name) then
						DrawRect(5,5,85,85,MAIN_GREENCOLOR)
					else
						DrawRect(5,5,85,85,MAIN_GUICOLOR)
					end
					
					DrawText(s.Data.Name,"DVText",95,5,MAIN_WHITECOLOR)
					DrawText("Price: GCS "..Comma(s.Data.StockValue),"DefaultSmall",95,25,MAIN_WHITECOLOR)
					DrawText("Turret Slots: "..(#s.Data.TurretSlots),"DefaultSmall",95,40,MAIN_WHITECOLOR)
					DrawText("Dmg taken: "..(100*math.ceil(10000*s.Data.DamageReduction)/10000).."%","DefaultSmall",95,55,MAIN_WHITECOLOR)
					DrawText("Type: "..s.Data.Type,"DefaultSmall",95,70,MAIN_WHITECOLOR)
					
					DrawText("HP: "..Comma(s.Data.HP),"DefaultSmall",195,40,MAIN_WHITECOLOR)
					DrawText("Armor: "..Comma(s.Data.Armor),"DefaultSmall",195,55,MAIN_WHITECOLOR)
					DrawText("Shield: "..Comma(s.Data.Shield),"DefaultSmall",195,70,MAIN_WHITECOLOR)
				end
				
				local b = vgui.Create("MBButton",a)
				b:SetPos(l:GetWide()-120,30)
				b:SetSize(100,20)
				b:SetText("Buy")
				b.Paint = function(s,w,h)
					if (s.Hovered) then DrawRect(0,0,w,h,MAIN_COLORD) end
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
					
					DrawText(s.Text,"DVTextSmall",w/2,h/2,MAIN_TEXTCOLOR,1)
				end
				b.DoClick = function(s)
					local X,Y = gui.MousePos()
					
					RequestAddShip(v.Name)
					
					surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
				end
				
				local b = vgui.Create("MBButton",a)
				b:SetPos(l:GetWide()-120,55)
				b:SetSize(100,20)
				b:SetText("Set")
				b.Paint = function(s,w,h)
					if (s.Hovered) then DrawRect(0,0,w,h,MAIN_COLORD) end
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
					
					DrawText(s.Text,"DVTextSmall",w/2,h/2,MAIN_TEXTCOLOR,1)
				end
				b.DoClick = function(s)
					local X,Y = gui.MousePos()
					
					RequestSetShip(v.Name)
					
					surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
				end
				
				local CamPos 	= Vector(1,0,0.6)*(v.Boundaries.Max-v.Boundaries.Min):Length()/2
				
				local c = vgui.Create("DModelPanel",a)
				c:SetPos(5,5)
				c:SetSize(85,85)
				c:SetModel(v.Model)
				c:SetLookAt(Zero)
				c:SetCamPos(CamPos)
			end
		end
	end
	
	ReloadShopInventoryList()
	ReloadShopSaleList()
	
	StationMenu.Shop:SetVisible(true)
end