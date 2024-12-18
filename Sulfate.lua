-- dont touch shit here
local function checkLoader()
    if isfile and readfile then
        return isfile("Sulfate.cnfg")
    end

    return LocalPlayer:GetAttribute(FileName) ~= nil
end

if not checkLoader() then
    LocalPlayer:Kick("Run The Loader First")
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window =
    Rayfield:CreateWindow(
    {
        Name = "sulfate.lol",
        LoadingTitle = "Sulfate.lol",
        LoadingSubtitle = "By Valk",
        Theme = "Amethyst",
        ConfigurationSaving = {
            Enabled = true,
            FileName = "Sulfate"
        }
    }
)

Rayfield:Notify(
    {
        Title = "❤️To Celebrate Christmas!",
        Content = "Key System is disabled. Happy New Year and Christmas!",
        Duration = 6.5
    }
)

local MainTab = Window:CreateTab("Main", "rewind")
local PlayerTab = Window:CreateTab("Player", "rewind")
local VisualsTab = Window:CreateTab("Visuals", "rewind")
local SettingsTab = Window:CreateTab("Settings", "rewind")
local AboutTab = Window:CreateTab("About", "rewind")
local CreditsTab = Window:CreateTab("Credits", "rewind")

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.Parent = character
end

local function setupPlayerHighlight(player)
    player.CharacterAdded:Connect(
        function(character)
            character:WaitForChild("Head")
            createHighlight(character)
        end
    )
    if player.Character then
        createHighlight(player.Character)
    end
end

VisualsTab:CreateButton(
    {
        Name = "Enable ESP",
        Callback = function()
            local Players = game:GetService("Players")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    setupPlayerHighlight(player)
                end
            end
            Players.PlayerAdded:Connect(setupPlayerHighlight)
        end
    }
)

VisualsTab:CreateButton(
    {
        Name = "FPS/Ping Display",
        Callback = function()
            local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local ScreenGui = Instance.new("ScreenGui", PlayerGui)
            local FPSLabel = Instance.new("TextLabel", ScreenGui)
            local PingLabel = Instance.new("TextLabel", ScreenGui)

            FPSLabel.Size = UDim2.new(0, 200, 0, 50)
            FPSLabel.Position = UDim2.new(1, -210, 0, 10)
            FPSLabel.BackgroundTransparency = 1
            FPSLabel.Font = Enum.Font.SourceSansBold
            FPSLabel.TextColor3 = Color3.fromRGB(128, 0, 128)
            FPSLabel.TextScaled = true
            FPSLabel.Text = "FPS: Calculating..."

            PingLabel.Size = UDim2.new(0, 200, 0, 50)
            PingLabel.Position = UDim2.new(1, -210, 0, 60)
            PingLabel.BackgroundTransparency = 1
            PingLabel.Font = Enum.Font.SourceSansBold
            PingLabel.TextColor3 = Color3.fromRGB(128, 0, 128)
            PingLabel.TextScaled = true
            PingLabel.Text = "Ping: Calculating..."

            local RunService = game:GetService("RunService")

            RunService.RenderStepped:Connect(
                function()
                    local fps = math.floor(1 / RunService.RenderStepped:Wait())
                    local ping =
                        math.floor(
                        game:GetService("Stats"):FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild(
                            "Data Ping"
                        ):GetValue() * 1000
                    )
                    FPSLabel.Text = "FPS: " .. fps
                    PingLabel.Text = "Ping: " .. ping .. " ms"
                end
            )
        end
    }
)

