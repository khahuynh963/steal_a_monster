--[[
    ===================================================================
    🦖 STEAL A MONSTER HUB - ĂN CẮP MỘT CON QUÁI VẬT! V1.0
    Game: [🦖] Ăn cắp một con quái vật! (Steal a Monster!)
    Developer: Oops Again
    Repository: https://github.com/khahuynh963/steal_a_monster.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus, Solara.
    
    CÁC TÍNH NĂNG CHÍNH:
    1. 🥷 AUTO STEAL MONSTERS: Tự động đột nhập căn cứ đối thủ, bế quái vật xịn nhất và tẩu thoát về căn cứ.
    2. 🛒 AUTO BUY CONVEYOR: Tự động mua quái vật trên băng chuyền trung tâm (Lọc theo độ hiếm).
    3. 💰 AUTO COLLECT COINS: Tự động gom tiền vàng sinh ra từ các quái vật trong căn cứ.
    4. 🛡️ AUTO DEFENSE & LOCKDOWN: Tự động kích hoạt Khóa căn cứ (Lockdown) khi có người lạ đột nhập.
    5. 🔄 AUTO REBIRTH: Tự động Tái sinh khi đủ điều kiện để tăng thời gian Lockdown vĩnh viễn.
    6. ⚡ TIỆN ÍCH TẨU THOÁT & TỐI ƯU: Tăng tốc chạy (Speed Boost), Nhảy vô hạn (Infinite Jump), Xuyên tường (Noclip), Anti-AFK 24/7, Siêu mượt 60 FPS.
    ===================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer

-- Khai báo ScreenGui trước để các hàm kiểm tra con cháu không bị lỗi nil
local ScreenGui = nil

local function isOurGui(obj)
    if not obj then return false end
    if ScreenGui and obj:IsDescendantOf(ScreenGui) then
        return true
    end
    local name = obj.Name
    if name == "StealAMonsterHubGui" or name == "StealMonsterHubGui" then
        return true
    end
    if obj:FindFirstAncestor("StealAMonsterHubGui") or obj:FindFirstAncestor("StealMonsterHubGui") then
        return true
    end
    return false
end

-- ── Safe GUI Container ──
local function getGuiContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        elseif syn and syn.protect_gui then
            container = game:GetService("CoreGui")
            syn.protect_gui(container)
        elseif game:GetService("CoreGui") then
            container = game:GetService("CoreGui")
        else
            container = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

-- ── Xóa dấu tiếng Việt & chuẩn hóa ký tự ──
local function stripVietnameseAccents(str)
    if not str or type(str) ~= "string" then return "" end
    local text = str
    local map = {
        ["a"] = "[aàáảãạăằắẳẵặâầấẩẫậ]",
        ["e"] = "[eèéẻẽẹêềếểễệ]",
        ["i"] = "[iìíỉĩị]",
        ["o"] = "[oòóỏõọôồốổỗộơờớởỡợ]",
        ["u"] = "[uùúủũụưừứửữự]",
        ["y"] = "[yỳýỷỹỵ]",
        ["d"] = "[dđ]",
        ["A"] = "[AÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬ]",
        ["E"] = "[EÈÉẺẼẸÊỀẾỂỄỆ]",
        ["I"] = "[IÌÍỈĨỊ]",
        ["O"] = "[OÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ]",
        ["U"] = "[UÙÚỦŨỤƯỪỨỬỮỰ]",
        ["Y"] = "[YỲÝỶỸỴ]",
        ["D"] = "[DĐ]"
    }
    for repl, pattern in pairs(map) do
        text = text:gsub(pattern, repl)
    end
    return text:lower()
end

-- ── Multi-Input Click Simulation ──
local function simulateClick(btn)
    if not btn or not btn:IsA("GuiObject") then return false end
    local success = false
    
    pcall(function()
        if firesignal then
            if btn.Activated then firesignal(btn.Activated) end
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
            success = true
        end
    end)

    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(btn.Activated)) do
                conn:Fire()
                success = true
            end
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
                success = true
            end
        end
    end)

    pcall(function()
        if VirtualInputManager and btn.AbsolutePosition and btn.AbsoluteSize then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local cx = pos.X + (size.X / 2)
            local cy = pos.Y + (size.Y / 2)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
            success = true
        end
    end)

    pcall(function()
        if VirtualUser and btn.AbsolutePosition and btn.AbsoluteSize then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local cx = pos.X + (size.X / 2)
            local cy = pos.Y + (size.Y / 2)
            VirtualUser:Button1Down(Vector2.new(cx, cy))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(cx, cy))
            success = true
        end
    end)

    return success
