-- loader.lua — version-gated loader with fallback
local LOADER_VERSION = "1.0.0"
local SCRIPT_URL     = "https://raw.githubusercontent.com/YOUR/REPO/main/main.lua"
local VERSION_URL    = "https://raw.githubusercontent.com/YOUR/REPO/main/version.txt"

local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        return ok and res.Body or nil
    elseif http and http.request then
        return http.request({ Url = url, Method = "GET" }).Body
    elseif request then
        return request({ Url = url, Method = "GET" }).Body
    elseif game and game.HttpGet then
        local ok, body = pcall(game.HttpGet, game, url)
        return ok and body or nil
    end
    return nil
end

local remoteVer = httpGet(VERSION_URL)
if not remoteVer then
    warn("[Fox] Version check failed, loading anyway...")
else
    remoteVer = remoteVer:gsub("%s+", "")
    if remoteVer ~= LOADER_VERSION then
        warn(("[Fox] Update available: local=%s remote=%s"):format(LOADER_VERSION, remoteVer))
    end
end

local src = httpGet(SCRIPT_URL)
if not src then
    error("[Fox] Failed to fetch main.lua — check URL / executor http support")
end

local fn, err = loadstring(src, "=fox_main")
if not fn then
    error("[Fox] Compile error: " .. tostring(err))
end

local ok, result = pcall(fn)
if not ok then
    error("[Fox] Runtime error: " .. tostring(result))
end

if getgenv then getgenv().FoxLoaded = true end
print(("[Fox] Loaded v%s"):format(LOADER_VERSION))