MainTab:CreateButton(
    {
        Name = "CamLock (Mobile Supported)",
        Callback = function()
            local StarterGui = game:GetService("StarterGui")
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local camera = game.Workspace.CurrentCamera
            local localPlayer = Players.LocalPlayer
            local mouse = localPlayer:GetMouse()

            local lockDistance = 200
            local rightClickHolding = false
            local isMobile = UserInputService.TouchEnabled
            local aimbotEnabled = true
            local projectileOffset = false
            local targetPartName = "Head"

            function getVisibleEnemy()
                local closestEnemy = nil
                local shortestDistance = lockDistance
                local playerTeam = localPlayer.Team

                for _, player in pairs(Players:GetPlayers()) do
                    if
                        player ~= localPlayer and player.Character and
                            player.Character:FindFirstChild("HumanoidRootPart")
                     then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        local team = player.Team

                        if humanoid and humanoid.Health > 0 and team ~= playerTeam then
                            local distance =
                                (localPlayer.Character.HumanoidRootPart.Position -
                                player.Character.HumanoidRootPart.Position).Magnitude
                            if distance < shortestDistance then
                                local screenPosition, onScreen =
                                    camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                                if onScreen and not isBehindWall(player.Character.HumanoidRootPart) then
                                    closestEnemy = player.Character.HumanoidRootPart
                                    shortestDistance = distance
                                end
                            end
                        end
                    end
                end
                return closestEnemy
            end

            function isBehindWall(targetPart)
                local origin = camera.CFrame.Position
                local direction = (targetPart.Position - origin).Unit
                local ray = Ray.new(origin, direction * lockDistance)
                local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character})
                return hitPart and hitPart:IsDescendantOf(targetPart.Parent) == false
            end

            function aimAtTarget(target)
                if target then
                    local targetPart = target.Parent:FindFirstChild(targetPartName)
                    if targetPart then
                        local targetPosition = targetPart.Position
                        local cameraPosition = camera.CFrame.Position
                        local direction = (targetPosition - cameraPosition).Unit
                        camera.CFrame = CFrame.new(cameraPosition, cameraPosition + direction)
                    end
                end
            end

            mouse.Button2Down:Connect(
                function()
                    rightClickHolding = true
                end
            )

            mouse.Button2Up:Connect(
                function()
                    rightClickHolding = false
                end
            )

            local screenGui = Instance.new("ScreenGui", game.CoreGui)
            local projectileButton = Instance.new("TextButton")
            projectileButton.Size = UDim2.new(0, 150, 0, 50)
            projectileButton.Position = UDim2.new(0, 50, 0, 50)
            projectileButton.Text = "Projectile Offset: OFF"
            projectileButton.Parent = screenGui
            projectileButton.MouseButton1Click:Connect(
                function()
                    projectileOffset = not projectileOffset
                    projectileButton.Text = "Projectile Offset: " .. (projectileOffset and "ON" or "OFF")
                end
            )

            RunService.RenderStepped:Connect(
                function()
                    if (rightClickHolding or isMobile) and aimbotEnabled then
                        local enemy = getVisibleEnemy()
                        aimAtTarget(enemy)
                    end
                end
            )

            Rayfield:Notify(
                {
                    Title = "Module Enabled",
                    Content = "Camlock Enabled",
                    Duration = 5
                }
            )
        end
    }
)

local targetPartName = "Head"

MainTab:CreateDropdown(
    {
        Name = "Aim Route",
        Options = {"Head", "Torso", "UpperTorso", "HumanoidRootPart"},
        CurrentOption = "Head",
        Callback = function(selectedOption)
            targetPartName = selectedOption
        end
    }
)

PlayerTab:CreateToggle(
    {
        Name = "Infinite Jump",
        CurrentValue = false,
        Callback = function(state)
            local InfiniteJump = state
            local UIS = game:GetService("UserInputService")

            UIS.JumpRequest:Connect(
                function()
                    if InfiniteJump then
                        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(
                            "Jumping"
                        )
                    end
                end
            )

            local message = state and "Enabled" or "Disabled"
            Rayfield:Notify(
                {
                    Title = "Infinite Jump",
                    Content = "Infinite Jump is now " .. message,
                    Duration = 3
                }
            )
        end
    }
)

VisualsTab:CreateButton(
    {
        Name = "Rainbow Atmosphere",
        Callback = function()
            local lighting = game:GetService("Lighting")
            local rainbowEffect = Instance.new("ColorCorrectionEffect")
            rainbowEffect.Name = "RainbowAtmosphere"
            rainbowEffect.Parent = lighting
            rainbowEffect.TintColor = Color3.new(1, 0, 0)

            local function rainbowCycle()
                while rainbowEffect and rainbowEffect.Parent == lighting do
                    for i = 0, 360, 1 do
                        local hue = i / 360
                        local color = Color3.fromHSV(hue, 1, 1)
                        rainbowEffect.TintColor = color
                        wait(0.03)
                    end
                end
            end

            task.spawn(rainbowCycle)

            -- Notification
            Rayfield:Notify(
                {
                    Title = "Module Enabled",
                    Content = "Rainbow Atmosphere Enabled!",
                    Duration = 5
                }
            )
        end
    }
)

