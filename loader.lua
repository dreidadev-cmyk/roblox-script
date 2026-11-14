-- loader.lua — v1.0.1
local BASE = "https://raw.githubusercontent.com/dreidadev-cmyk/roblox-script/main/"

local function httpGet(url)
    if syn and syn.request then
        local ok, r = pcall(syn.request, { Url = url, Method = "GET" })
        return ok and r.Body or nil
    elseif http and http.request then
        local ok, r = pcall(http.request, { Url = url, Method = "GET" })
        return ok and r.Body or nil
    elseif request then
        local ok, r = pcall(request, { Url = url, Method = "GET" })
        return ok and r.Body or nil
    end
    local ok, b = pcall(game.HttpGet, game, url)
    return ok and b or nil
end

local function loadRemote(path, chunkname)
    local src = httpGet(BASE .. path)
    if not src then error("[Fox] fetch failed: " .. path) end
    local fn, err = loadstring(src, "=" .. (chunkname or path))
    if not fn then error("[Fox] compile " .. path .. ": " .. tostring(err)) end
    return fn
end

-- shared namespace
local Fox = {
    BASE = BASE,
    httpGet = httpGet,
    loadRemote = loadRemote,
    version = "1.0.1",
}
if getgenv then getgenv().Fox = Fox end

-- load core
Fox.UI    = loadRemote("core/ui.lua", "ui")()
Fox.Utils = loadRemote("core/utils.lua", "utils")()

-- resolve which game script to run
local placeId = tostring(game.PlaceId)
local gameScriptPath = "script/game_" .. placeId .. ".lua"

-- check kung may per-game script; kung wala, fallback sa universal
local src = httpGet(BASE .. gameScriptPath)
if src and #src > 0 then
    local fn = loadstring(src, "=game_" .. placeId)
    if fn then
        print(("[Fox] loading game script for %s"):format(placeId))
        local ok, err = pcall(fn, Fox)
        if not ok then warn("[Fox] game script error: " .. tostring(err)) end
    end
else
    print(("[Fox] no script for %s, loading universal"):format(placeId))
    local fn = loadRemote("script/universal.lua", "universal")
    local ok, err = pcall(fn, Fox)
    if not ok then warn("[Fox] universal error: " .. tostring(err)) end
end
