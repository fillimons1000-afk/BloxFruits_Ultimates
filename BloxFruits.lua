local _ENV = (getgenv or getrenv or getfenv)()

local CURRENT_VERSION = _ENV.Version or "V3"

local Versions = {
    V1 = "https://raw.githubusercontent.com/fillimon1000-afk/BloxFruits_Ultimates/main/BloxFruits.lua",
    V2 = "https://pastebin.com/raw/BloxFruitsV2",
    V3 = "https://gist.githubusercontent.com/raw/BloxFruitsV3",
    V4 = "https://raw.githubusercontent.com/BloxFruits/Ultimate/main/Script.lua",
}

do
    local last_exec = _ENV.bf_execute_debounce
    if last_exec and (tick() - last_exec) <= 5 then
        return nil
    end
    _ENV.bf_execute_debounce = tick()
end

do
    local executor = syn or fluxus or krnl or scriptware or execute
    local queueteleport = queue_on_teleport or (executor and executor.queue_on_teleport)

    if not _ENV.bf_teleport_queue and type(queueteleport) == "function" then
        _ENV.bf_teleport_queue = true
        local sourceCode = ("loadstring(game:HttpGet('%s'))()"):format(Versions[CURRENT_VERSION] or Versions.V3)
        pcall(queueteleport, sourceCode)
    end
end

local fetcher = {}

local function CreateMessageError(text)
    if _ENV.bf_error_message then
        _ENV.bf_error_message:Destroy()
    end
    local message = Instance.new("Message", workspace)
    message.Text = text
    error(text, 2)
end

