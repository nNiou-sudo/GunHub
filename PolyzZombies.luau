local vars = game.Players.LocalPlayer:WaitForChild("Variables")

UI.AddTab("Polyz Zombies", function(tab)

	local gun = tab:Section("Gun", "Left")
	gun:Toggle("inf_ammo", "Infinite Ammo", false)
	
	local player_sec = tab:Section("Player", "Right")
	player_sec:Toggle("inf_stamina", "Infinite Stamina", false)

while true do

	if UI.GetValue("inf_ammo") then	do	
		vars:SetAttribute("Primary_Mag", 9e9)
		vars:SetAttribute("Primary_Ammo", 9e9)
		vars:SetAttribute("Secondary_Mag", 9e9)
		vars:SetAttribute("Secondary_Ammo", 9e9)
	end
end   
	if UI.GetValue("inf_stamina") then do
	vars:SetAttribute("Stamina", 100)
    vars:SetAttribute("Haste_Perk", true)
	end
end	
    task.wait(0.1)
end
