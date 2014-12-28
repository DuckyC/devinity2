
local Black		= Color(0,0,0,255)
local Zero		= Vector(0,0,0)
local Comma 	= string.Comma

function ReloadBankHUD()
	if (!StationMenu or !StationMenu.ListBank) then return end
	
	StationMenu.ListBank:Clear()
	
	for k,v in pairs(LocalPlayer():GetBank()) do
		if (v.Data) then
			local a = StationMenu.ListBank:Add("DButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h) DrawItemIcon(0,0,w,h,v.Data,v.Quantity,s) end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
				menu:AddOption( "Withdraw", function() RequestRemoveBank(k) end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Withdraw All Type", function()
					for k2,v2 in pairs(LocalPlayer():GetBank()) do
						if v.Data.ID == v2.Data.ID then  RequestRemoveBank(k2) end
					end
				end ):SetColor(MAIN_TEXTCOLOR)
				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end

function ReloadBankInventoryHUD()
	if (!StationMenu or !StationMenu.ListBankInv) then return end
	
	StationMenu.ListBankInv:Clear()
	
	for k,v in pairs(LocalPlayer():GetInventory()) do
		if (v.Data) then
			local a = StationMenu.ListBankInv:Add("DButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h) DrawItemIcon(0,0,w,h,v.Data,v.Quantity,s) end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
				menu:AddOption( "Deposit", function() RequestAddBank(k) end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Deposit All", function() for i=1, MAIN_MAXIMUM_SLOTS do RequestAddBank(i) end  end ):SetColor(MAIN_TEXTCOLOR)
				menu:AddOption( "Deposit All Type", function()
					for k2,v2 in pairs(LocalPlayer():GetInventory()) do
						if v.Data.ID == v2.Data.ID then  RequestAddBank(k2) end
					end
				end ):SetColor(MAIN_TEXTCOLOR)
				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end

function OpenStation_Bank(StationMenu)
	local W = StationMenu:GetWide()
	local H = StationMenu:GetTall()
	
	if (!StationMenu.Bank) then 
		StationMenu.Bank = vgui.Create("MBFrame",StationMenu)
		StationMenu.Bank:SetPos(320,H/2-300)
		StationMenu.Bank:SetSize(W-430,600)
		StationMenu.Bank:SetTitle("")
		StationMenu.Bank:SetVisible(false)
		StationMenu.Bank:ShowCloseButton(false)
		StationMenu.Bank.Paint = function(s,w,h) 
			DrawRect(0,0,w,h,Black)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
			
			DrawText("Bank","DVText",5,1,MAIN_TEXTCOLOR)
			DrawText("Inventory","DVText",w/2+5,1,MAIN_TEXTCOLOR)
			DrawText("Galactic Currency Silver: "..Comma(LocalPlayer():GetMoney()),"DefaultSmall",70,5,MAIN_TEXTCOLOR)
		end
		
		table.insert(StationMenu.SubMenues,StationMenu.Bank)
		
		local MW,MH = StationMenu.Bank:GetWide(),StationMenu.Bank:GetTall()
		
		--Bank
		StationMenu.PaneBank = vgui.Create("DScrollPanel",StationMenu.Bank)
		StationMenu.PaneBank:SetPos(5,20)
		StationMenu.PaneBank:SetSize(MW/2-5,MH-25)
		StationMenu.PaneBank.Paint = function(s,w,h)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		end
		
		StationMenu.PaneBank.VBar.Paint = function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.PaneBank.VBar.btnGrip.Paint = function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.PaneBank.VBar.btnDown.Paint = function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.PaneBank.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DIconLayout",StationMenu.PaneBank)
		l:SetSize(StationMenu.PaneBank:GetWide()-10,StationMenu.PaneBank:GetTall()-10)
		l:SetPos(5,5)
		l:SetSpaceY(5)
		l:SetSpaceX(5)

		StationMenu.ListBank = l
		
		--Inventory
		StationMenu.PaneBankInv = vgui.Create("DScrollPanel",StationMenu.Bank)
		StationMenu.PaneBankInv:SetPos(MW/2+5,20)
		StationMenu.PaneBankInv:SetSize(MW/2-10,MH-25)
		StationMenu.PaneBankInv.Paint = function(s,w,h)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		end
		
		StationMenu.PaneBankInv.VBar.Paint = function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.PaneBankInv.VBar.btnGrip.Paint = function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.PaneBankInv.VBar.btnDown.Paint = function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.PaneBankInv.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DIconLayout",StationMenu.PaneBankInv)
		l:SetSize(StationMenu.PaneBankInv:GetWide()-10,StationMenu.PaneBankInv:GetTall()-10)
		l:SetPos(5,5)
		l:SetSpaceY(5)
		l:SetSpaceX(5)

		StationMenu.ListBankInv = l
	end
	
	ReloadBankHUD()
	ReloadBankInventoryHUD()
	
	StationMenu.Bank:SetVisible(true)
end