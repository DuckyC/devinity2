PLUGIN.Name = "Auto Drop"
PLUGIN._autodrop = PLUGIN._autodrop or -1
PLUGIN._time = PLUGIN._time or 0

concommand.Add("dv2_autodrop", function(_,_,_,str)
	DV2P.GetPlugin( "Auto Drop" )._autodrop = tonumber(str or -1) or -1
end)

function PLUGIN:Think()
	if CurTime() <= self._time then return end
	self._time = CurTime() + 0.5

	if self._autodrop == -1 then return end
	local lp = LocalPlayer()
	for k,v in pairs(lp:GetInventory()) do
		if v.Data.ID == self._autodrop then lp:RequestDeleteItem(k, v.Quantity) end
	end
end