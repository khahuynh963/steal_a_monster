--[[
    ===================================================================
    🦖 STEAL A MONSTER HUB - BẢN TINH GỌN (LITE & SPEED EDITION) V2.2
    Game: [🦖] Ăn cắp một con quái vật! (Steal a Monster!)
    Developer: Oops Again
    Repository: https://github.com/khahuynh963/steal_a_monster.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus, Solara.
    
    CÁC TÍNH NĂNG CHÍNH ĐÃ KHẮC PHỤC TRIỆT ĐỂ:
    1. 🥷 1 NHẤN LẤY QUÁI VẬT (AUTO-HOLD 1-TAP STEAL):
       - Không còn lỗi bị hủy hold! Script tự động giữ nút thay người chơi đúng thời lượng server yêu cầu (1.2s).
       - Tự động ghim đứng yên vị trí khi cướp để không bị trượt ra ngoài.
       - Tích hợp thêm Nút Nổi "⚡ CƯỚP NHANH" trên màn hình để chạm 1 phát là tự bế quái gần nhất!
    2. ⚡ TĂNG TỐC ĐỘ CHẠY SIÊU MƯỢT (SMOOTH PHYSICS SPEED BOOST - CHỐNG GIẬT LÙI 100%):
       - Động cơ đẩy AssemblyLinearVelocity chuẩn vật lý Roblox, loại bỏ hoàn toàn CFrame offset thô.
       - Triệt tiêu 100% hiện tượng giật lùi (Rubberbanding / Rollback) khi chạy tốc độ cao.
       - Tự động khóa chống ngã/ragdoll khi va chạm, hãm phanh mượt mà khi nhả phím di chuyển.
    3. 🛡️ CHỐNG PHÁT HIỆN TỐC ĐỘ (SAFE ANTI-SPEED DETECT SPOOFER):
       - Ngụy trang WalkSpeed = 16 an toàn, không can thiệp __newindex tránh lỗi kẹt trạng thái bế quái.
    4. 💤 CHỐNG TREO MÁY AFK 24/7 (ANTI-AFK):
       - Chống ngắt kết nối sau 20 phút.
    ===================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local ProximityPromptService = nil
pcall(function()
    ProximityPromptService = game:GetService("ProximityPromptService")
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

-- ── Cấu hình & Biến trạng thái ──
local Config = {
    -- 1. Tốc độ
    SpeedBoost = false,
    SpeedLevelIndex = 2,
    SpeedPresets = {
        { Name = "⚡ Êm Ái (Speed 35)", Value = 35 },
        { Name = "🚀 Siêu Tốc (Speed 60)", Value = 60 },
        { Name = "🌪️ Cuồng Phong (Speed 90)", Value = 90 },
        { Name = "⚡ Tia Chớp (Speed 125)", Value = 125 },
        { Name = "👑 Thần Tốc (Speed 165)", Value = 165 },
        { Name = "🔥 Max Sonic (Speed 220)", Value = 220 }
    },
    
    -- 2. Một nhấn lấy quái vật
    InstantSteal = true,
    ExtendRange = true,
    PromptRange = 30,
    
    -- 3. Chống phát hiện tốc độ
    AntiSpeedDetect = true,
    
    -- 4. Anti-AFK
    AntiAFK = true
}

local Stats = {
    CurrentStatus = "Sẵn sàng hoạt động!",
    StealsCount = 0
}

local isHoldingMonster = false

-- ===================================================================
-- 🛡️ MÔ-ĐUN 1: CHỐNG PHÁT HIỆN TĂNG TỐC ĐỘ (SAFE ANTI-SPEED BYPASS)
-- ===================================================================
-- Chỉ ngụy trang __index để khi game kiểm tra WalkSpeed thì thấy 16,
-- TUYỆT ĐỐI KHÔNG chặn __newindex để game có thể gán trạng thái vác quái bình thường.
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() and Config.AntiSpeedDetect then
                pcall(function()
                    if self:IsA("Humanoid") and key == "WalkSpeed" then
                        local real = oldIndex(self, key)
                        if real and real > 16 then
                            return 16
                        end
                        return real
                    end
                end)
            end
            return oldIndex(self, key)
        end))
        print("[Steal a Monster Hub] Đã kích hoạt Metatable Hook chống phát hiện tốc độ an toàn!")
    end
end)

-- ===================================================================
-- ⚡ MÔ-ĐUN 2: TĂNG TỐC ĐỘ CHẠY SIÊU MƯỢT (SMOOTH PHYSICS SPEED BOOST)
-- ===================================================================
-- Chống giật lùi (Anti-Rubberband): Sử dụng AssemblyLinearVelocity đồng bộ chuẩn
-- vật lý Roblox replication. Giữ nguyên trục Y để trọng lực, nhảy và rơi tự nhiên.
local function applyCurrentSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 then
            if Config.SpeedBoost and not isHoldingMonster then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                hum.WalkSpeed = preset.Value
            else
                hum.WalkSpeed = 16
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end
            end
        end
    end)
