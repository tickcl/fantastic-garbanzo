local Player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Connections = {}
local function AddConnection(conn)
	table.insert(Connections, conn)
end

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if type(k) == "number" then
			v.Parent = obj
		else
			obj[k] = v
		end
	end
	return obj
end

local Modules = {
	Fly = {Key = Enum.KeyCode.F, State = false, connection = nil, gyro = nil, velocity = nil, bindMode = "toggle"},
	Noclip = {Key = Enum.KeyCode.V, State = false, bindMode = "toggle"},
	Speed = {Key = Enum.KeyCode.X, State = true, Value = 16, bindMode = "toggle"},
	Spin = {Key = Enum.KeyCode.R, State = false, Speed = 10, bindMode = "toggle"},
	Aimbot = {Key = Enum.KeyCode.Q, State = false, bindMode = "toggle"},
	ESP = {Key = Enum.KeyCode.H, State = false, bindMode = "toggle"},
	InfiniteJump = {Key = Enum.KeyCode.Space, State = false, bindMode = "toggle"},
	FakeLag = {Key = Enum.KeyCode.Z, State = false, teleportDistance = 10, teleportInterval = 1, fakeLagCooldown = 0.2, connection = nil, lastPosition = nil, lastTime = tick(), bindMode = "toggle"},
	Jitter = {Key = Enum.KeyCode.C, State = false, jitterStrength = 2, jitterSpeed = 0.1, connection = nil, bindMode = "toggle"},
	Peek = {Key = Enum.KeyCode.E, State = false, mode = "hold", isPeeking = false, initialPosition = nil, indicator = nil, indicatorColor = Color3.fromRGB(255,0,0), bindMode = "hold"}
}

local Gui = Create("ScreenGui", {
	Name = "VIPERR",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = CoreGui
})

