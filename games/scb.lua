local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/topraqk1/helixia-hub/refs/heads/main/Scripts/notification.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId

local Window = Rayfield:CreateWindow({
    Name = "Helixia Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "HELIXIA HUB",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "HelixiaHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Toprak Hub Key",
        Subtitle = "Giriş Anahtarı",
        Note = "Discord'dan key al",
        FileName = "ToprakKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "1234"
    }
})

local HomeTab = Window:CreateTab("Home", "home")

local CreditsSection = HomeTab:CreateSection("Credits")
HomeTab:CreateLabel("Owner: Memati")

local ServerSection = HomeTab:CreateSection("Server")

HomeTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

HomeTab:CreateButton({
    Name = "Join Another Server",
    Callback = function()
        local success, servers = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)
            local response = game:HttpGet(url)
            return HttpService:JSONDecode(response)
        end)
        
        if success and servers and servers.data then
            local availableServers = {}
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers then
                    table.insert(availableServers, server)
                end
            end

            if #availableServers > 0 then
                local randomServer = availableServers[math.random(1, #availableServers)]
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServer.id, LocalPlayer)
            end
        end
    end
})

local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Player")

PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 300},
	Increment = 5,
	Suffix = "WS",
	CurrentValue = 16,
	Callback = function(Value)
		local player = game.Players.LocalPlayer
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = Value
		end
	end,
})

PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 500},
	Increment = 10,
	Suffix = "JP",
	CurrentValue = 50,
	Callback = function(Value)
		local player = game.Players.LocalPlayer
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.JumpPower = Value
		end
	end,
})

local UIS = game:GetService("UserInputService")
local InfiniteJumpEnabled = false

PlayerTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "InfiniteJumpToggle",
	Callback = function(Value)
		InfiniteJumpEnabled = Value
	end,
})

UIS.JumpRequest:Connect(function()
	if InfiniteJumpEnabled then
		local player = game.Players.LocalPlayer
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

local NoclipEnabled = false
PlayerTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Flag = "NoclipToggle",
	Callback = function(Value)
		NoclipEnabled = Value
	end,
})

game:GetService("RunService").Stepped:Connect(function()
	if NoclipEnabled then
		local player = game.Players.LocalPlayer
		if player.Character then
			for _, part in ipairs(player.Character:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

local GameTab = Window:CreateTab("Game", "gamepad-2")

GameTab:CreateSection("Auto Collect")

local collectDelay = 0.1
GameTab:CreateSlider({
	Name = "Collect Delay",
	Range = {0.1, 5},
	Increment = 0.1,
	Suffix = "s",
	CurrentValue = collectDelay,
	Callback = function(Value)
		collectDelay = Value
	end,
})

GameTab:CreateToggle({
	Name = "Auto Collect Cash",
	CurrentValue = false,
	Flag = "AutoCollectToggle",
	Callback = function(Value)
		while Value do
			for i = 1, 10 do
				local args = { i }
				game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestClientCashCollection"):FireServer(unpack(args))
			end
		wait(collectDelay)
		end
	end,
})

local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateSection("Settings")

SettingsTab:CreateButton({
    Name = "Destroy Menu",
    Callback = function()
        Rayfield:Destroy()
    end
})

Rayfield:LoadConfiguration()
