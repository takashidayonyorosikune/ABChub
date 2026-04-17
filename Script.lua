repeat task.wait() until game:IsLoaded()

-- Rayfield UI 読み込み（最新の公式ソース）
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local P, L, R, RS, D, Li, U, W, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("RunService"), game:GetService("ReplicatedStorage"), game:GetService("Debris"), game:GetService("Lighting"), game:GetService("UserInputService"), workspace, game:GetService("TweenService")

repeat task.wait() until L.Character
local LC = L.Character or L.CharacterAdded:Wait()
L.CharacterAdded:Connect(function(c) LC = c end)

-- 必要なイベントの取得
local GE, MT, CE = RS:WaitForChild("GrabEvents", 10), RS:WaitForChild("MenuToys", 10), RS:WaitForChild("CharacterEvents", 10)
if not GE or not MT or not CE then 
    warn("必要なリモートイベントが見つかりませんでした") 
    return 
end

local SNO, STR, CGL, DGL, DToy, RR = GE:WaitForChild("SetNetworkOwner", 5), CE:WaitForChild("Struggle", 5), GE:WaitForChild("CreateGrabLine", 5), GE:WaitForChild("DestroyGrabLine", 5), MT:WaitForChild("DestroyToy", 5), CE:WaitForChild("RagdollRemote", 5)

-- ============================================
-- グローバル設定変数（元のまま）
-- ============================================
local cons = {}
local originalVoidHeight = workspace.FallenPartsDestroyHeight
local Cam = workspace.CurrentCamera

-- UI用変数（アニメーションなどはそのまま）
local UIAnimations = {}
local hoverEffects = {}
local clickEffects = {}

-- 各種設定テーブル（そのまま）
local cf = {PG = false, KG = false, HG = false, NG = false, CG = false, KiG = false, UG = false}
local LIT, throwEnabled = Enum.UserInputType.None, false
local TPO = "Spawn"
local _G = {}
_G.kF, _G.uRS, _G.uH = 150, 5, 10

local Config = { Throw = { Enabled = false, Power = 400 } }

local defenseSettings = {
    AntiGrab = false, AntiFling = false, AntiVoid = false,
    AntiExplode = false, AntiRagdoll = false, AntiGucci = false
}

local auraSettings = {
    Enabled = false, Radius = 32,
    Types = { Kill = false, Void = false, Ragdoll = false, Anchor = false, Fire = false, Noclip = false, Grab = false, Delete = false, Fling = false },
    Whitelist = false
}

local PlayerConfig = {
    SpeedValue = 16, JumpValue = 50, SpeedEnabled = false, JumpEnabled = false,
    Noclip = false, FreeCamera = false, CameraDistance = 128, Invincible = false
}

local BlobmanConfig = {
    Target = "", ArmSide = "左", GrabAura = false, KickAura = false, LoopKick = false,
    AutoDuo = false, DuoLoop = false, ServerCrash = false, Delay = 0.001,
    LeftTarget = "", RightTarget = "", BothTarget = "", UseDisplayName = false
}

local BlobmanConnections = {}

local _Gstr, _GbDly, _GkF, _GuRS, _GuH = 450, 0.001, 150, 5, 10 
local str, aRad, wlE, bDly, saDist, lsRes, lsE, SIL = 450, 20, false, 0.001, 30, 200, false, false 
local lineColor1, lineColor2, lineColor3, lineColor4 = Color3.new(1, 0, 0), Color3.new(0, 0, 1), Color3.new(0, 1, 0), Color3.new(1, 1, 0)
local rainbowEnabled, customGradientEnabled, gradientPoints = false, false, 2 
local pcDistance, IncreaseLineExtend, minDistance = 0, 3, 3 
_G.FurtherExtend = false

local TriggerBotEnabled = false
local TriggerBotDelay = 0.1
local AutoShootEnabled = false
local TriggerBotKeybind = "Q"

local crosshairOpacity, crosshairColor, crosshairRainbow = 1, Color3.new(1, 1, 1), false 
local originalCrosshair, customCrosshair, crosshairVisible = nil, nil, false 
local RainbowEnabled = true
local CustomColorEnabled = false
local selectedColor = Color3.fromRGB(255, 255, 255)

-- ============================================
-- UIアニメーション関数（そのまま）
-- ============================================
local function createHoverAnimation(button) ... end  -- 元の関数をそのままコピーしてください
local function createClickAnimation(button) ... end
local function animatedNotification(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483345998
    })
