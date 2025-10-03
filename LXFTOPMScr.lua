-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "LXFT [ OPM ]",
    Desc = "Test",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "LXFT"
    }
})

-- Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

-- Main Tab (Client-side Safe Helpers)
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Player Helpers"})

    -- Variables
    local autoClickEnabled = false
    local autoClickInterval = 0.10
    local autoConsumeEnabled = false
    local consumeInterval = 5
    local speedBoost = 25
    local jumpBoost = 50
    local espEnabled = false
    local espDots = {}

    local LocalPlayer = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    -------------------------
    -- Auto Click
    -------------------------
    MainTab:Toggle({
        Title = "Auto Click",
        Desc = "Automatically clicks mouse",
        Value = false,
        Callback = function(v)
            autoClickEnabled = v
            if autoClickEnabled then
                spawn(function()
                    while autoClickEnabled do
                        -- ใช้ MouseClick simulation
                        if UserInputService:GetMouseLocation() then
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                        end
                        task.wait(autoClickInterval)
                    end
                end)
            end
        end
    })

    MainTab:Slider({
        Title = "Click Speed",
        Min = 0.05,
        Max = 2,
        Rounding = 2,
        Value = autoClickInterval,
        Callback = function(val)
            autoClickInterval = val
        end
    })

    -------------------------
    -- Auto Consume (Eat/Drink)
    -------------------------
    MainTab:Toggle({
        Title = "Auto Consume",
        Desc = "Automatically eats/drinks items in backpack",
        Value = false,
        Callback = function(v)
            autoConsumeEnabled = v
            if autoConsumeEnabled then
                spawn(function()
                    while autoConsumeEnabled do
                        if LocalPlayer.Backpack then
                            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if item:IsA("Tool") then
                                    -- คลิก/แตะ item client-side
                                    item:Activate()
                                    task.wait(0.2)
                                end
                            end
                        end
                        task.wait(consumeInterval)
                    end
                end)
            end
        end
    })

    MainTab:Slider({
        Title = "Consume Interval",
        Min = 1,
        Max = 60,
        Rounding = 0,
        Value = consumeInterval,
        Callback = function(val)
            consumeInterval = val
        end
    })

    -------------------------
    -- Movement Helpers
    -------------------------
    MainTab:Slider({
        Title = "Speed Boost",
        Min = 16,
        Max = 200,
        Rounding = 0,
        Value = speedBoost,
        Callback = function(val)
            speedBoost = val
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = speedBoost
            end
        end
    })

    MainTab:Slider({
        Title = "Jump Boost",
        Min = 50,
        Max = 500,
        Rounding = 0,
        Value = jumpBoost,
        Callback = function(val)
            jumpBoost = val
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = jumpBoost
            end
        end
    })

    -------------------------
    -- ESP Dot + Name
    -------------------------
    MainTab:Toggle({
        Title = "ESP Dot + Name",
        Desc = "Show small dot and name above players",
        Value = false,
        Callback = function(v)
            espEnabled = v
        end
    })

    RunService.RenderStepped:Connect(function()
        if espEnabled then
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if not espDots[plr] then
                        local dot = Drawing.new("Circle")
                        dot.Radius = 4
                        dot.Color = Color3.fromRGB(0,255,0)
                        dot.Thickness = 1
                        dot.Filled = true
                        espDots[plr] = {dot = dot, name = Drawing.new("Text")}
                        espDots[plr].name.Text = plr.Name
                        espDots[plr].name.Size = 14
                        espDots[plr].name.Color = Color3.fromRGB(255,255,255)
                        espDots[plr].name.Center = true
                    end
                    local hrp = plr.Character.HumanoidRootPart
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        espDots[plr].dot.Position = Vector2.new(pos.X, pos.Y)
                        espDots[plr].dot.Visible = true
                        espDots[plr].name.Position = Vector2.new(pos.X, pos.Y - 10)
                        espDots[plr].name.Visible = true
                    else
                        espDots[plr].dot.Visible = false
                        espDots[plr].name.Visible = false
                    end
                end
            end
        else
            for _, v in pairs(espDots) do
                v.dot:Remove()
                v.name:Remove()
            end
            espDots = {}
        end
    end)

    -------------------------
    -- Mini Map / Nearby Items Highlight (Optional)
    -------------------------
    -- สามารถต่อยอดเพิ่ม overlay items ใกล้ตัวผู้เล่น
