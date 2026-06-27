local player = game.Players.LocalPlayer
local playerSettings = player:WaitForChild("Settings")

UI.AddTab("Blood Zone", function(tab)

    -- Gun Section
    local gun = tab:Section("Gun", "Left")
    gun:Toggle("inf_ammo", "Infinite Ammo", false)
    gun:Toggle("no_recoil", "No Recoil", false)
    gun:Toggle("no_spread", "No Spread", false)
    gun:Toggle("force_auto", "Force Full Auto", false)
    gun:SliderFloat("shoot_time", "Fire Rate", 0.01, 1.0, 0.5, "%.2f")
    gun:SliderInt("num_shots", "Bullets", 1, 20, 1)
	gun:SliderFloat("swing_time", "Swing Time", 0.01, 1.0, 1.0, "%.2f")

    -- Player Section
    local player_sec = tab:Section("Player", "Right")
    player_sec:Toggle("instant_respawn", "Instant Respawn", false)

end)

-- Main loop
while true do
    local char = player.Character

    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Settings") then
            local s = tool.Settings

            if UI.GetValue("inf_ammo") then
                if s:FindFirstChild("CurrentAmmo") then s.CurrentAmmo.Value = 9999 end
                if s:FindFirstChild("MaxAmmo") then s.MaxAmmo.Value = 9999 end
            end

            if UI.GetValue("no_recoil") then
                if s:FindFirstChild("Recoil") then s.Recoil.Value = 0 end
            end

            if UI.GetValue("no_spread") then
                if s:FindFirstChild("Spread") then s.Spread.Value = 0 end
            end

            if s:FindFirstChild("ShootTime") then
                s.ShootTime.Value = UI.GetValue("shoot_time")
            end

            if s:FindFirstChild("NumberOfShots") then
                s.NumberOfShots.Value = UI.GetValue("num_shots")
            end

            if UI.GetValue("force_auto") then
                if s:FindFirstChild("GunType") then s.GunType.Value = "Auto" end
            end

            if s:FindFirstChild("SwingTimer") then 
				s.SwingTimer.Value = UI.GetValue("swing_time")
            end
        end
    end

    -- Player settings
    playerSettings:SetAttribute("RespawnTime", UI.GetValue("instant_respawn") and 0 or 5)

    task.wait(0.1)
end