local NotificationFrame = Create("Frame", {
    Name = "Notifications",
    BackgroundTransparency = 1,
    Size = UDim2.new(0.2, 0, 0.5, 0),
    Position = UDim2.new(1, -10, 0.9, 0),
    AnchorPoint = Vector2.new(1, 1),
    Parent = Gui,
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Створення ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = Player:WaitForChild("PlayerGui")

-- Додавання ефекту блюру
local blurEffect = Instance.new("BlurEffect")
blurEffect.Parent = game.Lighting
blurEffect.Size = 0

-- Створення текстового елемента "VIPERR"
local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.Text = "VIPERR"
textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
textLabel.Position = UDim2.new(0.7, 0, 0.4, 0)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.TextSize = 72
textLabel.Font = Enum.Font.GothamBlack
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.BackgroundTransparency = 1
textLabel.TextTransparency = 1

-- Створення шкали прогресу
local progressBar = Instance.new("Frame")
progressBar.Parent = screenGui
progressBar.BackgroundColor3 = Color3.fromRGB(27, 27, 27) -- Колір заповнення
progressBar.Size = UDim2.new(0, 0, 0.01, 0)
progressBar.Position = UDim2.new(0.5, 0, 0.9, 0)
progressBar.AnchorPoint = Vector2.new(0.5, 0.5)


-- Анимація блюру
local blurTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local blurInTween = TweenService:Create(blurEffect, blurTweenInfo, { Size = 20 })

-- Анимація з'явлення тексту
local textTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textAppearTween = TweenService:Create(textLabel, textTweenInfo, { TextTransparency = 0 })

-- Запуск анимацій
blurInTween:Play()
blurInTween.Completed:Connect(function()
    textAppearTween:Play()
    textAppearTween.Completed:Connect(function()
        coroutine.wrap(function()
            wait(3) -- Час для завершення прогресу

            -- Анімація зникнення тексту
            local textDisappearTween = TweenService:Create(textLabel, textTweenInfo, { TextTransparency = 1 })

            -- Анімація зникнення блюру
            local blurOutTween = TweenService:Create(blurEffect, blurTweenInfo, { Size = 0 })

            -- Відтворення анімацій
            textDisappearTween:Play()
            blurOutTween:Play()

            -- Після завершення анімацій видаляємо елементи
            textDisappearTween.Completed:Connect(function()
                screenGui:Destroy()
                blurEffect:Destroy()

                -- Тут починається головна частина скрипта
                print("Скрипт успішно завантажено!")
            end)
        end)()
    end)
end)

local function Notify(title, state)
    local Notification = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30), -- Темний фон
        BackgroundTransparency = 0.5, 
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Parent = NotificationFrame,
        Create("UIStroke", {
            Color = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0), -- Зелений або червоний для ENABLED/DISABLED
            Thickness = 2,
            Transparency = 0.4,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Прибираємо закруглення для більш "жорсткого" вигляду
        Create("UICorner", {CornerRadius = UDim.new(0, 0)}),
        Create("Frame", { -- Додано лінію в стилі GameSense
            BackgroundColor3 = Color3.fromRGB(95, 144, 255), -- Яскравий колір (ціан)
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0
        }),
        Create("TextLabel", {
            Text = " " .. string.upper(title) .. " " .. (state and "ENABLED" or "DISABLED"),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14, -- Трошки більший шрифт для кращого вигляду
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    -- Замість простої анімації, використовується плавне переміщення
    TS:Create(Notification, TweenInfo.new(0.3), {Position = UDim2.new(1, -10, 0, 0)}):Play()
    task.delay(3, function()
        TS:Create(Notification, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        Notification:Destroy()
    end)
end


local Watermark = Create("Frame", {
    Name = "Watermark",
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    BackgroundTransparency = 0.6,
    Size = UDim2.new(0, 220, 0, 35),
    Position = UDim2.new(0.98, -220, 0.02, 0),
    AnchorPoint = Vector2.new(1, 0),
    Parent = Gui,
    Create("UIStroke", {
        Color = Color3.fromRGB(1, 1, 1), -- Cyan stroke for modern look
        Thickness = 2,
        Transparency = 0.6,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }),
    Create("TextLabel", {
        Text = "VIPERR | PREMIUM",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.8, -- Text stroke for clearer visibility
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    })
})

-- Різкокольорова лінія зверху (як у Скіт)
Create("Frame", {
    Name = "TopLine",
    BackgroundColor3 = Color3.fromRGB(240, 240, 240), -- Red for vibrant look
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    Parent = Watermark,
    BorderSizePixel = 0
})


local Menu = Create("Frame", {
	Name = "Menu",
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BorderSizePixel = 0,
	Size = UDim2.new(0, 500, 0, 450),
	Position = UDim2.new(0.5, -250, 0.5, -225),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Parent = Gui,
	Active = true,
	Draggable = true,
	Create("UIStroke", {
		Color = Color3.fromRGB(25, 25, 25),
		Thickness = 2,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}),
	Create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0
	}),
	Create("TextLabel", {
		Text = "VIPERR PREMIUM",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Center
	}),
	Create("ScrollingFrame", {
		Name = "ScrollFrame",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		CanvasSize = UDim2.new(0, 0, 0, 600),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		}),
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 15)
		})
	})
})

local SpeedFrame = Create("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 60),
	Parent = Menu.ScrollFrame,
	Create("TextLabel", {
		Text = "WALKSPEED",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left
	}),
	Create("Frame", {
		Name = "Track",
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 30),
		Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
		Create("Frame", {
			Name = "Fill",
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0.5, 0, 1, 0),
			Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})
	}),
	Create("TextLabel", {
		Name = "Value",
		Text = tostring(Modules.Speed.Value),
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -60, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right
	})
})
local Slider = SpeedFrame.Track
local Fill = Slider.Fill
local ValueLabel = SpeedFrame.Value
local Dragging = false

Slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		local X = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(X, 0, 1, 0)
		Modules.Speed.Value = math.floor(16 + (X * 84))
		ValueLabel.Text = tostring(Modules.Speed.Value)
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = Modules.Speed.Value
		end
	end