end


-- Player List Tab (Spectate / Teleport)
local PlayerListTab = Window:Tab({Title = "Player List", Icon = "user"}) do
    PlayerListTab:Section({Title = "Players"})

    local players = game:GetService("Players")
    local LocalPlayer = players.LocalPlayer

    -- เก็บรายชื่อและคนที่เลือก
    local selectedPlayerName = nil
    local playerNames = {}
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerNames, plr.Name)
        end
    end

    -- Dropdown สำหรับเลือก player
    local playerDropdown = PlayerListTab:Dropdown({
        Title = "Select Player",
        List = playerNames,
        Value = playerNames[1] or "",
        Callback = function(choice)
            selectedPlayerName = choice
            print("Selected player:", choice)
        end
    })

    -- ฟังก์ชันอัปเดตรายชื่อ dropdown
    local function updateDropdown()
        playerNames = {}
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(playerNames, plr.Name)
            end
        end
        playerDropdown:Refresh(playerNames, selectedPlayerName or playerNames[1] or "")
    end

    -- Event อัปเดตรายชื่อเมื่อ player เข้า/ออก
    players.PlayerAdded:Connect(updateDropdown)
    players.PlayerRemoving:Connect(function(plr)
        if plr.Name == selectedPlayerName then
            selectedPlayerName = nil
        end
        updateDropdown()
    end)

    -- เก็บสถานะ spectating
    local isSpectating = false

    -- ปุ่ม Spectate (toggle)
    PlayerListTab:Button({
        Title = "Spectate Player",
        Desc = "Toggle spectate selected player",
        Callback = function()
            if not selectedPlayerName then
                Window:Notify({
                    Title = "Spectate",
                    Desc = "No player selected.",
                    Time = 3
                })
                return
            end

            if isSpectating then
                -- กลับมากล้อง LocalPlayer
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                end
                isSpectating = false
                print("Stopped spectating")
                Window:Notify({
                    Title = "Spectate",
                    Desc = "Stopped spectating.",
                    Time = 3
                })
            else
                -- ไปดู player ที่เลือก
                local targetPlayer = players:FindFirstChild(selectedPlayerName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                    game.Workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
                    isSpectating = true
                    print("Spectating", selectedPlayerName)
                    Window:Notify({
                        Title = "Spectate",
                        Desc = "Now spectating "..selectedPlayerName,
                        Time = 3
                    })
                else
                    Window:Notify({
                        Title = "Spectate",
                        Desc = "Player character not found.",
                        Time = 3
                    })
                end
            end
        end
    })

    -- ปุ่ม Teleport
    PlayerListTab:Button({
        Title = "Teleport to Player",
        Desc = "Teleport to selected player",
        Callback = function()
            if selectedPlayerName then
                local targetPlayer = players:FindFirstChild(selectedPlayerName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = targetPlayer.Character.HumanoidRootPart
                    local plrHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if plrHRP then
                        plrHRP.CFrame = hrp.CFrame
                        print("Teleported to", selectedPlayerName)
                        Window:Notify({
                            Title = "Teleport",
                            Desc = "Teleported to "..selectedPlayerName,
                            Time = 3
                        })
                    end
                else
                    Window:Notify({
                        Title = "Teleport",
                        Desc = "Player character not found.",
                        Time = 3
                    })
                end
            else
                Window:Notify({
                    Title = "Teleport",
                    Desc = "No player selected.",
                    Time = 3
                })
            end
        end
    })
end

-- Auto Click Tab 
local AutoClickTab = Window:Tab({Title = "Auto Click", Icon = "tag"}) do
    AutoClickTab:Section({Title = "Auto Click"})

    local autoClickEnabled = false
    local autoClickInterval = 0.10 -- seconds
    local autoClickThread -- เก็บ reference ของ thread (ถ้ามี)

    -- ฟังก์ชันคลิก (พยายามใช้ mouse1click ถ้ามี, ถ้าไม่มี fallback เป็น VirtualUser)
    local function performClick()
        -- ถ้ามีฟังก์ชัน mouse1click (executor บางตัวมี)
        if type(mouse1click) == "function" then
            local ok, err = pcall(mouse1click)
            if not ok then
                -- ถ้าเรียกไม่สำเร็จ ลอง fallback
                -- (ไม่ต้องทำอะไรที่นี่ — fallback จะลอง VirtualUser ด้านล่าง)
            else
                return
            end
        end

        -- fallback: ใช้ VirtualUser (วิธีทั่วไปใน Roblox)
        local success, vu = pcall(function()
            return game:GetService("VirtualUser")
        end)
        if success and vu then
            pcall(function()
                -- Capture controller เพื่อให้ VirtualUser ทำงานแน่นอน
                vu:CaptureController()
                vu:Button1Down()
                task.wait(0.03) -- กดค้างสั้น ๆ
                vu:Button1Up()
            end)
        end
    end

    AutoClickTab:Toggle({
        Title = "Enable Auto Click",
        Desc = "Automatically clicks",
        Value = false,
        Callback = function(v)
            autoClickEnabled = v
            if autoClickEnabled then
                -- ถ้ามี thread เก่า ยังรันอยู่ ให้ไม่สร้างซ้ำ
                if autoClickThread and type(autoClickThread) == "thread" then
                    -- already running (แต่เราใช้ flag เป็นตัวควบคุม loop อยู่แล้ว)
                else
                    autoClickThread = task.spawn(function()
                        while autoClickEnabled do
                            -- เรียกการคลิกจริง
                            performClick()
                            task.wait(autoClickInterval)
                        end
                    end)
                end
            else
                -- ปิดการทำงาน (flag จะหยุด loop)
                autoClickEnabled = false
            end
        end
    })

    AutoClickTab:Slider({
        Title = "Click Speed",
        Min = 0.05,
        Max = 2,
        Rounding = 2,
        Value = 0.1,
        Callback = function(val)
            autoClickInterval = val
            print("Click speed set to:", val)
        end
    })
end


-- Auto Eat/Drink Tab (รวมเวอร์ชันปลอดภัย + rate limit)
local AutoDrinksTab = Window:Tab({Title = "Auto Drinks", Icon = "tag"}) do
    AutoDrinksTab:Section({Title = "Auto Eat/Drink"})

    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    local autoEatEnabled = false
    local eatInterval = 5

    -- Rate limit: จำนวนครั้งสูงสุดต่อชั่วโมง (ปรับได้)
    local useLimitEnabled = true
    local maxUsesPerHour = 120
    local usesCount = 0
    local lastResetTime = tick()

    -- รายชื่อเครื่องดื่ม (ตรวจชื่อแบบ case-insensitive)
    local drinkNames = {
        "Cider+", "Lemonade+", "Juice+", "Smoothie+",
        "Cider", "Lemonade", "Juice", "Smoothie"
    }

    local function isDrink(itemName)
        if not itemName then return false end
        local lower = string.lower(itemName)
        for _, d in ipairs(drinkNames) do
            if lower == string.lower(d) then
                return true
            end
        end
        return false
    end

    -- wait แบบสุ่มเพื่อให้ดูเป็นมนุษย์
    local function safeWait(minT, maxT)
        task.wait(minT + math.random() * (maxT - minT))
    end

    -- เช็กสถานะพื้นฐานก่อนใช้ (ตัวอย่าง: ไม่ใช้ตอนตาย)
    local function isInBadState(character)
        if not character then return true end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return true end
        if humanoid.Health <= 0 then return true end
        -- เพิ่มเงื่อนไขอื่นได้ตามเกม (เช่น กำลังสู้, สตัน ฯลฯ)
        return false
    end

    -- รีเซ็ตรอบนับการใช้ทุกชั่วโมง
    local function resetUsesIfNeeded()
        if tick() - lastResetTime >= 3600 then
            usesCount = 0
            lastResetTime = tick()
            print("[AutoDrinks] Reset uses counter.")
        end
    end

    -- ฟังก์ชันใช้/ดื่ม item อย่างปลอดภัย
    local function tryUseTool(tool)
        if not tool or not tool.Parent then return false end
        local success = false
        -- พยายาม Equip ก่อน
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(tool)
            end
        end)
        safeWait(0.08, 0.2)

        -- ถ้ามี method Activate ให้ใช้
        local ok, _ = pcall(function()
            if tool and tool.Parent == LocalPlayer.Character and type(tool.Activate) == "function" then
                tool:Activate()
                success = true
            end
        end)

        -- ถ้าไม่สำเร็จ ให้ลอง fallback ด้วย VirtualUser (ถ้ามี)
        if not success then
            pcall(function()
                if VirtualUser and tool and tool.Parent == LocalPlayer.Character then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down()
                    safeWait(0.03, 0.12)
                    VirtualUser:Button1Up()
                    success = true
                end
            end)
        end

        return success
    end

    -- ฟังก์ชันหลัก: ตรวจและกิน/ดื่มใน Backpack
    local function performEat()
        -- รีเซ็ตนับการใช้ถ้าผ่านชั่วโมง
        resetUsesIfNeeded()

        -- ถ้าเปิดจำกัดการใช้และเกินแล้ว ให้ข้ามรอบนี้
        if useLimitEnabled and usesCount >= maxUsesPerHour then
            print("[AutoDrinks] Reached max uses per hour:", usesCount)
            return
        end

        local ok, plr = pcall(function() return LocalPlayer end)
        if not ok or not plr then return end
        local backpack = plr:FindFirstChild("Backpack")
        local character = plr.Character
        if not backpack or not character then return end

        if isInBadState(character) then
            -- อยู่ในสถานะไม่ควรใช้ เช่น ตาย
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Velocity and hrp.Velocity.Magnitude > 8 then
            -- ถ้ากำลังเคลื่อนที่เร็ว ให้หน่วงเล็กน้อยก่อนใช้งาน
            safeWait(0.6, 1.2)
        end

        for _, item in ipairs(backpack:GetChildren()) do
            if item and item:IsA("Tool") and isDrink(item.Name) then
                -- ตรวจอีกทีก่อนใช้งาน (rate limit)
                resetUsesIfNeeded()
                if useLimitEnabled and usesCount >= maxUsesPerHour then
                    print("[AutoDrinks] Stop: reached limit during loop.")
                    return
                end

                local used = false
                local success, err = pcall(function()
                    used = tryUseTool(item)
                end)
                if not success then
                    warn("[AutoDrinks] Error when trying to use tool:", err)
                end

                if used then
                    usesCount = usesCount + 1
                    print(string.format("[AutoDrinks] Used %s (total this hour: %d)", item.Name, usesCount))
                end

                -- รอแบบสุ่มหลังแต่ละการใช้ เพื่อไม่ให้เป็น pattern เดิม
                safeWait(0.6, 1.6)
            end
        end
    end

    -- Toggle Auto
    AutoDrinksTab:Toggle({
        Title = "Enable Auto Eat/Drink",
        Desc = "Automatically drink items in backpack (safer mode)",
        Value = false,
        Callback = function(v)
            autoEatEnabled = v
            if autoEatEnabled then
                task.spawn(function()
                    while autoEatEnabled do
                        performEat()
                        task.wait(eatInterval + math.random() * 1.5) -- หยุดเป็นช่วงสุ่ม
                    end
                end)
            end
        end
    })

    -- Interval Slider
    AutoDrinksTab:Slider({
        Title = "Eat/Drink Interval (sec)",
        Min = 1,
        Max = 60,
        Rounding = 0,
        Value = 5,
        Callback = function(val)
            eatInterval = val
            print("Eat/Drink interval set to:", val)
        end
    })

    -- Optional: เปิด/ปิด rate limit
    AutoDrinksTab:Toggle({
        Title = "Enable Rate Limit (uses/hour)",
        Desc = "Limit how many uses per hour to reduce detection risk",
        Value = useLimitEnabled,
        Callback = function(v)
            useLimitEnabled = v
            print("Rate limit enabled:", useLimitEnabled)
        end
    })

    -- Slider สำหรับ max uses per hour
    AutoDrinksTab:Slider({
        Title = "Max Uses Per Hour",
        Min = 10,
        Max = 1000,
        Rounding = 0,
        Value = maxUsesPerHour,
        Callback = function(val)
            maxUsesPerHour = val
            print("Max uses per hour set to:", val)
        end
    })
end


-- Devil Fruit Tab (Spectate + Teleport + ESP)
local DevilFruitTab = Window:Tab({Title = "Devil Fruits", Icon = "tag"}) do
    DevilFruitTab:Section({Title = "Fruits on Map"})

    local LocalPlayer = game:GetService("Players").LocalPlayer
    local fruits = {} -- เก็บผลปีศาจที่เจอ
    local selectedFruitName = nil
    local fruitDropdown = nil
    local isSpectating = false

    -- ฟังก์ชันอัปเดตรายชื่อผลปีศาจ
    local function updateFruitList()
        fruits = {}
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Tool") and obj.Name:match("Fruit") then
                table.insert(fruits, obj.Name)
            end
        end

        if fruitDropdown then
            fruitDropdown:Refresh(fruits, selectedFruitName or fruits[1] or "")
        else
            fruitDropdown = DevilFruitTab:Dropdown({
                Title = "Select Fruit",
                List = fruits,
                Value = fruits[1] or "",
                Callback = function(choice)
                    selectedFruitName = choice
                    print("Selected fruit:", choice)
                end
            })
        end
    end

    -- อัปเดตผลปีศาจเมื่อมีของใหม่เกิด
    workspace.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") and obj.Name:match("Fruit") then
            task.wait(0.3)
            updateFruitList()
        end
    end)
    workspace.ChildRemoved:Connect(updateFruitList)

    updateFruitList() -- เริ่มต้น

    -- ปุ่ม Spectate
    DevilFruitTab:Button({
        Title = "Spectate Fruit",
        Desc = "View selected fruit",
        Callback = function()
            if not selectedFruitName then
                Window:Notify({
                    Title = "Spectate",
                    Desc = "No fruit selected.",
                    Time = 3
                })
                return
            end

            local targetFruit = workspace:FindFirstChild(selectedFruitName)
            if targetFruit and (targetFruit:FindFirstChild("Handle") or targetFruit.PrimaryPart or targetFruit:IsA("BasePart")) then
                local fruitPart = targetFruit:FindFirstChild("Handle") or targetFruit.PrimaryPart or targetFruit
                if isSpectating then
                    -- กลับมาที่ตัวเอง
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        game.Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                    end
                    isSpectating = false
                    Window:Notify({Title = "Spectate", Desc = "Stopped spectating.", Time = 3})
                else
                    game.Workspace.CurrentCamera.CameraSubject = fruitPart
                    isSpectating = true
                    Window:Notify({Title = "Spectate", Desc = "Now spectating "..selectedFruitName, Time = 3})
                end
            else
                Window:Notify({Title = "Spectate", Desc = "Fruit not found.", Time = 3})
            end
        end
    })

    -- ปุ่ม Teleport
    DevilFruitTab:Button({
        Title = "Teleport to Fruit",
        Desc = "Teleport to selected fruit",
        Callback = function()
            if not selectedFruitName then
                Window:Notify({Title = "Teleport", Desc = "No fruit selected.", Time = 3})
                return
            end

            local targetFruit = workspace:FindFirstChild(selectedFruitName)
            if targetFruit and (targetFruit:FindFirstChild("Handle") or targetFruit.PrimaryPart or targetFruit:IsA("BasePart")) then
                local fruitPart = targetFruit:FindFirstChild("Handle") or targetFruit.PrimaryPart or targetFruit
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = fruitPart.CFrame
                    Window:Notify({Title = "Teleport", Desc = "Teleported to "..selectedFruitName, Time = 3})
                end
            else
                Window:Notify({Title = "Teleport", Desc = "Fruit not found.", Time = 3})
            end
        end
    })
