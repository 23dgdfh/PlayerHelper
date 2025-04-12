local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SECRET_GUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 540)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui


-- Переключение видимости GUI по Ctrl
local guiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
		guiVisible = not guiVisible
		ScreenGui.Enabled = guiVisible
	end
end)




-- Draggable GUI
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Sound
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://17208361335"
toggleSound.Volume = 1
toggleSound.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Player Helper"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.Parent = MainFrame

-- Scrollable Button Container
local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Position = UDim2.new(0, 5, 0, 40)
ButtonContainer.Size = UDim2.new(1, -10, 1, -45)
ButtonContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
ButtonContainer.ScrollBarThickness = 4
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local layout = Instance.new("UIListLayout", ButtonContainer)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Folders
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "VaultESP"
local trailFolder = Instance.new("Folder", workspace)
trailFolder.Name = "VaultTrails"
local glowFolder = Instance.new("Folder", workspace)
glowFolder.Name = "VaultGlows"

-- Create Toggle Button
local function createToggleButton(text, stateRef, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Code
	btn.TextSize = 14
	btn.Parent = ButtonContainer

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(0, 20, 1, 0)
	status.Position = UDim2.new(1, -25, 0, 0)
	status.Text = stateRef.enabled and "✔" or "✖"
	status.TextColor3 = stateRef.enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
	status.Font = Enum.Font.Code
	status.TextSize = 14
	status.BackgroundTransparency = 1
	status.Parent = btn

	btn.MouseButton1Click:Connect(function()
		stateRef.enabled = not stateRef.enabled
		status.Text = stateRef.enabled and "✔" or "✖"
		status.TextColor3 = stateRef.enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
		toggleSound:Play()
		callback(stateRef.enabled)
	end)
end

-- ESP
local espState = {enabled = false}
createToggleButton("Toggle ESP", espState, function(enabled)
	espFolder:ClearAllChildren()
	if enabled then
		RunService:BindToRenderStep("VaultESP", Enum.RenderPriority.Camera.Value + 1, function()
			espFolder:ClearAllChildren()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local box = Instance.new("BoxHandleAdornment")
					box.Adornee = plr.Character
					box.Size = Vector3.new(4, 6, 2)
					box.Color3 = Color3.fromRGB(255, 60, 60)
					box.Transparency = 0.4
					box.AlwaysOnTop = true
					box.ZIndex = 5
					box.Parent = espFolder
				end
			end
		end)
	else
		RunService:UnbindFromRenderStep("VaultESP")
	end
end)

-- Name ESP with Distance
local nameESPState = {enabled = false}
createToggleButton("Toggle Name ESP", nameESPState, function(enabled)
	glowFolder:ClearAllChildren()
	if enabled then
		RunService:BindToRenderStep("NameESP", Enum.RenderPriority.Camera.Value + 2, function()
			glowFolder:ClearAllChildren()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
					local gui = Instance.new("BillboardGui")
					gui.Adornee = plr.Character.Head
					gui.Size = UDim2.new(0, 100, 0, 40)
					gui.StudsOffset = Vector3.new(0, 2, 0)
					gui.AlwaysOnTop = true
					gui.Parent = glowFolder

					local nameLabel = Instance.new("TextLabel")
					nameLabel.Size = UDim2.new(1, 0, 1, 0)
					nameLabel.BackgroundTransparency = 1
					nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					nameLabel.TextStrokeTransparency = 0.5
					nameLabel.TextScaled = true
					nameLabel.Font = Enum.Font.Code
					local distance = math.floor((plr.Character.Head.Position - Camera.CFrame.Position).Magnitude)
					nameLabel.Text = plr.DisplayName .. " [" .. distance .. "m]"
					nameLabel.Parent = gui
				end
			end
		end)
	else
		RunService:UnbindFromRenderStep("NameESP")
		glowFolder:ClearAllChildren()
	end
end)

local tracerFolder = Instance.new("Folder", workspace)
tracerFolder.Name = "VaultTracers"
local highlightFolder = Instance.new("Folder", workspace)
highlightFolder.Name = "VaultHighlights"
local healthBarFolder = Instance.new("Folder", workspace)
healthBarFolder.Name = "VaultHealthBars"

-- Удаление ESP при респавне
LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if espState.enabled then
		RunService:UnbindFromRenderStep("VaultESP")
		espState.enabled = false
		wait(0.1)
		espState.enabled = true
		RunService:BindToRenderStep("VaultESP", Enum.RenderPriority.Camera.Value + 1, function()
			espFolder:ClearAllChildren()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local box = Instance.new("BoxHandleAdornment")
					box.Adornee = plr.Character
					box.Size = Vector3.new(4, 6, 2)
					box.Color3 = Color3.fromRGB(255, 60, 60)
					box.Transparency = 0.4
					box.AlwaysOnTop = true
					box.ZIndex = 5
					box.Parent = espFolder
				end
			end
		end)
	end
end)

