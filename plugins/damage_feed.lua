local function CalculateDamage(self, dmg)
	if (!self.ShipHealth or self.ShipHealth <= 0) then return 0 end
	if (self:GetDocked()) then return 0 end
	
	local Data = self:GetShipData()
	
	if (!Data) then return 0 end
	dmg = math.ceil(dmg*Data.DamageReduction)
	
	local Dmg = self.ShipShield-dmg
	local TDmg = 0
	
	if (self.ShipShield > 0) then TDmg = TDmg + math.max(0,Dmg) end
	
	if (Dmg < 0) then
		local Dmg2 = self.ShipArmor-math.abs(Dmg)
		
		if (self.ShipArmor > 0) then TDmg = TDmg + math.max(0,Dmg2) end
		
		if (Dmg2 < 0) then
			local Dmg3 = self.ShipHealth-math.abs(Dmg2)
			
			TDmg = TDmg + math.max(0,Dmg2)
		end
	end
	return TDmg
end

local DamageQueue = {}
DV2P.OFF.AddFunction( "FireSlot_OnFire", "DamageFeed", function( from, target, turret, slot )
	if turret.Class == "Mining Laser" or from.Pirate or from.Police then return end

	local lp = LocalPlayer()
	if lp == target or lp == from then 
		if not target.GetShipData then return end
		local Dmg = turret.Dmg
		if (target:GetShipData().Type == turret.Type) then Dmg = Dmg*5 end
		Dmg = CalculateDamage(target, Dmg)

		local key = tostring(from).."_"..tostring(target)

		local P = DamageQueue[key]  or {Time = os.time(), Dmg = 0, Hits = 0, from = from, target = target}
		P.Dmg = P.Dmg + Dmg
		P.Hits = P.Hits + 1
		DamageQueue[key] = P
	end
end)

hook.Add("Think", "DamageFeedNotes", function()
	local lp = LocalPlayer()
	for k,v in pairs(DamageQueue) do
		if v.Time < os.time()  then
			local Pre = (v.from == lp) and ("you hit "..(v.target.GetName and v.target:GetName() or "Pirate")) or ((v.from.GetName and v.from:GetName() or "Pirate").." hit you ")
			lp:AddNote(Pre.." for "..string.Comma(v.Dmg).." damage. ("..v.Hits.." hits)")
			DamageQueue[k] = nil
		end
	end
end)
