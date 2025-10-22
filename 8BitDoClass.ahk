#Requires AutoHotkey v2.0

/*

8BitDo.ahk - Context Sensitive Hotkeys in AutoHotkey v2 for 8BitDo and Other Controllers
=======================================================================================

I use this class, _8, to more easily write hotkeys for my 8BitDo Controller.
I wanted something that would let me write hotkeys for a given program, but also have "defaults" to fallback to so I didn’t need to rewrite the functions (like pressing up/down/left/right) everywhere. I also wanted different shortcuts depending on whether I pressed a key quickly or held it down.

I knew about the built-in Joy mappings for Autohotkey and about simply mapping controller buttons to regular keys (like mapping a button in a manufacteror's app to F1, then writing F1:: as a hotkey trigger), but I wanted:
- An easier way to see my hotkeys in code as "a", "b", "x" instead of remembering what they were mapped to. 
- A way to change the mappings in one place instead of hunting through the script. (Say I want to use FN keys instead of numpadinsert, much easier to change the mapping than find all instances of Numpadinsert)
- Optional URL-specific shortcuts (via my OnWebsite.ahk script) so I could do different things depending on the website.
- A global fallback: e.g. I can set arrow keys for navigation once and not repeat them in every context.

Quick Example
-------------

Example:
    _8.a["global"] := (*) => MsgBox("Tapped A")
    _8.aH["global"] := (*) => MsgBox("Held A")


- Tap  : _8.a   (runs immediately on press)
- Hold : _8.aH  (runs if the button is held for longer than ~200ms)
When both are defined in the same context, _8 automatically decides which to trigger based on how long you hold the button.

You can use a URL (if you have OnWebsite.ahk included), Wintitle, class, or exe in the parameters:

 _8.aH["global"] := (*) => MsgBox("Held A global context") 
 _8.aH["browsers"] := (*) => MsgBox("Held A in a browser")
 _8.aH["Spotify Premium", "ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => MsgBox("Held A in either a window containing `"Spotify Premium`" or the desktop application")
 _8.aH["ahk_class #32768"] := (*) => MsgBox("Held A in a win 32 menu")
  _8.aH["mail.google.com"] := (*) => MsgBox("Held A a browser on Mail.google.com")


Context order - brief explanation how how the script determins priority:
When a button is pressed, _8 checks contexts in order of specificity:

1. Win32 Menus (ahk_class #32768) -> for right-click/context menus
2. Application-specific (e.g. ahk_exe notepad.exe,)
3. URL-specific (via OnWebsite.ahk — e.g. "youtube.com")
4. Window Title matches (checks if the active window’s title contains the context string)
5. Window Class matches (checks against the window’s class name)
6. Default (no context) -> hotkeys defined without a context
7. Global mappings -> last-resort fallback


This allows you to set defaults for all programs (or all browsers) and if nothing more specific is defined, it will fall back to that.


How to Set It Up
----------------
1.  Pick a key mapping style. Below are three options to start. Feel free to paste these over the ones in the class, or tweak and (or make your own).

2. Remap your controller as a keyboard (each gamepad uses a different method, but the 8BitDo has it's own app). Use your 8BitDo (or other controller) in keyboard mode and assign each button to a hotkey.
   You can use modifiers (Alt, Win, etc.), but be careful — for example, Alt+F4 will close programs. I try to stick with function keys or numpad keys to avoid conflicts.


Option 1: Function Keys Only
(Uses F13–F24 for buttons, F1–F4 for the D-pad)
    static keyMap := Map(
        "a", "F13",
        "b", "F14",
        "x", "F15",
        "y", "F16",
        "l", "F17",
        "r", "F18",
        "l2", "F19",
        "r2", "F20",
        "select", "F21",
        "start", "F22",
        "star", "F23",
        "home", "F24",
        "left", "F1",
        "down", "F2",
        "right", "F3",
        "up", "F4"
    )

Option 2: Windows + Function Keys
(Each button is Win+Fx, safe from most app shortcuts. D-pad stays plain F1–F4.)

    static keyMap := Map(
        "a", "#F1",
        "b", "#F2",
        "x", "#F3",
        "y", "#F4",
        "l", "#F5",
        "r", "#F6",
        "l2", "#F7",
        "r2", "#F8",
        "select", "#F9",
        "start", "#F10",
        "star", "#F11",
        "home", "#F12",
        "left", "F1",
        "down", "F2",
        "right", "F3",
        "up", "F4"
    )

Option 3: Numpad Keys
(Works well if you don’t use numpad for typing; easy to visualize.)

    static keyMap := Map(
        "a", "NumpadInsert", ; 0
        "b", "NumpadEnd",    ; 1
        "x", "NumpadDown",   ; 2
        "y", "NumpadPgDn",   ; 3
        "l", "NumpadPgUp",   ; 9
        "r", "NumpadDiv",    ; /
        "l2", "NumpadMult",  ; *
        "r2", "NumpadSub",   ; -
        "select", "NumpadAdd",   ; +
        "start", "NumpadClear", ; 5
        "star", "NumpadEnter",  ; Enter
        "home", "NumpadHome",   ; 7
        "left", "NumpadLeft",   ; 4
        "down", "NumpadDel",    ; .
        "right", "NumpadRight", ; 6
        "up", "NumpadUp"        ; 8
    )

A side note: I found it difficult to make the class flexible enough to have the hotkeys often changed, but allow combination buttons. I had a version that worked, but the deal-breaker I couldn't get past was not being able to press/hold buttons. (If anyone has ideas for that, I'm all ears. I could get the _8ab.[""] to dynamically assign _8ab, but with fat-arrow/lambda functions and logic of the detection pattern, they only executed after keys were pressed off.)

That's why you'll see me keep F1-F4 as the "arrow" up/down/left/right keys - then it's pretty easy to press up/down together to mimic my mouse gesture shortcuts:

Up + Left - Close Window                                      Up + Right = maximize window (or full screen if maximized)
Down + Left - Get out of full screen/Restore window           Down + Right - Minimize window

But write that as this outside of the functions.
Here is my monitor manager class::https://github.com/thehafenator/monitor-manager 
~F1 & F4::mm.GestureUL() 
~F4 & F1::mm.GestureUL()
~F3 & F4::mm.GestureUR() 
~F4 & F3::mm.GestureUR() 
~F2 & F1::mm.GestureDL()
~F1 & F2::mm.GestureDL()
~F2 & F3::mm.GestureDR()
~F3 & F2::mm.GestureDR()



Sample Defaults:
---------------
Here are some defaults I use as examples.

Global mappings:

    _8.home["global"] := (*) => Sendinput("!{Tab}") ; home button switches to most recent 
    _8.up["global"] := (*) => Send("{up down}") ; up presses and holds up arrow until released 
    _8.down["global"] := (*) => Send("{down down}") ; down presses down until released
    _8.start["global"] := (*) => send("^z") ; global undo

    ; a few I use globally, sharing mostly for ideas, but let me know if you want to see the functions themselves:
  ;   _8.selectH["global"] := (*) => chatgpt.screenshot() ; takes a screenshot, opens chatgpt, asks it to tell me more about it. Very fast. 
  ;  _8.starH["global"] := (*) => WebsiteMenus() 
  ; I have a set of menus for each website I use (see my script Macropad.ahk script). This is my personal 'context menu' for each program, and will open a win32 menu and move through it with the remote. Helpful for not needing to map out every command to the controller.   
   ; _8.star["global"] := (*) => Macropad.menus["default"].Show() 
   
   ; Shows my main macropad menu - how I quickly navigate through shortcuts. See here: https://github.com/thehafenator/Macropad.ahk, https://www.autohotkey.com/boards/viewtopic.php?t=136601

Win32 Menu mappings:
This is for win32 menus (Macropad.ahk). I like to have win32 menus for specific contexts:
call the menu, then circle through and select using the controller.

    ; Most important - arrow keys
    _8.up["ahk_class #32768"] := (*) => Send("{Up down}")
    _8.upH["ahk_class #32768"] := (*) => Send("{Up down}")
    _8.down["ahk_class #32768"] := (*) => Send("{Down down}")
    _8.downH["ahk_class #32768"] := (*) => Send("{Down down}")
    
    _8.left["ahk_class #32768"] := (*) => Send("{Left}") ; moves back up one submenu level
    _8.right["ahk_class #32768"] := (*) => Send("{Enter}")

    _8.l2["ahk_class #32768"] := (*) => (ToolTip("<<<< Moved Left!"), Send("^#{Left}"), SetTimer((*) => ToolTip(), -1000)) ; moves left a desktop while menu is open
    _8.r2["ahk_class #32768"] := (*) => (ToolTip(">>>> Moved Right!"), Send("^#{Right}"), SetTimer(() => ToolTip(), -1000)) ; moves right a desktop while open

    _8.a["ahk_class #32768"] := (*) => Send("1") ; clicks first thing on the menu
    _8.aH["ahk_class #32768"] := (*) => Send("{Media_Play_Pause}") 
    _8.b["ahk_class #32768"] := (*) => Send("2") ; 2nd thing on menu
    _8.r["ahk_class #32768"] := (*) => Send("{Media_Next}")
    _8.x["ahk_class #32768"] := (*) => Send("4")
    _8.y["ahk_class #32768"] := (*) => Send("3")
    _8.l["ahk_class #32768"] := (*) => Send("{Media_Prev}")

    _8.select["ahk_class #32768"] := (*) => Send("c")
    _8.selectH["ahk_class #32768"] := (*) => Send("t")
    _8.start["ahk_class #32768"] := (*) => Send("{Escape}")

Function key combos for Monitor Manager:
I use just Fn keys here — this lets me maximize or fullscreen programs in specific quadrants of the screen.
I tried for a long time to do write this in _8 syntax for combination buttons, but I ran into problems (hotkeys not firing until released, couldn’t hold down a key and repeat), etc. 
This is a fairly easy alternative and only for four keys. It calls into my MonitorManager class if you're interested https://github.com/thehafenator/monitor-manager. I also use it with my Mouse Gesture Scripts https://github.com/thehafenator/MouseGestures

    ~F1 & F4::mm.GestureUL()
    ~F4 & F1::mm.GestureUL()
    ~F3 & F4::mm.GestureUR()
    ~F4 & F3::mm.GestureUR()
    ~F2 & F1::mm.GestureDL()
    ~F1 & F2::mm.GestureDL()
    ~F2 & F3::mm.GestureDR()
    ~F3 & F2::mm.GestureDR()

Example of a specific program: Spotify

; I like to use the full desktop/class together so it only targets the desktop program. (Other spotify processes exist with Spotify.exe) 
_8.left["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.scrubbackorprevious()
_8.x["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.scrubforwardornext()
_8.b["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.scrubbackorprevious()
_8.up["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => media.volume.up()
_8.down["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => media.volume.down()
_8.a["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.toggleplaypause()
_8.select["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.increasespeed()
_8.start["ahk_exe Spotify.exe ahk_class Chrome_WidgetWin_1"] := (*) => spotify.decreasespeed()


A specific website
YouTube-specific mappings:
Uses the Video Speed Controller chrome extension (with w, e, and r set to decrease, increase, and set to 2.4x speed).

    _8.rightH["youtube.com"] := (*) => Send("r")
    _8.leftH["youtube.com"] := (*) => youtube.skipadd()
    _8.right["youtube.com"] := (*) => Send("{Right}")
    _8.left["youtube.com"] := (*) => Send("{Left}")
    _8.select["youtube.com"] := (*) => SendInput("e")
    _8.start["youtube.com"] := (*) =>  SendInput("w")
    _8.b["youtube.com"] := (*) => Send("{Left}")
    _8.x["youtube.com"] := (*) => Send("{Right}")
    _8.y["youtube.com"] := (*) => Send("f")
    _8.l2["youtube.com"] := (*) => SendInput("e")
    _8.r2["youtube.com"] := (*) => SendInput("w")
    _8.aH["youtube.com"] := (*) => Send("c")
    _8.a["youtube.com"] := (*) => Send("{Space}")
    _8.l["youtube.com"] := (*) => youtube.sethighestquality()
    _8.r2["youtube.com"] := (*) => youtube.sethighestquality()


*/