end)
AddConnection(Slider.InputBegan)

UIS.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local X = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(X, 0, 1, 0)
		Modules.Speed.Value = math.floor(16 + (X * 84))
		ValueLabel.Text = tostring(Modules.Speed.Value)
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = Modules.Speed.Value
		end
	end
end)
AddConnection(UIS.InputChanged)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end)
AddConnection(UIS.InputEnded)

local ESPHandles = {}

-- Функція для створення ESP для гравця
local function CreateESP(player)
	if ESPHandles[player] then return end

	-- Додати ESP до персонажа гравця
	local function AddESP(character)
		local handles = {}
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				-- Створення BillboardGui для відображення частини тіла
				local billboard = Create("BillboardGui", {
					Size = UDim2.new(2, 0, 2, 0), -- Розмір для покращення видимості
					Adornee = part,
					AlwaysOnTop = true,
					MaxDistance = 1000,
					Parent = part
				})
				
				-- Визначення кольору ESP для виділення частини тіла
				local frame = Create("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 2,
					BorderColor3 = Color3.fromRGB(255, 255, 255),
					Parent = billboard
				})

				-- Додати ESP для голови, червоний для помітності
				if part.Name == "Head" then
					local headBillboard = Create("BillboardGui", {
						Size = UDim2.new(2, 0, 2, 0),
						Adornee = part,
						AlwaysOnTop = true,
						MaxDistance = 1000,
						Parent = part
					})
					
					local headFrame = Create("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 0, 0),
						BackgroundTransparency = 0.5,
						BorderSizePixel = 2,
						BorderColor3 = Color3.fromRGB(255, 255, 255),
						Parent = headBillboard
					})
					table.insert(handles, headBillboard)
				end

				table.insert(handles, billboard)
			end
		end

		-- Додати відображення нікнейму над головою
		local nameTag = Create("BillboardGui", {
			Size = UDim2.new(4, 0, 1, 0),
			Adornee = character:WaitForChild("Head"),
			AlwaysOnTop = true,
			MaxDistance = 1000,
			Parent = character:WaitForChild("Head")
		})

		local nameFrame = Create("TextLabel", {
			Text = player.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, -1, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = nameTag
		})
		table.insert(handles, nameTag)

		-- Додати відображення здоров'я ліворуч від гравця
		local healthBar = Create("BillboardGui", {
			Size = UDim2.new(2, 0, 0.5, 0),
			Adornee = character:WaitForChild("Head"),
			AlwaysOnTop = true,
			MaxDistance = 1000,
			Parent = character:WaitForChild("Head")
		})

		local healthFrame = Create("Frame", {
			Size = UDim2.new(1, 0, 0.1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 255, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 2,
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			Parent = healthBar
		})

		-- Оновлення здоров'я
		local function UpdateHealth()
			local healthPercentage = character:WaitForChild("Humanoid").Health / character:WaitForChild("Humanoid").MaxHealth
			healthFrame.Size = UDim2.new(healthPercentage, 0, 0.1, 0)
		end

		-- Підключаємо оновлення здоров'я
		character:WaitForChild("Humanoid").HealthChanged:Connect(UpdateHealth)
		UpdateHealth()

		table.insert(handles, healthBar)

		ESPHandles[player] = handles
	end

	if player.Character then
		AddESP(player.Character)
	end

	-- Автоматично додавати ESP для нових гравців
	player.CharacterAdded:Connect(AddESP)
end

local function ClearESP()
	for _, handles in pairs(ESPHandles) do
		for _, obj in ipairs(handles) do
			obj:Destroy()
		end
	end
	table.clear(ESPHandles)
end

local AimbotEnabled = false
local Camera = Workspace.CurrentCamera
local TargetKey = Enum.KeyCode.Q
local AimSmoothness = 0.1

local function GetClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local otherRootPart = otherPlayer.Character.HumanoidRootPart
			local screenPoint, onScreen = Camera:WorldToViewportPoint(otherRootPart.Position)
			if onScreen then
				local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
				local distance = (mousePosition - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
				if distance < shortestDistance then
					closestPlayer = otherPlayer
					shortestDistance = distance
				end
			end
		end
	end
	return closestPlayer
end

local function AimAtTarget(target)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetRootPart = target.Character.HumanoidRootPart
		local direction = (targetRootPart.Position - Camera.CFrame.Position).Unit
		local currentLook = Camera.CFrame.LookVector
		local newLook = currentLook:Lerp(direction, AimSmoothness)
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
	end
end

AddConnection(UIS.InputBegan:Connect(function(input)
	if input.KeyCode == TargetKey then
		AimbotEnabled = not AimbotEnabled
		Notify("Aimbot", AimbotEnabled)
	end
end))

AddConnection(RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local closestPlayer = GetClosestPlayer()
		if closestPlayer then
			AimAtTarget(closestPlayer)
		end
	end
end))

-- NoClip Fix
AddConnection(RunService.Stepped:Connect(function()
	if Modules.Noclip.State and Player.Character then
		for _, v in ipairs(Player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end))

local function RebindPrompt(moduleName, data, button)
	local RebindUI = Create("Frame", {
		BackgroundColor3 = Color3.new(0.1,0.1,0.1),
		Size = UDim2.new(0,300,0,180),
		Position = UDim2.new(0.5, -150, 0.5, -90),
		Parent = Gui,
		Active = true,
		ZIndex = 10,
		Create("UICorner", {CornerRadius = UDim.new(0, 0)})
	})
	local Title = Create("TextLabel", {
		Text = "Rebind: " .. moduleName,
		Size = UDim2.new(1,0,0,30),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = RebindUI
	})
	local Info = Create("TextLabel", {
		Text = "Press a key for bind\nCurrent mode: " .. data.bindMode,
		Size = UDim2.new(1,0,0,40),
		Position = UDim2.new(0,0,0,35),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Parent = RebindUI
	})
	local ModeBtn = Create("TextButton", {
		Text = "Toggle Mode",
		Size = UDim2.new(0,120,0,30),
		Position = UDim2.new(0.5, -60, 0, 80),
		BackgroundColor3 = Color3.new(0.2,0.2,0.2),
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = RebindUI,
		Create("UICorner", {CornerRadius = UDim.new(0, 0)})
	})
	ModeBtn.MouseButton1Click:Connect(function()
		data.bindMode = (data.bindMode == "toggle") and "hold" or "toggle"
		Info.Text = "Press a key for bind\nCurrent mode: " .. data.bindMode
	end)
	local CloseBtn = Create("TextButton", {
		Text = "Close",
		Size = UDim2.new(0,60,0,25),
		Position = UDim2.new(1, -70, 0, 5),
		BackgroundColor3 = Color3.new(0.3,0,0),
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = RebindUI,
		Create("UICorner", {CornerRadius = UDim.new(0, 0)})
	})
	local binding = true
	local conn = UIS.InputBegan:Connect(function(input)
		if binding and input.UserInputType == Enum.UserInputType.Keyboard then
			data.Key = input.KeyCode
			button.Text = "[" .. input.KeyCode.Name .. "]"
			Notify(moduleName .. " bind", true)
			binding = false
			RebindUI:Destroy()
			conn:Disconnect()
		end
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		binding = false
		RebindUI:Destroy()
		conn:Disconnect()
	end)
end

local function CreateModule(name, data)
	local Frame = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = Menu.ScrollFrame,
		Create("TextLabel", {
			Text = name:upper(),
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.6, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextButton", {
			Name = "ToggleButton",
			Text = "[" .. (data.Key and data.Key.Name or "NONE") .. "]",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			Size = UDim2.new(0.3, 0, 1, 0),
			Position = UDim2.new(0.7, 0, 0, 0),
			Create("UICorner", {CornerRadius = UDim.new(0.15, 0)})
		})
	})
	Frame.ToggleButton.MouseButton1Click:Connect(function()
		data.State = not data.State
		Frame.ToggleButton.BackgroundColor3 = data.State and Color3.new(0, 0.5, 0) or Color3.new(0.15, 0.15, 0.15)
		Notify(name, data.State)
		if name == "ESP" then
			if data.State then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= Player then
						CreateESP(player)
					end
				end
			else
				ClearESP()
			end
		elseif name == "Spin" then
			if data.State then
				spawn(function()
					while data.State do
						if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
							Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(data.Speed), 0)
						end
						wait(0.1)
					end
				end)
			end
		elseif name == "InfiniteJump" then
			if data.State then
				if Player.Character and Player.Character:FindFirstChild("Humanoid") then
					Player.Character.Humanoid.JumpPower = 50
					Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
			else
				if Player.Character and Player.Character:FindFirstChild("Humanoid") then
					Player.Character.Humanoid.JumpPower = 50
					Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				end
			end
		elseif name == "FakeLag" then
			if data.State then
				data.lastTime = tick()
				data.connection = RunService.RenderStepped:Connect(function()
					if tick() - data.lastTime >= data.teleportInterval then
						if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
							data.lastPosition = Player.Character.HumanoidRootPart.Position
							local backOffset = Player.Character.HumanoidRootPart.CFrame.LookVector * -data.teleportDistance
							Player.Character.HumanoidRootPart.CFrame = CFrame.new(data.lastPosition + backOffset)
							task.wait(data.fakeLagCooldown)
							Player.Character.HumanoidRootPart.CFrame = CFrame.new(data.lastPosition)
							data.lastTime = tick()
						end
					end
				end)
			else
				if data.connection then
					data.connection:Disconnect()
					data.connection = nil
				end
			end
		elseif name == "Jitter" then
			if data.State then
				data.connection = RunService.RenderStepped:Connect(function()
					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
						local hrp = Player.Character.HumanoidRootPart
						local randomOffset = Vector3.new(
							(math.random() * data.jitterStrength - data.jitterStrength / 2),
							0,
							(math.random() * data.jitterStrength - data.jitterStrength / 2)
						)
						hrp.CFrame = hrp.CFrame * CFrame.new(randomOffset)
					end
				end)
			else
				if data.connection then
					data.connection:Disconnect()
					data.connection = nil
				end
			end
		elseif name == "Fly" then
			if data.State then
				local Char = Player.Character
				if not Char then return end
				local Humanoid = Char:FindFirstChildOfClass("Humanoid")
				local Root = Char:FindFirstChild("HumanoidRootPart")
				if not Humanoid or not Root then return end
				Humanoid.PlatformStand = true
				data.gyro = Create("BodyGyro", {
					P = 10000,
					MaxTorque = Vector3.new(100000, 100000, 100000),
					Parent = Root
				})
				data.velocity = Create("BodyVelocity", {
					Velocity = Vector3.new(0, 0, 0),
					MaxForce = Vector3.new(100000, 100000, 100000),
					Parent = Root
				})
				data.connection = UIS.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.W then
						data.velocity.Velocity = Root.CFrame.LookVector * 50
					elseif input.KeyCode == Enum.KeyCode.S then
						data.velocity.Velocity = Root.CFrame.LookVector * -50
					elseif input.KeyCode == Enum.KeyCode.A then
						data.velocity.Velocity = Root.CFrame.RightVector * -50
					elseif input.KeyCode == Enum.KeyCode.D then
						data.velocity.Velocity = Root.CFrame.RightVector * 50
					elseif input.KeyCode == Enum.KeyCode.Space then
						data.velocity.Velocity = Vector3.new(0, 50, 0)
					elseif input.KeyCode == Enum.KeyCode.LeftShift then
						data.velocity.Velocity = Vector3.new(0, -50, 0)
					end
				end)
				AddConnection(data.connection)
			else
				if data.connection then
					data.connection:Disconnect()
					data.connection = nil
				end
				if Player.Character and Player.Character:FindFirstChild("Humanoid") then
					Player.Character.Humanoid.PlatformStand = false
				end
				if data.gyro then
					data.gyro:Destroy()
					data.gyro = nil
				end
				if data.velocity then
					data.velocity:Destroy()
					data.velocity = nil
				end
			end
		end
	end)
	Frame.ToggleButton.MouseButton2Click:Connect(function()
		RebindPrompt(name, data, Frame.ToggleButton)
	end)
