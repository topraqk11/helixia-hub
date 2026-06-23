local HelixiaHUB = loadstring(game:HttpGet("https://raw.githubusercontent.com/topraqk11/Helixia-HUB/refs/heads/main/library/source"))()

local win = HelixiaHUB:CreateWindow({
	Title    = "Helixia HUB",
	SubTitle = "Helixia HUB v2.0 - Enhanced",
	Icon     = "rbxassetid://102278873791566",
	Size     = Vector2.new(860, 540),
})

local themeNames = {}
for name in pairs(HelixiaHUB.Themes) do
	table.insert(themeNames, name)
end
table.sort(themeNames)

-- ===== GENERAL TAB =====
local generalTab = win:CreateTab({
	Name = "General",
	Icon = "rbxassetid://138525646531017",
})

generalTab:CreateSection("Welcome", {
	Description = "Use the tabs on the left to navigate through Helixia HUB's features.",
})

generalTab:CreateButton({
	Text        = "Welcome!",
	Description = "Helixia HUB v2.0 has loaded successfully.",
	Callback    = function()
		HelixiaHUB:Notify({
			Title    = "Helixia HUB",
			Message  = "Script is active and running.",
			Type     = "Success",
			Duration = 3,
		})
	end,
})

generalTab:CreateButton({
	Text        = "Rejoin Server",
	Description = "Teleport to the same server",
	Callback    = function()
		local ts = game:GetService("TeleportService")
		local placeId = game.PlaceId
		ts:Teleport(placeId, game.Players.LocalPlayer)
	end,
})

