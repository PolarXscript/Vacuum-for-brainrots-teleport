-- =====================
--    LOAD RAYFIELD
-- =====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =====================
--    ROLE SYSTEM
-- =====================
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Isi username sesuai kebutuhan
local OWNERS   = {"UsernameOwner1"}   -- ganti username owner
local ADMINS   = {"UsernameAdmin1"}   -- ganti username admin
local PREMIUMS = {"UsernamePremium1"} -- ganti username premium

local function hasRole(list)
   for _, name in pairs(list) do
      if name == LocalPlayer.Name then return true end
   end
   return false
end

local isOwner   = hasRole(OWNERS)
local isAdmin   = hasRole(ADMINS)
local isPremium = hasRole(PREMIUMS)
local isFree    = not isOwner and not isAdmin and not isPremium

-- Cek apakah boleh akses fitur
-- level: "free" | "premium" | "admin" | "owner"
local function canAccess(level)
   if isOwner then return true end
   if level == "owner" then return false end
   if isAdmin then return true end
   if level == "admin" then return false end
   if isPremium then return true end
   if level == "premium" then return false end
   return true -- level "free", semua bisa
end

local function roleLabel()
   if isOwner   then return "👑 Owner"   end
   if isAdmin   then return "🛡️ Admin"   end
   if isPremium then return "⭐ Premium" end
   return "🆓 Free"
end

-- =====================
--      WINDOW
-- =====================
local Window = Rayfield:CreateWindow({
   Name = "X Script",
   LoadingTitle = "X script",
   LoadingSubtitle = "by X script",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MyHub",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "yourdiscord",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "My Hub",
      Subtitle = "Key System",
      Note = "Masukkan key yang benar untuk lanjut!",
      FileName = "MyHubKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = "X script"
   }
})

-- =====================
--       TABS
-- =====================
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab   = Window:CreateTab("Misc",   4483362458)

-- =====================
--    SERVICES
-- =====================
local RS          = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")

-- =====================
--   DETECT MOBILE
-- =====================
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- =====================
--  TOMBOL TURUN GUI
-- =====================
local mobileDown = false
local mobileGui  = nil

local function createDownButton()
   if not isMobile then return end
   mobileGui = Instance.new("ScreenGui")
   mobileGui.Name             = "FlyDownGui"
   mobileGui.ResetOnSpawn     = false
   mobileGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
   mobileGui.Parent           = LocalPlayer.PlayerGui
   local btn = Instance.new("TextButton")
   btn.Size                   = UDim2.new(0, 50, 0, 50)
   btn.Position               = UDim2.new(1, -65, 0, 15)
   btn.BackgroundColor3       = Color3.fromRGB(20, 20, 20)
   btn.BackgroundTransparency = 0.3
   btn.Text                   = "▼"
   btn.TextColor3             = Color3.fromRGB(255, 255, 255)
   btn.TextSize               = 20
   btn.Font                   = Enum.Font.GothamBold
   btn.Parent                 = mobileGui
   Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
   btn.InputBegan:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.Touch then mobileDown = true end
   end)
   btn.InputEnded:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.Touch then mobileDown = false end
   end)
end

local function removeDownButton()
   mobileDown = false
   if mobileGui then mobileGui:Destroy(); mobileGui = nil end
end

-- =====================
--    FLY FEATURE
-- =====================
local flyEnabled  = false
local flySpeed    = 50
local bodyGyro, bodyVelocity
local flyConnection
local jumpHeld    = false
local jumpConnRef = nil

