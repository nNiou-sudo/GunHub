--[[
    ESP Library for Roblox Executors
    Compatible with GameSneeze UI Framework
    Features: Box, Name, Distance, Equipped Item, Skeleton, Head Dot, Health, Healthbar
]]

local ESPLibrary = {}

-- ============================================
-- CONFIGURATION
-- ============================================
ESPLibrary.Settings = {
    Enabled = false,
    
    -- Visual Toggles
    Box = true,
    Name = true,
    Distance = true,
    EquippedItem = true,
    Skeleton = true,
    HeadDot = true,
    Health = true,
    Healthbar = true,
    
    -- Colors
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(200, 200, 200),
    EquippedColor = Color3.fromRGB(0, 200, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    HealthColor = Color3.fromRGB(0, 255, 0),
    HealthbarColor = Color3.fromRGB(0, 255, 0),
    HealthbarBackground = Color3.fromRGB(30, 30, 30),
    
    -- Transparency
    BoxTransparency = 0.5,
    NameTransparency = 1,
    DistanceTransparency = 0.8,
    EquippedTransparency = 1,
    SkeletonTransparency = 1,
    HeadDotTransparency = 1,
    HealthTransparency = 1,
    HealthbarTransparency = 1,
    
    -- Filters
    MaxDistance = 5000,
    ShowTeammates = true,
    ShowEnemies = true,
    ShowLocal = false,
}

-- ============================================
-- DRAWING FUNCTIONS (Custom implementations)
-- ============================================
local function DrawBox(p1, p2, color, transparency)
    -- Simple box drawing using Drawing objects or native functions
    -- Fallback to standard drawing methods
    local box = Drawing.new("Square")
    box.Position = p1
    box.Size = p2 - p1
    box.Color = color
    box.Transparency = transparency
    box.Visible = true
    box.Thickness = 1
    box.Filled = false
    return box
end

local function DrawText(text, position, color, transparency, size, center)
    local textObj = Drawing.new("Text")
    textObj.Text = text
    textObj.Position = position
    textObj.Color = color
    textObj.Transparency = transparency
    textObj.Size = size or 14
    textObj.Center = center or false
    textObj.Visible = true
    return textObj
end

local function DrawLine(p1, p2, color, transparency)
    local line = Drawing.new("Line")
    line.From = p1
    line.To = p2
    line.Color = color
    line.Transparency = transparency
    line.Thickness = 1
    line.Visible = true
    return line
end

local function DrawCircle(position, radius, color, transparency, filled)
    local circle = Drawing.new("Circle")
    circle.Position = position
    circle.Radius = radius or 4
    circle.Color = color
    circle.Transparency = transparency
    circle.Filled = filled or true
    circle.Visible = true
    return circle
end

local function WorldToScreen(position)
    -- Standard Roblox WorldToScreen
    local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(position)
    return Vector2.new(vector.X, vector.Y), onScreen
end

-- ============================================
-- MAIN ESP RENDERING
-- ============================================
local function GetPlayerCharacter(player)
    if not player or not player.Character then return nil end
    if not player.Character:FindFirstChild("Humanoid") then return nil end
    if not player.Character:FindFirstChild("Head") then return nil end
    return player.Character
end

local function GetHumanoidRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function IsPlayerTeammate(player)
    if not game.Players.LocalPlayer then return false end
    if player == game.Players.LocalPlayer then return false end
    -- Check team
    if game.Players.LocalPlayer.Team and player.Team then
        return game.Players.LocalPlayer.Team == player.Team
    end
    return false
end

local function GetPlayerHealth(player)
    local character = GetPlayerCharacter(player)
    if not character then return 0 end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return 0 end
    return humanoid.Health
end

local function GetPlayerMaxHealth(player)
    local character = GetPlayerCharacter(player)
    if not character then return 100 end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return 100 end
    return humanoid.MaxHealth
end

local function GetEquippedItem(player)
    local character = GetPlayerCharacter(player)
    if not character then return nil end
    -- Check for tools
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool.Name
        end
    end
    return nil
end

local function GetBones(player)
    local character = GetPlayerCharacter(player)
    if not character then return {} end
    
    local bones = {}
    local boneNames = {"Head", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Torso", "HumanoidRootPart"}
    
    for _, name in ipairs(boneNames) do
        local part = character:FindFirstChild(name)
        if part then
            table.insert(bones, part)
        end
    end
    
    return bones
end

-- ============================================
-- MAIN ESP LOOP
-- ============================================
local espObjects = {}
local espConnections = {}

local function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Visible ~= nil then
            obj.Visible = false
        end
    end
    espObjects = {}
end

local function RenderESP()
    ClearESP()
    
    if not ESPLibrary.Settings.Enabled then return end
    
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local players = game.Players:GetPlayers()
    local maxDist = ESPLibrary.Settings.MaxDistance
    local showTeammates = ESPLibrary.Settings.ShowTeammates
    local showEnemies = ESPLibrary.Settings.ShowEnemies
    local showLocal = ESPLibrary.Settings.ShowLocal
    
    for _, player in ipairs(players) do
        if player == localPlayer and not showLocal then continue end
        
        local character = GetPlayerCharacter(player)
        if not character then continue end
        
        local rootPart = GetHumanoidRootPart(character)
        if not rootPart then continue end
        
        -- Check distance
        local dist = (rootPart.Position - camera.CFrame.Position).Magnitude
        if dist > maxDist then continue end
        
        -- Check teammate filter
        local isTeammate = IsPlayerTeammate(player)
        if isTeammate and not showTeammates then continue end
        if not isTeammate and not showEnemies then continue end
        
        -- World to Screen
        local screenPos, onScreen = WorldToScreen(rootPart.Position)
        if not onScreen then continue end
        
        local head = character:FindFirstChild("Head")
        if not head then continue end
        local headPos, headOnScreen = WorldToScreen(head.Position)
        if not headOnScreen then continue end
        
        -- Calculate box size
        local boxWidth = 120 / (dist / 10 + 1)
        local boxHeight = 200 / (dist / 10 + 1)
        local boxTop = headPos.Y - boxHeight / 2
        local boxLeft = headPos.X - boxWidth / 2
        
        -- Get player health
        local health = GetPlayerHealth(player)
        local maxHealth = GetPlayerMaxHealth(player)
        local healthPercent = health / maxHealth
        
        -- Get equipped item
        local equippedItem = GetEquippedItem(player)
        
        -- ============================================
        -- DRAW ESP ELEMENTS
        -- ============================================
        
        -- 1. BOX
        if ESPLibrary.Settings.Box then
            local box = Drawing.new("Square")
            box.Position = Vector2.new(boxLeft, boxTop)
            box.Size = Vector2.new(boxWidth, boxHeight)
            box.Color = ESPLibrary.Settings.BoxColor
            box.Transparency = ESPLibrary.Settings.BoxTransparency
            box.Thickness = 1.5
            box.Filled = false
            box.Visible = true
            table.insert(espObjects, box)
        end
        
        -- 2. NAME
        if ESPLibrary.Settings.Name then
            local nameObj = Drawing.new("Text")
            nameObj.Text = player.Name
            nameObj.Position = Vector2.new(headPos.X, boxTop - 18)
            nameObj.Color = ESPLibrary.Settings.NameColor
            nameObj.Transparency = ESPLibrary.Settings.NameTransparency
            nameObj.Size = 14
            nameObj.Center = true
            nameObj.Visible = true
            table.insert(espObjects, nameObj)
        end
        
        -- 3. DISTANCE
        if ESPLibrary.Settings.Distance then
            local distObj = Drawing.new("Text")
            distObj.Text = math.floor(dist) .. "m"
            distObj.Position = Vector2.new(headPos.X, boxTop + boxHeight + 2)
            distObj.Color = ESPLibrary.Settings.DistanceColor
            distObj.Transparency = ESPLibrary.Settings.DistanceTransparency
            distObj.Size = 12
            distObj.Center = true
            distObj.Visible = true
            table.insert(espObjects, distObj)
        end
        
        -- 4. EQUIPPED ITEM
        if ESPLibrary.Settings.EquippedItem and equippedItem then
            local itemObj = Drawing.new("Text")
            itemObj.Text = equippedItem
            itemObj.Position = Vector2.new(headPos.X, boxTop + boxHeight + 16)
            itemObj.Color = ESPLibrary.Settings.EquippedColor
            itemObj.Transparency = ESPLibrary.Settings.EquippedTransparency
            itemObj.Size = 12
            itemObj.Center = true
            itemObj.Visible = true
            table.insert(espObjects, itemObj)
        end
        
        -- 5. SKELETON
        if ESPLibrary.Settings.Skeleton then
            local bones = GetBones(player)
            local bonePositions = {}
            
            for _, bone in ipairs(bones) do
                local pos, onScreen = WorldToScreen(bone.Position)
                if onScreen then
                    bonePositions[bone.Name] = pos
                end
            end
            
            -- Draw connections
            local connections = {
                {"Head", "Torso"},
                {"Torso", "LeftArm"},
                {"Torso", "RightArm"},
                {"Torso", "LeftLeg"},
                {"Torso", "RightLeg"},
                {"LeftArm", "RightArm"},
                {"LeftLeg", "RightLeg"},
            }
            
            for _, conn in ipairs(connections) do
                local p1 = bonePositions[conn[1]]
                local p2 = bonePositions[conn[2]]
                if p1 and p2 then
                    local line = Drawing.new("Line")
                    line.From = p1
                    line.To = p2
                    line.Color = ESPLibrary.Settings.SkeletonColor
                    line.Transparency = ESPLibrary.Settings.SkeletonTransparency
                    line.Thickness = 1
                    line.Visible = true
                    table.insert(espObjects, line)
                end
            end
        end
        
        -- 6. HEAD DOT
        if ESPLibrary.Settings.HeadDot then
            local dot = Drawing.new("Circle")
            dot.Position = headPos
            dot.Radius = 4
            dot.Color = ESPLibrary.Settings.HeadDotColor
            dot.Transparency = ESPLibrary.Settings.HeadDotTransparency
            dot.Filled = true
            dot.Visible = true
            table.insert(espObjects, dot)
        end
        
        -- 7. HEALTH TEXT
        if ESPLibrary.Settings.Health then
            local healthObj = Drawing.new("Text")
            healthObj.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
            healthObj.Position = Vector2.new(boxLeft + boxWidth + 8, headPos.Y - 10)
            healthObj.Color = ESPLibrary.Settings.HealthColor
            healthObj.Transparency = ESPLibrary.Settings.HealthTransparency
            healthObj.Size = 12
            healthObj.Center = false
            healthObj.Visible = true
            table.insert(espObjects, healthObj)
        end
        
        -- 8. HEALTHBAR
        if ESPLibrary.Settings.Healthbar then
            local barWidth = 4
            local barHeight = boxHeight
            
            -- Background
            local bg = Drawing.new("Square")
            bg.Position = Vector2.new(boxLeft - 10, boxTop)
            bg.Size = Vector2.new(barWidth, barHeight)
            bg.Color = ESPLibrary.Settings.HealthbarBackground
            bg.Transparency = 0.5
            bg.Filled = true
            bg.Visible = true
            table.insert(espObjects, bg)
            
            -- Health fill
            local fill = Drawing.new("Square")
            fill.Position = Vector2.new(boxLeft - 10, boxTop + barHeight - (barHeight * healthPercent))
            fill.Size = Vector2.new(barWidth, barHeight * healthPercent)
            fill.Color = ESPLibrary.Settings.HealthbarColor
            fill.Transparency = ESPLibrary.Settings.HealthbarTransparency
            fill.Filled = true
            fill.Visible = true
            table.insert(espObjects, fill)
        end
    end
end

-- ============================================
-- UI INTEGRATION (GameSneeze Compatible)
-- ============================================
function ESPLibrary.CreateUI(Window, PageName)
    local page = Window:Page({Name = PageName or "ESP"})
    
    -- Left Column: Main Toggles
    local mainSection = page:Section({
        Name = "ESP Settings",
        Side = "Left",
        Fill = true
    })
    
    -- Master Toggle
    local masterToggle = mainSection:Toggle({
        Name = "Enable ESP",
        Default = false,
        Flag = "esp_enabled",
        callback = function(state)
            ESPLibrary.Settings.Enabled = state
            if not state then
                ClearESP()
            end
        end
    }):Keybind({
        Name = "ESP Keybind",
        Default = Enum.KeyCode.F,
        Mode = "Toggle",
        callback = function(input, state)
            masterToggle:Set(state)
        end
    })
    
    -- Visual Toggles
    mainSection:Label({Name = "Visual Elements", Center = true})
    
    mainSection:Toggle({
        Name = "Box ESP",
        Default = true,
        Flag = "esp_box",
        callback = function(state)
            ESPLibrary.Settings.Box = state
        end
    })
    
    mainSection:Toggle({
        Name = "Name ESP",
        Default = true,
        Flag = "esp_name",
        callback = function(state)
            ESPLibrary.Settings.Name = state
        end
    })
    
    mainSection:Toggle({
        Name = "Distance ESP",
        Default = true,
        Flag = "esp_distance",
        callback = function(state)
            ESPLibrary.Settings.Distance = state
        end
    })
    
    mainSection:Toggle({
        Name = "Equipped Item",
        Default = true,
        Flag = "esp_item",
        callback = function(state)
            ESPLibrary.Settings.EquippedItem = state
        end
    })
    
    mainSection:Toggle({
        Name = "Skeleton ESP",
        Default = false,
        Flag = "esp_skeleton",
        callback = function(state)
            ESPLibrary.Settings.Skeleton = state
        end
    })
    
    mainSection:Toggle({
        Name = "Head Dot",
        Default = true,
        Flag = "esp_dot",
        callback = function(state)
            ESPLibrary.Settings.HeadDot = state
        end
    })
    
    mainSection:Toggle({
        Name = "Health Text",
        Default = true,
        Flag = "esp_health",
        callback = function(state)
            ESPLibrary.Settings.Health = state
        end
    })
    
    mainSection:Toggle({
        Name = "Health Bar",
        Default = true,
        Flag = "esp_healthbar",
        callback = function(state)
            ESPLibrary.Settings.Healthbar = state
        end
    })
    
    -- Right Column: Filters & Colors
    local filterSection = page:Section({
        Name = "Filters & Colors",
        Side = "Right",
        Fill = true
    })
    
    -- Filters
    filterSection:Label({Name = "Filters", Center = true})
    
    filterSection:Toggle({
        Name = "Show Teammates",
        Default = true,
        Flag = "esp_teammates",
        callback = function(state)
            ESPLibrary.Settings.ShowTeammates = state
        end
    })
    
    filterSection:Toggle({
        Name = "Show Enemies",
        Default = true,
        Flag = "esp_enemies",
        callback = function(state)
            ESPLibrary.Settings.ShowEnemies = state
        end
    })
    
    filterSection:Toggle({
        Name = "Show Local Player",
        Default = false,
        Flag = "esp_local",
        callback = function(state)
            ESPLibrary.Settings.ShowLocal = state
        end
    })
    
    filterSection:Slider({
        Name = "Max Distance",
        Min = 500,
        Max = 20000,
        Default = 5000,
        Suffix = "m",
        Flag = "esp_distance",
        callback = function(value)
            ESPLibrary.Settings.MaxDistance = value
        end
    })
    
    -- Colors
    filterSection:Label({Name = "Colors", Center = true})
    
    filterSection:Colorpicker({
        Name = "Box Color",
        Default = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5,
        Flag = "esp_box_color",
        callback = function(color, alpha)
            ESPLibrary.Settings.BoxColor = color
            ESPLibrary.Settings.BoxTransparency = alpha
        end
    })
    
    filterSection:Colorpicker({
        Name = "Name Color",
        Default = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Flag = "esp_name_color",
        callback = function(color, alpha)
            ESPLibrary.Settings.NameColor = color
            ESPLibrary.Settings.NameTransparency = alpha
        end
    })
    
    filterSection:Colorpicker({
        Name = "Skeleton Color",
        Default = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Flag = "esp_skeleton_color",
        callback = function(color, alpha)
            ESPLibrary.Settings.SkeletonColor = color
            ESPLibrary.Settings.SkeletonTransparency = alpha
        end
    })
    
    filterSection:Colorpicker({
        Name = "Health Bar Color",
        Default = Color3.fromRGB(0, 255, 0),
        Transparency = 1,
        Flag = "esp_health_color",
        callback = function(color, alpha)
            ESPLibrary.Settings.HealthbarColor = color
            ESPLibrary.Settings.HealthbarTransparency = alpha
        end
    })
end

-- ============================================
-- INITIALIZATION
-- ============================================
local renderLoop

function ESPLibrary.Start()
    if renderLoop then
        renderLoop:Disconnect()
        renderLoop = nil
    end
    
    renderLoop = game:GetService("RunService").RenderStepped:Connect(function()
        RenderESP()
    end)
end

function ESPLibrary.Stop()
    if renderLoop then
        renderLoop:Disconnect()
        renderLoop = nil
    end
    ClearESP()
end

function ESPLibrary.Toggle(state)
    ESPLibrary.Settings.Enabled = state
    if state then
        ESPLibrary.Start()
    else
        ESPLibrary.Stop()
    end
end

-- ============================================
-- RETURN LIBRARY
-- ============================================
return ESPLibrary