end

-- Thiết lập chống vấp ngã (Anti-Fall/Ragdoll) và khôi phục tốc độ cho nhân vật
local function setupCharacter(char)
    task.wait(0.3)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            -- Chống vấp té, ragdoll khi va chạm góc cạnh ở tốc độ cao
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            if Config.SpeedBoost and not isHoldingMonster then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                hum.WalkSpeed = preset.Value
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Duy trì tốc độ và gia tốc mượt mà qua Heartbeat (Chuẩn vật lý, KHÔNG CFrame offset, chống giật lùi 100%)
RunService.Heartbeat:Connect(function(dt)
    if Config.SpeedBoost and not isHoldingMonster then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                local targetSpeed = preset.Value or 60
                
                -- 1. Khóa cố định WalkSpeed của Humanoid
                if hum.WalkSpeed ~= targetSpeed then
                    hum.WalkSpeed = targetSpeed
                end
                
                -- 2. Gia tốc vật lý thuần túy (AssemblyLinearVelocity)
                -- Khi di chuyển: đẩy vận tốc theo hướng joystick/bàn phím
                if hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection.Unit
                    local currentY = hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * targetSpeed,
                        currentY,
                        moveDir.Z * targetSpeed
                    )
                else
                    -- Khi nhả phím di chuyển: hãm phanh mượt mà trên trục ngang X-Z
                    local currentVel = hrp.AssemblyLinearVelocity
                    local horizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
                    if horizSpeed > 1 then
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            currentVel.X * 0.75,
                            currentVel.Y,
                            currentVel.Z * 0.75
                        )
                    end
                end
            end
        end)
    elseif isHoldingMonster then
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
end)

-- ===================================================================
-- 🥷 MÔ-ĐUN 3: 1 NHẤN LẤY QUÁI VẬT (AUTO-HOLD 1-TAP STEAL)
-- ===================================================================
-- Hàm thực hiện cướp quái: Tự động giữ nút đủ thời lượng server yêu cầu,
-- người chơi CHỈ CẦN CHẠM 1 LẦN mà không cần phải giữ tay trên màn hình!
local function performStealHold(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
    if isHoldingMonster then return end
    isHoldingMonster = true
    
    task.spawn(function()
        local anchorConn = nil
        local success, err = pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- 1. Triệt tiêu vận tốc ngay lập tức để không bị trượt quán tính
            if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
            
            -- 2. Đọc thời gian giữ thực tế của prompt (thường 1.0s - 1.5s)
            local holdTime = prompt.HoldDuration
            if not holdTime or holdTime <= 0 then holdTime = 1.2 end
            
            Stats.CurrentStatus = string.format("🥷 Đang tự động giữ cướp... (%.1fs - Không cần giữ tay!)", holdTime)
            
            -- 3. Khóa vị trí nhân vật cạnh quái vật trong suốt thời gian giữ
            local lockCF = hrp and hrp.CFrame
            if hrp and lockCF then
                anchorConn = RunService.Heartbeat:Connect(function()
                    if isHoldingMonster and hrp then
                        hrp.CFrame = lockCF
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            end
            
            -- 4. Bắt đầu giữ nút trên client
            pcall(function()
                prompt:InputHoldBegin()
            end)
            
            -- 5. Đợi đúng thời gian quy định để server xác nhận hợp lệ
            task.wait(holdTime + 0.15)
            
            -- 6. Hoàn tất giữ nút
            pcall(function()
                prompt:InputHoldEnd()
            end)
            
            -- Dự phòng gọi thêm fireproximityprompt nếu executor hỗ trợ
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt, holdTime)
                end
            end)
            
            -- Kích hoạt tín hiệu Triggered nếu có
            pcall(function()
                if firesignal and prompt.Triggered then
                    firesignal(prompt.Triggered, LocalPlayer)
                end
            end)
            
            Stats.StealsCount = Stats.StealsCount + 1
            Stats.CurrentStatus = string.format("✅ Cướp thành công! (Lần %d) - Đang kích hoạt tốc độ tẩu thoát!", Stats.StealsCount)
        end)
        
        -- Mở khóa nhân vật an toàn (luôn chạy kể cả khi có lỗi)
        pcall(function()
            if anchorConn then anchorConn:Disconnect() end
        end)
        task.wait(0.2)
        isHoldingMonster = false
        
        if not success then
            warn("[Steal a Monster] Lỗi cướp quái:", err)
        end
    end)
end