end

for name, data in pairs(Modules) do
	if name ~= "Speed" then
		CreateModule(name, data)
	end
end

local function toggleModule(moduleName)
	local data = Modules[moduleName]
	data.State = not data.State
	Notify(moduleName, data.State)
	if moduleName == "ESP" then
		if data.State then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= Player then
					CreateESP(player)
				end
			end
		else
			ClearESP()
		end
	elseif moduleName == "Spin" then
		if data.State then
			spawn(function()
				while data.State do
					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
						Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(data.Speed), 0)
					end
					wait(0.1)
				end
			end)
		end
	elseif moduleName == "InfiniteJump" then
		if data.State then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.JumpPower = 50
				Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			end
		else
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.JumpPower = 50
				Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			end
		end
	elseif moduleName == "FakeLag" then
		if data.State then
			data.lastTime = tick()
			data.connection = RunService.RenderStepped:Connect(function()
				if tick() - data.lastTime >= data.teleportInterval then
					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
						data.lastPosition = Player.Character.HumanoidRootPart.Position
						local backOffset = Player.Character.HumanoidRootPart.CFrame.LookVector * -data.teleportDistance
						Player.Character.HumanoidRootPart.CFrame = CFrame.new(data.lastPosition + backOffset)
						task.wait(data.fakeLagCooldown)
						Player.Character.HumanoidRootPart.CFrame = CFrame.new(data.lastPosition)
						data.lastTime = tick()
					end
				end
			end)
		else
			if data.connection then
				data.connection:Disconnect()
				data.connection = nil
			end
		end
	elseif moduleName == "Jitter" then
		if data.State then
			data.connection = RunService.RenderStepped:Connect(function()
				if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = Player.Character.HumanoidRootPart
					local randomOffset = Vector3.new(
						(math.random() * data.jitterStrength - data.jitterStrength / 2),
						0,
						(math.random() * data.jitterStrength - data.jitterStrength / 2)
					)
					hrp.CFrame = hrp.CFrame * CFrame.new(randomOffset)
				end
			end)
		else
			if data.connection then
				data.connection:Disconnect()
				data.connection = nil
			end
		end
	elseif moduleName == "Fly" then
		if data.State then
			local Char = Player.Character
			if not Char then return end
			local Humanoid = Char:FindFirstChildOfClass("Humanoid")
			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Humanoid or not Root then return end
			Humanoid.PlatformStand = true
			data.gyro = Create("BodyGyro", {
				P = 10000,
				MaxTorque = Vector3.new(100000, 100000, 100000),
				Parent = Root
			})
			data.velocity = Create("BodyVelocity", {
				Velocity = Vector3.new(0, 0, 0),
				MaxForce = Vector3.new(100000, 100000, 100000),
				Parent = Root
			})
			data.connection = UIS.InputBegan:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.W then
					data.velocity.Velocity = Root.CFrame.LookVector * 50
				elseif input.KeyCode == Enum.KeyCode.S then
					data.velocity.Velocity = Root.CFrame.LookVector * -50
				elseif input.KeyCode == Enum.KeyCode.A then
					data.velocity.Velocity = Root.CFrame.RightVector * -50
				elseif input.KeyCode == Enum.KeyCode.D then
					data.velocity.Velocity = Root.CFrame.RightVector * 50
				elseif input.KeyCode == Enum.KeyCode.Space then
					data.velocity.Velocity = Vector3.new(0, 50, 0)
				elseif input.KeyCode == Enum.KeyCode.LeftShift then
					data.velocity.Velocity = Vector3.new(0, -50, 0)
				end
			end)
			AddConnection(data.connection)
		else
			if data.connection then
				data.connection:Disconnect()
				data.connection = nil
			end
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.PlatformStand = false
			end
			if data.gyro then
				data.gyro:Destroy()
				data.gyro = nil
			end
			if data.velocity then
				data.velocity:Destroy()
				data.velocity = nil
			end
		end
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for name, data in pairs(Modules) do
		if name ~= "Aimbot" and name ~= "Peek" then
			if input.KeyCode == data.Key then
				if data.bindMode == "toggle" then
					toggleModule(name)
				elseif data.bindMode == "hold" then
					if not data.State then
						toggleModule(name)
					end
				end
			end
		end
	end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for name, data in pairs(Modules) do
		if name ~= "Aimbot" and name ~= "Peek" then
			if input.KeyCode == data.Key and data.bindMode == "hold" then
				if data.State then
					toggleModule(name)
				end
			end
		end
	end
