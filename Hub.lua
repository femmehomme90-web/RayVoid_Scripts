--[[
    VoidHub -- point d'entree unique
    Genere automatiquement par voidhub-bridge, ne pas editer a la main.
    Build: 2026-08-18 11:40:05
]]

local UI_URL  = ""
local DISCORD = ""

local MAP = {
	["10198343402"] = {{n="Paint-Or-OOF",u="https://raw.githubusercontent.com/femmehomme90-web/RayVoid_Scripts/main/POF"}},
	["10410945205"] = {{n="1",u="https://raw.githubusercontent.com/femmehomme90-web/RayVoid_Scripts/main/1"}},
}

-- ---------------------------------------------------------------------------

-- On route sur GameId (l'univers), pas sur PlaceId : il est identique dans
-- le lobby et toutes les places d'un meme jeu.
local gameId  = tostring(game.GameId)
local entries = MAP[gameId]

local function copyText(text)
    if setclipboard then
        pcall(setclipboard, text)
    end
end

local function runScript(url)
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(src) ~= "string" or #src < 16 then
        warn("[VoidHub] download failed: " .. tostring(url))
        return false
    end
    local fn, err = loadstring(src)
    if not fn then
        warn("[VoidHub] compile failed: " .. tostring(err))
        return false
    end
    local ranOk, runErr = pcall(fn)
    if not ranOk then
        warn("[VoidHub] runtime error: " .. tostring(runErr))
        return false
    end
    return true
end

-- Chemin rapide : un seul script pour ce jeu, on charge sans passer par l'UI.
if entries and #entries == 1 then
    runScript(entries[1].u)
    return
end

-- A partir d'ici on a besoin de l'interface (selection ou jeu non supporte).
local okUi, Ui = pcall(function()
    return loadstring(game:HttpGet(UI_URL))()
end)
if not okUi or not Ui then
    warn("[VoidHub] UI failed to load")
    return
end

Ui:SetScriptName("VoidHub")

-- [ Plusieurs scripts pour ce jeu : selection ]
if entries and #entries > 1 then
    Ui:ShowCredit()

    local Window = Ui:CreateWindow({
        Name = "VoidHub",
        LoadingTitle = "VoidHub",
        LoadingSubtitle = "by AKkiwi",
        ConfigurationSaving = { Enabled = true, FolderName = "VoidHub", FileName = "hub" },
    })

    local Tab = Window:CreateTab("Scripts", "gamepad-2")

    Tab:CreateParagraph({
        Title = "Multiple scripts available",
        Content = tostring(#entries) .. " scripts exist for this game. Pick the one you want to load.",
    })

    for i = 1, #entries do
        local entry = entries[i]
        Tab:CreateButton({
            Name = "Load " .. entry.n,
            Callback = function()
                pcall(function() Ui:Destroy() end)
                task.wait(0.25)
                runScript(entry.u)
            end,
        })
    end

    return
end

-- [ Aucun script pour ce jeu : ecran minimal, redirection Discord uniquement ]
local Window = Ui:CreateWindow({
    Name = "VoidHub",
    LoadingTitle = "VoidHub",
    LoadingSubtitle = "by AKkiwi",
    ConfigurationSaving = { Enabled = true, FolderName = "VoidHub", FileName = "hub" },
})

local Info = Window:CreateTab("Not Supported", "bug")

Info:CreateParagraph({
    Title = "This script isn't supported",
    Content = "This game isn't supported. Join the Discord to see every available game.",
})

Info:CreateButton({
    Name = "Copy Discord invite",
    Callback = function()
        copyText(DISCORD)
        Ui:Notify({ Title = "Copied", Content = "Discord invite copied to clipboard.", Duration = 4 })
    end,
})
