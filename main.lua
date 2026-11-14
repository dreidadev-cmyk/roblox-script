-- main.lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/ui.lua"))()

local win = UI.Window("Fox — Roblox", UDim2.new(0, 520, 0, 380))

local tabMain = win:AddTab("Main")
local tabVis  = win:AddTab("Visuals")
local tabMisc = win:AddTab("Misc")

-- Features placeholder — idadagdag natin next
local state = { fly=false, speed=50, esp=false }

win:Toggle(tabMain, "Fly", false, function(v) state.fly = v end)
win:Slider(tabMain, "WalkSpeed", 16, 200, 50, function(v) state.speed = v end)
win:Toggle(tabVis, "ESP", false, function(v) state.esp = v end)
win:Button(tabMisc, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)
win:Button(tabMisc, "Print Hello", function() print("[Fox] hello") end)
