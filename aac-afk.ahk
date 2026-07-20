#Requires AutoHotkey v2.0
#SingleInstance Force

; Remember to change version.txt in GitHub: 1.0.0 → 1.1.0

; Hotkey
F1:: {
    global running
    running := !running
    if (!running) {
        chkDeepWounds.Enabled := true
        chkFacetank.Enabled := true
        chkFeeble.Enabled := true
        chkGlassSoul.Enabled := true
        chkLevel1.Enabled := true
        chkPoverty.Enabled := true
        chkRelentless.Enabled := true
        chkRuination.Enabled := true
        chkSimple.Enabled := true
        chkSlowStart.Enabled := true
        chkSurpriseRound.Enabled := true
        chkToweringForces.Enabled := true
        chkUnfair.Enabled := true
        chkUnrelenting.Enabled := true

        ddl.Enabled := true

        ShowToast("OFF")
        statusText.Text := "OFF"
        statusText.Opt("cRed")
    }
    else {
        chkDeepWounds.Enabled := false
        chkFacetank.Enabled := false
        chkFeeble.Enabled := false
        chkGlassSoul.Enabled := false
        chkLevel1.Enabled := false
        chkPoverty.Enabled := false
        chkRelentless.Enabled := false
        chkRuination.Enabled := false
        chkSimple.Enabled := false
        chkSlowStart.Enabled := false
        chkSurpriseRound.Enabled := false
        chkToweringForces.Enabled := false
        chkUnfair.Enabled := false
        chkUnrelenting.Enabled := false

        ddl.Enabled := false

        ShowToast("ON")
        statusText.Text := "ON"
        statusText.Opt("c00FF00")
    }
}
F3:: {
    ShowToast("Closing App")
    saveSetting()
    ExitApp() ; Full Quit
}
F4:: {
    ShowToast("Reloading...")
    saveSetting()
    if A_IsCompiled
        Run('"' . A_ScriptFullPath . '"')
    else
        Reload()
    ExitApp()
}

; Var
global running := false
global haveFullscreen := false

global scriptDir := A_ScriptDir
global assetsDir := scriptDir . "\assets"

global modifiersDir := assetsDir . "\Modifiers"
global uiDir := assetsDir . "\UI"
global classDir := assetsDir . "\ClassNeed"

global settingsFile := scriptDir . "\settings.ini"

; Modifiers
global DeepWounds := modifiersDir . "\DeepWounds.png"
global Facetank := modifiersDir . "\Facetank.png"
global Feeble := modifiersDir . "\Feeble.png"
global GlassSoul := modifiersDir . "\GlassSoul.png"
global Level1 := modifiersDir . "\Level1.png"
global Poverty := modifiersDir . "\Poverty.png"
global Relentless := modifiersDir . "\Relentless.png"
global Ruination := modifiersDir . "\Ruination.png"
global Simple := modifiersDir . "\Simple.png"
global SlowStart := modifiersDir . "\SlowStart.png"
global SurpriseRound := modifiersDir . "\SurpriseRound.png"
global ToweringForces := modifiersDir . "\ToweringForces.png"
global Unfair := modifiersDir . "\Unfair.png"
global Unrelenting := modifiersDir . "\Unrelenting.png"

; UI
global fightButton := uiDir . "\Fight.png"
global focusButton := uiDir . "\Focus.png"
global cantUpgrade := uiDir . "\cantUp.png"

global GiantDone := uiDir . "\GiantDone.png"

; Master Class
; Warrior
global warriorCard := classDir . "\Warrior" . "\WarriorCard.png"
global IronChestplate := classDir . "\Warrior" . "\IronChestplate.png"
global IronLeggings := classDir . "\Warrior" . "\IronLeggings.png"
global IronGreaves := classDir . "\Warrior" . "\IronGreaves.png"
global IronHelmet := classDir . "\Warrior" . "\IronHelmet.png"
global MetalScrap := classDir . "\Warrior" . "\MetalScrap.png"

;Skill
global BrutalSlashes := classDir . "\Warrior" . "\BrutalSlashes.png"
global CrossSlash := classDir . "\Warrior" . "\CrossSlash.png"
global OverpoweringSlash := classDir . "\Warrior" . "\OverpoweringSlash.png"

; Raw file
global GITHUB_RAW := "https://raw.githubusercontent.com/WaterKansuza/AFK-An-Average-Campaign/main/"

global realVersion := GITHUB_RAW . "version.txt"

global zipPath := GITHUB_RAW . "assets.zip"
global zipFile := scriptDir . "\assets_temp.zip"

; CHANGE THIS IF UPDATE
global localVer := "3.0.0"

if !DirExist(assetsDir) {
    Download(zipPath, zipFile)
    ExtractAndClean(zipFile, assetsDir)
}