end

-- ── ProximityPrompt Trigger ──
local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if not prompt.Enabled then return false end
    
    local oldHold = prompt.HoldDuration
    local oldDist = prompt.MaxActivationDistance
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 99999
    end)
    
    local ok = false
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
            ok = true
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
            ok = true
        end
    end)
    
    pcall(function()
        prompt.HoldDuration = oldHold
        prompt.MaxActivationDistance = oldDist
    end)
    return ok
end

-- ── Cấu hình & Biến trạng thái ──
local Config = {
    -- 1. Auto Steal
    AutoSteal = false,
    StealPriority = "Best Value", -- "Best Value" hoặc "Any Monster"
    StealInterval = 3.5,
    AvoidLockdown = true,
    AutoReturnBase = true,
    
    -- 2. Auto Conveyor
    AutoBuyConveyor = false,
    ConveyorMinRarity = "All", -- "All", "Rare+", "Epic+", "Legendary+", "Celestial+"
    ConveyorInterval = 1.0,
    
    -- 3. Auto Base Collect
    AutoCollectCoins = true,
    CollectInterval = 2.5,
    
    -- 4. Auto Defense
    AutoLockdown = false,
    DefendDistance = 45,
    
    -- 5. Auto Rebirth
    AutoRebirth = false,
    
    -- 6. Utilities
    SpeedBoost = false,
    SpeedValue = 35,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true,
    FPSBooster = false
}

local Stats = {
    MonstersStolen = 0,
    ConveyorBought = 0,
    CoinsCollected = 0,
    CurrentStatus = "Đang chờ kích hoạt..."
}

local RarityLevels = {
    ["common"] = 1,
    ["uncommon"] = 2,
    ["rare"] = 3,
    ["epic"] = 4,
    ["legendary"] = 5,
    ["mythic"] = 6,
    ["celestial"] = 7,
    ["celestial emperor"] = 8
}

-- ── Nhận diện Căn Cứ Của Người Chơi (My Base Plot) ──
local MyBasePlot = nil
local MyBaseCFrame = nil

