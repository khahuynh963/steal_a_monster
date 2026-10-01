--[[
    ===================================================================
    🦖 STEAL A MONSTER HUB - LOADER V1.0
    Game: [🦖] Ăn cắp một con quái vật! (Steal a Monster!)
    Developer: Oops Again
    Repository: https://github.com/khahuynh963/steal_a_monster.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus, Solara.
    ===================================================================
--]]

pcall(function()
    local container = (gethui and gethui()) or game:GetService("CoreGui")
    if container then
        if container:FindFirstChild("StealAMonsterHubGui") then
            container.StealAMonsterHubGui:Destroy()
        end
        if container:FindFirstChild("StealMonsterHubGui") then
            container.StealMonsterHubGui:Destroy()
        end
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") then
        if pl.PlayerGui:FindFirstChild("StealAMonsterHubGui") then
            pl.PlayerGui.StealAMonsterHubGui:Destroy()
        end
        if pl.PlayerGui:FindFirstChild("StealMonsterHubGui") then
            pl.PlayerGui.StealMonsterHubGui:Destroy()
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_a_monster/main/script.lua?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))))()