-- Добавление UI Corner для Health Bar ESP

local healthESPState = {enabled = false}

createToggleButton("Health Bar ESP", healthESPState, function(enabled)
	healthBarFolder:ClearAllChildren()
	if enabled then
		RunService:BindToRenderStep("HealthBarESP", Enum.RenderPriority.Camera.Value + 3, function()
			healthBarFolder:ClearAllChildren()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
					local gui = Instance.new("BillboardGui")
					gui.Adornee = plr.Character.Head
					gui.Size = UDim2.new(0, 100, 0, 8)
					gui.StudsOffset = Vector3.new(0, 3, 0)
					gui.AlwaysOnTop = true
					
					-- Добавляем UI Corner для округлённых углов
					local uiCorner = Instance.new("UICorner")
					uiCorner.CornerRadius = UDim.new(0, 4)  -- Округляем углы
					uiCorner.Parent = gui

					gui.Parent = healthBarFolder

					local bar = Instance.new("Frame")
					bar.Size = UDim2.new(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth, 0, 1, 0)
					bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
					bar.BorderSizePixel = 0
					bar.Parent = gui

					local bg = Instance.new("Frame")
					bg.Size = UDim2.new(1, 0, 1, 0)
					bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					bg.BorderSizePixel = 0
					bg.ZIndex = -1
					bg.Parent = gui

					-- Добавление UI Corner для фона
					local bgCorner = Instance.new("UICorner")
					bgCorner.CornerRadius = UDim.new(0, 4)  -- Округляем углы фона
					bgCorner.Parent = bg
				end
			end
		end)
	else
		RunService:UnbindFromRenderStep("HealthBarESP")
		healthBarFolder:ClearAllChildren()
	end
end)

local highlightState = {enabled = false}
createToggleButton("Highlight ESP", highlightState, function(enabled)
	highlightFolder:ClearAllChildren()
	if enabled then
		RunService:BindToRenderStep("HighlightESP", Enum.RenderPriority.Camera.Value + 6, function()
			highlightFolder:ClearAllChildren()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local highlight = Instance.new("Highlight")
					highlight.Adornee = plr.Character
					highlight.FillColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
					highlight.Parent = highlightFolder
				end
			end
		end)
	else
		RunService:UnbindFromRenderStep("HighlightESP")
	end
end)

-- Aimbot Logic
local aimbotState = {enabled = false}  -- Изначально аимбот выключен
local aimRadius = 25  -- Радиус захвата цели
local smoothness = 0.12  -- Плавность поворота камеры

local target = nil
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Кнопка для включения/выключения аимбота
createToggleButton("Toggle Aimbot", aimbotState, function(enabled)
    aimbotState.enabled = enabled
    if aimbotState.enabled then
        toggleButton.Text = "Aimbot: ON"
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson  -- Переводим камеру в режим первого лица
    else
        toggleButton.Text = "Aimbot: OFF"
        LocalPlayer.CameraMode = Enum.CameraMode.Classic  -- Возвращаем стандартный режим
    end
end)


-- Aimbot Settings Panel (внутри основного GUI)

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, -10, 0, 20)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Aim Radius"
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.Font = Enum.Font.Code
radiusLabel.TextSize = 14
radiusLabel.Parent = ButtonContainer

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, -10, 0, 25)
radiusBox.Text = tostring(aimRadius)
radiusBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.Font = Enum.Font.Code
radiusBox.TextSize = 14
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = ButtonContainer

local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(1, -10, 0, 20)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Text = "Smoothness"
smoothLabel.TextColor3 = Color3.new(1, 1, 1)
smoothLabel.Font = Enum.Font.Code
smoothLabel.TextSize = 14
smoothLabel.Parent = ButtonContainer