local function getMyBase()
    if MyBasePlot and MyBasePlot.Parent then
        return MyBasePlot, MyBaseCFrame
    end
    
    local pName = LocalPlayer.Name:lower()
    local pUserId = tostring(LocalPlayer.UserId)
    
    -- Tìm trong Workspace các thư mục Bases, Plots, Tycoons
    for _, folder in ipairs(Workspace:GetChildren()) do
        local fName = folder.Name:lower()
        if fName:find("base") or fName:find("plot") or fName:find("tycoon") or fName:find("island") then
            for _, plot in ipairs(folder:GetChildren()) do
                local plotStr = (plot.Name .. " " .. tostring(plot:GetAttribute("Owner") or "") .. " " .. tostring(plot:GetAttribute("Player") or "")):lower()
                
                -- Tìm OwnerSign hoặc TextLabel mang tên mình
                for _, desc in ipairs(plot:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("SurfaceGui") or desc:IsA("BillboardGui") then
                        local t = desc:IsA("TextLabel") and desc.Text:lower() or ""
                        if t:find(pName) or t:find(pUserId) then
                            MyBasePlot = plot
                            local cf = plot:GetPivot()
                            MyBaseCFrame = cf
                            return MyBasePlot, MyBaseCFrame
                        end
                    end
                end
                
                if plotStr:find(pName) or plotStr:find(pUserId) then
                    MyBasePlot = plot
                    MyBaseCFrame = plot:GetPivot()
                    return MyBasePlot, MyBaseCFrame
                end
            end
        end
    end
    
    -- Nếu không tìm thấy plot gán tên, lưu vị trí nhân vật đứng lúc ban đầu làm điểm về
    if not MyBaseCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
    
    return MyBasePlot, MyBaseCFrame
end

-- ===================================================================
-- 🥷 MÔ-ĐUN 1: TỰ ĐỘNG ĂN CẮP QUÁI VẬT (AUTO STEAL MONSTERS)
-- ===================================================================
local isStealing = false

local function isPlotLocked(plot)
    if not plot then return false end
    -- Kiểm tra thuộc tính Lockdown hoặc hiệu ứng khiên đỏ/kính chắn
    local isLocked = plot:GetAttribute("Lockdown") or plot:GetAttribute("IsLocked") or plot:GetAttribute("Shield")
    if isLocked == true then return true end
    
    for _, desc in ipairs(plot:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible then
            local clean = stripVietnameseAccents(desc.Text)
            if clean:find("lockdown") or clean:find("khoa") or clean:find("shield") then
                return true
            end
        end
        if desc:IsA("BasePart") and desc.Name:lower():find("lockdown") and desc.Transparency < 0.8 then
            return true
        end
    end
    return false
end

local function scanMonstersToSteal()
    local myPlot, _ = getMyBase()
    local targets = {}
    
    -- Quét toàn bộ quái vật trong các căn cứ khác
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = stripVietnameseAccents(obj.Name)
            local isMonster = name:find("monster") or name:find("quai vat") or obj:GetAttribute("Monster") or obj:GetAttribute("Value") or obj:GetAttribute("Rarity")
            
            -- Không lấy quái vật trong căn cứ của mình
            local inMyPlot = myPlot and obj:IsDescendantOf(myPlot)
            
            if isMonster and not inMyPlot then
                -- Kiểm tra căn cứ chứa quái này có bị Lockdown không
                local hostPlot = nil
                for _, folder in ipairs(Workspace:GetChildren()) do
                    if folder.Name:lower():find("base") or folder.Name:lower():find("plot") then
                        if obj:IsDescendantOf(folder) then
                            for _, p in ipairs(folder:GetChildren()) do
                                if obj:IsDescendantOf(p) and p ~= myPlot then
                                    hostPlot = p
                                    break
                                end
                            end
                        end
                    end
                end
                
                local locked = Config.AvoidLockdown and isPlotLocked(hostPlot)
                if not locked then
                    -- Tìm ProximityPrompt ăn cắp
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        local act = stripVietnameseAccents(prompt.ActionText)
                        local objText = stripVietnameseAccents(prompt.ObjectText)
                        if act:find("steal") or act:find("cap") or act:find("take") or act:find("lay") or act:find("grab") or objText:find("steal") or act == "" then
                            local value = tonumber(obj:GetAttribute("Value") or obj:GetAttribute("Income") or 1)
                            table.insert(targets, {
                                Instance = obj,
                                Prompt = prompt,
                                CFrame = obj:GetPivot(),
                                Value = value,
                                Name = obj.Name
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sắp xếp theo giá trị cao nhất nếu chọn "Best Value"
    if Config.StealPriority == "Best Value" then
        table.sort(targets, function(a, b)
            return a.Value > b.Value
        end)
    end
    
    return targets
end

task.spawn(function()
    while true do
        task.wait(Config.StealInterval or 3.5)
        if Config.AutoSteal and not isStealing then
            pcall(function()
                local targets = scanMonstersToSteal()
                if #targets > 0 then
                    local target = targets[1]
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum and hum.Health > 0 then
                        isStealing = true
                        local _, baseCF = getMyBase()
                        local originalCF = hrp.CFrame
                        
                        Stats.CurrentStatus = string.format("🥷 Đang đột nhập cướp [%s]...", target.Name)
                        
                        -- Dịch chuyển tiếp cận quái vật
                        hrp.CFrame = target.CFrame + Vector3.new(0, 2.5, 0)
                        task.wait(0.25)
                        
                        -- Kích hoạt Prompt bế quái vật
                        firePrompt(target.Prompt)
                        task.wait(0.4)
                        
                        -- Tẩu thoát về căn cứ của mình
                        if Config.AutoReturnBase and baseCF then
                            Stats.CurrentStatus = "🏃 Đang mang quái vật tẩu thoát về căn cứ an toàn..."
                            hrp.CFrame = baseCF + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                        end
                        
                        Stats.MonstersStolen = Stats.MonstersStolen + 1
                        Stats.CurrentStatus = string.format("✅ Cướp thành công! (Tổng: %d con)", Stats.MonstersStolen)
                        
                        task.wait(1.5)
                        isStealing = false
                    end
                else
                    Stats.CurrentStatus = "🔍 Đang tìm kiếm quái vật có thể cướp..."
                end
            end)
        end
    end
end)

-- ===================================================================
-- 🛒 MÔ-ĐUN 2: TỰ ĐỘNG MUA QUÁI VẬT BĂNG CHUYỀN (CONVEYOR BUYER)
-- ===================================================================
local function scanConveyorPrompts()
    local prompts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = stripVietnameseAccents(obj.ActionText)
            local objText = stripVietnameseAccents(obj.ObjectText)
            local pName = stripVietnameseAccents(obj.Parent.Name)
            
            if act:find("buy") or act:find("mua") or act:find("purchase") or objText:find("buy") or pName:find("conveyor") or pName:find("spawner") then
                -- Lọc theo độ hiếm nếu được cấu hình
                local passFilter = true
                if Config.ConveyorMinRarity ~= "All" then
                    local targetMin = RarityLevels[Config.ConveyorMinRarity:lower()] or 1
                    local promptRarity = 1
                    for k, v in pairs(RarityLevels) do
                        if objText:find(k) or pName:find(k) then
                            if v > promptRarity then promptRarity = v end
                        end
                    end
                    if promptRarity < targetMin then
                        passFilter = false
                    end
                end
                
                if passFilter then
                    table.insert(prompts, obj)
                end
            end
        end
    end
    return prompts
end

task.spawn(function()
    while true do
        task.wait(Config.ConveyorInterval or 1.0)
        if Config.AutoBuyConveyor and not isStealing then
            pcall(function()
                local prompts = scanConveyorPrompts()
                for _, prompt in ipairs(prompts) do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and prompt.Parent and prompt.Parent:IsA("BasePart") then
                        -- Tiếp cận nhẹ nếu cần
                        local dist = (hrp.Position - prompt.Parent.Position).Magnitude
                        if dist < 40 then
                            firePrompt(prompt)
                            Stats.ConveyorBought = Stats.ConveyorBought + 1
                            Stats.CurrentStatus = string.format("🛒 Đã mua quái vật băng chuyền! (Tổng: %d)", Stats.ConveyorBought)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================================
-- 💰 MÔ-ĐUN 3: TỰ ĐỘNG GOM TIỀN VÀNG CĂN CỨ (COIN VACUUM)
-- ===================================================================
task.spawn(function()
    while true do
        task.wait(Config.CollectInterval or 2.5)
        if Config.AutoCollectCoins and not isStealing then
            pcall(function()
                local myPlot, _ = getMyBase()
                if myPlot then
                    -- Quét các bệ Collector, CoinPad, Bank
                    for _, desc in ipairs(myPlot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            local act = stripVietnameseAccents(desc.ActionText)
                            local objText = stripVietnameseAccents(desc.ObjectText)
                            if act:find("collect") or act:find("thu") or act:find("nhan") or objText:find("coin") or objText:find("cash") then
                                firePrompt(desc)
                                Stats.CurrentStatus = "💰 Đã thu hoạch tiền vàng trong căn cứ!"
                            end
                        elseif desc:IsA("BasePart") then
                            local dName = desc.Name:lower()
                            if dName:find("collect") or dName == "collector" or dName:find("coinpad") or dName:find("money") then
                                local char = LocalPlayer.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    if firetouchinterest then
                                        firetouchinterest(hrp, desc, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hrp, desc, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================================
-- 🛡️ MÔ-ĐUN 4: TỰ ĐỘNG BẬT KHÓA CĂN CỨ KHI CÓ ĐỊCH (AUTO LOCKDOWN)
-- ===================================================================
local function triggerBaseLockdown()
    local myPlot, _ = getMyBase()
    if not myPlot then return end
    
    for _, desc in ipairs(myPlot:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            local act = stripVietnameseAccents(desc.ActionText)
            local objText = stripVietnameseAccents(desc.ObjectText)
            if act:find("lock") or act:find("khoa") or objText:find("lockdown") or objText:find("shield") then
                firePrompt(desc)
                Stats.CurrentStatus = "🛡️ ĐÃ KÍCH HOẠT KHÓA CĂN CỨ (LOCKDOWN) BẢO VỆ QUÁI VẬT!"
                return
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if Config.AutoLockdown then
            pcall(function()
                local myPlot, baseCF = getMyBase()
                if baseCF then
                    local basePos = baseCF.Position
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local enemyPos = player.Character.HumanoidRootPart.Position
                            local dist = (enemyPos - basePos).Magnitude
                            if dist <= (Config.DefendDistance or 45) then
                                Stats.CurrentStatus = string.format("⚠️ CẢNH BÁO: Phát hiện %s đột nhập căn cứ!", player.DisplayName)
                                triggerBaseLockdown()
                                task.wait(5.0)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================================
-- 🔄 MÔ-ĐUN 5: TỰ ĐỘNG TÁI SINH (AUTO REBIRTH)
-- ===================================================================
local function triggerRebirth()
    -- Tìm RemoteEvent hoặc nút bấm trong PlayerGui
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("LayerCollector") and not isOurGui(gui) and gui.Enabled then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                        local t = stripVietnameseAccents(btn.Text)
                        local n = btn.Name:lower()
                        if t:find("rebirth") or t:find("tai sinh") or n:find("rebirth") then
                            simulateClick(btn)
                            Stats.CurrentStatus = "🔄 Đã kích hoạt Tái Sinh (Rebirth)!"
                            return
                        end
                    end
                end
            end
        end
    end
    
    -- Gửi RemoteEvent
    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local rName = rem.Name:lower()
            if rName:find("rebirth") then
                pcall(function()
                    if rem:IsA("RemoteEvent") then rem:FireServer() else rem:InvokeServer() end
                    Stats.CurrentStatus = "🔄 Đã gửi yêu cầu Tái Sinh qua Remote!"
                end)
                return
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(5.0)
        if Config.AutoRebirth and not isStealing then
            pcall(function()
                triggerRebirth()
            end)
        end
    end
end)

-- ===================================================================
-- ⚡ MÔ-ĐUN 6: TIỆN ÍCH TẨU THOÁT, ANTI-AFK & FPS BOOSTER
-- ===================================================================
-- 1. Anti-AFK
task.spawn(function()
    if getconnections then
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then conn:Disable() end
        end
    end
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                else
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(1), 0) end
                end
            end)
        end
    end)
end)

-- 2. Tăng tốc chạy (Speed Boost)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.SpeedBoost then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Config.SpeedValue or 35 end
            end)
        end
    end
end)

-- 3. Nhảy vô hạn (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- 4. Xuyên tường (Noclip)
RunService.Stepped:Connect(function()
    if Config.Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- 5. FPS Booster
local function applyFPSBooster(enable)
    pcall(function()
        if enable then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostProcessEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v.Enabled = false
                end
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                end
            end
        else
            Lighting.GlobalShadows = true
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostProcessEffect") then v.Enabled = true end
            end
        end
    end)
end

-- ===================================================================
-- 🎨 GIAO DIỆN ĐIỀU KHIỂN: JURASSIC CYBER THEME (EMERALD & DRAGON GOLD)
-- ===================================================================
local container = getGuiContainer()

-- Dọn dẹp GUI cũ nếu còn chạy
pcall(function()
    if container:FindFirstChild("StealAMonsterHubGui") then
        container.StealAMonsterHubGui:Destroy()
    end
end)

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAMonsterHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = container

-- ── 1. NÚT TRÒN THU NHỎ (FLOATING TOGGLE ICON 🦖) ──
local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "FloatingToggleBtn"
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0.04, 0, 0.22, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(5, 150, 105) -- Xanh ngọc lục bảo Emerald
FloatingBtn.BorderSizePixel = 0
FloatingBtn.AutoButtonColor = true
FloatingBtn.ZIndex = 1000
FloatingBtn.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = FloatingBtn

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = Color3.fromRGB(245, 158, 11) -- Viền rồng vàng Gold
FloatingStroke.Thickness = 2.5
FloatingStroke.Parent = FloatingBtn

local FloatingLabel = Instance.new("TextLabel")
FloatingLabel.Size = UDim2.new(1, 0, 1, 0)
FloatingLabel.BackgroundTransparency = 1
FloatingLabel.Text = "🦖"
FloatingLabel.TextSize = 26
FloatingLabel.ZIndex = 1001
FloatingLabel.Parent = FloatingBtn

-- Kéo thả nút tròn
do
    local dragging, dragStart, startPos
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatingBtn.Position
        end
    end)
    FloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            FloatingBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── 2. KHUNG ĐIỀU KHIỂN CHÍNH (MAIN FRAME) ──
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 420)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Nền tối ánh đá núi lửa
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(16, 185, 129)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Kéo thả khung chính
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) 
            and input.Position.Y - MainFrame.AbsolutePosition.Y <= 45 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Bấm nút tròn để ẩn/hiện bảng điều khiển
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ── Header ──
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🦖 STEAL A MONSTER HUB V1.0"
TitleLabel.TextColor3 = Color3.fromRGB(245, 158, 11)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ── Thanh trạng thái Live Banner ──
local StatusBanner = Instance.new("Frame")
StatusBanner.Name = "StatusBanner"
StatusBanner.Size = UDim2.new(1, -24, 0, 30)
StatusBanner.Position = UDim2.new(0, 12, 0, 50)
StatusBanner.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
StatusBanner.BorderSizePixel = 0
StatusBanner.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBanner

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -12, 1, 0)
StatusText.Position = UDim2.new(0, 6, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Trạng thái: " .. Stats.CurrentStatus
StatusText.TextColor3 = Color3.fromRGB(52, 211, 153)
StatusText.TextSize = 11
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBanner

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            StatusText.Text = "Trạng thái: " .. Stats.CurrentStatus
        end)
    end
end)

-- ── Scrollable Body ──
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Name = "ScrollList"
ScrollList.Size = UDim2.new(1, -24, 1, -92)
ScrollList.Position = UDim2.new(0, 12, 0, 86)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 580)
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(16, 185, 129)
ScrollList.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ScrollList

-- ── Helper tạo Toggle Switch ──
local function createToggle(parent, title, desc, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(24, 34, 53)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -85, 0, 22)
    titleLbl.Position = UDim2.new(0, 10, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -85, 0, 16)
    descLbl.Position = UDim2.new(0, 10, 0, 24)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    descLbl.TextSize = 10
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 28)
    toggleBtn.Position = UDim2.new(1, -70, 0, 9)
    toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(75, 85, 99)
    toggleBtn.Text = defaultVal and "BẬT" or "TẮT"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    local isEnabled = defaultVal
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(75, 85, 99)
        toggleBtn.Text = isEnabled and "BẬT" or "TẮT"
        callback(isEnabled)
    end)
    return frame