-- Tối ưu hóa ProximityPrompt: Mở rộng tầm với và không yêu cầu góc nhìn thẳng
local function optimizePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        -- GIỮ NGUYÊN HoldDuration của game để không bị server hủy cướp
        prompt.RequiresLineOfSight = false
        if Config.ExtendRange then
            prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, Config.PromptRange or 30)
        end
    end)
end

pcall(function()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            optimizePrompt(prompt)
        end
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        task.wait(0.05)
        optimizePrompt(desc)
    end
end)

-- Bắt sự kiện khi người chơi chạm/bấm 1 cái vào nút cướp trên màn hình
if ProximityPromptService then
    pcall(function()
        ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
            if player == LocalPlayer and Config.InstantSteal and not isHoldingMonster then
                local act = stripVietnameseAccents(prompt.ActionText)
                local obj = stripVietnameseAccents(prompt.ObjectText)
                local pName = prompt.Parent and stripVietnameseAccents(prompt.Parent.Name) or ""
                
                -- Nhận diện prompt cướp quái vật
                local isSteal = act:find("steal") or act:find("cap") or act:find("cuop") or act:find("take") or act:find("grab") or act:find("lay") or act:find("be")
                             or obj:find("monster") or obj:find("steal") or obj:find("quai")
                             or pName:find("monster") or pName:find("quai") or act == ""
                
                if isSteal then
                    performStealHold(prompt)
                end
            end
        end)
    end)
end

-- Tìm quái vật có prompt cướp ở gần nhất trong phạm vi maxDist
local function findNearestStealPrompt(maxDist)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearestPrompt = nil
    local shortestDist = maxDist or 30
    
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
            local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
            if pPart then
                local dist = (pPart.Position - hrp.Position).Magnitude
                if dist < shortestDist then
                    local act = stripVietnameseAccents(prompt.ActionText)
                    local obj = stripVietnameseAccents(prompt.ObjectText)
                    local pName = stripVietnameseAccents(prompt.Parent.Name)
                    
                    local isSteal = act:find("steal") or act:find("cap") or act:find("cuop") or act:find("take") or act:find("grab") or act:find("lay") or act:find("be")
                                 or obj:find("monster") or obj:find("steal") or obj:find("quai")
                                 or pName:find("monster") or pName:find("quai") or act == ""
                    
                    if isSteal then
                        shortestDist = dist
                        nearestPrompt = prompt
                    end
                end
            end
        end
    end
    return nearestPrompt
end

-- ===================================================================
-- 💤 MÔ-ĐUN 4: CHỐNG TREO MÁY AFK 24/7 (ANTI-AFK)
-- ===================================================================
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

-- ===================================================================
-- 🎨 GIAO DIỆN ĐIỀU KHIỂN: JURASSIC SPEED EDITION (EMERALD & DRAGON GOLD)
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

-- ── 2. NÚT NỔI "⚡ CƯỚP NHANH" DÀNH CHO ĐIỆN THOẠI (QUICK STEAL FLOATING BUTTON) ──
local QuickStealBtn = Instance.new("TextButton")
QuickStealBtn.Name = "QuickStealFloatingBtn"
QuickStealBtn.Size = UDim2.new(0, 52, 0, 52)
QuickStealBtn.Position = UDim2.new(0.04, 0, 0.32, 0)
QuickStealBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11) -- Vàng cam nổi bật
QuickStealBtn.BorderSizePixel = 0
QuickStealBtn.AutoButtonColor = true
QuickStealBtn.Text = "⚡"
QuickStealBtn.TextSize = 28
QuickStealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickStealBtn.ZIndex = 1000
QuickStealBtn.Parent = ScreenGui

local QuickCorner = Instance.new("UICorner")
QuickCorner.CornerRadius = UDim.new(1, 0)
QuickCorner.Parent = QuickStealBtn

local QuickStroke = Instance.new("UIStroke")
QuickStroke.Color = Color3.fromRGB(16, 185, 129)
QuickStroke.Thickness = 2.5
QuickStroke.Parent = QuickStealBtn

-- Kéo thả nút Cướp Nhanh
do
    local dragging, dragStart, startPos
    QuickStealBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = QuickStealBtn.Position
        end
    end)
    QuickStealBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            QuickStealBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Chạm nút ⚡ để tự động cướp quái vật gần nhất ngay lập tức
QuickStealBtn.MouseButton1Click:Connect(function()
    local prompt = findNearestStealPrompt(35)
    if prompt then
        performStealHold(prompt)
    else
        Stats.CurrentStatus = "⚠️ Hãy lại gần quái vật trong căn cứ đối thủ rồi bấm ⚡!"
    end
end)

-- ── 3. KHUNG ĐIỀU KHIỂN CHÍNH (MAIN FRAME TINH GỌN) ──
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 370)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -185)
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