end


-- Player ESP Safe (dot + name)
local PlayerESPTab = Window:Tab({Title = "Main II", Icon = "eye"}) do
    PlayerESPTab:Section({Title = "ESP Options"})

    local espEnabled = false

    PlayerESPTab:Toggle({
        Title = "Enable Player ESP (Dot + Name)",
        Desc = "Show dot and name above players",
        Value = false,
        Callback = function(v)
            espEnabled = v
        end
    })

    local playerDrawings = {}

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    RunService.RenderStepped:Connect(function()
        if not espEnabled then
            -- ลบ Drawing ทุกอัน
            for _, draw in pairs(playerDrawings) do
                if draw.dot then draw.dot:Remove() end
                if draw.name then draw.name:Remove() end
            end
            playerDrawings = {}
            return
        end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2, 0))

                if not playerDrawings[plr] then
                    -- สร้าง Drawing ใหม่
                    local dot = Drawing.new("Circle")
                    dot.Color = Color3.fromRGB(0, 255, 0)
                    dot.Radius = 4
                    dot.Filled = true
                    dot.Thickness = 1

                    local nameLabel = Drawing.new("Text")
                    nameLabel.Text = plr.Name
                    nameLabel.Color = Color3.fromRGB(255, 255, 255)
                    nameLabel.Size = 16
                    nameLabel.Center = true
                    nameLabel.Outline = true

                    playerDrawings[plr] = {dot = dot, name = nameLabel}
                end

                -- อัปเดตตำแหน่ง
                if onScreen then
                    playerDrawings[plr].dot.Visible = true
                    playerDrawings[plr].dot.Position = Vector2.new(screenPos.X, screenPos.Y)

                    playerDrawings[plr].name.Visible = true
                    playerDrawings[plr].name.Position = Vector2.new(screenPos.X, screenPos.Y - 12) -- ชื่อข้างบนจุด
                else
                    playerDrawings[plr].dot.Visible = false
                    playerDrawings[plr].name.Visible = false
                end
            elseif playerDrawings[plr] then
                -- ลบ Drawing ถ้า player ไม่มี character
                playerDrawings[plr].dot:Remove()
                playerDrawings[plr].name:Remove()
                playerDrawings[plr] = nil
            end
        end
    end)
