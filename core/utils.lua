-- core/utils.lua
local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

local Utils = {}

function Utils.notify(title, text, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "FoxNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 60)
    frame.Position = UDim2.new(1, 300, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(90, 140, 255)
    stroke.Thickness = 1

    local t = Instance.new("TextLabel", frame)
    t.Text = title
    t.Size = UDim2.new(1, -16, 0, 22)
    t.Position = UDim2.new(0, 8, 0, 6)
    t.BackgroundTransparency = 1
    t.TextColor3 = Color3.fromRGB(230, 230, 235)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left

    local s = Instance.new("TextLabel", frame)
    s.Text = text or ""
    s.Size = UDim2.new(1, -16, 0, 24)
    s.Position = UDim2.new(0, 8, 0, 28)
    s.BackgroundTransparency = 1
    s.TextColor3 = Color3.fromRGB(150, 150, 160)
    s.Font = Enum.Font.Gotham
    s.TextSize = 12
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.TextWrapped = true

    TS:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -280, 0, 20)
    }):Play()

    task.delay(duration or 3, function()
        TS:Create(frame, TweenInfo.new(0.2), {
            Position = UDim2.new(1, 300, 0, 20)
        }):Play()
        task.wait(0.25)
        gui:Destroy()
    end)
end

-- keybind: returns connection object; cb fires on key press
function Utils.keybind(keyCode, callback)
    return UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keyCode then
            pcall(callback)
        end
    end)
end

-- simple config save/load (executor-dependent)
function Utils.saveConfig(name, data)
    if not writefile then return false end
    local ok, err = pcall(function()
        writefile("Fox_" .. name .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
    return ok
end

function Utils.loadConfig(name)
    if not (isfile and readfile) then return nil end
    local path = "Fox_" .. name .. ".json"
    if not isfile(path) then return nil end
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end)
    return ok and data or nil
end

return Utils