PlayerTab:CreateButton(
    {
        Name = "Enable Forcefield",
        Callback = function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if not character:FindFirstChild("ForceField") then
                local forceField = Instance.new("ForceField")
                forceField.Parent = character
                Rayfield:Notify(
                    {
                        Title = "Module Enabled",
                        Content = "ForceField Enabled!",
                        Duration = 3
                    }
                )
            else
                Rayfield:Notify(
                    {
                        Title = "Already Active",
                        Content = "You already have a Forcefield!",
                        Duration = 3
                    }
                )
            end
        end
    }
)

VisualsTab:CreateButton(
    {
        Name = "Enable Custom Skybox",
        Callback = function()
            Rayfield:Notify(
                {
                    Title = "Module Error",
                    Content = "Module Has Bugs!",
                    Duration = 3
                }
            )
        end
    }
)

PlayerTab:CreateToggle(
    {
        Name = "Spin",
        CurrentValue = false,
        Callback = function(state)
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

            if state then
                local spinVelocity = Instance.new("BodyAngularVelocity")
                spinVelocity.Name = "PlayerSpin"
                spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                spinVelocity.AngularVelocity = Vector3.new(0, 25, 0)
                spinVelocity.Parent = HumanoidRootPart

                Rayfield:Notify(
                    {
                        Title = "Module Enabled",
                        Content = "Spin Enabld!",
                        Duration = 3
                    }
                )
            else
                if HumanoidRootPart:FindFirstChild("PlayerSpin") then
                    HumanoidRootPart.PlayerSpin:Destroy()
                end

                Rayfield:Notify(
                    {
                        Title = "Module Disabled",
                        Content = "Spin Disabled.",
                        Duration = 3
                    }
                )
            end
        end
    }
)

SettingsTab:CreateToggle(
    {
        Name = "Disco Lights",
        CurrentValue = false,
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            local RunService = game:GetService("RunService")

            _G.Disco = state

            if state then
                coroutine.wrap(
                    function()
                        while _G.Disco do
                            Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
                            Lighting.OutdoorAmbient = Color3.new(math.random(), math.random(), math.random())
                            wait(0.1)
                        end
                    end
                )()

                Rayfield:Notify(
                    {
                        Title = "Module Enabled!",
                        Content = "Disco Enabled!",
                        Duration = 3
                    }
                )
            else
                Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)

                Rayfield:Notify(
                    {
                        Title = "Module Disabled",
                        Content = "Disco Disabled",
                        Duration = 3
                    }
                )
            end
        end
    }
)

PlayerTab:CreateToggle(
    {
        Name = "Rainbow Character",
        CurrentValue = false,
        Callback = function(state)
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            _G.RainbowActive = state

            coroutine.wrap(
                function()
                    while _G.RainbowActive do
                        for _, part in ipairs(character:GetChildren()) do
                            if part:IsA("BasePart") or part:IsA("MeshPart") then
                                part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                            end
                        end
                        wait(0.1)
                    end
                end
            )()

            if not state then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Color = Color3.new(1, 1, 1)
                    end
                end
                Rayfield:Notify(
                    {
                        Title = "Rainbow Disabled",
                        Content = "Character colors reset.",
                        Duration = 3
                    }
                )
            end
        end
    }
)

PlayerTab:CreateButton(
    {
        Name = "Spawn Disco Ball",
        Callback = function()
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")

            local discoBall = Instance.new("Part")
            discoBall.Size = Vector3.new(7, 7, 7)
            discoBall.Shape = Enum.PartType.Ball
            discoBall.BrickColor = BrickColor.new("Bright violet")
            discoBall.Material = Enum.Material.Neon
            discoBall.Anchored = false
            discoBall.CanCollide = false
            discoBall.Parent = workspace

            local weld = Instance.new("WeldConstraint", discoBall)
            weld.Part0 = discoBall
            weld.Part1 = rootPart

            Rayfield:Notify(
                {
                    Title = "Module Enabled",
                    Content = "Disco Ball Enabled!",
                    Duration = 3
                }
            )
        end
    }
)

