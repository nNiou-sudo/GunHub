local vars = game.Players.LocalPlayer:WaitForChild("Variables")

UI.AddTab("Polyz Zombies", function(tab)
    local gun = tab:Section("Gun", "Left")
    gun:Toggle("inf_ammo", "Infinite Ammo", false)
    
    local player_sec = tab:Section("Player", "Right")
    player_sec:Toggle("inf_stamina", "Infinite Stamina", false)
end)

-- Run the loop in a separate thread
task.spawn(function()
    while true do
        -- Check for Infinite Ammo
        if UI.GetValue("inf_ammo") then
            vars:SetAttribute("Primary_Mag", 9e9)
            vars:SetAttribute("Primary_Ammo", 9e9)
            vars:SetAttribute("Secondary_Mag", 9e9)
            vars:SetAttribute("Secondary_Ammo", 9e9)
        end

        -- Check for Infinite Stamina
        if UI.GetValue("inf_stamina") then
            vars:SetAttribute("Stamina", 100)
            vars:SetAttribute("Haste_Perk", true)
        end

        task.wait(0.1)
    end
end)