end)

AddConnection(UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Modules.Peek.Key then
		if Modules.Peek.mode == "hold" then
			if not Modules.Peek.isPeeking then
				if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
					Modules.Peek.initialPosition = Player.Character.HumanoidRootPart.Position
					Modules.Peek.isPeeking = true
					if not Modules.Peek.indicator then
						local part = Instance.new("Part")
						part.Size = Vector3.new(4, 0.1, 4)
						part.Position = Player.Character.HumanoidRootPart.Position - Vector3.new(0, Player.Character.HumanoidRootPart.Size.Y/2 + 0.1, 0)
						part.Anchored = true
						part.CanCollide = false
						part.Shape = Enum.PartType.Cylinder
						part.Material = Enum.Material.Neon
						part.Color = Modules.Peek.indicatorColor
						part.CFrame = CFrame.new(part.Position) * CFrame.Angles(math.rad(90), 0, 0)
						part.Parent = Workspace
						Modules.Peek.indicator = part
					end
				end
			end
		end
	end
end))

AddConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Modules.Peek.Key and Modules.Peek.mode ~= "hold" then
		Modules.Peek.State = not Modules.Peek.State
		Notify("Peek", Modules.Peek.State)
	end
end))

AddConnection(UIS.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Modules.Peek.Key and Modules.Peek.mode == "hold" and Modules.Peek.isPeeking then
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Modules.Peek.initialPosition then
			Player.Character.HumanoidRootPart.CFrame = CFrame.new(Modules.Peek.initialPosition)
		end
		Modules.Peek.isPeeking = false
		if Modules.Peek.indicator then
			Modules.Peek.indicator:Destroy()
			Modules.Peek.indicator = nil
		end
	end
end))

