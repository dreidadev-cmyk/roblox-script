-- ui.lua — minimal draggable window lib
-- API: Window.new(title, size) -> { AddTab, Toggle, Button, Slider, Destroy }

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

local Theme = {
    bg        = Color3.fromRGB(22, 22, 28),
    header    = Color3.fromRGB(30, 30, 38),
    accent    = Color3.fromRGB(90, 140, 255),
    text      = Color3.fromRGB(230, 230, 235),
    subtext   = Color3.fromRGB(150, 150, 160),
    stroke    = Color3.fromRGB(50, 50, 60),
    toggleOn  = Color3.fromRGB(90, 140, 255),
    toggleOff = Color3.fromRGB(60, 60, 70),
}

local UI = {}

local function newInstance(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function protectGui(gui)
    if syn and syn.protect_gui then syn.protect_gui(gui) end
    if gethui then gui.Parent = gethui() end
end

-- draggable helper
local function makeDraggable(frame, handle)
    local dragging, startPos, startInput = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startPos   = frame.Position
            startInput = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - startInput
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

function UI.Window(title, size)
    local self = { Tabs = {}, ActiveTab = nil }

    local gui = newInstance("ScreenGui", {
        Name = "FoxUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, game:GetService("CoreGui"))

    protectGui(gui)

    local main = newInstance("Frame", {
        Name = "Main",
        Size = size or UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = Theme.bg,
        BorderSizePixel = 0,
    }, gui)

    newInstance("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
    newInstance("UIStroke", { Color = Theme.stroke, Thickness = 1 }, main)

    -- header
    local header = newInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.header,
        BorderSizePixel = 0,
    }, main)
    newInstance("UICorner", { CornerRadius = UDim.new(0, 8) }, header)

    newInstance("TextLabel", {
        Text = "  " .. (title or "Fox"),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    -- close
    local close = newInstance("TextButton", {
        Text = "×",
        Size = UDim2.new(0, 34, 1, 0),
        Position = UDim2.new(1, -34, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.subtext,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
    }, header)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- tab bar
    local tabBar = newInstance("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 120, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundColor3 = Theme.header,
        BorderSizePixel = 0,
    }, main)

    local content = newInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -120, 1, -34),
        Position = UDim2.new(0, 120, 0, 34),
        BackgroundTransparency = 1,
    }, main)

    makeDraggable(main, header)

    -- tab list container
    local tabList = newInstance("Frame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
    }, tabBar)

    newInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)

    -- API: AddTab(name) -> tab
    function self.AddTab(name)
        local btn = newInstance("TextButton", {
            Text = "  " .. name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.bg,
            BorderSizePixel = 0,
            TextColor3 = Theme.subtext,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        }, tabList)
        newInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

        local page = newInstance("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, content)
        newInstance("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        newInstance("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }, page)

        local tab = { Button = btn, Page = page, Name = name }

        local function activate()
            for _, t in pairs(self.Tabs) do
                t.Button.BackgroundColor3 = Theme.bg
                t.Button.TextColor3 = Theme.subtext
                t.Page.Visible = false
            end
            btn.BackgroundColor3 = Theme.accent
            btn.TextColor3 = Theme.text
            page.Visible = true
            self.ActiveTab = tab
        end

        btn.MouseButton1Click:Connect(activate)
        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then activate() end
        return tab
    end

    -- Toggle row
    function self.Toggle(tab, label, default, callback)
        local row = newInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.header,
            BorderSizePixel = 0,
        }, tab.Page)
        newInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

        newInstance("TextLabel", {
            Text = "  " .. label,
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local state = default or false
        local pill = newInstance("Frame", {
            Size = UDim2.new(0, 36, 0, 18),
            Position = UDim2.new(1, -50, 0.5, -9),
            BackgroundColor3 = state and Theme.toggleOn or Theme.toggleOff,
            BorderSizePixel = 0,
        }, row)
        newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)

        local knob = newInstance("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Theme.text,
            BorderSizePixel = 0,
        }, pill)
        newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

        local btn = newInstance("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
        }, row)

        local function setState(v)
            state = v
            TS:Create(pill, TweenInfo.new(0.15), {
                BackgroundColor3 = v and Theme.toggleOn or Theme.toggleOff
            }):Play()
            TS:Create(knob, TweenInfo.new(0.15), {
                Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }):Play()
            if callback then pcall(callback, v) end
        end

        btn.MouseButton1Click:Connect(function() setState(not state) end)
        return { Set = setState, Get = function() return state end }
    end

    -- Button row
    function self.Button(tab, label, callback)
        local btn = newInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.accent,
            BorderSizePixel = 0,
            Text = label,
            TextColor3 = Theme.text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
        }, tab.Page)
        newInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
        btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        return btn
    end

    -- Slider row
    function self.Slider(tab, label, min, max, default, callback)
        local row = newInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = Theme.header,
            BorderSizePixel = 0,
        }, tab.Page)
        newInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

        local title = newInstance("TextLabel", {
            Text = "  " .. label .. "  [" .. tostring(default) .. "]",
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = Theme.text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local track = newInstance("Frame", {
            Size = UDim2.new(1, -20, 0, 4),
            Position = UDim2.new(0, 10, 0, 32),
            BackgroundColor3 = Theme.toggleOff,
            BorderSizePixel = 0,
        }, row)
        newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

        local fill = newInstance("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Theme.accent,
            BorderSizePixel = 0,
        }, track)
        newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

        local knob = newInstance("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
            BackgroundColor3 = Theme.text,
            BorderSizePixel = 0,
        }, track)
        newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

        local val = default
        local dragging = false
        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            title.Text = "  " .. label .. "  [" .. tostring(val) .. "]"
            if callback then pcall(callback, val) end
        end

        local hit = newInstance("TextButton", {
            Size = UDim2.new(1, 20, 0, 20),
            Position = UDim2.new(0, -10, 0, 22),
            BackgroundTransparency = 1,
            Text = "",
        }, row)
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)

        return { Set = function(v) val = v; title.Text = "  " .. label .. "  [" .. tostring(v) .. "]" end,
                 Get = function() return val end }
    end

    function self.Destroy() gui:Destroy() end
    return self
end

return UI
