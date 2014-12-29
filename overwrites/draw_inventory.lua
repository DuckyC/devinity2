local X,Y 		= ScrW()+100,ScrH()/2-150
local xh,yh 	= ScrW()/2,ScrH()/2
local w,h 		= 600,300
local Tim 		= 0

local Mat 	= Material("devinity2/hud/top.png")
local Blu 	= Material("devinity2/hud/circle_blur.png")
local Car	= nil
local Hov	= nil
local Floor = math.floor
local Comma	= string.Comma
local Clamp = math.Clamp
local input = input

hook.Add("Tick","ThinkInventory",function()
	local O = IsQMenuOpen()
	
	if (O and Tim < 1) then Tim = Tim + (1-Tim)/8
	elseif (!O and Tim >= 0.01) then Tim = Tim - Tim/8
	else return end
	
	Tim = Clamp(Tim,0,1)
end)

function DrawInventory()
	local lp = LocalPlayer()
	
	DrawTurretSlots(Car)
	
	if (Tim < 0.01) then return end
	
	local x	= X-705*Tim
	
	DrawRect(x,Y,w,h,MAIN_BLACKCOLOR)
	DrawOutlinedRect(x,Y,w,h,MAIN_GUICOLOR)
	
	DrawRect(x,Y-45,w,40,MAIN_BLACKCOLOR)
	DrawOutlinedRect(x,Y-45,w,40,MAIN_GUICOLOR)
	
	DrawRect(x+10,Y-65,w-10,14,MAIN_BLACKCOLOR)
	DrawOutlinedRect(x+10,Y-65,w-10,14,MAIN_GUICOLOR)
	
	DrawRect(x,Y+h+5,w,130,MAIN_BLACKCOLOR)
	DrawOutlinedRect(x,Y+h+5,w,130,MAIN_GUICOLOR)
	DrawText("Standings", "DVTextNormal", x+10,Y+h+10, MAIN_TEXTCOLOR)
	
	DrawMaterialRectRotated(x-4,Y+h/2+36,512,32,MAIN_COLOR,Mat,90)
	DrawText("Inventory", "DVTextNormal", x+10,Y-43, MAIN_TEXTCOLOR)
	
	
	local Count = 0
	
	if (lp.Inventory) then Count = table.Count(lp.Inventory) end
	
	DrawText(Comma(lp:GetMoney()).." GCS.","DefaultSmall",x+24,Y-66,MAIN_TEXTCOLOR)
	
	DrawText("Items: "..Count.."/"..MAIN_MAXIMUM_SLOTS, "DVTextSmall", x+170,Y-30, MAIN_TEXTCOLOR)
	DrawText("Weight: 0 t.", "DVTextSmall", x+320,Y-30, MAIN_TEXTCOLOR)
	
	if (lp.Inventory) then 
		for k = 1,MAIN_MAXIMUM_SLOTS do
			local x_i = 60*(k-1-10*Floor(k/10-0.1))
			local y_i = 60*Floor(k/10-0.1)
				
			local v	= lp.Inventory[k]
			local M = input.IsMouseDown(MOUSE_LEFT)
				
			if (input.IsMouseInBox(x+x_i,Y+y_i,60,60) and Car) then
				DrawRect(x+x_i,Y+y_i,60,60,MAIN_GUICOLOR)
				
				if (!M) then
					if (Car != k) then lp:RequestSwap(Car,k) end
					Car = nil
					
					surface.PlaySound("devinity2/ui/buttons/button_click2.wav")
				end
			end
			
			if (v and v.Data) then
				if (DrawItemIcon(x+x_i,Y+y_i,60,60,v.Data,v.Quantity)) then
					if (M and !Car) then
						Car = k
						
						surface.PlaySound("devinity2/ui/buttons/button_click1.wav")
					end
			
					if (input.MousePress(MOUSE_RIGHT,"Swapper") and v and v.Data.Name) then
						local mx,my = gui.MousePos()
						local menu = DermaMenu() 
						menu.ID = k
						menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
						menu:AddOption( "Equip 64", function() 
							local lp = LocalPlayer()
							local equipment = lp:GetEquipment()
							local weps = 0
							local slot = 0
							repeat
								slot = slot + 1
								if not equipment[slot] then
									RequestEquipItem(slot,menu.ID)
									weps = weps + 1
								end
							until(weps >= lp.Inventory[menu.ID].Quantity or slot >= 64)
						end ):SetColor(MAIN_TEXTCOLOR)
						menu:AddOption( "Delete", function() lp:RequestDeleteItem(menu.ID,v.Quantity) end ):SetColor(MAIN_TEXTCOLOR)
						menu:AddOption( "Delete 1", function() lp:RequestDeleteItem(menu.ID,1) end ):SetColor(MAIN_TEXTCOLOR)
						menu:AddOption( "Drop stack", function() LaunchJettisonObject(menu.ID) end ):SetColor(MAIN_TEXTCOLOR)
						menu:Open()
						menu:SetPos(Clamp(mx,0,ScrW()-100),Clamp(my,0,ScrH()-100))
						
						surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
					end
				end
			end
		end
	end
	
	if (Tim < 0.99 or !lp.Inventory) then return end
	
	if (Car and lp.Inventory[Car]) then
		local v   	= lp.Inventory[Car]
		local A	  	= MAIN_WHITECOLOR.a*1
		local Xi,Yi = gui.MousePos()
		
		MAIN_WHITECOLOR.a = 100
		DrawMaterialRect(Xi-25,Yi-25,50,50,MAIN_WHITECOLOR,v.Data.Rarity.Overlay)
		MAIN_WHITECOLOR.a = A
		
		if (!input.IsMouseDown(MOUSE_LEFT)) then Car = nil end
	end
end