end

-- ── Helper tạo Action Button ──
local function createActionButton(parent, title, btnText, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(24, 34, 53)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -120, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 100, 0, 28)
    actionBtn.Position = UDim2.new(1, -110, 0, 7)
    actionBtn.BackgroundColor3 = color or Color3.fromRGB(16, 185, 129)
    actionBtn.Text = btnText
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 11
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn

    actionBtn.MouseButton1Click:Connect(callback)
    return frame
end

-- ── 1. TỰ ĐỘNG ĂN CẮP QUÁI VẬT ──
createToggle(ScrollList, "🥷 Tự Động Ăn Cắp Quái Vật (Auto Steal)", "Tự đột nhập căn cứ đối thủ, bế quái và tẩu thoát về nhà", Config.AutoSteal, function(val)
    Config.AutoSteal = val
end)

createToggle(ScrollList, "🛡️ Né Căn Cứ Đang Bật Khóa (Avoid Lockdown)", "Bỏ qua các căn cứ đối thủ đang bật khiên/Lockdown an toàn", Config.AvoidLockdown, function(val)
    Config.AvoidLockdown = val
end)

-- ── 2. TỰ ĐỘNG MUA BĂNG CHUYỀN ──
createToggle(ScrollList, "🛒 Tự Động Mua Băng Chuyền (Auto Buy)", "Tự động kích hoạt mua quái vật chạy trên băng chuyền trung tâm", Config.AutoBuyConveyor, function(val)
    Config.AutoBuyConveyor = val
end)