remoteVer := Trim(FetchText(realVersion), " `n`r")
if (remoteVer = "") {
    MsgBox("Không thể kết nối để kiểm tra update.", "Lỗi", "Iconi")
} else if (localVer != remoteVer) {
    result := MsgBox(
        "Có phiên bản mới: " remoteVer "`nPhiên bản hiện tại: " localVer "`n`nCập nhật ngay?",
        "Update Available",
        "YesNo Icon?"
    )
    if (result = "Yes")
        DoUpdate()
}

; AHK tạo file .ps1 tạm, chạy, rồi ps1 tự xóa
ExtractAndClean(srcZip, destDir) {
    ps1Path := A_Temp . "\ahk_extractor.ps1"

    script := "
    (
    $zip  = '" srcZip "'
    $dest = '" destDir "'

    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    New-Item -ItemType Directory -Path $dest | Out-Null
    Expand-Archive -Path $zip -DestinationPath $dest -Force
    Remove-Item $zip -Force

    # Tự xóa file ps1 này
    Remove-Item $MyInvocation.MyCommand.Path -Force
    )"

    FileOpen(ps1Path, "w").Write(script)

    ; -ExecutionPolicy Bypass để không bị chặn
    RunWait('powershell -NoProfile -ExecutionPolicy Bypass -File "' . ps1Path . '"', , "Hide")
}

FetchText(url) {
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.Open("GET", url, false)
        req.SetTimeouts(5000, 5000, 10000, 10000)
        req.Send()
        if (req.Status = 200)
            return req.ResponseText
    }
    return ""
}

DoUpdate() {
    global GITHUB_RAW, scriptDir, assetsDir, zipPath, zipFile

    ; ── 1. Xóa assets cũ và tải lại toàn bộ ─────────────────
    try {
        Download(zipPath, zipFile)
        ExtractAndClean(zipFile, assetsDir)  ; tự xóa zip + ps1 sau khi xong
    } catch as e {
        MsgBox("Lỗi tải assets: " . e.Message, "Lỗi", "Iconx")
        return
    }

    ; ── 2. Tải exe mới ───────────────────────────────────────
    tmpExe := scriptDir . "\app_new.exe"
    try {
        Download(GITHUB_RAW . "releases/aac-afk.exe", tmpExe)
    } catch as e {
        MsgBox("Lỗi tải bản cập nhật: " . e.Message, "Lỗi", "Iconx")
        return
    }

    ; ── 3. Batch thay exe sau khi app tắt ────────────────────
    batPath := scriptDir . "\updater.bat"
    oldExe := A_ScriptFullPath

    batch := "@echo off`n"
        . ":wait`n"
        . 'tasklist | find "' . A_ScriptName . '" >nul 2>&1`n'
        . 'move /y "' . tmpExe . '" "' . oldExe . '"' . "`n"
        . 'start "" "' . oldExe . '"' . "`n"
        . 'del "%~f0"'

    FileOpen(batPath, "w").Write(batch)

    MsgBox("Tải xong! App sẽ khởi động lại.", "Update", "Iconi T2")
    Run(batPath)
    ExitApp()
}

global generalSetting := Map(
    "isAlwaysOnTop", false,
    "selectedClass", 1,
)

global modifierSetting := Map(
    "DeepWounds", 0,
    "Facetank", 1,
    "Feeble", 1,
    "GlassSoul", 1,
    "Level1", 0,
    "Poverty", 1,
    "Relentless", 1,
    "Ruination", 1,
    "Simple", 0,
    "SlowStart", 0,
    "SurpriseRound", 0,
    "ToweringForces", 0,
    "Unfair", 0,
    "Unrelenting", 1
)

; Load Setting
loadSettings()

; plss bro why bro can wrong this
; Create Map first and u can load vro ;-;

saveSetting() {
    global modifierSetting, generalSetting, settingsFile
    IniWrite(generalSetting["isAlwaysOnTop"], settingsFile, "General", "isAlwaysOnTop")
    IniWrite(generalSetting["selectedClass"], settingsFile, "General", "selectedClass")
    for key, val in modifierSetting {
        IniWrite(val, settingsFile, "Modifiers", key)
    }
}

loadSettings() {
    global generalSetting, modifierSetting, settingsFile
    if (!FileExist(settingsFile)) {
        saveSetting()
    }
    for key, val in generalSetting
        generalSetting[key] := IniRead(settingsFile, "General", key, val)
    for key, val in modifierSetting
        modifierSetting[key] := IniRead(settingsFile, "Modifiers", key, val)
}

; State

global currentState := "CheckingGame"
;global currentState := "Testing"

;global currentState := "MainGame"
;global currentState := "inInventory"
;global currentState := "choosingEvent"

; UI
classAAC := ["Warrior", "Rogue", "Mage", "Priest", "Brawler", "Ranger", "Bard"]
guiW := 300
ddlW := 200
chkW := 200

g := Gui("", "Macro AnAverageCampaign")
g.SetFont("s12")
g.BackColor := "1F1F1E"
g.Add("Text", "x0 y+16 Center cWhite w" . guiW, "AFK AAC")
g.Add("Text", "x0 y+32 Center cWhite w" . guiW, "Choose Class")