local function startFly()
   local char     = LocalPlayer.Character
   if not char then return end
   local hrp      = char:FindFirstChild("HumanoidRootPart")
   local humanoid = char:FindFirstChild("Humanoid")
   if not hrp or not humanoid then return end
   humanoid.PlatformStand   = true
   humanoid.AutoJumpEnabled = false
   bodyGyro           = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
   bodyGyro.P         = 9e4
   bodyGyro.Parent    = hrp
   bodyVelocity          = Instance.new("BodyVelocity")
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bodyVelocity.Parent   = hrp
   jumpConnRef = UIS.JumpRequest:Connect(function()
      if flyEnabled then jumpHeld = true end
   end)
   createDownButton()
   local jumpTimer = 0
   local camera    = workspace.CurrentCamera
   flyConnection = RS.RenderStepped:Connect(function(dt)
      if not flyEnabled then return end
      local char2 = LocalPlayer.Character
      local hum2  = char2 and char2:FindFirstChild("Humanoid")
      if not hum2 then return end
      local moveDir = Vector3.new(0, 0, 0)
      if isMobile then
         local md = hum2.MoveDirection
         if md.Magnitude > 0.1 then moveDir = moveDir + Vector3.new(md.X, 0, md.Z) end
         if jumpHeld then jumpTimer = 0.5; jumpHeld = false end
         if jumpTimer > 0 then moveDir = moveDir + Vector3.new(0, 1, 0); jumpTimer = jumpTimer - dt end
         if mobileDown then moveDir = moveDir - Vector3.new(0, 1, 0) end
      else
         if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector  end
         if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector  end
         if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
         if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
         if UIS:IsKeyDown(Enum.KeyCode.Space)       then moveDir = moveDir + Vector3.new(0,  1, 0) end
         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,  1, 0) end
      end
      bodyVelocity.Velocity = moveDir * flySpeed
      bodyGyro.CFrame       = camera.CFrame
   end)
end

local function stopFly()
   flyEnabled = false; jumpHeld = false
   if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
   if jumpConnRef   then jumpConnRef:Disconnect();   jumpConnRef   = nil end
   local char     = LocalPlayer.Character
   local humanoid = char and char:FindFirstChild("Humanoid")
   if humanoid then humanoid.PlatformStand = false; humanoid.AutoJumpEnabled = true end
   if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end
   if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
   removeDownButton()
end

LocalPlayer.CharacterAdded:Connect(function()
   if flyEnabled then task.wait(0.5); startFly() end
end)

-- =====================
--   NOCLIP FEATURE
-- =====================
local noclipEnabled = false
local noclipConnection

local function startNoclip()
   noclipConnection = RS.Stepped:Connect(function()
      local char = LocalPlayer.Character
      if char then
         for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
         end
      end
   end)
end

local function stopNoclip()
   if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
   local char = LocalPlayer.Character
   if char then
      for _, part in pairs(char:GetDescendants()) do
         if part:IsA("BasePart") then part.CanCollide = true end
      end
   end
end

-- =====================
--    GOD MODE FEATURE
-- =====================
local godEnabled    = false
local godConnection

local function startGod()
   godConnection = RS.Heartbeat:Connect(function()
      if not godEnabled then return end
      local c   = LocalPlayer.Character
      local hum = c and c:FindFirstChild("Humanoid")
      if hum then hum.Health = hum.MaxHealth end
   end)
   local char     = LocalPlayer.Character
   local humanoid = char and char:FindFirstChild("Humanoid")
   if humanoid then
      humanoid.HealthChanged:Connect(function(health)
         if not godEnabled then return end
         if health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
      end)
   end
   LocalPlayer.CharacterAdded:Connect(function(newChar)
      if not godEnabled then return end
      task.wait(0.1)
      local hum = newChar:FindFirstChild("Humanoid")
      if hum then hum.Health = hum.MaxHealth end
   end)
end

local function stopGod()
   if godConnection then godConnection:Disconnect(); godConnection = nil end
end

-- =====================
--    ESP FEATURE
-- =====================
local espEnabled = false
local espBoxes   = {}

local function createESP(player)
   if player == LocalPlayer then return end
   local highlight               = Instance.new("Highlight")
   highlight.FillColor           = Color3.fromRGB(255, 0, 0)
   highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
   highlight.FillTransparency    = 0.5
   highlight.OutlineTransparency = 0
   espBoxes[player]              = highlight
end

local function removeESP(player)
   if espBoxes[player] then espBoxes[player]:Destroy(); espBoxes[player] = nil end
end

