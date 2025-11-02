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

-- 🕒 Auto Collect Delay Slider
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

-- 💰 Auto Collect Toggle
local autoCollectEnabled = false

GameTab:CreateToggle({
	Name = "Auto Collect Cash",
	CurrentValue = false,
	Flag = "AutoCollectToggle",
	Callback = function(Value)
		autoCollectEnabled = Value

		if autoCollectEnabled then
			task.spawn(function()
				while autoCollectEnabled do
					for i = 1, 10 do
						if not autoCollectEnabled then break end
						local args = { i }
						game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestClientCashCollection"):FireServer(unpack(args))
						task.wait(collectDelay)
					end
				end
			end)
		end
	end,
})

------------------------------------------------------------
-- 🔒 AUTO LOCK SİSTEMİ
------------------------------------------------------------

GameTab:CreateSection("Auto Lock")

local player = game.Players.LocalPlayer
local myBase = nil

-- ✅ Oyuncunun kendi base'ini bulma
for i = 1, 8 do
	local base = workspace:WaitForChild("Bases"):FindFirstChild("base" .. i)
	if base then
		local textLabel = base:FindFirstChild("BaseNameParent", true)
		if textLabel and textLabel:FindFirstChild("BaseNameContainer") then
			local gui = textLabel.BaseNameContainer:FindFirstChild("SurfaceGui")
			if gui and gui:FindFirstChild("TextLabel") then
				if gui.TextLabel.Text == player.Name then
					myBase = base
					break
				end
			end
		end
	end
end

-- Eğer oyuncunun base'i bulunamadıysa hata mesajı
if not myBase then
	warn("Oyuncunun base'i bulunamadı.")
end

-- 🕓 Label: Timer değeri
local autoLockLabel = GameTab:CreateLabel("To unlock: ...")

-- Label’ı güncelleyen döngü
task.spawn(function()
	while task.wait(1) do
		if myBase then
			local timerLabel = myBase:FindFirstChild("Lock", true)
			if timerLabel and timerLabel:FindFirstChild("Text") and timerLabel.Text:FindFirstChild("BillboardGui") then
				local timeLabel = timerLabel.Text.BillboardGui:FindFirstChild("Timer")
				if timeLabel and timeLabel:IsA("TextLabel") then
					autoLockLabel:Set("To unlock: " .. (timeLabel.Text ~= "" and timeLabel.Text or "Ready!"))
				end
			end
		end
	end
end)

-- 🔁 Auto Lock Toggle
local autoLockEnabled = false

GameTab:CreateToggle({
	Name = "Auto Lock",
	CurrentValue = false,
	Flag = "AutoLockToggle",
	Callback = function(Value)
		autoLockEnabled = Value

		if autoLockEnabled and myBase then
			task.spawn(function()
				while autoLockEnabled do
					local lockPart = myBase:FindFirstChild("Lock", true)
					if lockPart and lockPart:FindFirstChild("Text") and lockPart.Text:FindFirstChild("BillboardGui") then
						local timeLabel = lockPart.Text.BillboardGui:FindFirstChild("Timer")

						if timeLabel and timeLabel.Text == "" then
							-- Oyuncunun mevcut konumunu kaydet
							local char = player.Character
							if char and char:FindFirstChild("HumanoidRootPart") then
								local oldCFrame = char.HumanoidRootPart.CFrame
								
								-- Lock partına ışınla
								char.HumanoidRootPart.CFrame = lockPart.CFrame + Vector3.new(0, 3, 0)

								task.wait(0.2) -- kısa bekleme
								
								-- Eski konuma geri ışınla
								char.HumanoidRootPart.CFrame = oldCFrame
							end
						end
					end
					task.wait(0.5)
				end
			end)
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
