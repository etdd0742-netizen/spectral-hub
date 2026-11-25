-- [[ SPECTRAL HUB v11 ]] --
-- Красивое переключение скриптов (выгрузка старых меню)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Spectral Hub | MM2",
    LoadingTitle = "Спектрал на связи...",
    LoadingSubtitle = "Загружаем меню",
    ConfigurationSaving = { Enabled = true, FolderName = "SpectralHub", FileName = "Config" },
    KeySystem = false
})

-- === ФУНКЦИЯ ЗАПУСКА СКРИПТОВ (С ВЫГРУЗКОЙ СТАРЫХ) ===
local function LoadScriptWithTransition(name, url)
    -- 1. Плавно закрываем текущее меню Spectral
    Rayfield:Notify({ Title = "Переключение", Content = "Загрузка " .. name .. "...", Duration = 2 })
    
    -- Уничтожаем старое меню Rayfield (все ScreenGui от Rayfield)
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        if gui.Name:match("Rayfield") or gui.Name:match("Spectral") then
            gui:Destroy()
        end
    end

    -- 2. Небольшая пауза для анимации
    task.wait(0.5)

    -- 3. Запускаем новый скрипт
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    -- 4. Восстанавливаем хаб, если скрипт упал (опционально)
    if not success then
        Rayfield:Notify({ Title = "Ошибка", Content = "Не удалось загрузить: " .. tostring(err), Duration = 5 })
        -- Перезапуск хаба после ошибки (чтобы не остаться без меню)
        task.wait(1)
        loadstring(game:HttpGet("https://sirius.menu/rayfield"))() 
    end
end

-- === ВКЛАДКА 1: СКРИПТЫ ===
local ScriptTab = Window:CreateTab("📜 Скрипты", 4483362458)
ScriptTab:CreateSection("Твои скрипты")

ScriptTab:CreateButton({
    Name = "▶ Запустить: Космос",
    Callback = function() LoadScriptWithTransition("Космос", "https://rockscript.xyz/nnscript.lua") end
})

ScriptTab:CreateButton({
    Name = "▶ Запустить: Шитара",
    Callback = function() LoadScriptWithTransition("Шитара", "https://api.luarmor.net/files/v4/loaders/7ff98f5720dfa9d35225cfaa2c907cf0.lua") end
})

ScriptTab:CreateSection("Внешние загрузчики")

ScriptTab:CreateButton({
    Name = "▶ Mozql Hub",
    Callback = function() LoadScriptWithTransition("Mozql Hub", "https://raw.githubusercontent.com/snxpzscripts/mm2/refs/heads/main/MozqlHub") end
})

ScriptTab:CreateButton({
    Name = "▶ SP Hub",
    Callback = function() LoadScriptWithTransition("SP Hub", "https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/Loader") end
})

