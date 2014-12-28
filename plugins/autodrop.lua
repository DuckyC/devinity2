local AUTODROP = -1
concommand.Add("dv2_autodrop", function(_,_,_,str)
	AUTODROP = tonumber(str or -1) or -1
end)

hook.Add("Tick", "dropautodrop", function()
	if AUTODROP == -1 then return end
	local lp = LocalPlayer()
	for k,v in pairs(lp:GetInventory()) do
		if v.Data.ID == AUTODROP then lp:RequestDeleteItem(k, v.Quantity) end
	end
end)