VisualsTab:CreateToggle(
    {
        Name = "Neon World",
        CurrentValue = false,
        Callback = function(state)
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    if state then
                        part.OriginalMaterial = part.Material
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    else
                        part.Material = part.OriginalMaterial or Enum.Material.Plastic
                    end
                end
            end

            Rayfield:Notify(
                {
                    Title = "Module Enabled",
                    Content = state and "Neon World enabled!" or "Neon World disabled.",
                    Duration = 3
                }
            )
        end
    }
)

PlayerTab:CreateToggle(
    {
        Name = "Rainbow Trail",
        CurrentValue = false,
        Callback = function(state)
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")

            if state then
                local trail = Instance.new("Trail", rootPart)
                trail.Lifetime = 1
                trail.Color =
                    ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1))
                }
                trail.Attachment0 = Instance.new("Attachment", rootPart)
                trail.Attachment1 = Instance.new("Attachment", rootPart)

                Rayfield:Notify(
                    {
                        Title = "Module Enabled",
                        Content = "Trail Enabled!",
                        Duration = 3
                    }
                )
            else
                for _, trail in ipairs(rootPart:GetChildren()) do
                    if trail:IsA("Trail") then
                        trail:Destroy()
                    end
                end
                Rayfield:Notify(
                    {
                        Title = "Module Disabled",
                        Content = "trail removed.",
                        Duration = 3
                    }
                )
            end
        end
    }
)

VisualsTab:CreateButton(
    {
        Name = "Colorful",
        Callback = function()
            local lighting = game:GetService("Lighting")

            local bloom = Instance.new("BloomEffect")
            bloom.Parent = lighting
            bloom.Intensity = 0.1
            bloom.Size = 24
            bloom.Threshold = 0.8

            local colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = lighting
            colorCorrection.Saturation = 1.3
            colorCorrection.Contrast = 0.3
            colorCorrection.Brightness = 0.1

            local depthOfField = Instance.new("DepthOfFieldEffect")
            depthOfField.Parent = lighting
            depthOfField.FarIntensity = 0.5
            depthOfField.NearIntensity = 0.5
            depthOfField.FocusDistance = 15

            local antiAliasing = Instance.new("AntiAliasingEffect")
            antiAliasing.Parent = lighting
            antiAliasing.Samples = Enum.AntiAliasingSamples.Five -- Choose how many samples to reduce jagged edges

            -- Optional: A simple dynamic color shift to make the world feel even more colorful
            local function dynamicColors()
                while true do
                    local hue = tick() % 10 / 10 -- Smooth, dynamic color shift
                    lighting.Ambient = Color3.fromHSV(hue, 1, 1)
                    wait(0.1)
                end
            end

            -- Start the dynamic color shift in a separate thread
            task.spawn(dynamicColors)

            -- Notification to let the user know the effect is enabled
            Rayfield:Notify(
                {
                    Title = "Colorful Shaders",
                    Content = "The game environment is now enhanced with vibrant shaders!",
                    Duration = 5
                }
            )
        end
    }
)