local smoothBox = Instance.new("TextBox")
smoothBox.Size = UDim2.new(1, -10, 0, 25)
smoothBox.Text = tostring(smoothness)
smoothBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
smoothBox.TextColor3 = Color3.new(1, 1, 1)
smoothBox.Font = Enum.Font.Code
smoothBox.TextSize = 14
smoothBox.ClearTextOnFocus = false
smoothBox.Parent = ButtonContainer

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, 0, 0, 30)
applyBtn.Text = "Apply Aimbot Settings"
applyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
applyBtn.TextColor3 = Color3.new(1, 1, 1)
applyBtn.Font = Enum.Font.Code
applyBtn.TextSize = 14
applyBtn.Parent = ButtonContainer

applyBtn.MouseButton1Click:Connect(function()
	local newRadius = tonumber(radiusBox.Text)
	local newSmooth = tonumber(smoothBox.Text)
	if newRadius and newSmooth then
		aimRadius = newRadius
		smoothness = newSmooth
	end
end)




-- Функция для обновления целей
local function updateTarget()
    local closest = nil
    local shortestDist = aimRadius

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local dist = (Camera.CFrame.Position - head.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = head
            end
        end
    end

    target = closest
end

-- Логика аимбота
RunService.RenderStepped:Connect(function()
    if aimbotState.enabled then
        updateTarget()
        if target then
            local camPos = Camera.CFrame.Position
            local headPos = target.Position + Vector3.new(0, 0.1, 0)
            local newCFrame = CFrame.new(camPos, headPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smoothness)
        end
    end
end)





-- Slider для WalkSpeed
-- Slider для WalkSpeed (синий, с отображением значения)
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "WalkSpeed: 16"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.Code
speedLabel.TextSize = 14
speedLabel.Parent = ButtonContainer

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(1, -10, 0, 20)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSlider.Text = ""
speedSlider.AutoButtonColor = false
speedSlider.Parent = ButtonContainer

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.05, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local speedValue = 16

speedSlider.MouseButton1Down:Connect(function()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local pos = UserInputService:GetMouseLocation().X
		local rel = pos - speedSlider.AbsolutePosition.X
		local percent = math.clamp(rel / speedSlider.AbsoluteSize.X, 0, 1)
		speedFill.Size = UDim2.new(percent, 0, 1, 0)
		speedValue = math.floor(16 + (500 - 16) * percent)
		speedLabel.Text = "WalkSpeed: " .. speedValue
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
		end
	end)
	UserInputService.InputEnded:Wait()
	if conn then conn:Disconnect() end
end)

-- Slider для JumpPower (тоже синий, с отображением значения)
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -10, 0, 20)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "JumpPower: 50"
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.Font = Enum.Font.Code
jumpLabel.TextSize = 14
jumpLabel.Parent = ButtonContainer

local jumpSlider = Instance.new("TextButton")
jumpSlider.Size = UDim2.new(1, -10, 0, 20)
jumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpSlider.Text = ""
jumpSlider.AutoButtonColor = false
jumpSlider.Parent = ButtonContainer

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new(0.1, 0, 1, 0)
jumpFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
jumpFill.BorderSizePixel = 0
jumpFill.Parent = jumpSlider

local jumpValue = 50

jumpSlider.MouseButton1Down:Connect(function()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local pos = UserInputService:GetMouseLocation().X
		local rel = pos - jumpSlider.AbsolutePosition.X
		local percent = math.clamp(rel / jumpSlider.AbsoluteSize.X, 0, 1)
		jumpFill.Size = UDim2.new(percent, 0, 1, 0)
		jumpValue = math.floor(50 + (500 - 50) * percent)
		jumpLabel.Text = "JumpPower: " .. jumpValue
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.JumpPower = jumpValue
		end
	end)
	UserInputService.InputEnded:Wait()
	if conn then conn:Disconnect() end
end)



-- Self Destruct Button
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, 0, 0, 30)
destroyButton.Text = "[!] Destroy GUI"
destroyButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
destroyButton.TextColor3 = Color3.new(1, 1, 1)
destroyButton.Font = Enum.Font.Code
destroyButton.TextSize = 14
destroyButton.Parent = ButtonContainer

destroyButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)



-- Подсказка снизу
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -10, 0, 20)
hintLabel.Position = UDim2.new(0, 5, 1, -25)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "[CTRL] - hide/show GUI"
hintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
hintLabel.Font = Enum.Font.Code
hintLabel.TextSize = 13
hintLabel.TextXAlignment = Enum.TextXAlignment.Right
hintLabel.Parent = MainFrame