end


Window:Line()

-- Auto Farm Tab (รวม Auto Farm + Anti AFK + Walk/R Loop)
local AutoFarmTab = Window:Tab({Title = "Auto Farm", Icon = "sword"}) do
    AutoFarmTab:Section({Title = "Auto Farm Settings"})

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================
    -- Auto Farm Variables
    -- ==========================
    local autoFarmEnabled = false
    local autoFarmLoopRunning = false
    local farmMode = "Single"
    local farmInterval = 0.5
    local selectedToolName = ""
    local selectedTools = {}
    local currentToolIndex = 1

    -- Mode Dropdown
    AutoFarmTab:Dropdown({
        Title = "Farm Mode",
        List = {"Single", "Multi"},
        Value = farmMode,
        Callback = function(choice)
            farmMode = choice
            print("Farm mode:", farmMode)
        end
    })

    -- Tools input
    AutoFarmTab:Textbox({
        Title = "Tools (comma for multi)",
        Placeholder = "Tool1,Tool2",
        Callback = function(text)
            if farmMode == "Single" then
                selectedToolName = text
            else
                selectedTools = {}
                for tool in string.gmatch(text, "[^,]+") do
                    table.insert(selectedTools, tool)
                end
            end
            print("Selected tools:", farmMode == "Single" and selectedToolName or table.concat(selectedTools, ", "))
        end
    })

    -- Interval Slider
    AutoFarmTab:Slider({
        Title = "Farm Interval (sec)",
        Min = 0.1,
        Max = 2,
        Rounding = 2,
        Value = farmInterval,
        Callback = function(val)
            farmInterval = val
            print("Farm interval set to:", val)
        end
    })

    -- Toggle AutoFarm
    AutoFarmTab:Toggle({
        Title = "Enable Auto Farm",
        Desc = "Automatically attack with selected tool(s)",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if autoFarmEnabled and not autoFarmLoopRunning then
                autoFarmLoopRunning = true
                spawn(function()
                    while autoFarmEnabled do
                        local char = LocalPlayer.Character
                        local backpack = LocalPlayer.Backpack
                        if char and backpack then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                if farmMode == "Single" and selectedToolName ~= "" then
                                    local tool = backpack:FindFirstChild(selectedToolName)
                                    if tool then
                                        tool.Parent = char
                                        print("Farming with:", tool.Name)
                                        task.wait(farmInterval)
                                        tool.Parent = backpack
                                    end
                                elseif farmMode == "Multi" and #selectedTools > 0 then
                                    currentToolIndex = currentToolIndex + 1
                                    if currentToolIndex > #selectedTools then currentToolIndex = 1 end
                                    local tool = backpack:FindFirstChild(selectedTools[currentToolIndex])
                                    if tool then
                                        tool.Parent = char
                                        print("Farming with:", tool.Name)
                                        task.wait(farmInterval)
                                        tool.Parent = backpack
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                    autoFarmLoopRunning = false
                end)
            end
        end
    })

    -- ==========================
    -- Anti AFK Section
    -- ==========================
    AutoFarmTab:Section({Title = "Anti AFK"})

    local antiAFKEnabled = false
    local antiAFKLoopRunning = false
    local antiAFKStep = 0.1
    local antiAFKInterval = 60

    AutoFarmTab:Toggle({
        Title = "Enable Anti AFK",
        Desc = "Keep character active safely to avoid AFK",
        Value = false,
        Callback = function(v)
            antiAFKEnabled = v
            if antiAFKEnabled and not antiAFKLoopRunning then
                antiAFKLoopRunning = true
                spawn(function()
                    while antiAFKEnabled do
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, antiAFKStep, 0)
                            task.wait(1)
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, -antiAFKStep, 0)
                        end
                        task.wait(antiAFKInterval)
                    end
                    antiAFKLoopRunning = false
                end)
            end
        end
    })

    -- ==========================
    -- Walk + R Loop Section
    -- ==========================
    AutoFarmTab:Section({Title = "Haki Farm (Test)"})

    local walkRLoopEnabled = false
    local walkRLoopRunning = false

    local waypoints = {
        Vector3.new(-1263.9, 218, -1354.2),
        Vector3.new(-1264.8, 217, -1393.1),
        Vector3.new(-1135.2, 216.3, -1444.1),
        Vector3.new(-1135.5, 222.9, -1583.3),
        Vector3.new(-1169, 222.9, -1584)
    }

    AutoFarmTab:Toggle({
        Title = "Enable Farm Haki",
        Desc = "Automatically walk to Mob",
        Value = false,
        Callback = function(v)
            walkRLoopEnabled = v
            if walkRLoopEnabled and not walkRLoopRunning then
                walkRLoopRunning = true
                spawn(function()
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid")
                    local hrp = character:WaitForChild("HumanoidRootPart")

                    while walkRLoopEnabled do
                        -- เดินไป waypoint ยกเว้นสุดท้าย
                        for i = 1, #waypoints - 1 do
                            humanoid:MoveTo(waypoints[i])
                            humanoid.MoveToFinished:Wait()
                            task.wait(0.5)
                        end

                        local finalPos = waypoints[#waypoints]

                        -- วนลูปเดินไป final + กด R 2 นาที / เดิน 2 นาที
                        while walkRLoopEnabled do
                            -- กด R ค้าง 2 นาที
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                            task.wait(120)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)

                            -- เดินกลับ finalPos 2 นาที
                            local startTime = tick()
                            while tick() - startTime < 120 and walkRLoopEnabled do
                                local distance = (hrp.Position - finalPos).Magnitude
                                if distance > 10 then
                                    humanoid:MoveTo(finalPos)
                                end
                                task.wait(0.5)
                            end
                        end
                    end
                    walkRLoopRunning = false
                end)
            end
        end
    })