-- Bấm nút tròn 🦖 để ẩn/hiện bảng điều khiển
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
TitleLabel.Text = "🦖 STEAL A MONSTER - SPEED & 1-CLICK V2.1"
TitleLabel.TextColor3 = Color3.fromRGB(245, 158, 11)
TitleLabel.TextSize = 13
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
        task.wait(0.4)
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
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 390)
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

-- ===================================================================
-- CÁC TÍNH NĂNG ĐƯỢC HIỂN THỊ TRÊN GIAO DIỆN
-- ===================================================================

-- 1. NÚT THỰC THI CƯỚP QUÁI GẦN NHẤT
createActionButton(ScrollList, "⚡ Cướp Quái Vật Gần Nhất (1-Chạm)", "CƯỚP NGAY", Color3.fromRGB(245, 158, 11), function()
    local prompt = findNearestStealPrompt(35)
    if prompt then
        performStealHold(prompt)
    else
        Stats.CurrentStatus = "⚠️ Hãy tiến lại gần quái vật đối thủ rồi bấm CƯỚP NGAY!"
    end
end)

-- 2. BẬT / TẮT 1 NHẤN LẤY QUÁI VẬT
createToggle(ScrollList, "🥷 1 Nhấn Lấy Quái Vật (Auto-Hold)", "Chạm 1 cái là tự giữ nút bế quái, không cần giữ tay!", Config.InstantSteal, function(val)
    Config.InstantSteal = val
    if val then
        Stats.CurrentStatus = "🥷 Đã bật 1 Nhấn Lấy Quái! Chạm 1 cái là tự cướp."
    else
        Stats.CurrentStatus = "Đã tắt 1 Nhấn Lấy Quái."
    end
end)

-- 3. BẬT / TẮT TĂNG TỐC ĐỘ CHẠY
createToggle(ScrollList, "⚡ Tăng Tốc Độ Chạy (Speed Boost)", "Bật tốc độ siêu mượt, chuẩn vật lý chống giật lùi 100%", Config.SpeedBoost, function(val)
    Config.SpeedBoost = val
    applyCurrentSpeed()
    if val then
        local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
        Stats.CurrentStatus = "⚡ Đã bật Tăng Tốc: " .. preset.Name
    else
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then hum.WalkSpeed = 16 end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
        Stats.CurrentStatus = "Đã tắt Tăng Tốc."
    end
end)

-- 4. CHỌN MỨC TỐC ĐỘ
do
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, 0, 0, 42)
    speedFrame.BackgroundColor3 = Color3.fromRGB(24, 34, 53)
    speedFrame.BorderSizePixel = 0
    speedFrame.Parent = ScrollList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = speedFrame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 140, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Chọn Mức Tốc Độ:"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = speedFrame

    local currentPreset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(1, -155, 0, 28)
    speedBtn.Position = UDim2.new(0, 145, 0, 7)
    speedBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    speedBtn.Text = currentPreset.Name
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.TextSize = 11
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.Parent = speedFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = speedBtn

    speedBtn.MouseButton1Click:Connect(function()
        Config.SpeedLevelIndex = Config.SpeedLevelIndex + 1
        if Config.SpeedLevelIndex > #Config.SpeedPresets then
            Config.SpeedLevelIndex = 1
        end
        local newPreset = Config.SpeedPresets[Config.SpeedLevelIndex]
        speedBtn.Text = newPreset.Name
        if Config.SpeedBoost then
            applyCurrentSpeed()
            Stats.CurrentStatus = "⚡ Đã chuyển tốc độ: " .. newPreset.Name
        end
    end)
end

-- 5. CHỐNG PHÁT HIỆN TĂNG TỐC ĐỘ (ANTI-SPEED DETECT BYPASS)
createToggle(ScrollList, "🛡️ Chống Phát Hiện Tốc Độ (Anti-Detect)", "Ẩn chỉ số WalkSpeed qua Metatable, chống game phát hiện/kick", Config.AntiSpeedDetect, function(val)
    Config.AntiSpeedDetect = val
    if val then
        Stats.CurrentStatus = "🛡️ Đã bật Chống Phát Hiện Tốc Độ!"
    else
        Stats.CurrentStatus = "Đã tắt Chống Phát Hiện Tốc Độ."
    end
end)

-- 6. CHỐNG TREO MÁY AFK 24/7
createToggle(ScrollList, "💤 Chống Treo Máy AFK 24/7 (Anti-AFK)", "Tự động chống văng game sau 20 phút khi treo máy", Config.AntiAFK, function(val)
    Config.AntiAFK = val
end)

-- ── Thông báo khởi động ──
print("[Steal a Monster Hub] Khởi động thành công Bản V2.1!")
Stats.CurrentStatus = "Sẵn sàng hoạt động! Hãy chạm 1 lần hoặc bấm nút ⚡ để cướp quái."