generalTab:CreateButton({
	Text        = "Hop to New Server",
	Description = "Join a different server with space available",
	Callback    = function()
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

-- ===== PLAYER TAB =====
local playerTab = win:CreateTab({
	Name = "Player",
	Icon = "rbxassetid://98097754960306",
})

playerTab:CreateSection("Movement")

playerTab:CreateSlider({
	Text      = "Walk Speed",
	Min       = 16,
	Max       = 250,
	Default   = 16,
	Increment = 1,
	Suffix    = " stud/s",
	Callback  = function(v)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = v
		end
	end,
})

playerTab:CreateSlider({
	Text      = "Jump Power",
	Min       = 0,
	Max       = 300,
	Default   = 50,
	Increment = 1,
	Suffix    = " power",
	Callback  = function(v)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = v
		end
	end,
})

playerTab:CreateSection("Abilities")

local infiniteJumpEnabled = false
playerTab:CreateToggle({
	Text        = "Infinite Jump",
	Description = "Allows jumping while already in the air",
	Default     = false,
	Callback    = function(v)
		infiniteJumpEnabled = v
		if v then
			local UIS = game:GetService("UserInputService")
			UIS.JumpRequest:Connect(function()
				if infiniteJumpEnabled then
					local char = game.Players.LocalPlayer.Character
					if char and char:FindFirstChild("Humanoid") then
						char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		end
	end,
})

playerTab:CreateToggle({
	Text        = "No Clip",
	Description = "Allows walking through walls and objects",
	Default     = false,
	Callback    = function(v)
		print("No Clip:", v)
	end,
})

playerTab:CreateToggle({
	Text        = "God Mode",
	Description = "Makes the character invincible",
	Default     = false,
	Callback    = function(v)
		print("God Mode:", v)
	end,
})

-- ===== VISUAL TAB =====
local visualTab = win:CreateTab({
	Name = "Visual",
	Icon = "rbxassetid://104214411068348",
})

visualTab:CreateSection("Camera")

visualTab:CreateSlider({
	Text      = "Field of View",
	Min       = 30,
	Max       = 120,
	Default   = 70,
	Increment = 1,
	Suffix    = "°",
	Callback  = function(v)
		workspace.CurrentCamera.FieldOfView = v
	end,
})

visualTab:CreateSection("Environment")

visualTab:CreateToggle({
	Text        = "Fullbright",
	Description = "Removes darkness and shadows from the environment",
	Default     = false,
	Callback    = function(v)
		local Lighting = game:GetService("Lighting")
		if v then
			Lighting.Brightness    = 2
			Lighting.ClockTime     = 14
			Lighting.FogEnd        = 100000
			Lighting.GlobalShadows = false
			Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
		else
			Lighting.Brightness    = 1
			Lighting.ClockTime     = 14
			Lighting.FogEnd        = 100000
			Lighting.GlobalShadows = true
			Lighting.Ambient       = Color3.fromRGB(70, 70, 70)
		end
	end,
})

-- ===== GAME TAB (ESP & AIMBOT) =====
local gameTab = win:CreateTab({
	Name = "Game",
	Icon = "rbxassetid://104214411068348",
})

gameTab:CreateSection("ESP")

local espBoxTable = {}  
local runServiceConnection = nil  

gameTab:CreateToggle({  
	Text = "ESP",  
	Description = "Shows boxes around other players",
	Default = false,  
	Callback = function(Value)  
		if Value then  
			runServiceConnection = game:GetService("RunService").RenderStepped:Connect(function()  
				for _, player in pairs(game:GetService("Players"):GetPlayers()) do  
					if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
						local rootPart = player.Character:FindFirstChild("HumanoidRootPart")  
						local espBox = espBoxTable[player]  
		
						if not espBox then  
							espBox = Instance.new("BoxHandleAdornment")  
							espBox.Size = rootPart.Size + Vector3.new(5, 5, 5)  
							espBox.Adornee = rootPart  
							espBox.AlwaysOnTop = true  
							espBox.ZIndex = 10  
							espBox.Transparency = 0.8  
							espBox.Color3 = Color3.new(1, 0, 0)  
							espBox.Parent = rootPart  
							espBoxTable[player] = espBox  
						end  
					end  
				end  
		
				for player, espBox in pairs(espBoxTable) do  
					if not player.Character or player.Team == game.Players.LocalPlayer.Team or not player.Character:FindFirstChild("HumanoidRootPart") then  
						espBox:Destroy()  
						espBoxTable[player] = nil  
					end  
				end  
			end)  
		else  
			if runServiceConnection then  
				runServiceConnection:Disconnect()  
				runServiceConnection = nil  
			end  
			for _, espBox in pairs(espBoxTable) do  
				espBox:Destroy()  
			end  
			espBoxTable = {}  
		end  
	end  
})

gameTab:CreateSection("Aimbot")

local aimbotEnabled = false  

local fov = 1000  
local maxDistance = 400  
local maxTransparency = 0.1  
local teamCheck = true  

local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local Players = game:GetService("Players")  
local Cam = workspace.CurrentCamera  

local FOVring = Drawing.new("Circle")  
FOVring.Visible = false  
FOVring.Thickness = 2  
FOVring.Color = Color3.fromRGB(128, 0, 128)  
FOVring.Filled = false  
FOVring.Radius = fov  
FOVring.Position = Cam.ViewportSize / 2  

local function updateDrawings()  
	FOVring.Position = Cam.ViewportSize / 2  
end  

local function lookAt(target)  
	local lookVector = (target - Cam.CFrame.Position).unit  
	Cam.CFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)  
end  

local function calculateTransparency(distance)  
	return (1 - (distance / fov)) * maxTransparency  
end  

local function isPlayerAlive(player)  
	local character = player.Character  
	return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0  
end  

local function isVisible(part)  
	local origin = Cam.CFrame.Position  
	local direction = (part.Position - origin).unit * maxDistance  
	local ray = Ray.new(origin, direction)  
	local hit = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character)  
	return hit and hit:IsDescendantOf(part.Parent)  
end  

local function getClosestVisiblePlayerInFOV(trg_part)  
	local nearest, last = nil, math.huge  
	local playerMousePos = Cam.ViewportSize / 2  
	local localPlayer = Players.LocalPlayer  

	for _, player in ipairs(Players:GetPlayers()) do  
		if player ~= localPlayer and (not teamCheck or player.Team ~= localPlayer.Team) then  
			if isPlayerAlive(player) then  
				local part = player.Character and player.Character:FindFirstChild(trg_part)  
				if part and isVisible(part) then  
					local ePos = Cam:WorldToViewportPoint(part.Position)  
					local distance = (Vector2.new(ePos.X, ePos.Y) - playerMousePos).Magnitude  
					if distance < last and distance < fov and distance < maxDistance then  
						last = distance  
						nearest = player  
					end  
				end  
			end  
		end  
	end  
	return nearest  
end  

local function aimbotFunction()  
	if not aimbotEnabled then return end  
	updateDrawings()  
	local target = getClosestVisiblePlayerInFOV("Head")  
	if target and target.Character and target.Character:FindFirstChild("Head") then  
		lookAt(target.Character.Head.Position)  
		local ePos = Cam:WorldToViewportPoint(target.Character.Head.Position)  
		local distance = (Vector2.new(ePos.X, ePos.Y) - (Cam.ViewportSize / 2)).Magnitude  
		FOVring.Transparency = calculateTransparency(distance)  
	else  
		FOVring.Transparency = maxTransparency  
	end  
end  

gameTab:CreateToggle({
	Text = "Aimbot",
	Description = "Auto aim to closest player",
	Default = false,
	Callback = function(Value)
		aimbotEnabled = Value
		FOVring.Visible = Value

		if Value then
			RunService:BindToRenderStep("AimbotUpdate", Enum.RenderPriority.Camera.Value, aimbotFunction)
			HelixiaHUB:Notify({
				Title    = "Aimbot",
				Message  = "Enabled",
				Type     = "Success",
				Duration = 2,
			})
		else
			RunService:UnbindFromRenderStep("AimbotUpdate")
			FOVring.Visible = false
			HelixiaHUB:Notify({
				Title    = "Aimbot",
				Message  = "Disabled",
				Type     = "Info",
				Duration = 2,
			})
		end
	end,
})

gameTab:CreateSlider({
	Text      = "Aimbot FOV",
	Min       = 100,
	Max       = 2000,
	Default   = 1000,
	Increment = 50,
	Suffix    = " px",
	Callback  = function(v)
		fov = v
		FOVring.Radius = fov
	end,
})

gameTab:CreateSlider({
	Text      = "Max Distance",
	Min       = 100,
	Max       = 1000,
	Default   = 400,
	Increment = 50,
	Suffix    = " stud",
	Callback  = function(v)
		maxDistance = v
	end,
})

gameTab:CreateToggle({
	Text        = "Team Check",
	Description = "Only target enemy team",
	Default     = true,
	Callback    = function(v)
		teamCheck = v
	end,
})

gameTab:CreateSection("Weapons")

local infiniteAmmoConnection = nil

local function infiniteAmmoFunction()
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		local gui = playerGui:FindFirstChild("GUI")
		if gui and gui:FindFirstChild("Client") and gui.Client:FindFirstChild("Variables") then
			local variables = gui.Client.Variables
			if variables:FindFirstChild("ammocount") and variables:FindFirstChild("ammocount2") then
				variables.ammocount.Value = 99
				variables.ammocount2.Value = 99
			end
		end
	end
end

gameTab:CreateToggle({
	Text        = "Infinite Ammo",
	Description = "Unlimited ammunition",
	Default     = false,
	Callback    = function(Value)
		if Value and not infiniteAmmoConnection then
			infiniteAmmoConnection = game:GetService("RunService").Stepped:Connect(infiniteAmmoFunction)
			HelixiaHUB:Notify({
				Title    = "Infinite Ammo",
				Message  = "Enabled",
				Type     = "Success",
				Duration = 2,
			})
		elseif not Value and infiniteAmmoConnection then
			infiniteAmmoConnection:Disconnect()
			infiniteAmmoConnection = nil
			HelixiaHUB:Notify({
				Title    = "Infinite Ammo",
				Message  = "Disabled",
				Type     = "Info",
				Duration = 2,
			})
		end
	end,
})

local originalValues = {
	ReloadTime = {},
	EReloadTime = {}
}

gameTab:CreateToggle({
	Text        = "Fast Reload",
	Description = "Speed up weapon reload time",
	Default     = false,
	Callback    = function(Value)
		for _, weapon in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
			if weapon:FindFirstChild("ReloadTime") then
				if Value then
					if not originalValues.ReloadTime[weapon] then
						originalValues.ReloadTime[weapon] = weapon.ReloadTime.Value
					end
					weapon.ReloadTime.Value = 0.01
				else
					if originalValues.ReloadTime[weapon] then
						weapon.ReloadTime.Value = originalValues.ReloadTime[weapon]
					else
						weapon.ReloadTime.Value = 0.8
					end
				end
			end

			if weapon:FindFirstChild("EReloadTime") then
				if Value then
					if not originalValues.EReloadTime[weapon] then
						originalValues.EReloadTime[weapon] = weapon.EReloadTime.Value
					end
					weapon.EReloadTime.Value = 0.01
				else
					if originalValues.EReloadTime[weapon] then
						weapon.EReloadTime.Value = originalValues.EReloadTime[weapon]
					else
						weapon.EReloadTime.Value = 0.8
					end
				end
			end
		end

		HelixiaHUB:Notify({
			Title    = "Fast Reload",
			Message  = Value and "Enabled" or "Disabled",
			Type     = "Success",
			Duration = 2,
		})
	end,
})

-- ===== SETTINGS TAB =====
local settingsTab = win:CreateTab({
	Name = "Settings",
	Icon = "rbxassetid://119673892841288",
})

settingsTab:CreateSection("Theme")

settingsTab:CreateDropdown({
	Text     = "Select Theme",
	Options  = themeNames,
	Default  = "Midnight",
	Callback = function(v)
		HelixiaHUB.Theme:SetPalette(v)
		HelixiaHUB:Notify({
			Title    = "Theme Changed",
			Message  = v .. " theme applied.",
			Type     = "Success",
			Duration = 2,
		})
	end,
})

settingsTab:CreateSection("Window")

settingsTab:CreateToggle({
	Text        = "Background Blur",
	Description = "Toggles the blur effect behind the window",
	Default     = true,
	Callback    = function(v)
		local blur = game:GetService("Lighting"):FindFirstChild("HelixiaHUBBlur")
		if blur then
			blur.Enabled = v
		end
	end,
})

settingsTab:CreateSection("About")

settingsTab:CreateButton({
	Text        = "Helixia HUB v2.0 - Enhanced",
	Description = "Built with the HelixiaHUB library + Rayfield features.",
	Callback    = function()
		HelixiaHUB:Notify({
			Title    = "Helixia HUB",
			Message  = "v2.0 Enhanced — Features merged successfully!",
			Type     = "Info",
			Duration = 3,
		})
	end,
})

-- ===== STARTUP NOTIFICATION =====
task.delay(0.8, function()
	HelixiaHUB:Notify({
		Title    = "Helixia HUB",
		Message  = "Welcome! Enhanced script loaded with Game features.",
		Type     = "Success",
		Duration = 5,
	})
end)