AddConnection(UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Modules.InfiniteJump.Key and Modules.InfiniteJump.State then
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end))

local MenuOpen = false
AddConnection(UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.I then
		if MenuOpen then
			TS:Create(Menu, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 1.5, 0)}):Play()
		else
			TS:Create(Menu, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 0.5, 0)}):Play()
		end
		MenuOpen = not MenuOpen
	end
end))

AddConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Modules.Aimbot.Key then return end
	if input.KeyCode == Modules.Peek.Key then return end
end))

Player.CharacterAdded:Connect(function(Char)
	local Humanoid = Char:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = Modules.Speed.Value
end)

for _, conn in ipairs(Connections) do end

AddConnection(UIS.InputBegan:Connect(function(input)
	if input.KeyCode == TargetKey then end
end))

-- Unload function
local UnloadModule = Create("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 40),
	Parent = Menu.ScrollFrame,
	Create("TextButton", {
		Name = "UnloadButton",
		Text = "UNLOAD",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundColor3 = Color3.new(0.8, 0, 0),
		Size = UDim2.new(1, 0, 1, 0)
	})
})
UnloadModule.UnloadButton.MouseButton1Click:Connect(function()
	Notify("Unloading", true)
	for _, conn in ipairs(Connections) do
		if conn.Disconnect then
			conn:Disconnect()
		end
	end
	Gui:Destroy()
end)
