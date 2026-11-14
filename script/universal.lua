-- script/universal.lua
return function(Fox)
    local UI    = Fox.UI
    local Utils = Fox.Utils
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer

    local win = UI.Window("Fox — Universal", UDim2.new(0, 520, 0, 380))
    local tabMain = win:AddTab("Main")
    local tabVis  = win:AddTab("Visuals")
    local tabMisc = win:AddTab("Misc")

    local state = { fly=false, speed=16, esp=false }

    local flyConn
    win:Toggle(tabMain, "Fly", false, function(v)
        state.fly = v
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if v then
            local cam = workspace.CurrentCamera
            flyConn = game:GetService("RunService").RenderStepped:Connect(function()
                local c = LP.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if not r then return end
                local move = Vector3.zero
                local uis = game:GetService("UserInputService")
                if uis:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
                r.Velocity = Vector3.zero
                r.CFrame = r.CFrame + move * 2
            end)
        else
            if flyConn then flyConn:Disconnect(); flyConn = nil end
        end
    end)

    win:Slider(tabMain, "WalkSpeed", 16, 200, 50, function(v)
        state.speed = v
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)

    -- ESP for players
    local espObjs = {}
    local function clearESP()
        for _, g in pairs(espObjs) do g:Destroy() end
        espObjs = {}
    end
    local function addESP(plr)
        if plr == LP then return end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "FoxESP"
        bb.Size = UDim2.new(0, 200, 0, 30)
        bb.AlwaysOnTop = true
        bb.Adornee = hrp
        local label = Instance.new("TextLabel", bb)
        label.Size = UDim2.fromScale(1,1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,60,60)
        label.TextStrokeTransparency = 0
        label.Text = plr.Name
        bb.Parent = hrp
        espObjs[plr] = bb
    end

    win:Toggle(tabVis, "ESP Players", false, function(v)
        state.esp = v
        if v then
            clearESP()
            for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
            Players.PlayerAdded:Connect(function(p) if state.esp then addESP(p) end end)
        else
            clearESP()
        end
    end)

    win:Button(tabMisc, "Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
    win:Button(tabMisc, "Notify test", function()
        Utils.notify("Fox", "Notification system works.", 3)
    end)

    Utils.notify("Fox", "Universal script loaded.", 3)
end