RS.RenderStepped:Connect(function()
   if not espEnabled then return end
   for player, highlight in pairs(espBoxes) do
      if player.Character then highlight.Parent = player.Character end
   end
end)

-- =====================
--   AIM LOCK FEATURE
-- =====================
local aimlockEnabled = false
local aimlockTarget  = "Badan"

local function getNearestPlayer()
   local camera        = workspace.CurrentCamera
   local closestDist   = math.huge
   local closestPlayer = nil
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local hrp      = player.Character:FindFirstChild("HumanoidRootPart")
         local humanoid = player.Character:FindFirstChild("Humanoid")
         if hrp and humanoid and humanoid.Health > 0 then
            local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
            if onScreen then
               local dist = Vector2.new(screenPos.X, screenPos.Y)
                          - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
               if dist.Magnitude < closestDist then
                  closestDist = dist.Magnitude; closestPlayer = player
               end
            end
         end
      end
   end
   return closestPlayer
end

RS.RenderStepped:Connect(function()
   if not aimlockEnabled then return end
   if not isMobile and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
   local target = getNearestPlayer()
   if target and target.Character then
      local targetPos
      if aimlockTarget == "Kepala" then
         local head = target.Character:FindFirstChild("Head")
         if head then targetPos = head.Position end
      elseif aimlockTarget == "Kaki" then
         local hrp = target.Character:FindFirstChild("HumanoidRootPart")
         if hrp then targetPos = hrp.Position - Vector3.new(0, 2.5, 0) end
      else
         local hrp = target.Character:FindFirstChild("HumanoidRootPart")
         if hrp then targetPos = hrp.Position end
      end
      if targetPos then
         local targetCFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
         workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCFrame, 0.2)
      end
   end
end)

-- =====================
--  HELPER: LOCKED MSG
-- =====================
local function notifyLocked(requiredRole)
   Rayfield:Notify({
      Title   = "🔒 Akses Ditolak",
      Content = "Fitur ini butuh role " .. requiredRole .. "!",
      Duration = 3,
   })
end

-- =====================
--    PLAYER TAB
-- =====================
local _ = PlayerTab:CreateSection("Player Controls | Role: " .. roleLabel())

-- FLY — Free
PlayerTab:CreateToggle({
   Name = "Fly", CurrentValue = false, Flag = "FlyToggle",
   Callback = function(value)
      -- Free bisa
      flyEnabled = value
      if value then
         startFly()
         local hint = isMobile
            and "Thumbstick = gerak | Jump = naik | ▼ = turun"
            or  "WASD = gerak | Space = naik | Ctrl = turun"
         Rayfield:Notify({ Title = "Fly ON ✅", Content = hint, Duration = 4 })
      else
         stopFly()
         Rayfield:Notify({ Title = "Fly OFF ❌", Content = "Fly dimatikan!", Duration = 3 })
      end
   end,
})

-- FLY SPEED — Free
PlayerTab:CreateSlider({
   Name = "Fly Speed", Range = {10, 200}, Increment = 10,
   Suffix = "Speed", CurrentValue = 50, Flag = "FlySpeed",
   Callback = function(value)
      flySpeed = value
      Rayfield:Notify({ Title = "Fly Speed", Content = "Kecepatan: " .. value, Duration = 2 })
   end,
})

-- NOCLIP — Free
PlayerTab:CreateToggle({
   Name = "Noclip", CurrentValue = false, Flag = "NoclipToggle",
   Callback = function(value)
      noclipEnabled = value
      if value then
         startNoclip()
         Rayfield:Notify({ Title = "Noclip ON ✅", Content = "Kamu bisa tembus dinding!", Duration = 3 })
      else
         stopNoclip()
         Rayfield:Notify({ Title = "Noclip OFF ❌", Content = "Collision dikembalikan!", Duration = 3 })
      end
   end,
})

