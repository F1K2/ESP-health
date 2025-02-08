-- ESP.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Fonction pour créer une barre de santé
local function createHealthBar(parent)
    local healthBarGui = Instance.new("BillboardGui")
    healthBarGui.Size = UDim2.new(3, 0, 0.5, 0)
    healthBarGui.StudsOffset = Vector3.new(0, 3, 0)
    healthBarGui.AlwaysOnTop = true
    healthBarGui.Parent = parent

    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 1, 0)
    healthFrame.BackgroundTransparency = 1
    healthFrame.Parent = healthBarGui

    local healthBar = Instance.new("Frame")
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0) -- Vert pour santé pleine
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthFrame

    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 1
    border.BorderColor3 = Color3.new(0, 0, 0) -- Bordure noire
    border.Parent = healthFrame

    return healthBar
end

-- Fonction pour mettre à jour la barre de santé
local function updateHealthBar(healthBar, humanoid)
    healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(1 - (humanoid.Health / humanoid.MaxHealth), humanoid.Health / humanoid.MaxHealth, 0)
end

-- Fonction pour gérer les changements de santé
local function handleHealthChanges(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local healthBar = createHealthBar(character:FindFirstChild("Head") or character.HumanoidRootPart)
    updateHealthBar(healthBar, humanoid)

    local healthChangedConnection
    healthChangedConnection = humanoid.HealthChanged:Connect(function()
        updateHealthBar(healthBar, humanoid)
    end)

    -- Nettoyage à la mort du personnage
    local diedConnection
    diedConnection = humanoid.Died:Connect(function()
        healthBar.Parent:Destroy()
        healthChangedConnection:Disconnect()
        diedConnection:Disconnect()
    end)
end

-- Fonction pour gérer l'ajout et la suppression de joueurs
local function managePlayer(player)
    local characterAddedConnection
    local characterRemovingConnection

    characterAddedConnection = player.CharacterAdded:Connect(function(character)
        if character then
            handleHealthChanges(character)
        end
    end)

    characterRemovingConnection = player.CharacterRemoving:Connect(function()
        -- Si le personnage est supprimé, on nettoie l'ESP associé (bien que ce soit généralement géré par le Died event)
        if player.Character and player.Character:FindFirstChild("Head") then
            local healthBarGui = player.Character.Head:FindFirstChildOfClass("BillboardGui")
            if healthBarGui then healthBarGui:Destroy() end
        end
    end)

    -- Nettoyage si le joueur quitte
    local playerRemovingConnection
    playerRemovingConnection = player.AncestryChanged:Connect(function(_, parent)
        if parent == nil then -- Le joueur a quitté
            characterAddedConnection:Disconnect()
            characterRemovingConnection:Disconnect()
            playerRemovingConnection:Disconnect()
        end
    end)
end

-- Initialisation pour les joueurs existants
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        managePlayer(player)
    end
end

-- Gestion des nouveaux joueurs
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        managePlayer(player)
    end
end)

print("ESP with Health Bars initialized.")