end



-- Line Separator
Window:Line()

-- Extra Tab
local Extra = Window:Tab({Title = "Extra", Icon = "tag"}) do
    Extra:Section({Title = "About"})
    Extra:Button({
        Title = "Show Message",
        Desc = "Display a popup",
        Callback = function()
            Window:Notify({
                Title = "Fluent UI",
                Desc = "Everything works fine!",
                Time = 3
            })
        end
    })

    -------------------------
    -- Fly System
    -------------------------
    Extra:Section({Title = "Fly System"})

    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInput = game:GetService("UserInputService")

    -- รายชื่อตำแหน่ง
    local locations = {
        ["Windmill"] = Vector3.new(105.8, 265.0, -37.4),
        ["Big Cave"] = Vector3.new(60.9, 300.0, -986.7),
        ["Sam Island"] = Vector3.new(-1410.2, 268.7, -1440.1),
        ["Orange House"] = Vector3.new(868.3, 290.0, 1243.1),
        ["Cafe"] = Vector3.new(1480.2, 288.6, 2128.8),
        ["Red House"] = Vector3.new(1126.2, 220.9, 3345.6),
        ["Sand (AF)"] = Vector3.new(122.8, 282.5, 4945.1),
        ["Snow Island (Small)"] = Vector3.new(-1819.4, 412.2, 3322.9),
        ["Ball"] = Vector3.new(-2621.9, 317.9, 1099.4),
        ["Big Tree"] = Vector3.new(-6034.5, 424.7, -7.5),
        ["One Block"] = Vector3.new(-4004.7, 220.1, -2191.0),
        ["Marin"] = Vector3.new(-3134.5, 509.0, -3990.7),
        ["Purple Island"] = Vector3.new(-5284.6, 544.2, -7758.0),
        ["Sand Island"] = Vector3.new(1075.6, 289.5, -3332.1),
        ["Summon Island"] = Vector3.new(4846.3, 648.7, -7257.8),
        ["Snow Island (Big)"] = Vector3.new(6209.7, 586.6, -1263.7),
        ["Vokun Island"] = Vector3.new(4613.5, 587.0, 5265.0),
        ["Moon Island"] = Vector3.new(3229, 420.0, 1675.3),
        ["Mini Town"] = Vector3.new(1886.2, 340.6, 634.9),
        ["Tree Stone"] = Vector3.new(-31.2, 248.8, 2153.5),
        ["Krizma Island"] = Vector3.new(-1073.9, 380.5, 1668.7),
        ["Sand Island (Very Small)"] = Vector3.new(-1213.9, 266.7, 651.9),
        ["Bear Island"] = Vector3.new(-1623.6, 260.0, -248.5)
    }

    local selectedLocation = nil
    local FlyMode = "Not Gas"
    local FlyKey = Enum.KeyCode.Z

    -- Dropdown เลือกตำแหน่ง
    local locDropdown = Extra:Dropdown({
        Title = "Select Location",
        List = (function() local t={} for k,v in pairs(locations) do table.insert(t,k) end return t end)(),
        Value = "Windmill",
        Callback = function(choice)
            selectedLocation = choice
        end
    })
    selectedLocation = locDropdown.Value

    -- Dropdown เลือกโหมดบิน
    local modeDropdown = Extra:Dropdown({
        Title = "Fly Mode",
        List = {"Gas", "Not Gas"},
        Value = "Not Gas",
        Callback = function(choice)
            FlyMode = choice
        end
    })

    -- Dropdown เลือก KeyBind
    local keyDropdown = Extra:Dropdown({
        Title = "Fly Key",
        List = {"Z","X","C","V","B","N","F"},
        Value = "Z",
        Callback = function(choice)
            FlyKey = Enum.KeyCode[choice]
        end
    })

    local flyActive = false

    Extra:Button({
        Title = "Fly to Mark",
        Desc = "Start flying to the selected location",
        Callback = function()
            if flyActive then return end
            flyActive = true
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            local target = locations[selectedLocation]
            if not target then return end

            spawn(function()
                local vu = game:GetService("VirtualUser")

                -- Gas Mode กด KeyBind ก่อนลอย
                if FlyMode == "Gas" then
                    vu:CaptureController()
                    vu:Button2Down() -- simulate key press
                    task.wait(0.1)
                    vu:Button2Up()
                end

                -- ลอยขึ้น 30 stud
                local upTween = TweenService:Create(hrp, TweenInfo.new(0.5), {CFrame = hrp.CFrame + Vector3.new(0,30,0)})
                upTween:Play()
                upTween.Completed:Wait()

                -- ลอยไปตำแหน่ง
                local distance = (Vector3.new(target.X, target.Y+30, target.Z) - hrp.Position).Magnitude
                local moveTween = TweenService:Create(hrp, TweenInfo.new(distance/100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target.X, target.Y+30, target.Z)})
                moveTween:Play()
                moveTween.Completed:Wait()

                -- กด KeyBind อีกครั้งเมื่อถึง
                if FlyMode == "Gas" then
                    vu:CaptureController()
                    vu:Button2Down()
                    task.wait(0.1)
                    vu:Button2Up()
                end

                flyActive = false
            end)
        end
    })
end



Window:Line()

-- Settings Tab
local Settings = Window:Tab({Title = "Settings", Icon = "wrench"}) do
    Settings:Section({Title = "Config"})
    Settings:Button({
        Title = "Show Message",
        Desc = "Display a popup",
        Callback = function()
            Window:Notify({
                Title = "Fluent UI",
                Desc = "Everything works fine!",
                Time = 3
            })
        end
    })
end

-- Final Notification
Window:Notify({
    Title = "LX",
    Desc = "All components loaded successfully! Credits Ui: @x2zu",
    Time = 4

})





