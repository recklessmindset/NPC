-- Configuration
local antiModIDs = {
    7423673502,
    38701072,
    418307435,
    73344996,
    37343237,
    210949,
    103578797,
    2542703855,
    1159074474,
    1562079996,
    337367059
}

-- Function to check if a player is eligible (not in antiModIDs list)
local function isPlayerEligible(player)
    local gameId = game.PlaceId
    if gameId == 6218169544 then
        for _, id in pairs(antiModIDs) do
            if player.UserId == id then
                return false
            end
        end
    end
    return true
end

-- Function to get a random eligible player
local function getRandomEligiblePlayer()
    local players = game:GetService("Players"):GetPlayers()
    local eligiblePlayers = {}
    
    for _, player in pairs(players) do
        if player ~= game.Players.LocalPlayer and isPlayerEligible(player) then
            table.insert(eligiblePlayers, player)
        end
    end
    
    if #eligiblePlayers > 0 then
        return eligiblePlayers[math.random(1, #eligiblePlayers)]
    else
        return nil
    end
end

-- Function to calculate a position at a certain distance from a target position
local function getPositionAtDistance(targetPosition, distance)
    local character = game.Players.LocalPlayer.Character
    local direction = (targetPosition - character.HumanoidRootPart.Position).Unit
    return targetPosition - direction * distance
end

-- Anti-sit function
local function antiSit()
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("Seat") then
            object:Destroy()
        end
    end
end

-- Function to teleport to a random player
local function teleportToRandomPlayer()
    local randomPlayer = getRandomEligiblePlayer()
    if randomPlayer then
        local targetPosition = randomPlayer.Character.HumanoidRootPart.Position
        local distance = 5
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(getPositionAtDistance(targetPosition, distance))
    end
end

-- Function to walk to target player
local function walkToTargetPlayer(targetPlayer)
    local character = game.Players.LocalPlayer.Character
    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
    local distance = 5
    local walkSpeed = 16
    
    character.Humanoid.WalkSpeed = walkSpeed
    
    while (character.HumanoidRootPart.Position - targetPosition).Magnitude > distance do
        local direction = (targetPosition - character.HumanoidRootPart.Position).Unit
        character.Humanoid:MoveTo(targetPosition)
        wait(0.1)
    end
end

-- Function to face target player
local function faceTargetPlayer(targetPlayer)
    local character = game.Players.LocalPlayer.Character
    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
    local direction = (targetPosition - character.HumanoidRootPart.Position).Unit
    character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetPosition)
end

-- Server hop function
local function serverHop()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end

-- Main loop
local lastTeleportTime = tick()
local lastServerHopTime = tick()
local targetPlayer = getRandomEligiblePlayer()
local reachedPlayer = false
local reachedPlayerTime = 0
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or queueteleport or (fluxus and fluxus.queue_on_teleport)

while true do
    -- Check if the character is dead
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or character.Humanoid.Health <= 0 then
        wait(1)
        character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            targetPlayer = getRandomEligiblePlayer()
            reachedPlayer = false
        end
    else
        -- Check if 60 seconds have passed since the last teleport
        if tick() - lastTeleportTime > 60 and targetPlayer == nil then
            teleportToRandomPlayer()
            lastTeleportTime = tick()
        end
        
        -- Check if 10 minutes have passed since the last server hop
        if tick() - lastServerHopTime > 600 then
            serverHop()
            lastServerHopTime = tick()
        end
        
        -- Walk to target player
        if targetPlayer and not reachedPlayer then
            walkToTargetPlayer(targetPlayer)
            faceTargetPlayer(targetPlayer)
            
            -- Check if we've reached the target player
            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude < 5 then
                reachedPlayer = true
                reachedPlayerTime = tick()
            end
        elseif reachedPlayer and tick() - reachedPlayerTime < 8 then
            -- Stay near the player for 8 seconds
            walkToTargetPlayer(targetPlayer)
            faceTargetPlayer(targetPlayer)
        elseif reachedPlayer and tick() - reachedPlayerTime >= 8 then
            -- Reset and find a new target player
            targetPlayer = nil
            reachedPlayer = false
            lastTeleportTime = tick()
        else
            targetPlayer = getRandomEligiblePlayer()
        end
        
        -- Anti-sit
        antiSit()
        
        -- Wait for 1 second
        wait(1)
    end
end

-- Re-execution on teleport
if queueteleport then
    queueteleport(loadstring(game:HttpGet("https://raw.githubusercontent.com/recklessmindset/NPC/refs/heads/main/walk.lua")))
end