ddl := g.Add("DropDownList", "y+16 w200 x" . ((guiW - ddlW) / 2), classAAC)
ddl.Value := generalSetting["selectedClass"]
ddl.OnEvent("Change", ddlChange)
ddlChange(ctrl, info) {
    global generalSetting

    if ctrl.Value == 4 {
        MsgBox("Can you change another Class `n I'm still working on this", "Warning")
        generalSetting["selectedClass"] := 1
        ctrl.Value := 1
    }
    else if ctrl.Value == 7 {
        MsgBox("Can you change another Class `n I'm still working on this", "Warning")
        generalSetting["selectedClass"] := 1
        ctrl.Value := 1
    }
    else {
        generalSetting["selectedClass"] := ctrl.Value
    }
}

;global classChoose := ddl.Value

; Modifiers choose
g.Add("Text", "x0 y+32 Center cWhite w" . guiW, "Choose Modifiers")

chkDeepWounds := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Deep Wounds")
chkFacetank := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Facetank")
chkFeeble := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Feeble")
chkGlassSoul := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Glass Soul")
chkLevel1 := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Level 1")
chkPoverty := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Poverty")
chkRelentless := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Relentless")
chkRuination := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Ruination")
chkSimple := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Simple")
chkSlowStart := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Slow Start")
chkSurpriseRound := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Surprise Round")
chkToweringForces := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Towering Forces")
chkUnfair := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Unfair")
chkUnrelenting := g.Add("Checkbox", "y+8 cWhite x" . ((guiW - chkW) / 2) . " w" . chkW, "Unrelenting")

chkDeepWounds.Value := modifierSetting["DeepWounds"]
chkFacetank.Value := modifierSetting["Facetank"]
chkFeeble.Value := modifierSetting["Feeble"]
chkGlassSoul.Value := modifierSetting["GlassSoul"]
chkLevel1.Value := modifierSetting["Level1"]
chkPoverty.Value := modifierSetting["Poverty"]
chkRelentless.Value := modifierSetting["Relentless"]
chkRuination.Value := modifierSetting["Ruination"]
chkSimple.Value := modifierSetting["Simple"]
chkSlowStart.Value := modifierSetting["SlowStart"]
chkSurpriseRound.Value := modifierSetting["SurpriseRound"]
chkToweringForces.Value := modifierSetting["ToweringForces"]
chkUnfair.Value := modifierSetting["Unfair"]
chkUnrelenting.Value := modifierSetting["Unrelenting"]

;global valDeepWounds := chkDeepWounds.Value
;global valFacetank := chkFacetank.Value
;global valFeeble := chkFeeble.Value
;global valGlassSoul := chkGlassSoul.Value
;global valLevel1 := chkLevel1.Value
;global valPoverty := chkPoverty.Value
;global valRelentless := chkRelentless.Value
;global valRuination := chkRuination.Value
;global valSimple := chkSimple.Value
;global valSlowStart := chkSlowStart.Value
;global valSurpriseRound := chkSurpriseRound.Value
;global valToweringForces := chkToweringForces.Value
;global valUnfair := chkUnfair.Value
;global valUnrelenting := chkUnrelenting.Value

; Update CheckBox if it's clicked

global chkModifiers := [chkDeepWounds, chkFacetank, chkFeeble, chkGlassSoul, chkLevel1, chkPoverty, chkRelentless,
    chkRuination, chkSimple, chkSlowStart, chkSurpriseRound, chkToweringForces, chkUnfair, chkUnrelenting]

for chk in chkModifiers {
    chk.OnEvent("Click", modSave)
}

modSave(ctrl, info) {
    global modifierSetting
    keyName := StrReplace(ctrl.Text, " ", "")
    modifierSetting[keyName] := ctrl.Value
}

global statusText := g.Add("Text", "x0 y+32 Center cRed w" . guiW, "OFF")
statusText.SetFont("s16")    ; it is a control so take it out

g.Add("Text", "x0 y+32 Center cWhite w" . guiW, "F1: On/Off `n F3: Quit `n F4: Reload")

; AlwaysOnTop
global chkAlwaysOnTop := g.Add("Checkbox", "y+16 cWhite Checked x" . ((guiW - 120) / 2) . " w" . chkW, "AlwaysOnTop")

chkAlwaysOnTop.Value := generalSetting["isAlwaysOnTop"]

if chkAlwaysOnTop.Value == 1 {
    g.Opt("+AlwaysOnTop")
}
else {
    g.Opt("-AlwaysOnTop")
}

chkAlwaysOnTop.OnEvent("Click", ToggleAlwaysOnTop)
ToggleAlwaysOnTop(ctrl, info) {
    ; ctrl.Gui auto take father of this checkbox
    if (ctrl.Value == 1) {
        ctrl.Gui.Opt("+AlwaysOnTop")
    } else {
        ctrl.Gui.Opt("-AlwaysOnTop")
    }

    global generalSetting
    keyName := "is" . ctrl.Text
    generalSetting[keyName] := ctrl.Value
}

