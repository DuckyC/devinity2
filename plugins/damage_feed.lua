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

local damage = {}
local targets = {}
DV2P.OFF.AddFunction( "FireSlot_OnFire", "DamageFeed", function( from, target, turret, slot )
	if turret.Class == "Mining Laser" then return end
	local lp = LocalPlayer()
	if target == lp or lp == from then
		local Dmg = turret.Dmg
		if not target.GetShipData then return end
		
		if (target:GetShipData().Type == turret.Type) then Dmg = Dmg*5 end
		Dmg = CalculateDamage(target, Dmg)
		local parent = (lp == target and damage or targets)
		local fromd = (lp == target and from or target)
		local tbl = parent[fromd] or {Time = os.time(), TDmg = 0, Hits = 0}
		tbl.TDmg = tbl.TDmg + Dmg
		tbl.Hits = tbl.Hits + 1
		parent[from] = tbl
	end
end)

hook.Add("Think", "DamageFeedNotes", function()
	for k,v in pairs(damage) do
		if v.Time+1 < os.time() then
			LocalPlayer():AddNote(k:GetName().." hit you for "..string.Comma(v.TDmg).." damage. ("..v.Hits.." hits)")
			damage[k] = nil
		end
	end
	for k,v in pairs(targets) do
		if v.Time+1 < os.time() then
			LocalPlayer():AddNote("you hit "..k:GetName().." for "..string.Comma(v.TDmg).." damage. ("..v.Hits.." hits)")
			targets[k] = nil
		end
	end
end)