#Requires AutoHotkey v2.0
class _8 { ; version 08.013.2025
    static hotkeys := Map()

    static browsers := [
        "ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe",
        "ahk_class ApplicationFrameWindow ahk_exe msedge.exe", 
        "ahk_class MozillaWindowClass ahk_exe firefox.exe",
        "ahk_class Chrome_WidgetWin_1 ahk_exe thorium.exe",
        "ahk_class Chrome_WidgetWin_1 ahk_exe floorp.exe"
    ]

    static keyMap := Map( ; see others in readme file
        "a", "F13",
        "b", "F14",
        "x", "F15",
        "y", "F16",
        "l", "F17",
        "r", "F18",
        "l2", "F19",
        "r2", "F20",
        "select", "F21",
        "start", "F22",
        "star", "F23",
        "home", "F24",
        "left", "F1",
        "down", "F2",
        "right", "F3",
        "up", "F4"
    )

    static __New() {
        this.CreateDynamicProperties()
    }

    static CreateDynamicProperties() {
        for button in this.keyMap {
            this.CreateButtonProperty(button, false)
        }
        for button in this.keyMap {
            this.CreateButtonProperty(button, true)
        }
    }

    static CreateButtonProperty(buttonName, isHold) {
        propName := isHold ? buttonName . "H" : buttonName
        capturedButton := buttonName
        capturedIsHold := isHold
        this.DefineProp(propName, {
            set: (this, value, contexts*) => 
                capturedIsHold ? 
                    this.SetupHoldHotkey(capturedButton, contexts, value) : 
                    this.SetupHotkey(capturedButton, contexts, value)
        })
    }