end

-- ============================================
-- 入力検知・共通関数・各種機能関数（gH, kG, hG, nG ... executeAura, updateDefense など）
-- ============================================
-- （ここは元のスクリプトと同じなので省略。すべてそのまま貼り付けてください）

-- ============================================
-- Rayfield UI 作成
-- ============================================

local Window = Rayfield:CreateWindow({
    Name = "FTAP Suki HUB",
    LoadingTitle = "FTAP Suki Hub",
    LoadingSubtitle = "完全総合版",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FTAP_Complete",
        FileName = "FTAP_Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false
})

-- タブ1: 掴み機能
local GT = Window:CreateTab("掴み機能", 4483345998)

GT:CreateSection("基本グラブ機能")

GT:CreateToggle({
    Name = "ポイズン・グラブ (毒)",
    CurrentValue = false,
    Flag = "PoisonGrab",
    Callback = function(Value)
        cf.PG = Value
        if Value then task.spawn(gH) end
        animatedNotification("ポイズングラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateToggle({
    Name = "キル・グラブ (即殺)",
    CurrentValue = false,
    Flag = "KillGrab",
    Callback = function(Value)
        cf.KG = Value
        if Value then task.spawn(kG) end
        animatedNotification("キルグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateToggle({
    Name = "ヘブン・グラブ (打ち上げ)",
    CurrentValue = false,
    Flag = "HeavenGrab",
    Callback = function(Value)
        cf.HG = Value
        if Value then task.spawn(hG) end
        animatedNotification("ヘブングラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateToggle({
    Name = "ノークリップ・グラブ (壁抜け)",
    CurrentValue = false,
    Flag = "NoclipGrab",
    Callback = function(Value)
        cf.NG = Value
        if Value then task.spawn(nG) end
        animatedNotification("ノークリップグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateSection("特殊グラブ機能")

GT:CreateToggle({
    Name = "TPグラブ",
    CurrentValue = false,
    Flag = "TPGrab",
    Callback = function(Value)
        cf.CG = Value
        if Value then task.spawn(cG) end
        animatedNotification("TPグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateToggle({
    Name = "キックグラブ",
    CurrentValue = false,
    Flag = "KickGrab",
    Callback = function(Value)
        cf.KiG = Value
        if Value then task.spawn(kiG) end
        animatedNotification("キックグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateToggle({
    Name = "UFOグラブ",
    CurrentValue = false,
    Flag = "UFOGrab",
    Callback = function(Value)
        cf.UG = Value
        if Value then task.spawn(uG) end
        animatedNotification("UFOグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateSection("投げ機能設定")

GT:CreateSlider({
    Name = "投げる強さ",
    Range = {100, 4000},
    Increment = 10,
    CurrentValue = 400,
    Suffix = "パワー",
    Flag = "ThrowPower",
    Callback = function(Value)
        Config.Throw.Power = Value
        animatedNotification("投げ設定", "投げパワー: " .. Value, 2)
    end
})

GT:CreateToggle({
    Name = "投げ機能を有効化",
    CurrentValue = false,
    Flag = "ThrowEnabled",
    Callback = function(Value)
        Config.Throw.Enabled = Value
        setupThrow()
        animatedNotification("投げ機能", Value and "有効化しました" or "無効化しました", 2)
    end
})

GT:CreateLabel("使い方: 掴んだ後、右クリックで投げます")

-- 以降のタブ（防御機能、オーラ、Blobman、プレイヤー機能、ビジュアル、フック設定）も同様に変換してください。
-- 例: 防御機能タブ
local DT = Window:CreateTab("防御機能", 4483362458)

DT:CreateToggle({
    Name = "アンチ・グラブ (掴み防止)",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        defenseSettings.AntiGrab = Value
        updateDefense()
        animatedNotification("アンチグラブ", Value and "有効化しました" or "無効化しました", 2)
    end
})

-- （他のタブも同じ要領で CreateToggle, CreateSlider, CreateButton, CreateDropdown, CreateTextbox, CreateColorpicker に置き換え）

-- 最後に Rayfield を初期化
Rayfield:LoadConfiguration()

-- 初期化通知
animatedNotification("FTAP Suki HUB", "Rayfield版が正常に読み込まれました！", 5)

-- 残りのロジック（Heartbeat, RenderStepped, STS(), updateDefense() など）は元のまま