-- GOD MODE — Premium
PlayerTab:CreateToggle({
   Name = "God Mode 🔒 Premium", CurrentValue = false, Flag = "GodToggle",
   Callback = function(value)
      if not canAccess("premium") then
         notifyLocked("⭐ Premium")
         -- paksa balik off
         Rayfield:GetFlag("GodToggle").Value = false
         return
      end
      godEnabled = value
      if value then
         startGod()
         Rayfield:Notify({ Title = "God Mode ON ✅", Content = "Kamu sekarang kebal!", Duration = 3 })
      else
         stopGod()
         Rayfield:Notify({ Title = "God Mode OFF ❌", Content = "God Mode dimatikan!", Duration = 3 })
      end
   end,
})

-- RESET CHARACTER — Premium
PlayerTab:CreateButton({
   Name = "Reset Character 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
      if hum then hum.Health = 0 end
      Rayfield:Notify({ Title = "Reset", Content = "Character di-reset!", Duration = 3 })
   end,
})

-- =====================
--   TELEPORT AREA — Free
-- =====================
local _ = PlayerTab:CreateSection("Teleport Area")

PlayerTab:CreateButton({
   Name = "Teleport ke Spawn",
   Callback = function()
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
         hrp.CFrame = CFrame.new(-36, 58, 79)
         Rayfield:Notify({ Title = "Teleport ✅", Content = "Berhasil teleport ke Spawn!", Duration = 3 })
      end
   end,
})

PlayerTab:CreateButton({
   Name = "Teleport ke Celestial",
   Callback = function()
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
         hrp.CFrame = CFrame.new(-1097, 58, 3)
         Rayfield:Notify({ Title = "Teleport ✅", Content = "Berhasil teleport ke Celestial!", Duration = 3 })
      end
   end,
})

-- CEK POSISI — Admin+
PlayerTab:CreateButton({
   Name = "📍 Cek Posisi Saya 🔒 Admin",
   Callback = function()
      if not canAccess("admin") then notifyLocked("🛡️ Admin"); return end
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
         local pos = hrp.Position
         local msg = "X: " .. math.floor(pos.X) .. " | Y: " .. math.floor(pos.Y) .. " | Z: " .. math.floor(pos.Z)
         print("[POSISI] " .. msg)
         Rayfield:Notify({ Title = "Posisi Kamu 📍", Content = msg, Duration = 6 })
      end
   end,
})

-- =====================
--      COMBAT — Free
-- =====================
local _ = PlayerTab:CreateSection("Combat")

-- ESP — Free
PlayerTab:CreateToggle({
   Name = "ESP", CurrentValue = false, Flag = "ESPToggle",
   Callback = function(value)
      espEnabled = value
      if value then
         for _, player in pairs(Players:GetPlayers()) do createESP(player) end
         Players.PlayerAdded:Connect(createESP)
         Players.PlayerRemoving:Connect(removeESP)
         Rayfield:Notify({ Title = "ESP ON ✅", Content = "Player ESP aktif!", Duration = 3 })
      else
         for _, player in pairs(Players:GetPlayers()) do removeESP(player) end
         Rayfield:Notify({ Title = "ESP OFF ❌", Content = "ESP dimatikan!", Duration = 3 })
      end
   end,
})

-- AIM LOCK — Free
PlayerTab:CreateToggle({
   Name = "Aim Lock", CurrentValue = false, Flag = "AimlockToggle",
   Callback = function(value)
      aimlockEnabled = value
      local hint = isMobile and "Aim Lock aktif otomatis!" or "Tahan klik kanan untuk lock!"
      if value then
         Rayfield:Notify({ Title = "Aim Lock ON ✅", Content = hint, Duration = 3 })
      else
         Rayfield:Notify({ Title = "Aim Lock OFF ❌", Content = "Aim Lock dimatikan!", Duration = 3 })
      end
   end,
})

PlayerTab:CreateDropdown({
   Name = "Aim Lock Target", Options = {"Kepala", "Badan", "Kaki"},
   CurrentOption = {"Badan"}, Flag = "AimlockTarget",
   Callback = function(option)
      aimlockTarget = option[1]
      Rayfield:Notify({ Title = "Aim Target 🎯", Content = "Target: " .. option[1], Duration = 2 })
   end,
})