g.Show("NoActivate x10 y10 h800 w" . guiW)

g.OnEvent("Close", GuiClose)

GuiClose(thisGui) {
    saveSetting()
    ExitApp()
}

WinActivate("ahk_pid " . ProcessExist())
;WinActivate("ahk_exe RobloxPlayerBeta.exe")

; Main loop
SetTimer(MacroLoop, 2000)
;SetTimer(KillBloxstrapPopup, 2000)
KillBloxstrapPopup() {
    if WinExist("Bloxstrap ahk_exe Bloxstrap.exe")
        WinClose("Bloxstrap ahk_exe Bloxstrap.exe")
}

MacroLoop() {
    global currentState, running
    if !running
        return

    if running {
        SetTimer(KillBloxstrapPopup, 2000)
    }
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        ShowToast("Roblox haven't open yet!")
        Sleep(3000)
        return
        ; Run("https://www.roblox.com/games/start?placeId=80734098185936")
    }
    else {
        switch currentState {
            case "Testing": TestFunc()

            case "CheckingGame": CheckingGame()
            case "MainMenu": MainMenu()
            case "MainGame": MainGame()

            case "WarriorRun": WarriorFight()
            case "RogueRun": RogueFight()
            case "MageRun": MageFight()
            case "BrawlerRun": BrawlerFight()
            case "RangerRun": RangerFight()

            case "inInventory": inventory()
            case "choosingEvent": ChoosingEvent()
            case "EndingTime": EndingTime()
        }
    }
}

CheckingGame() {
    global currentState
    WinActivate("ahk_exe RobloxPlayerBeta.exe")
    Sleep(200)

    if (CheckBorderless() == false) {
        SendInput("{F11}")
        ShowToast("Fullscreen!!!")
        Sleep(500)
    }

    currentState := "MainMenu"
}

CheckBorderless() {
    try {
        style := WinGetStyle("ahk_exe RobloxPlayerBeta.exe")
        if !(style & 0x00C00000) {
            return true
        }
        return false
    } catch {
        return false
    }
}

MainMenu() {
    ;ShowToast(ddl.Value)

    ; Check Menu Loading
    if (PixelGetColor(953, 227) = 0x22242B) {
        ; Skip Menu Loading
        MouseMove(962, 990)
        Click(962, 988)
        Sleep(1000)
    }
    else {
    }

    ; Open Play
    MouseMove(1858, 360)
    clicking(1858, 357)
    Sleep(1000)

    ; Create Party
    MouseMove(847, 880)
    clicking(847, 876)
    Sleep(1000)

    MouseMove(870, 405)
    clicking(869, 405)
    Sleep(1000)

    MouseMove(961, 570)
    clicking(961, 562)
    Sleep(1000)

    MouseMove(960, 740)
    clicking(960, 731)
    Sleep(1000)

    ; Create Party
    MouseMove(847, 880)
    clicking(847, 876)
    Sleep(1000)

    ; val

    ; Click Modifier
    ModX := 1170
    ModY := 252
    ModX2 := ModX + 288
    ModY2 := ModY + 427
    global valDeepWounds := chkDeepWounds.Value
    global valFacetank := chkFacetank.Value
    global valFeeble := chkFeeble.Value
    global valGlassSoul := chkGlassSoul.Value
    global valLevel1 := chkLevel1.Value
    global valPoverty := chkPoverty.Value
    global valRelentless := chkRelentless.Value
    global valRuination := chkRuination.Value
    global valSimple := chkSimple.Value
    global valSlowStart := chkSlowStart.Value
    global valSurpriseRound := chkSurpriseRound.Value
    global valToweringForces := chkToweringForces.Value
    global valUnfair := chkUnfair.Value
    global valUnrelenting := chkUnrelenting.Value

    global modifiersData := [{ val: valPoverty, img: Poverty }, { val: valUnfair, img: Unfair }, { val: valFeeble, img: Feeble }, { val: valSlowStart,
        img: SlowStart }, { val: valLevel1, img: Level1 }, { val: valUnrelenting, img: Unrelenting }, { val: valSimple,
            img: Simple }, { val: valToweringForces, img: ToweringForces }, { val: valRuination, img: Ruination }, { val: valDeepWounds,
                img: DeepWounds }, { val: valGlassSoul, img: GlassSoul }, { val: valRelentless, img: Relentless }, { val: valFacetank,
                    img: Facetank }, { val: valSurpriseRound, img: SurpriseRound }
    ]
    for item in modifiersData {
        if (item.val == 1) {
            loop 15 {
                if (ImageSearch(&x, &y, ModX, ModY, ModX2, ModY2, "*40 " . item.img) == 1) {
                    MouseMove(x, y)
                    clicking(x + 40, y + 15)
                    Sleep(1000)
                    break
                }
                else {
                    MouseMove(ModX + 50, ModY + 50)
                    Send("{WheelDown}")
                    Sleep(200)
                }
            }
        }
    }

    ; Start AFK
    Sleep(1000)
    ;MouseMove(915, 740)
    clicking(911, 735)
    Sleep(500)

    timeout := A_TickCount + 120000
    loop {
        if (PixelSearch(&outX, &outY, 1014, 929, 1014, 940, 0xFFFFFF, 2) == 1) {
            Sleep(200)
            break
        }
        if (A_TickCount > timeout)
            break
    }
    Sleep(500)

    ShowToast("Vao main game")

    global currentState := "MainGame"
}
global needRest := false
global numMana := 0
global numRound := 0
global turnInFight := 1
global numArmour := 0