    static SetupHotkey(button, contexts, callback) {
        hotkeyName := this.keyMap[button]
        hotkeyId := hotkeyName
        if (!this.hotkeys.Has(hotkeyId)) {
            this.hotkeys[hotkeyId] := Map()
        }
        if (contexts.Length == 0) {
            this.hotkeys[hotkeyId]["|"] := {context: "", callback: callback}
        } else {
            for context in contexts {
                context := Trim(context)
                this.hotkeys[hotkeyId][context . "|"] := {context: context, callback: callback}
            }
        }
        this.RegisterHotkeyWrapper(hotkeyName, button, false)
    }
    
    static SetupHoldHotkey(button, contexts, callback) {
        hotkeyName := this.keyMap[button]
        hotkeyId := hotkeyName . "_hold"
        if (!this.hotkeys.Has(hotkeyId)) {
            this.hotkeys[hotkeyId] := Map()
        }
        if (contexts.Length == 0) {
            this.hotkeys[hotkeyId]["|"] := {context: "", callback: callback}
        } else {
            for context in contexts {
                context := Trim(context)
                this.hotkeys[hotkeyId][context . "|"] := {context: context, callback: callback}
            }
        }
        this.RegisterHotkeyWrapper(hotkeyName, button, true)
    }

static RegisterHotkeyWrapper(hotkeyName, button, isHold) {
    wrapperFunc(thisHotkey) {
        currentUrl := ""
        if IsSet(On) {
            try {
                currentUrl := On.LastResult.url ? On.LastResult.url : ""
            } catch {
            }
        }
        hasContextMenu := false
        try {
            hasContextMenu := WinExist("ahk_class #32768")
        }
        activeWin := ""
        activeClass := ""
        activeExe := ""
        try {
            activeWin := WinGetTitle("A")
            activeClass := WinGetClass("A")
            activeExe := WinGetProcessName("A")
        }
        regularHotkeyId := _8.keyMap[button]
        holdHotkeyId := regularHotkeyId . "_hold"
        regularCallback := ""
        holdCallback := ""
        globalRegularCallback := ""
        globalHoldCallback := ""
        
        if (_8.hotkeys.Has(regularHotkeyId) && _8.hotkeys[regularHotkeyId].Has("global|")) {
            globalRegularCallback := _8.hotkeys[regularHotkeyId]["global|"].callback
        }
        if (_8.hotkeys.Has(holdHotkeyId) && _8.hotkeys[holdHotkeyId].Has("global|")) {
            globalHoldCallback := _8.hotkeys[holdHotkeyId]["global|"].callback
        }
        
        if (hasContextMenu) {
            if (_8.hotkeys.Has(regularHotkeyId)) {
                for key, entry in _8.hotkeys[regularHotkeyId] {
                    if (entry.context == "#32768" || entry.context == "ahk_class #32768") {
                        regularCallback := entry.callback
                        break
                    }
                }
            }
            if (_8.hotkeys.Has(holdHotkeyId)) {
                for key, entry in _8.hotkeys[holdHotkeyId] {
                    if (entry.context == "#32768" || entry.context == "ahk_class #32768") {
                        holdCallback := entry.callback
                        break
                    }
                }
            }
        }
        
        ContextMatches(context) {
            if (context == "" || context == "global")
                return false
            
            ; Updated browser detection - use combined class+exe criteria like _MG class
            isBrowserActive := false
            for criteria in _8.browsers {
                if (WinActive(criteria)) {
                    isBrowserActive := true
                    break
                }
            }
            
            if (isBrowserActive && currentUrl != "" && InStr(currentUrl, context))
                return true
            return ((activeWin != "" && InStr(activeWin, context)) || 
                    (activeClass != "" && InStr(activeClass, context)) || 
                    (activeExe != "" && InStr(activeExe, context)) || 
                    WinActive(context))
        }
        
        ; Helper function to determine context specificity
        GetContextSpecificity(context) {
            ; URL contexts (most specific)
            if (InStr(context, ".com") || InStr(context, ".org") || InStr(context, ".net") || 
                InStr(context, ".edu") || InStr(context, ".gov") || InStr(context, "://"))
                return 3
            ; Executable contexts  
            if (InStr(context, ".exe"))
                return 1
            ; Window/class contexts
            return 2
        }
        
        ; Sort contexts by specificity
        SortContextsBySpecificity(contextArray) {
            ; Simple bubble sort by specificity (URL > Window > Exe)
            n := contextArray.Length
            Loop n-1 {
                i := A_Index
                Loop n-i {
                    j := A_Index
                    if (GetContextSpecificity(contextArray[j].context) < GetContextSpecificity(contextArray[j+1].context)) {
                        ; Swap
                        temp := contextArray[j]
                        contextArray[j] := contextArray[j+1]
                        contextArray[j+1] := temp
                    }
                }
            }
            return contextArray
        }
        
        if (regularCallback == "" && holdCallback == "") {
            ; Collect matching regular contexts
            regularMatches := []
            if (_8.hotkeys.Has(regularHotkeyId)) {
                for key, entry in _8.hotkeys[regularHotkeyId] {
                    if (entry.context != "" && ContextMatches(entry.context)) {
                        regularMatches.Push(entry)
                    }
                }
            }
            
            ; Collect matching hold contexts  
            holdMatches := []
            if (_8.hotkeys.Has(holdHotkeyId)) {
                for key, entry in _8.hotkeys[holdHotkeyId] {
                    if (entry.context != "" && ContextMatches(entry.context)) {
                        holdMatches.Push(entry)
                    }
                }
            }
            
            ; Sort by specificity and take most specific match
            if (regularMatches.Length > 0) {
                regularMatches := SortContextsBySpecificity(regularMatches)
                regularCallback := regularMatches[1].callback
            }
            if (holdMatches.Length > 0) {
                holdMatches := SortContextsBySpecificity(holdMatches)
                holdCallback := holdMatches[1].callback
            }
            
            ; Fall back to default callbacks
            if (regularCallback == "" && _8.hotkeys.Has(regularHotkeyId) && _8.hotkeys[regularHotkeyId].Has("|")) {
                regularCallback := _8.hotkeys[regularHotkeyId]["|"].callback
            }
            if (holdCallback == "" && _8.hotkeys.Has(holdHotkeyId) && _8.hotkeys[holdHotkeyId].Has("|")) {
                holdCallback := _8.hotkeys[holdHotkeyId]["|"].callback
            }
            
            ; Fall back to global callbacks
            if (regularCallback == "" && globalRegularCallback != "") {
                regularCallback := globalRegularCallback
            }
            if (holdCallback == "" && globalHoldCallback != "") {
                holdCallback := globalHoldCallback
            }
        }
        
        ; Execute based on what we have
        if (regularCallback != "" && holdCallback != "") {
            ; We have both - use press/hold detection
            _8.HandlePressOrHold(hotkeyName, regularCallback, holdCallback)
        } else if (regularCallback != "") {
            ; Only regular callback - execute immediately
            regularCallback()
        } else if (holdCallback != "") {
            ; Only hold callback - require actual hold
            _8.HandlePressOrHold(hotkeyName, "", holdCallback)
        }
    }
    registryKey := button . "_registered"
    if (!this.hotkeys.Has(registryKey)) {
        try {
            Hotkey(hotkeyName, , "Off")
        }
        try {
            Hotkey(hotkeyName, wrapperFunc, "On")
            this.hotkeys[registryKey] := true
        }
    }
}
    
static HandlePressOrHold(key, pressCallback, holdCallback, holdTime := 0.2) {
   keyName := RegExReplace(key, "[\^!+#]+", "")
    
    if (pressCallback == "" && holdCallback == "") {
        return
    }
    if (!KeyWait(keyName, "T" holdTime)) {
        if (holdCallback != "") {
            holdCallback()
        }
    } else if (pressCallback != "") {
        pressCallback()
    }
    KeyWait(keyName)
}
}
