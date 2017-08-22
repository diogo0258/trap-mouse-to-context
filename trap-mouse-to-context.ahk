#NoEnv

h =
(
Ctrl+f12	Trap to win
Ctrl+f11	Trap to control
Ctrl+f10	Trap to rectangle
Esc	Free mouse
Ctrl+Alt+Q	Exit
)

Icon_def  := A_ScriptDir . "\def.ico"
Icon_win  := A_ScriptDir . "\win.ico"
Icon_ctrl := A_ScriptDir . "\ctrl.ico"
Icon_rect := A_ScriptDir . "\rect.ico"

;---

OnExit, Fin
CoordMode, Mouse, Screen
GroupAdd, allw

if fileexist(Icon_def)
	Menu, Tray, Icon, % Icon_def
Menu, Tray, Add		; separator
Menu, Tray, Add, Trap to Window (Ctrl + F12), Menu_win
Menu, Tray, Add, Trap to Control (Ctrl + F11), Menu_ctrl
Menu, Tray, Add, Trap to Rectangle (Ctrl + F10), Menu_rect

TrayTip, %A_ScriptName%, %h%,,1
SetTimer, KillTrayTip, -5000
return

;---

^f12::ClipCursorCall("win")
^f11::ClipCursorCall("ctrl")
^f10::ClipCursorCall("rect")

Menu_win:
Menu_ctrl:
Menu_rect:
SetTimer, KillTrayTip, off
StringTrimLeft, gcmd, A_ThisLabel, 5
if gcmd = rect
{
	TrayTip, %A_ScriptName%, Activate the target window
	Hotkey, Esc, Free, on
	WinWaitActive, ahk_group allw
	ClipCursorCall(gcmd)
}
else
{
	TrayTip, %A_ScriptName%, % "Click on the " (gcmd = "win" ? "window" : "control" ) " you wanna`ntrap the mouse into."
	Hotkey, LButton, Clik, on, UseErrorLevel
	Hotkey, Esc, Free, on
}
return


Clik:
Hotkey, LButton, off
ClipCursorCall(gcmd)
TrayTip
return


Free:
	ClipCursor(False)
	Hotkey, Esc, off
	
	if fileexist(Icon_def)
		Menu, Tray, Icon, % Icon_def
	TrayTip
return


ClipCursorCall(cmd) {
	if (cmd = "win")
	{
		MouseGetPos,,, wid
		WinActivate, ahk_id %wid%
		WinGetPos, wx,wy,ww,wh, ahk_id %wid%
		if not (wx and wy and ww and wh)
			return
		x1:=wx, y1:=wy, x2:=wx+ww, y2:=wy+wh
	}
	else if (cmd = "ctrl")
	{
		MouseGetPos,,, wid, cid, 2
		WinActivate, ahk_id %wid%
		WinGetPos, wx,wy,ww,wh, ahk_id %wid%
		ControlGetPos, cx,cy,cw,ch,, ahk_id %cid%
		if not (cx and cy and cw and ch)
			return
		x1:=wx+cx, y1:=wy+cy, x2:=wx+cx+cw, y2:=wy+cy+ch
	}
	else if (cmd = "rect")
	{
		ClipCursor(False)
		TrayTip, %A_ScriptName%, Draw the rectangle you wanna`ntrap the mouse into
		LetUserSelectRect(x1, y1, x2, y2)
		TrayTip
	}
	else
		return
	
	ClipCursor(True, x1, y1, x2, y2)
	Hotkey, Esc, Free, on

	if FileExist(Icon_%cmd%)
		Menu, Tray, Icon, % Icon_%cmd%
}


;~ SKAN's, http://www.autohotkey.com/forum/post-141037.html#141037
ClipCursor(Confine=True, x1=0 , y1=0, x2=1, y2=1) {
	VarSetCapacity(R,16,0),  NumPut(x1,&R+0),NumPut(y1,&R+4),NumPut(x2,&R+8),NumPut(y2,&R+12)
	Return Confine ? DllCall( "ClipCursor", UInt,&R ) : DllCall( "ClipCursor" )
}


;~ Lexikos', http://www.autohotkey.com/forum/topic49784.html
LetUserSelectRect(ByRef X1, ByRef Y1, ByRef X2, ByRef Y2)
{
    static r := 1
    ; Create the "selection rectangle" GUIs (one for each edge).
    Loop 4 {
        Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTop
        Gui, %A_Index%: Color, Red
    }
    ; Disable LButton.
    Hotkey, *LButton, lusr_return, On
    ; Wait for user to press LButton.
    KeyWait, LButton, D
    ; Get initial coordinates.
    MouseGetPos, xorigin, yorigin
    ; Set timer for updating the selection rectangle.
    SetTimer, lusr_update, 10
    ; Wait for user to release LButton.
    KeyWait, LButton
    ; Re-enable LButton.
    Hotkey, *LButton, Off
    ; Disable timer.
    SetTimer, lusr_update, Off
    ; Destroy "selection rectangle" GUIs.
    Loop 4
        Gui, %A_Index%: Destroy
    return
 
    lusr_update:
        MouseGetPos, x, y
        if (x = xlast && y = ylast)
            ; Mouse hasn't moved so there's nothing to do.
            return
        if (x < xorigin)
             x1 := x, x2 := xorigin
        else x2 := x, x1 := xorigin
        if (y < yorigin)
             y1 := y, y2 := yorigin
        else y2 := y, y1 := yorigin
        ; Update the "selection rectangle".
        Gui, 1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" r
        Gui, 2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" r
        Gui, 3:Show, % "NA X" x1 " Y" y1 " W" r " H" y2-y1
        Gui, 4:Show, % "NA X" x2-r " Y" y1 " W" r " H" y2-y1
    lusr_return:
    return
}

;---

KillTrayTip:
	TrayTip
return

^!q::
Fin:
	ClipCursor(False)
ExitApp