-- ── 3. TỰ ĐỘNG GOM TIỀN VÀNG ──
createToggle(ScrollList, "💰 Tự Động Thu Tiền Căn Cứ (Coin Vacuum)", "Tự động thu thập tiền do quái vật trong căn cứ sinh ra", Config.AutoCollectCoins, function(val)
    Config.AutoCollectCoins = val
end)

-- ── 4. TỰ ĐỘNG KHÓA CĂN CỨ BẢO VỆ ──
createToggle(ScrollList, "🚨 Tự Động Bật Lockdown Khi Có Địch", "Tự động kích hoạt khóa căn cứ khi phát hiện người lạ đột nhập", Config.AutoLockdown, function(val)
    Config.AutoLockdown = val
end)

-- ── 5. TỰ ĐỘNG TÁI SINH ──
createToggle(ScrollList, "🔄 Tự Động Tái Sinh (Auto Rebirth)", "Tự động Rebirth khi đủ tiền để tăng thời gian Lockdown vĩnh viễn", Config.AutoRebirth, function(val)
    Config.AutoRebirth = val
end)

-- ── 6. TIỆN ÍCH TẨU THOÁT & TỐI ƯU ──
createToggle(ScrollList, "🏃 Tăng Tốc Độ Chạy (Speed Boost 35)", "Tăng tốc chạy giúp tẩu thoát nhanh khi bế quái vật", Config.SpeedBoost, function(val)
    Config.SpeedBoost = val
    if not val then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
    end
end)

