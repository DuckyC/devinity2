
net.Receive("FireSlot",function()
	local pl = net.ReadEntity()
	
	if (!IsValid(pl)) then return end
	
	local slot = net.ReadUInt(6)
	local targ = pl:GetTarget(net.ReadUInt(6))
	
	if (!pl.Equipment or !pl.Equipment[slot] or !pl.Equipment[slot].OnFire) then return end
	
	if (!pl.ActiveSlots) then pl.ActiveSlots = {} end
	
	local Ite = pl.Equipment[slot]
	
	if (!targ) then return end
	
	pl.ActiveSlots[slot] = {Time=CurTime()+Ite.CD}

	DV2P.OFF.RunFunction( "FireSlot_OnFire", pl, targ, Ite, slot )
	Ite:OnFire(pl,slot,targ)
end)