MainTab:CreateButton(
    {
        Name = "WallBang",
        Callback = 
        Rayfield:Notify(
                {
                    Title = "Module Error",
                    Content = "WallBang Is Bugged",
                    Duration = 5
                }
            )
        end

VisualsTab:CreateButton(
    {
        Name = "Watermark",
        Callback = function()
            local screenGui = Instance.new("ScreenGui")
            local watermarkText = Instance.new("TextLabel")

            screenGui.Name = "WatermarkGui"
            screenGui.Parent = game.CoreGui

            watermarkText.Parent = screenGui
            watermarkText.Size = UDim2.new(0, 300, 0, 100)
            watermarkText.Position = UDim2.new(0, 10, 0, 10)
            watermarkText.Text = "Sulfate.lol"
            watermarkText.Font = Enum.Font.Fantasy
            watermarkText.TextSize = 48
            watermarkText.TextColor3 = Color3.fromRGB(175, 0, 255)
            watermarkText.TextStrokeTransparency = 0.5
            watermarkText.BackgroundTransparency = 1
        end
    }
)

SettingsTab:CreateToggle(
    {
        Name = "Toggle Day/Night",
        CurrentValue = false,
        Callback = function(state)
            local Lighting = game:GetService("Lighting")

            if state then
                Lighting.TimeOfDay = "00:00:00"
                Rayfield:Notify(
                    {
                        Title = "Night Mode",
                        Content = "The game is now nighttime!",
                        Duration = 3
                    }
                )
            else
                Lighting.TimeOfDay = "14:00:00"
                Rayfield:Notify(
                    {
                        Title = "Day Mode",
                        Content = "The game is now daytime!",
                        Duration = 3
                    }
                )
            end
        end
    }
)

PlayerTab:CreateToggle(
    {
        Name = "Fire VFX",
        CurrentValue = false,
        Callback = function(state)
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if state then
                local fireTrail = Instance.new("Fire")
                fireTrail.Size = 5
                fireTrail.Heat = 10
                fireTrail.Name = "FireTrail"

                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        fireTrail:Clone().Parent = part
                    end
                end

                Rayfield:Notify(
                    {
                        Title = "Module Enabled",
                        Content = "VFX Enabled!",
                        Duration = 3
                    }
                )
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:FindFirstChild("FireTrail") then
                        part.FireTrail:Destroy()
                    end
                end

                Rayfield:Notify(
                    {
                        Title = "Module Disabled",
                        Content = "VFX Disabled.",
                        Duration = 3
                    }
                )
            end
        end
    }
)

Player:CreateDropdown(
    {
        Name = "Teleport to Player",
        Options = {"Player1", "Player2", "Player3"},
        Callback = function(playerName)
            local LocalPlayer = game.Players.LocalPlayer
            local targetPlayer = game.Players:FindFirstChild(playerName)

            if targetPlayer and targetPlayer.Character then
                LocalPlayer.Character:MoveTo(targetPlayer.Character:WaitForChild("HumanoidRootPart").Position)
                Rayfield:Notify(
                    {
                        Title = "Teleported",
                        Content = "You teleported to " .. playerName,
                        Duration = 3
                    }
                )
            else
                Rayfield:Notify(
                    {
                        Title = "Error",
                        Content = "Player not found or unavailable.",
                        Duration = 3
                    }
                )
            end
        end
    }
)

SettingsTab:CreateSlider(
    {
        Name = "Gravity Modifier",
        Min = 0,
        Max = 196.2,
        CurrentValue = 196.2,
        Callback = function(value)
            workspace.Gravity = value

            Rayfield:Notify(
                {
                    Title = "Gravity Updated",
                    Content = "Gravity set to " .. value,
                    Duration = 3
                }
            )
        end
    }
)

PlayerTab:CreateButton(
    {
        Name = "Launch Yourself",
        Callback = function()
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")

            rootPart.Velocity = Vector3.new(0, 200, 0)

            Rayfield:Notify(
                {
                    Title = "Launched!",
                    Content = "You’ve been launched into the air!",
                    Duration = 3
                }
            )
        end
    }
)

PlayerTab:CreateButton(
    {
        Name = "Serverhop",
        Callback = function()
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local PlaceId = game.PlaceId

            local servers = {}
            local function getServerList()
                local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = HttpService:JSONDecode(game:HttpGet(url))
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
            end

            getServerList()

            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServer)
            else
                Rayfield:Notify(
                    {
                        Title = "Serverhop",
                        Content = "No available servers found.",
                        Duration = 5
                    }
                )
            end
        end
    }
)

PlayerTab:CreateSlider(
    {
        Name = "Walkspeed",
        Range = {16, 500},
        Increment = 1,
        Suffix = "Speed",
        Default = 16,
        Callback = function(value)
            local localPlayer = game:GetService("Players").LocalPlayer
            local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    }
)