createToggle(ScrollList, "🦘 Nhảy Vô Hạn (Infinite Jump)", "Nhảy liên tục trên không trung để vượt tường và chướng ngại vật", Config.InfiniteJump, function(val)
    Config.InfiniteJump = val
end)

createToggle(ScrollList, "👻 Xuyên Tường (Noclip)", "Đi xuyên tường căn cứ đối thủ để rút ngắn đường tẩu thoát", Config.Noclip, function(val)
    Config.Noclip = val
end)

createToggle(ScrollList, "🛡️ Chống Disconnect 24/7 (Anti-AFK)", "Tự động chống văng game sau 20 phút khi treo máy", Config.AntiAFK, function(val)
    Config.AntiAFK = val
end)

createToggle(ScrollList, "🚀 Siêu Mượt 60 FPS (FPS Booster)", "Giảm tải bóng và hiệu ứng hạt cho điện thoại Android", Config.FPSBooster, function(val)
    Config.FPSBooster = val
    applyFPSBooster(val)
end)

-- Nút lưu vị trí căn cứ hiện tại
createActionButton(ScrollList, "📍 Đặt Vị Trí Căn Cứ Hiện Tại", "LƯU TỌA ĐỘ", Color3.fromRGB(59, 130, 246), function()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            MyBaseCFrame = hrp.CFrame
            Stats.CurrentStatus = "📍 Đã lưu tọa độ vị trí căn cứ hiện tại để tẩu thoát!"
        end
    end)
end)

-- ── Thông báo khởi động ──
print("[Steal a Monster Hub] Khởi động thành công V1.0!")
Stats.CurrentStatus = "Sẵn sàng hoạt động! Hãy bật các tính năng bạn muốn."