-- === ВКЛАДКА 2: ВЫЖИВАНИЕ ===
local SurvTab = Window:CreateTab("🛡️ Выживание", 4483362458)
SurvTab:CreateSection("Режим Скользкой Рыбы")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local noclipConn = nil
SurvTab:CreateToggle({
    Name = "Noclip (Проход сквозь стены)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

local speedConn = nil
SurvTab:CreateToggle({
    Name = "Speed Hack (Ускорение)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            speedConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 60 end
            end)
        else
            if speedConn then speedConn:Disconnect() end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

local infJumpConn = nil
SurvTab:CreateToggle({
    Name = "Infinite Jump (Бесконечный прыжок)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            infJumpConn = UIS.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if infJumpConn then infJumpConn:Disconnect() end
        end
    end
})

SurvTab:CreateButton({
    Name = "Мгновенный Респавн (Если убили)",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
        task.wait(0.5)
        LocalPlayer:LoadCharacter()
        Rayfield:Notify({ Title = "Выживание", Content = "Возрождение...", Duration = 2 })
    end
})

-- === ВКЛАДКА 3: АВТОФАРМ ===
local FarmTab = Window:CreateTab("💰 Автофарм", 4483362458)
FarmTab:CreateSection("Сбор ресурсов")

local coinFarmConn = nil
FarmTab:CreateToggle({
    Name = "Автофарм Монет",
    CurrentValue = false,
    Callback = function(state)
        if state then
            coinFarmConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local closestCoin = nil
                local minDist = 500
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name:match("Coin")) then
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < minDist then minDist = dist closestCoin = obj end
                    end
                end
                if closestCoin then root.CFrame = CFrame.new(closestCoin.Position) end
            end)
        else
            if coinFarmConn then coinFarmConn:Disconnect() end
        end
    end
})

FarmTab:CreateSection("Бой (Aimbot)")
local aimbotEnabled = false
local aimbotFOV = 150
local aimbotPart = "Head"
local aimbotSmooth = 0.2

FarmTab:CreateToggle({
    Name = "Включить Аимбот",
    CurrentValue = false,
    Callback = function(state) aimbotEnabled = state end
})

FarmTab:CreateDropdown({
    Name = "Куда целиться",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Callback = function(option) aimbotPart = option[1] end
})

FarmTab:CreateSlider({
    Name = "Радиус (FOV)",
    Range = {10, 360},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 150,
    Callback = function(val) aimbotFOV = val end
})

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local closest = nil
    local shortestDist = aimbotFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(aimbotPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then shortestDist = dist closest = targetPart end
                end
            end
        end
    end
    if closest then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimbotSmooth)
    end
end)

-- === ВКЛАДКА 4: ДИПСИК ===
local DeepSeekTab = Window:CreateTab("🧠 Дипсик", 4483362458)
DeepSeekTab:CreateSection("Визуальные фишки")

local espConn = nil
local espHighlights = {}

local function toggleESP(state)
    if state then
        espConn = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    if not espHighlights[player] or not espHighlights[player].Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "BenchESP"
                        hl.Adornee = char
                        hl.Parent = char
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        espHighlights[player] = hl
                    end
                end
            end
        end)
    else
        if espConn then espConn:Disconnect() end
        for player, hl in pairs(espHighlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        espHighlights = {}
    end
end

DeepSeekTab:CreateToggle({ Name = "ESP (Видеть всех сквозь стены)", CurrentValue = false, Callback = toggleESP })

DeepSeekTab:CreateToggle({
    Name = "Фейковый нож в руке",
    CurrentValue = false,
    Callback = function(state)
        local char = LocalPlayer.Character
        if not char then return end
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        if state and rightHand then
            local knife = Instance.new("Part")
            knife.Name = "FakeKnife"
            knife.Size = Vector3.new(0.5, 0.5, 2.5)
            knife.Material = Enum.Material.Metal
            knife.Color = Color3.fromRGB(200, 200, 200)
            knife.CanCollide = false
            knife.Massless = true
            knife.Parent = rightHand
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = rightHand
            weld.Part1 = knife
            weld.Parent = knife
            knife.CFrame = rightHand.CFrame * CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        else
            local old = char:FindFirstChild("FakeKnife")
            if old then old:Destroy() end
        end
    end
})

-- === ВКЛАДКА 5: УТИЛИТЫ ===
local UtilTab = Window:CreateTab("⚙️ Утилиты", 4483362458)
UtilTab:CreateSection("Байпас ключей Delta")
local bypassSite = "https://izen.lol/"
local deltaKeyLink = "https://gateway.platoboost.com/a/8"

UtilTab:CreateButton({
    Name = "🔑 Получить ключ Delta",
    Callback = function()
        local finalUrl = bypassSite .. "?link=" .. deltaKeyLink 
        setclipboard(finalUrl)
        Rayfield:Notify({ Title = "Ссылка скопирована", Content = "Вставь её в браузер.", Duration = 5 })
    end
})

Rayfield:LoadConfiguration()