-- =====================
--    VISUAL TAB — Premium
-- =====================
local _ = VisualTab:CreateSection("Visual Controls 🔒 Premium")

VisualTab:CreateButton({
   Name = "Fullbright 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      game.Lighting.Brightness = 10
      game.Lighting.ClockTime  = 14
      Rayfield:Notify({ Title = "Fullbright", Content = "Lighting ke maksimal!", Duration = 3 })
   end,
})

VisualTab:CreateButton({
   Name = "Reset Lighting 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      game.Lighting.Brightness = 1
      game.Lighting.ClockTime  = 14
      Rayfield:Notify({ Title = "Reset Lighting", Content = "Lighting normal!", Duration = 3 })
   end,
})

-- =====================
--      MISC TAB
-- =====================
local _ = MiscTab:CreateSection("Misc")

-- Copy Player Name — Free
MiscTab:CreateButton({
   Name = "Copy Player Name",
   Callback = function()
      local name = LocalPlayer.Name
      setclipboard(name)
      Rayfield:Notify({ Title = "Copied!", Content = "Username: " .. name .. " disalin!", Duration = 3 })
   end,
})

-- Rejoin — Premium
MiscTab:CreateButton({
   Name = "Rejoin Server 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      game:GetService("TeleportService"):Teleport(game.PlaceId)
   end,
})

-- =====================
--    TEAM INFO — Premium
-- =====================
local _ = MiscTab:CreateSection("Team Info 🔒 Premium")

MiscTab:CreateButton({
   Name = "Cek Team Saya 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      if LocalPlayer.Team then
         Rayfield:Notify({
            Title   = "Team Kamu 🏳️",
            Content  = "Team: " .. LocalPlayer.Team.Name .. " | Warna: " .. tostring(LocalPlayer.TeamColor),
            Duration = 5,
         })
      else
         Rayfield:Notify({ Title = "Team Kamu", Content = "Kamu tidak ada di team manapun!", Duration = 3 })
      end
   end,
})

MiscTab:CreateButton({
   Name = "Cek Team Semua Player 🔒 Admin",
   Callback = function()
      if not canAccess("admin") then notifyLocked("🛡️ Admin"); return end
      for _, player in pairs(Players:GetPlayers()) do
         local teamName = player.Team and player.Team.Name or "No Team"
         print("[Team] " .. player.Name .. " → " .. teamName)
      end
      Rayfield:Notify({ Title = "Team List 📋", Content = "Cek console executor!", Duration = 5 })
   end,
})

MiscTab:CreateButton({
   Name = "Cek Team Player Terdekat 🔒 Premium",
   Callback = function()
      if not canAccess("premium") then notifyLocked("⭐ Premium"); return end
      local char = LocalPlayer.Character
      if not char then return end
      local hrp = char:FindFirstChild("HumanoidRootPart")
      if not hrp then return end
      local closestPlayer = nil
      local closestDist   = math.huge
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            local otherHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if otherHrp then
               local dist = (hrp.Position - otherHrp.Position).Magnitude
               if dist < closestDist then closestDist = dist; closestPlayer = player end
            end
         end
      end
      if closestPlayer then
         local teamName = closestPlayer.Team and closestPlayer.Team.Name or "No Team"
         local isEnemy  = LocalPlayer.Team ~= closestPlayer.Team
         Rayfield:Notify({
            Title   = "Player Terdekat 🎯",
            Content  = closestPlayer.Name .. " | Team: " .. teamName .. " | " .. (isEnemy and "⚔️ MUSUH!" or "🤝 TEMAN!"),
            Duration = 5,
         })
      else
         Rayfield:Notify({ Title = "Tidak Ada Player", Content = "Tidak ada player di sekitar!", Duration = 3 })
      end
   end,
})

-- =====================
--   NOTIF ROLE SAAT LOGIN
-- =====================
Rayfield:Notify({
   Title    = "X Script Loaded ✅",
   Content  = "Role kamu: " .. roleLabel(),
   Duration = 5,
})
