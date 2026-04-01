--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗    ███████╗██████╗ ██╗   ██╗██╗████████╗███████╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝    ██╔════╝██╔══██╗██║   ██║██║╚══██╔══╝██╔════╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝     █████╗  ██████╔╝██║   ██║██║   ██║   █████╗  
    ██╔══██╗██║     ██║   ██║ ██╔██╗     ██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██╔══╝  
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗    ██║     ██║  ██║╚██████╔╝██║   ██║   ███████╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝
                                    BLOX FRUITS ULTIMATE
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- CONFIGURATION
local Settings = {
    AutoFarm = false,
    AutoFarmType = "NPC", -- NPC/BOSS
    SelectedNPC = "Diamond",
    AutoFruit = false,
    AutoFruitDistance = 500,
    AutoRace = false,
    SelectedRace = "Ghoul",
    AutoAwaken = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoClick = false,
    AutoSkill = false,
    SelectedSkills = {"Z", "X", "C", "V"},
    AutoTeleport = false,
    SelectedIsland = "Island 1"
}

-- TELEPORT LOCATIONS
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
    ["Sky Island"] = CFrame.new(-500, 850, -1350)
}

-- MAIN FUNCTIONS
function TeleportTo(Location)
    if type(Location) == "string" and Teleports[Location] then
        RootPart.CFrame = Teleports[Location]
    elseif type(Location) == "CFrame" then
        RootPart.CFrame = Location
    end
end

function GetNearestNPC()
    local nearest = nil
    local minDist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if not v:FindFirstChild("HumanoidRootPart") then continue end
            if v.Name:lower():find(Settings.SelectedNPC:lower()) or v.Name:lower():find("boss") then
                local dist = (RootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

function Attack()
    for _, v in pairs(getupvalues(require(LocalPlayer.PlayerScripts.CombatFramework))) do
        if type(v) == "function" and getfenv(v) then
            for k, w in pairs(getfenv(v)) do
                if type(w) == "table" and w.attack and w.hit then
                    pcall(function() w.attack() end)
                end
            end
        end
    end
end

function UseSkill(Skill)
    local key = Skill:upper()
    local action = game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
end

-- AUTO FARM
spawn(function()
    while true do
        task.wait()
        if Settings.AutoFarm then
            local target = GetNearestNPC()
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                local dist = (RootPart.Position - target.HumanoidRootPart.Position).Magnitude
                if dist > 5 then
                    RootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
                if Settings.AutoClick then
                    Attack()
                end
                if Settings.AutoSkill then
                    for _, skill in ipairs(Settings.SelectedSkills) do
                        UseSkill(skill)
                        task.wait(0.3)
                    end
                end
            else
                task.wait(1)
            end
        end
    end
end)

-- AUTO FRUIT
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

-- AUTO RACE V4
spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoRace then
            local args = {[1] = "StartTrial", [2] = Settings.SelectedRace}
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
        end
    end
end)

-- AUTO AWAKEN
spawn(function()
    while true do
        task.wait(5)
        if Settings.AutoAwaken then
            local args = {[1] = "Awakener", [2] = "Check"}
            local result = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
            if result and result.Awaken then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Awakener", "Awaken")
            end
        end
    end
end)

-- AUTO TELEPORT
spawn(function()
    while true do
        task.wait(30)
        if Settings.AutoTeleport then
            TeleportTo(Settings.SelectedIsland)
        end
    end
end)

-- UI LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = Library:MakeWindow({
    Name = "BLOX FRUITS ULTIMATE",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BloxFruitsUltimate"
})

-- AUTO FARM TAB
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998"})
FarmTab:AddToggle({
    Name = "Auto Farm NPC",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
    end
})
FarmTab:AddToggle({
    Name = "Auto Click",
    Default = false,
    Callback = function(Value)
        Settings.AutoClick = Value
    end
})
FarmTab:AddToggle({
    Name = "Auto Skills",
    Default = false,
    Callback = function(Value)
        Settings.AutoSkill = Value
    end
})
FarmTab:AddDropdown({
    Name = "Select NPC",
    Default = "Diamond",
    Options = {"Diamond", "Pirate", "Marine", "Shark", "Mob", "Boss", "Dough King", "Cake Queen"},
    Callback = function(Value)
        Settings.SelectedNPC = Value
    end
})

-- FRUIT TAB
local FruitTab = Window:MakeTab({Name = "Auto Fruit", Icon = "rbxassetid://4483345998"})
FruitTab:AddToggle({
    Name = "Auto Find Fruits",
    Default = false,
    Callback = function(Value)
        Settings.AutoFruit = Value
    end
})
FruitTab:AddSlider({
    Name = "Fruit Search Distance",
    Min = 100,
    Max = 1000,
    Default = 500,
    Callback = function(Value)
        Settings.AutoFruitDistance = Value
    end
})

-- RACE TAB
local RaceTab = Window:MakeTab({Name = "Auto Race", Icon = "rbxassetid://4483345998"})
RaceTab:AddToggle({
    Name = "Auto Race V4",
    Default = false,
    Callback = function(Value)
        Settings.AutoRace = Value
    end
})
RaceTab:AddDropdown({
    Name = "Select Race",
    Default = "Ghoul",
    Options = {"Human", "Ghoul", "Fishman", "Skypiea", "Mink", "Cyborg"},
    Callback = function(Value)
        Settings.SelectedRace = Value
    end
})
RaceTab:AddToggle({
    Name = "Auto Awaken",
    Default = false,
    Callback = function(Value)
        Settings.AutoAwaken = Value
    end
})

-- TELEPORT TAB
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998"})
for name, _ in pairs(Teleports) do
    TeleportTab:AddButton({
        Name = "Teleport to " .. name,
        Callback = function()
            TeleportTo(name)
        end
    })
end

-- MOVEMENT TAB
local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998"})
MoveTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(Value)
        Settings.WalkSpeed = Value
        Humanoid.WalkSpeed = Value
    end
})
MoveTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(Value)
        Settings.JumpPower = Value
        Humanoid.JumpPower = Value
    end
})
MoveTab:AddButton({
    Name = "Fly (Noclip)",
    Callback = function()
        local noclip = false
        game:GetService("RunService").Stepped:Connect(function()
            if noclip then
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
        noclip = not noclip
    end
})

-- SETTINGS TAB
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
SettingsTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})
SettingsTab:AddButton({
    Name = "Hop to New Server",
    Callback = function()
        local Http = game:GetService("HttpService")
        local Servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        for _, v in pairs(Servers.data) do
            if v.playing < v.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
                break
            end
        end
    end
})
SettingsTab:AddButton({
    Name = "Reset Character",
    Callback = function()
        Character:BreakJoints()
    end
})
SettingsTab:AddButton({
    Name = "Infinite Yield (Admin)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- NOTIFICATION
Library:MakeNotification({
    Name = "Blox Fruits Ultimate",
    Content = "Скрипт успешно загружен!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

Library:Init()
print("✅ BLOX FRUITS ULTIMATE | Готов к работе!")