MainGame() {
    global classChoose := ddl.Value
    global currentState, numRound, turnInFight, numMana

    ShowToast("In MainGame")
    ; Travelling
    ;loop {
    ;    sawIt := 0
    ;    if PixelSearch(&outX, &outY, 903, 556, 903, 584, 0xFFFFFF, 5) == 1 {
    ;        sawIt++
    ;    }
    ;    if sawIt == 1 {
    ;        sawIt := 0
    ;        break
    ;    }
    ;}

    ; Ưu tiên 1: Game over
    if (PixelSearch(&outX, &outY, 14, 1025, 15, 1026, 0x010202, 5) == 1) {
        clicking(1113, 1022)
        numRound := 0
        turnInFight := 1
        numArmour := 0
        numMana := 0

        return
    }

    ; Ưu tiên 2: Loading screen
    else if (PixelSearch(&outX, &outY, 1014, 929, 1014, 940, 0xFFFFFF, 2) == 1) {
        clicking(953, 935)
        turnInFight := 1
        numMana := 0
        ShowToast("It LOADINGSCREEN")
        return
    }

    ; Ưu tiên 3: isFighting
    else if PixelSearch(&outX, &outY, 677, 1047, 677, 1054, 0xFFFFFF, 2) == 1 {
        ;else if (PixelSearch(&outX, &outY, 158, 754, 159, 755, 0x505050, 5) == 1) {
        ShowToast("It fighting")
        switch classChoose {
            case 1: currentState := "WarriorRun"
            case 2: currentState := "RogueRun"
            case 3: currentState := "MageRun"
            case 5: currentState := "BrawlerRun"
            case 6: currentState := "RangerRun"
        }
        return
    }

    ; Ending time
    else if ImageSearch(&x, &y, 95, 213, 843, 909, "*40 " . GiantDone) == 1 {
        ;else if PixelSearch(&outX, &outY, 479, 248, 531, 440, 0xFDFDFD, 2) == 1 {
        Sleep(500)
        ShowToast("Ending Time")
        currentState := "EndingTime"
        return
    }

    ; Ưu tiên 4: inInventory
    else if (PixelSearch(&outX, &outY, 137, 235, 138, 236, 0x646464, 5) == 1) {
        turnInFight := 1
        numMana := 0
        ShowToast("It in inventory")
        currentState := "inInventory"

        return
    }

    ; Ưu tiên 5: chosing Card
    ; White in the ? symbol
    else if (PixelSearch(&outX, &outY, 1127, 227, 1141, 233, 0xFFFFFF, 5) == 1) {

        numRound := numRound + 1
        ShowToast(numRound)

        turnInFight := 1
        numMana := 0
        ShowToast("It Choosing card")
        currentState := "choosingEvent"
        return
    }
}

global FightX := 704
global FightY := 1050

global FocusX := 1211

global ItemX := 958

global realHpColor := 0xFF4E4E
global otherHpColor := 0xB95555

global realManaColor := 0x56B4EF

global strikeX := 739
global strikeY := 776
; mana have same Y
global manaY := 1010
; this is mana X
global mana1 := 1018
global mana2 := 1077

; FIX ADD ROUND 8
WarriorFight() {
    global currentState, numMana, numRound, turnInFight
    global FightX, FightY, strikeX, strikeY
    global BrutalSlashes, CrossSlash, OverpoweringSlash

    ; wait for our turn (wait for color white in Fight button)
    timeout := A_TickCount + 120000
    loop {
        if PixelSearch(&outX, &outY, 677, 1047, 677, 1054, 0xFFFFFF, 2) == 1 {
            Sleep(500)
            break
        }
        else if PixelSearch(&outX, &outY, 903, 556, 903, 584, 0xFFFFFF, 5) == 1 {
            Sleep(500)
            currentState := 'MainGame'
            break
        }
        if (A_TickCount > timeout)
            break
    }

    ; Check Mana when it our turn

    CheckMana()
    if PixelSearch(&outX, &outY, 795, 1050, 810, 1051, 0x646464, 2) == 1 {

        ; Click Fight
        clicking(705, 1053)
        Sleep(1000)

        ; Using Cross Slash
        if numRound != 8 {
            ; Cross Slash/Brutal Slashes need 2 Mana
            if numMana < 3 {
                clicking(strikeX, strikeY)
                Sleep(1000)
            }
            else {
                if (ImageSearch(&x, &y, 615, 738, 1304, 955, "*40 " . CrossSlash) == 1) {
                    ; Cross Slash cooldown
                    clicking(x, y)
                    Sleep(1000)
                }
                else if ImageSearch(&x, &y, 615, 738, 1304, 955, "*40 " . BrutalSlashes) == 1 {
                    clicking(x, y)
                    Sleep(1000)
                }
                else {
                    clicking(strikeX, strikeY)
                    ;clicking(1186, 774)
                    Sleep(1000)
                }
            }
        }

        ; Using Overpowering Slash
        else {
            if numMana != 4 {
                clicking(strikeX, strikeY)
                Sleep(1000)
            }
            else {
                if ImageSearch(&x, &y, 615, 738, 1304, 955, "*40 " . OverpoweringSlash) == 1 {
                    clicking(x, y)
                    Sleep(1000)
                }
            }
            if numMana == 2 && ImageSearch(&x, &y, 615, 738, 1304, 955, "*40 " . OverpoweringSlash) == 0 {
                if ImageSearch(&Brutalx, &Brutaly, 615, 738, 1304, 955, "*40 " . BrutalSlashes) == 0 {
                    clicking(Brutalx, Brutaly)
                }
            }
        }

        turnInFight := turnInFight + 1
    }
    ; choose enermy
    clicking(737, 778)

    Sleep(1000)
    ; Check HP after we got hit
    CheckHP()

    currentState := 'MainGame'
    return
}

RogueFight() {
}
MageFight() {
}
BrawlerFight() {
}
RangerFight() {
}

CheckHP() {
    global otherHpColor, needRest, numRound

    if (numRound == 7 || numRound == 8) {
        needRest := true
        return
    }

    if (PixelSearch(&outX, &outY, 779, 999, 780, 1000, otherHpColor, 5) == 1) {
        needRest := true
    }
    return
}

; FIX CHECK MANA
CheckMana() {
    global realManaColor, numMana, manaY, mana1, mana2
    if PixelSearch(&outX, &outY, 1198, 998, 1199, 998, realManaColor, 2) == 1 {
        numMana := 4
    }
    else if PixelSearch(&outX, &outY, 1142, 998, 1143, 998, realManaColor, 2) == 1 {
        numMana := 3
    }
    else if PixelSearch(&outX, &outY, 1076, 998, 1077, 998, realManaColor, 2) == 1 {
        numMana := 2
    }
    else if PixelSearch(&outX, &outY, 1021, 998, 1022, 998, realManaColor, 2) == 1 {
        numMana := 1
    }
}

inventory() {
    transferButtonX := 1189
    transferButtonY := 283

    colorBG := 0x646464
    bgX := 956
    bgY := 277
    global classChoose := ddl.Value, cantUpgrade
    global currentState

    ;transfer items
    ;while PixelSearch(&outX, &OutY, bgX, bgY, bgX + 1, bgY + 1,
    ;    colorBG, 15) == 0 {
    ;    MouseMove(transferButtonX + 5, transferButtonY + 5)
    ;    Click(transferButtonX, transferButtonY)
    ;}
    ;Sleep(1000)

    ;   Up grade

    ; OLD
    ;clicking(1632, 891)
    ;Sleep(500)

    ;loop {
    ;    while (ImageSearch(&x, &y, 1715, 876, 1773, 903, "*40 " . cantUpgrade) == 0) {
    ;        switch classChoose {
    ;            case 1:
    ;            {
    ;                loop 5 {
    ;                    clicking(550, 500)
    ;                    Sleep(1000)
    ;                }
    ;            }
    ;                ;case 2:
    ;                ;case 3:
    ;                ;case 5:
    ;                ;case 6:
    ;        }
    ;        clicking(952, 709)
    ;        Sleep(1000)
    ;    }
    ;}

    ; NEW
    timeout := A_TickCount + 120000
    loop {
        ; Click Invest
        clicking(1632, 891)
        Sleep(500)
        if PixelSearch(&outX, &outY, 549, 492, 550, 493, 0xFFFFFF, 2) == 0 {
            ;if (ImageSearch(&x, &y, 1715, 876, 1773, 903, "*40 " . cantUpgrade) == 1) {
            ShowToast("cant up")
            Sleep(500)
            break
        }
        else {
            ; uping
            switch classChoose {
                case 1:
                {
                    loop 5 {
                        clicking(550, 500)
                        Sleep(250)
                    }
                }
                    ;case 2:
                    ;case 3:
                    ;case 5:
                    ;case 6:
            }
            ; Confirm
            clicking(952, 709)
            Sleep(1000)
        }
        if (A_TickCount > timeout)
            break
    }

    ShowToast("DONE UPGRADE")

    ; Craft Button
    clicking(559, 342)
    Sleep(1000)
    ShowToast("Crafting table!!")

    ; Move Mouse to Crafting table
    MouseMove(276, 348)
    MouseMove(277, 349)
    clicking(277, 349)

    ShowToast("Crafting table menu")
    ; Crafting
    switch classChoose {
        case 1: WarriorCraft()

    }

    ; Ready
    clicking(962, 1026)
    Sleep(1000)
    timeout := A_TickCount + 120000
    loop {
        if PixelSearch(&outX, &outY, 137, 235, 138, 236, 0x646464, 5) == 0 {
            Sleep(200)
            break
        }
        if (A_TickCount > timeout)
            break
    }
    ;Sleep(1000)
    ;if PixelSearch(&outX, &outY, 1127, 227, 1141, 233, 0xFFFFFF, 5) == 1 {
    ;    Sleep(500)
    ;    currentState := "MainGame"
    ;}

    global currentState := "MainGame"
    return
}

WarriorCraft() {
    global numArmour, IronChestplate, IronLeggings, IronGreaves, IronHelmet, MetalScrap

    armourSequence := [IronChestplate, IronLeggings, IronGreaves, IronHelmet]
    ShowToast("Crafting")

    timeout := A_TickCount + 120000
    loop {
        if (numArmour >= armourSequence.Length)
            return

        targetArmour := armourSequence[numArmour + 1]

        if (ImageSearch(&x, &y, 64, 247, 509, 887, "*20 " . targetArmour) == 1) {
            ShowToast("Found item")

            if PixelSearch(&outX, &outY, x - 10, y - 10, x + 392, y + 34, 0x89FF77, 5) {
                ; Thấy ảnh + thấy màu xanh → craft và wear
                Sleep(500)
                clicking(outX, outY)
                Sleep(500)

                MouseMove(967, 292)
                clicking(968, 293)

                loop {
                    if PixelSearch(&outX, &outY, 1244, 624, 1245, 625, 0x323232, 2) == 1 {
                        Sleep(300)
                        break
                    }
                    else {
                        Send("{WheelDown}")
                        Sleep(200)
                    }
                    if (A_TickCount > timeout) {
                        break
                    }
                }

                Sleep(500)
                clicking(966, 604)
                ShowToast("Wear Done")
                Sleep(1000)

                clicking(277, 349)
                ShowToast("Continue Search")
                numArmour++

            }
            else {
                ; Thấy ảnh nhưng không thấy màu xanh → scroll xuống tiếp
                Send("{WheelDown}")
                Sleep(250)
            }
        }
        else {
            ; Không thấy ảnh → kiểm tra đã đến bottom chưa
            if PixelSearch(&outX, &outY, 495, 860, 496, 861, 0x323232, 5) == 1 {
                ; Đã đến bottom → mua MetalScrap nếu có, kéo lên và break
                if ImageSearch(&x, &y, 64, 247, 509, 887, "*40 " . MetalScrap) == 1 {
                    clicking(x + 350, y + 5)
                    Sleep(1000)
                }

                loop {
                    if PixelSearch(&outX, &outY, 495, 277, 496, 278, 0x323232, 5) == 1 {
                        ShowToast("End Scroll")
                        Sleep(500)
                        break
                    }
                    else {
                        ShowToast("Scroll up")
                        Send("{WheelUp}")
                        Sleep(100)
                    }
                    if (A_TickCount > timeout) {
                        break
                    }

                }

                Sleep(1000)
                break
            }
            else {
                ; Chưa đến bottom, chưa thấy ảnh → scroll xuống
                Send("{WheelDown}")
                Sleep(250)
            }
        }
    }
    return
}

EndingTime() {
    global currentState

    Sleep(500)
    clicking(1117, 666)
    ; in inventory
    loop {
        if PixelSearch(&outX, &outY, 137, 235, 138, 236, 0x646464, 5) == 1 {
            Sleep(200)
            break
        }

    }

    clicking(962, 1026)

    ;in choosing Event
    loop {
        if PixelSearch(&outX, &outY, 1127, 227, 1141, 233, 0xFFFFFF, 5) == 1 {
            Sleep(200)
            break
        }

    }

    clicking(1364, 937)

    loop {
        if (PixelSearch(&outX, &outY, 990, 246, 994, 255, 0xFFFFFF, 2) == 1) {
            Sleep(200)
            break
        }

    }

    ; Rest
    loop {
        if (PixelSearch(&outX, &outY, 1127, 227, 1141, 233, 0xFFFFFF, 5) == 0) {
            Sleep(200)
            break
        }

    }
    loop {
        if (PixelSearch(&outX, &outY, 990, 246, 994, 255, 0xFFFFFF, 2) == 1) {
            Sleep(200)
            break
        }

    }
    ; Rest
    clicking(1171, 667)
    Sleep(1000)

    ; ONLY FOCUS IN FIGHT to RESET

    ; wait in fight
    loop {
        if PixelSearch(&outX, &outY, 677, 1047, 677, 1054, 0xFFFFFF, 2) == 1 {
            Sleep(200)
            break
        }

    }

    loop {
        ; Done Fight
        if PixelSearch(&outX, &outY, 158, 754, 159, 755, 0x505050, 5) == 0 {
            Sleep(200)
            break
        }
        else {
            if PixelSearch(&outX, &outY, 677, 1047, 677, 1054, 0xFFFFFF, 2) == 1 {
                clicking(1210, 1051)
            }
        }

    }
    Sleep(500)
    currentState := "MainGame"
    return
}

; HUMAN DRAG
HumanDrag(startX, startY, endX, endY, moveSpeed := 15) {
    MouseMove(startX + 1, startY + 1)
    MouseMove(startX, startY)
    Sleep(150)

    Click("Down")
    Sleep(150)

    MouseMove(endX, endY, moveSpeed)
    Sleep(150)

    Click("Up")
    Sleep(100)
}

ChoosingEvent() {
    global currentState, classChoose := ddl.Value
    global warriorCard

    switch classChoose {
        case 1:
        {
            if ImageSearch(&x, &y, 323, 224, 1585, 901, "*40 " . warriorCard) == 1 {
                Sleep(1000)
                clicking(x, y)

                ;while (sawIt != 3) {
                ;    if PixelSearch(&outX, &outY, 934, 96, 1426, 89, 0x3C3C3C) == 1 {
                ;        Sleep(1000)
                ;        sawIt++
                ;    }
                ;}
                timeout := A_TickCount + 120000
                loop {
                    if (PixelSearch(&outX, &outY, 1448, 242, 1464, 244, 0xFFFFFF) == 1) {
                        Sleep(200)
                        break
                    }
                    if (A_TickCount > timeout) {
                        break
                    }
                }

                Sleep(1000)
                clicking(1134, 733)

                loop {
                    if PixelSearch(&outX, &outY, 903, 556, 903, 584, 0xFFFFFF, 5) == 1 {
                        Sleep(200)
                        break
                    }
                    if (A_TickCount > timeout) {
                        break
                    }
                }
                loop {
                    if (PixelSearch(&outX, &outY, 1448, 242, 1464, 244, 0xFFFFFF) == 1) {
                        Sleep(200)
                        break
                    }
                    if (A_TickCount > timeout) {
                        break
                    }
                }
                Sleep(1000)
                clicking(1194, 668)

                currentState := "MainGame"
            }
            else {
                SameEventPick()
                currentState := "MainGame"
            }
        }
    }
    return
}
SameEventPick() {
    global currentState, needRest, classChoose := ddl.Value

    if needRest == true {
        ; Short rest event
        clicking(1364, 937)
        Sleep(500)
        timeout := A_TickCount + 120000
        loop {
            if (PixelSearch(&outX, &outY, 1127, 227, 1141, 233, 0xFFFFFF, 5) == 0) {
                Sleep(200)
                break
            }
            if (A_TickCount > timeout) {
                break
            }
            Sleep(1000)
        }
        timeout := A_TickCount + 120000
        loop {
            if (PixelSearch(&outX, &outY, 990, 246, 994, 255, 0xFFFFFF, 2) == 1) {
                Sleep(200)
                break
            }
            if (A_TickCount > timeout) {
                break
            }
            Sleep(1000)
        }
        ; Rest
        clicking(1171, 667)
        Sleep(1000)
        needRest := false
    }
    else {
        ; scavenge event
        clicking(536, 937)
        Sleep(2000)
        timeout := A_TickCount + 120000
        switch classChoose {
            case 1, 2:
            {
                ; middle option
                timeout := A_TickCount + 120000
                loop {
                    if (PixelSearch(&outX, &outY, 990, 246, 994, 255, 0xFFFFFF, 3) == 1) {
                        Sleep(500)
                        break
                    }
                    if (A_TickCount > timeout) {
                        break
                    }
                    Sleep(500)
                }
                clicking(1152, 736)
                Sleep(2000)
            }

        }
        timeout := A_TickCount + 120000
        loop {
            if (PixelSearch(&outX, &outY, 990, 246, 994, 255, 0xFFFFFF, 3) == 1) {
                Sleep(500)
                break
            }
            if (A_TickCount > timeout) {
                break
            }
            Sleep(500)
        }
        Sleep(1000)

        MouseMove(1192, 670)
        clicking(1191, 668)
        Sleep(1000)
    }
    return
}

clicking(x, y) {
    MouseMove(x + 3, y + 3)
    Click(x, y)
}

TestFunc() {
    MsgBox(PixelSearch(&outX, &OutY, 974, 145, 975, 146, 0x282828, 15))

}
ShowToast(msg, duration := 2000) {
    t := Gui("+AlwaysOnTop -Caption +ToolWindow")
    t.SetFont("s16")
    t.Add("Text", "cBlack", msg)
    t.BackColor := "FFFFFF"
    ; t.Show("Center")
    ;t.Show("NoActivate x" . (A_ScreenWidth - 300) . " y" . (A_ScreenHeight - 600))
    t.Show("NoActivate x0 y0")

    SetTimer(() => t.Destroy(), -duration)
}
