-- Configuration
local serverHopInterval = 600 -- 10 minutes
local teleportTimeout = 60 -- 1 minute
local gameId = 6218169544
local distanceFromPlayers = 5 -- 5 studs
local walkSpeed = 10 -- walking speed

-- Anti-Mod list functionality
local antiModList = {}
if game.PlaceId == gameId then
    -- Load anti-mod list
    for _, playerId in pairs({1234567890, 9876543210}) do -- Replace with actual player IDs
        table.insert(antiModList, playerId)
    end
end

-- Server hop functionality
local lastServerHop = tick()
while true do
    if tick() - lastServerHop >= serverHopInterval then
        -- Server hop
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
        lastServerHop = tick()
    end
    wait(1)
end

-- Teleport to player functionality
local function teleportToPlayer()
    local players = game:GetService("Players"):GetPlayers()
    for _, player in pairs(players) do
        if player ~= game:GetService("Players").LocalPlayer then
            local character = player.Character
            if character and character.HumanoidRootPart then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, {character.HumanoidRootPart.Position + Vector3.new(0, 0, distanceFromPlayers)})
                return
            end
        end
    end
end

-- Walk to player functionality
local function walkToPlayer()
    local players = game:GetService("Players"):GetPlayers()
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, player in pairs(players) do
        if player ~= game:GetService("Players").LocalPlayer then
            local character = player.Character
            if character and character.HumanoidRootPart then
                local distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    if closestPlayer then
        local character = closestPlayer.Character
        if character and character.HumanoidRootPart then
            local direction = (character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Unit
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame + direction * walkSpeed * (1/60)
            if (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude < distanceFromPlayers then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, 0, distanceFromPlayers)
            end
        end
    end
end

-- Main loop
local lastTeleport = tick()
while true do
    walkToPlayer()
    if tick() - lastTeleport >= teleportTimeout then
        teleportToPlayer()
        lastTeleport = tick()
    end
    wait(1/60)
end

-- Queue on teleport functionality
local queueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

local function queueOnTeleportFunc()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    TeleportService.Teleported:Connect(function()
        loadstring(game:HttpGet("https://github.com/recklessmindset/NPC/blob/main/Code"))()
    end)
end
queueOnTeleport(queueOnTeleportFunc)
