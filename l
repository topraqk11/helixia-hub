local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/topraqk1/helixia-hub/refs/heads/main/Scripts/library.lua"))()

local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"

local Window = Rayfield:CreateWindow({
   Name = "Helixia Hub | " .. gameName,
   Icon = "gamepad",
   LoadingTitle = "Helixia Hub",
   LoadingSubtitle = "discord.gg/JRzMYAWvUZ",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HelixiaHub",
      FileName = "Config"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Helixia Hub",
      Subtitle = "Key System",
      Note = "Anahtar almak için özel bilgi verilmemiş",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local MainTab = Window:CreateTab("Home", "home")
MainTab:CreateSection("General")

MainTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      local ts = game:GetService("TeleportService")
      local placeId = game.PlaceId
      ts:Teleport(placeId, game.Players.LocalPlayer)
   end,
})

MainTab:CreateButton({
   Name = "Hop to New Server",
   Callback = function()
      local HttpService = game:GetService("HttpService")
      local TeleportService = game:GetService("TeleportService")
      local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
      
      for _, v in pairs(Servers) do
         if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, game.Players.LocalPlayer)
            break
         end
      end
   end,
})

local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateSection("Player Settings")

local player = game.Players.LocalPlayer
local character = function() return player.Character or player.CharacterAdded:Wait() end

PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
      character():WaitForChild("Humanoid").WalkSpeed = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 5,
   CurrentValue = 50,
   Flag = "Slider1",
   Callback = function(Value)
      character():WaitForChild("Humanoid").JumpPower = Value
   end,
})

local infiniteJumpEnabled = false

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
      infiniteJumpEnabled = Value
      if infiniteJumpEnabled then
         Rayfield:Notify({
            Title = "Infinite Jump",
            Content = "Enabled",
            Duration = 3
         })
      else
         Rayfield:Notify({
            Title = "Infinite Jump",
            Content = "Disabled",
            Duration = 3
         })
      end
   end,
})

local UIS = game:GetService("UserInputService")
UIS.JumpRequest:Connect(function()
   if infiniteJumpEnabled then
      character():WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

local GameTab = Window:CreateTab("Game", "crosshair")
GameTab:CreateSection("ESP")

local espHighlights = {}
local runServiceConnection = nil

GameTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            runServiceConnection = game:GetService("RunService").RenderStepped:Connect(function()
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
                        local character = player.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local existingHighlight = espHighlights[player]

                            if not existingHighlight or existingHighlight.Adornee ~= character then
                                if existingHighlight then
                                    existingHighlight:Destroy()
                                end

                                local highlight = Instance.new("Highlight")
                                highlight.Adornee = character
                                highlight.FillColor = Color3.new(1, 0, 0)
                                highlight.OutlineColor = Color3.new(0, 0, 0)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent = game.CoreGui
                                espHighlights[player] = highlight
                            end
                        end
                    end
                end

                for player, highlight in pairs(espHighlights) do
                    if not player.Character or player.Team == game.Players.LocalPlayer.Team then
                        highlight:Destroy()
                        espHighlights[player] = nil
                    end
                end
            end)
        else
            if runServiceConnection then
                runServiceConnection:Disconnect()
                runServiceConnection = nil
            end
            for _, highlight in pairs(espHighlights) do
                highlight:Destroy()
            end
            espHighlights = {}
        end
    end
})

GameTab:CreateSection("AimBot")
local aimbotEnabled = false

local teamCheck = true
local maxDistance = 500

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Backpack = LocalPlayer:WaitForChild("Backpack")

local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shoot")

local function getClosestEnemyPlayer()
	local closestPlayer = nil
	local shortestDistance = maxDistance

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if not teamCheck or player.Team ~= LocalPlayer.Team then
				local hrp = player.Character.HumanoidRootPart
				local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

local function isOnScreen(part)
	local _, onScreen = Camera:WorldToViewportPoint(part.Position)
	return onScreen
end

local function shootAtPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end

	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local firePos = root.Position + Vector3.new(0, 1.5, 0)

	local targetPart = nil
	for _, part in ipairs(targetPlayer.Character:GetChildren()) do
		if part:IsA("BasePart") and isOnScreen(part) then
			targetPart = part
			break
		end
	end

	if not targetPart then return end

	local args = {
		firePos,
		targetPart.Position,
		targetPart,
		targetPart.Position
	}

	ShootRemote:FireServer(unpack(args))
end

local lastShootTime = 0
local shootDelay = 0.1

RunService.RenderStepped:Connect(function()
	if not aimbotEnabled then return end

	local currentTime = tick()
	if currentTime - lastShootTime < shootDelay then return end

	local target = getClosestEnemyPlayer()
	if target then
		shootAtPlayer(target)
		lastShootTime = currentTime
	end
end)

GameTab:CreateToggle({
	Name = "AimBot",
	CurrentValue = false,
	Callback = function(Value)
		aimbotEnabled = Value

		Rayfield:Notify({
			Title = "AimBot",
			Content = Value and "Enabled, take the gun." or "Disabled",
			Duration = 3
		})
	end
})