function fetcher.get(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return response
    else
        CreateMessageError(("[Fetcher Error] Failed to get URL: %s\n>>%s<<"):format(url, response))
    end
end

function fetcher.load(url)
    local raw = fetcher.get(url)
    local func, err = loadstring(raw)
    if type(func) ~= "function" then
        CreateMessageError(("[Load Error] Syntax error at: %s\n>>%s<<"):format(url, err))
    else
        return func
    end
end

-- ОСНОВНОЙ СКРИПТ С ЧЕРНО-БЕЛЫМ UI
local function MainScript()
    -- ПРОВЕРКА НА BLOX FRUITS
    if not game:IsLoaded() then game.Loaded:Wait() end
    if not game.PlaceId == 2753915549 and not game.PlaceId == 4442272183 and not game.PlaceId == 7449423635 then
        CreateMessageError("This script only works in Blox Fruits!")
        return
    end

    -- ЧЕРНО-БЕЛЫЙ UI СТИЛЬ
    local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    
    local Window = OrionLib:MakeWindow({
        Name = "BLOX FRUITS | ULTIMATE",
        HidePremium = true,
        SaveConfig = true,
        ConfigFolder = "BloxFruitsUltimate",
        IntroEnabled = true,
        IntroText = "BLOX FRUITS ULTIMATE"
    })
    
    -- ИЗМЕНЕНИЕ СТИЛЯ НА ЧЕРНО-БЕЛЫЙ
    local function ApplyMonochrome()
        pcall(function()
            local OrionGui = game:GetService("CoreGui"):FindFirstChild("Orion")
            if OrionGui then
                for _, v in pairs(OrionGui:GetDescendants()) do
                    if v:IsA("Frame") or v:IsA("ScrollingFrame") or v:IsA("ImageButton") then
                        if v.BackgroundColor3 then
                            if v.BackgroundColor3.r > 0.5 then
                                v.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
                            else
                                v.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
                            end
                        end
                    end
                    if v:IsA("TextLabel") or v:IsA("TextButton") then
                        v.TextColor3 = Color3.new(1, 1, 1)
                        if v.BackgroundColor3 then
                            v.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
                        end
                    end
                end
            end
        end)
    end
    
    -- ОСНОВНЫЕ ПЕРЕМЕННЫЕ
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local VirtualInput = game:GetService("VirtualInputManager")
    local RunService = game:GetService("RunService")
    
    -- НАСТРОЙКИ
    local Settings = {
        AutoFarm = false,
        AutoFarmNPC = "Diamond",
        AutoFruit = false,
        AutoFruitDistance = 500,
        AutoRace = false,
        AutoRaceType = "Ghoul",
        AutoAwaken = false,
        AutoMastery = false,
        AutoBounty = false,
        WalkSpeed = 16,
        JumpPower = 50,
        AutoClick = false,
        AutoSkills = false,
        Skills = {"Z", "X", "C", "V"},
        TeleportIsland = "Island 1",
        AutoTeleport = false
    }
    
    -- ТЕЛЕПОРТЫ
    local Teleports = {
        ["Island 1"] = CFrame.new(-1110, 130, 220),
        ["Island 2"] = CFrame.new(-2800, 45, -2100),
        ["Island 3"] = CFrame.new(3800, 10, -1200),
        ["Sea 1"] = CFrame.new(350, 10, 50),
        ["Sea 2"] = CFrame.new(-2500, 10, -1000),
        ["Sea 3"] = CFrame.new(5000, 10, -3000),
        ["Cafe"] = CFrame.new(-754, 62, -256),
        ["Mansion"] = CFrame.new(-1280, 100, -580),
        ["Castle"] = CFrame.new(-460, 130, 450),
        ["Hydra"] = CFrame.new(5500, 150, -4500),
        ["Great Tree"] = CFrame.new(6200, 350, -3800),
        ["Dragon Dojo"] = CFrame.new(4850, 180, -5200),
        ["Factory"] = CFrame.new(-515, 210, 610),
        ["Graveyard"] = CFrame.new(-930, 40, -280),
        ["Prison"] = CFrame.new(4850, 5, 950),
        ["Sky Island"] = CFrame.new(-500, 850, -1350),
        ["Dough King"] = CFrame.new(2600, 50, -500),
        ["Cake Queen"] = CFrame.new(-1700, 120, -800)
    }
    
    -- ФУНКЦИИ
    local function TeleportTo(place)
        if type(place) == "string" and Teleports[place] then
            RootPart.CFrame = Teleports[place]
        elseif type(place) == "CFrame" then
            RootPart.CFrame = place
        end
    end
    
    local function GetNearestNPC()
        local nearest = nil
        local minDist = math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local name = v.Name:lower()
                    local target = Settings.AutoFarmNPC:lower()
                    if name:find(target) or (target == "boss" and (name:find("boss") or name:find("king") or name:find("queen"))) then
                        local dist = (RootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = v
                        end
                    end
                end
            end
        end
        return nearest
    end
    
    local function Attack()
        pcall(function()
            local combat = require(LocalPlayer.PlayerScripts.CombatFramework)
            for _, v in pairs(getupvalues(combat)) do
                if type(v) == "function" and getfenv(v) then
                    for k, w in pairs(getfenv(v)) do
                        if type(w) == "table" and w.attack and w.hit then
                            w.attack()
                        end
                    end
                end
            end
        end)
    end
    
    local function UseSkill(key)
        VirtualInput:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, key, false, game)
    end
    
    -- АВТОФАРМ
    spawn(function()
        while true do
            task.wait()
            if Settings.AutoFarm then
                local target = GetNearestNPC()
                if target and target.Humanoid.Health > 0 then
                    local dist = (RootPart.Position - target.HumanoidRootPart.Position).Magnitude
                    if dist > 5 then
                        RootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    end
                    if Settings.AutoClick then
                        Attack()
                    end
                    if Settings.AutoSkills then
                        for _, skill in ipairs(Settings.Skills) do
                            UseSkill(skill)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end)
    
    -- АВТОФРУКТЫ
    spawn(function()
        while true do
            task.wait(0.5)
            if Settings.AutoFruit then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") and v.Parent ~= Character then
                        local dist = (RootPart.Position - v.Position).Magnitude
                        if dist < Settings.AutoFruitDistance then
                            RootPart.CFrame = CFrame.new(v.Position)
                            task.wait(0.3)
                            local click = v:FindFirstChild("ClickDetector")
                            if click then
                                fireclickdetector(click)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- АВТОРЕЙС V4
    spawn(function()
        while true do
            task.wait(1)
            if Settings.AutoRace then
                local args = {[1] = "StartTrial", [2] = Settings.AutoRaceType}
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                end)
            end
        end
    end)
    
    -- АВТОМАСТЕРИ
    spawn(function()
        while true do
            task.wait(0.1)
            if Settings.AutoMastery then
                for _, v in pairs(Character:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Level") then
                        for _, skill in ipairs(Settings.Skills) do
                            UseSkill(skill)
                        end
                    end
                end
            end
        end
    end)
    
    -- АВТОБАУНТИ
    spawn(function()
        while true do
            task.wait(30)
            if Settings.AutoBounty then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Name:lower():find("player") and v ~= Character then
                            RootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            for _, skill in ipairs(Settings.Skills) do
                                UseSkill(skill)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- АВТОТЕЛЕПОРТ
    spawn(function()
        while true do
            task.wait(60)
            if Settings.AutoTeleport then
                TeleportTo(Settings.TeleportIsland)
            end
        end
    end)
    
    -- СОЗДАНИЕ ВКЛАДОК
    local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998"})
    FarmTab:AddToggle({Name = "Auto Farm NPC", Default = false, Callback = function(v) Settings.AutoFarm = v end})
    FarmTab:AddToggle({Name = "Auto Click", Default = false, Callback = function(v) Settings.AutoClick = v end})
    FarmTab:AddToggle({Name = "Auto Skills", Default = false, Callback = function(v) Settings.AutoSkills = v end})
    FarmTab:AddDropdown({
        Name = "Select NPC",
        Default = "Diamond",
        Options = {"Diamond", "Pirate", "Marine", "Shark", "Mob", "Boss", "Dough King", "Cake Queen"},
        Callback = function(v) Settings.AutoFarmNPC = v end
    })
    
    local FruitTab = Window:MakeTab({Name = "Auto Fruit", Icon = "rbxassetid://4483345998"})
    FruitTab:AddToggle({Name = "Auto Find Fruits", Default = false, Callback = function(v) Settings.AutoFruit = v end})
    FruitTab:AddSlider({
        Name = "Search Distance",
        Min = 100,
        Max = 1000,
        Default = 500,
        Callback = function(v) Settings.AutoFruitDistance = v end
    })
    
    local RaceTab = Window:MakeTab({Name = "Auto Race", Icon = "rbxassetid://4483345998"})
    RaceTab:AddToggle({Name = "Auto Race V4", Default = false, Callback = function(v) Settings.AutoRace = v end})
    RaceTab:AddDropdown({
        Name = "Select Race",
        Default = "Ghoul",
        Options = {"Human", "Ghoul", "Fishman", "Skypiea", "Mink", "Cyborg"},
        Callback = function(v) Settings.AutoRaceType = v end
    })
    RaceTab:AddToggle({Name = "Auto Awaken", Default = false, Callback = function(v) Settings.AutoAwaken = v end})
    
    local MasteryTab = Window:MakeTab({Name = "Auto Mastery", Icon = "rbxassetid://4483345998"})
    MasteryTab:AddToggle({Name = "Auto Mastery Farm", Default = false, Callback = function(v) Settings.AutoMastery = v end})
    
    local BountyTab = Window:MakeTab({Name = "Auto Bounty", Icon = "rbxassetid://4483345998"})
    BountyTab:AddToggle({Name = "Auto Bounty Hunt", Default = false, Callback = function(v) Settings.AutoBounty = v end})
    
    local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998"})
    for name, _ in pairs(Teleports) do
        TeleportTab:AddButton({Name = "TP to " .. name, Callback = function() TeleportTo(name) end})
    end
    
    local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998"})
    MoveTab:AddSlider({Name = "Walk Speed", Min = 16, Max = 300, Default = 16, Callback = function(v) Humanoid.WalkSpeed = v end})
    MoveTab:AddSlider({Name = "Jump Power", Min = 50, Max = 500, Default = 50, Callback = function(v) Humanoid.JumpPower = v end})
    MoveTab:AddButton({Name = "Reset Character", Callback = function() Character:BreakJoints() end})
    
    local ServerTab = Window:MakeTab({Name = "Server", Icon = "rbxassetid://4483345998"})
    ServerTab:AddButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end})
    ServerTab:AddButton({Name = "Server Hop", Callback = function()
        local Http = game:GetService("HttpService")
        local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        for _, v in pairs(servers.data) do
            if v.playing < v.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
                break
            end
        end
    end})
    
    local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
    SettingsTab:AddButton({Name = "Infinite Yield (Admin)", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end})
    SettingsTab:AddButton({Name = "Cmd-X (Admin)", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))()
    end})
    
    -- ПРИМЕНЕНИЕ СТИЛЯ
    task.wait(0.5)
    ApplyMonochrome()
    
    OrionLib:Init()
    print("✅ Blox Fruits Ultimate | Black & White Style | Loaded!")
end

-- ЗАПУСК
local versionUrl = Versions[CURRENT_VERSION] or Versions.V3
local success, err = pcall(function()
    if CURRENT_VERSION == "V3" or not fetcher.get(versionUrl) then
        MainScript()
    else
        return fetcher.load(versionUrl)()
    end
end)

if not success then
    MainScript()
end
