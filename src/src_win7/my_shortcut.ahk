

; shift + esc - Turn Monitor Off
; Ctrl + win + L - Lock PC then turn off monitor
; win + g - googling selected text
; win + tab - open selected text(web link) in new tab, only within browser window
; powerful screen capture funtion
;    Ctrl + Shift + mouse drag capture to clipboard
;    Ctrl + Alt + mouse drag capture to desktop\screen.bmp(drag top to bottom) / desktop\screen.jpg(drag bottom to top)
; win + arrow
; 	left/right - move window between left and right monitor, active window will be used
; 	up/down - minimize / maximize window, active window will be used
; win+alt+arrow - place window at right/left/top/down side within monitor, active window will be used
; win+c=c drive, win+n = notepad, win+p = mspaint, win + z = cmd prompt
;
; #############################################################################################

#Include %A_ScriptDir%\ScreenCapture.ahk	; credit to sreen capture script by Sean


; vnc exception
; Both Left & Right Button press emulate Middle Button
;#IfWinActive, ahk_class rfb::win32::DesktopWindowClass
;~LButton & RButton::
;Thread, priority, 1
;MouseClick, LEFT, , , , , U
;MouseClick, MIDDLE, , , , , D
;KeyWait, LButton
;MouseClick, MIDDLE, , , , , U
;return
;#IfWinActive


#c::run, c:\
#n::run, notepad
#p::run, mspaint 
#z::run, cmd

winhide:=0
winhide2:=0
winhideid=
winhide2id=
#h::
winhide := !winhide
if (winhide = 1) {
  WinGet, winhideid, ID, A
  WinHide, ahk_id %winhideid%
} else {
  WinShow, ahk_id %winhideid%
  WinActivate, ahk_id %winhideid%
}
return

^#h::
winhide2 := !winhide2
if (winhide2 = 1) {
  WinGet, winhide2id, ID, A
  WinHide, ahk_id %winhide2id%
} else {
  WinShow, ahk_id %winhide2id%
  WinActivate, ahk_id %winhide2id%
}
return


; CapsLock::return	; ignore capslock if pressing alone

CapsLock up::
autocompletion:
if A_ThisHotkey != %A_PriorHotkey%
  return
Input, UserInput, T5 L%SYS_aliaslen% C, {space}{tab}{esc}{enter}, *
;if ErrorLevel = Max
;{
;  SYS_ToolTipText = You entered "%UserInput%", which is the maximum length of text.
;  Gosub, SYS_ToolTipFeedbackShow
;  return
;}
;if ErrorLevel = Timeout
;{
;  SYS_ToolTipText = You entered "%UserInput%" at which time the input timed out.
;  Gosub, SYS_ToolTipFeedbackShow
;  return
;}
if ErrorLevel = NewInput
    return

; Otherwise, a match was found.
SetKeyDelay, -1  ; Most editors can handle the fastest speed.
compmatch=0
Loop, parse, CompletionsL, `,
{
    if UserInput = %A_LoopField%
    {
      compmatch=1
      if IsLabel(CompletionsR%A_Index%)
        gosub % CompletionsR%A_Index%
      else if RegExMatch(CompletionsR%A_Index%,"^run_(.*)",matchrun)
        Run, % matchrun1
      else  
        Send, % CompletionsR%A_Index%
    }
}

if compmatch=0
  if UserInput!=
  {
    SYS_ToolTipText = You entered "%UserInput%" which is no match !!!
    Gosub, SYS_ToolTipFeedbackShow
  }  
return

 
$tab::
GetKeyState, CapsState, CapsLock, P
if ( CapsState = "D" )
	Gosub, CAPSMENU
else  
	Send, {tab}
return	

/*
#q::
	Send, ^c
  Run, %clipboard%
return	
*/



CAPSMENU:
Menu,convert,Add
Menu,convert,Delete
Menu,convert,Add,CAPStoggle,CAPSTOGGLE
Menu,convert,Add,
Menu,Convert,Add,CapsLock &On,CAPSON
Menu,Convert,Add,&CapsLock Off,CAPSOFF
Menu,convert,Add,
Menu,convert,Add,&UPPER CASE,UPPER
Menu,convert,Add,&lower case,LOWER
Menu,convert,Add,&Title Case,TITLE
Menu,convert,Add,&iNVERT cASE,INVERT
;Menu,convert,Default,CapShift
Menu,convert,Show
Return

CAPSON:
SetCapsLockState,On
SYS_ToolTipText = Capslock On
Gosub, SYS_ToolTipFeedbackShow
Return


CAPSOFF:
SetCapsLockState,Off
SYS_ToolTipText = Capslock Off
Gosub, SYS_ToolTipFeedbackShow
Return

CAPSTOGGLE:
GetKeyState,state,CapsLock,T
If state=D
{
  SetCapsLockState,Off
  SYS_ToolTipText = Capslock Off
}
Else
{
  SetCapsLockState,On
  SYS_ToolTipText = Capslock On
}
Gosub, SYS_ToolTipFeedbackShow
Return


STRCUT:
oldclipboard:=ClipboardAll
WinActivate,ahk_id %id%
WinWaitActive,ahk_id %id%,,1
WinGetClass,class,ahk_id %id%
If class In Progman,WorkerW,Explorer,CabinetWClass
  Send,{F2}
Send,^x
Sleep,30
ClipWait,1
string=%clipboard%
; SYS_ToolTipText = %string%
; Gosub, SYS_ToolTipFeedbackShow
Return


PASTESTR:
WinActivate,ahk_id %id%
WinWaitActive,ahk_id %id%,,1
If class In Progman,WorkerW,Explorer,CabinetWClass
  Send,{F2}
clipboard=%string%
Send,^v
Sleep,30
Clipboard:=oldclipboard
oldclipboard=
Return


UPPER:
Gosub,STRCUT
StringUpper,string,string
Gosub,PASTESTR
SYS_ToolTipText = Selection converted to UPPER CASE
Gosub, SYS_ToolTipFeedbackShow
string=
Return


LOWER:
Gosub,STRCUT
StringLower,string,string
Gosub,PASTESTR
SYS_ToolTipText = Selection converted to lower CASE
Gosub, SYS_ToolTipFeedbackShow
string=
Return


TITLE:
Gosub,STRCUT
StringLower,string,string,T
Gosub,PASTESTR
SYS_ToolTipText = Selection converted to Title CASE
Gosub, SYS_ToolTipFeedbackShow
string=
Return


INVERT:
Gosub,STRCUT
StringLen,length,string
Loop,%length%
{
  StringLeft,char,string,1
  If char Is Upper
    StringLower,char,char
  Else
  If char Is Lower
    StringUpper,char,char
  StringTrimLeft,string,string,1
  string=%string%%char%
}
Gosub,PASTESTR
SYS_ToolTipText = Selection converted to iNVERTED CASE
Gosub, SYS_ToolTipFeedbackShow
string=
Return


; disable this for onenote
#IfWinNotActive, ahk_class Framework::CFrame
$up::
GetKeyState, CapsState, CapsLock, P
if ( CapsState = "D" )
	Send, {WheelUp}
else
	Send, {up}
return

$down::
GetKeyState, CapsState, CapsLock, P
if ( CapsState = "D" )
	Send, {WheelDown}
else
	Send, {down}
return
#IfWinNotActive

$left::
GetKeyState, CapsState, CapsLock, P
if ( CapsState = "D" )
	Send, {WheelLeft}
else
	Send, {left}
return

$right::
GetKeyState, CapsState, CapsLock, P
if ( CapsState = "D" )
	Send, {WheelRight}
else
	Send, {right}
return

; Top 3 favourite Apps / Directory
; $1::
; GetKeyState, CapsState, CapsLock, P
; if ( CapsState = "D" )
; 	run, %Favourite1%
; else
; 	Send, 1
; return	
; 
; $2::
; GetKeyState, CapsState, CapsLock, P
; if ( CapsState = "D" )
; 	run, %Favourite2%
; else
; 	Send, 2
; return	
; 
; $3::
; GetKeyState, CapsState, CapsLock, P
; if ( CapsState = "D" )
; 	run, %Favourite3%
; else
; 	Send, 3
; return	




; $CapsLock::
; 	GetKeyState, ShiftState, Shift, P
; 	GetKeyState, CtrlState, Ctrl, P
; 	
; 	if( (ShiftState = "D") or (CtrlState = "D") )
; 	{
; 		Send, {CapsLock}
; 	}
; return
	
;$CapsLock::
;If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 400)
;	Send, {CapsLock}
;; KeyWait, CapsLock
;return


; Turn Monitor Off
+Esc::
OffMonitor:
Sleep 1500  ; Give user a chance to release keys (in case their release would wake up the monitor again).
SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
; lparam : -1 (the display is powering on), 1 (the display is going to low power), 2 (the display is being shut off)
return


; Lock PC then turn off monitor
^#l::
Send, #l
gosub, OffMonitor
return


; googling selected text
#g::
	ClipTemp = %Clipboard%
	Clipboard := ""		; clear
	Send, ^c
	ClipWait, 0
	selection = %Clipboard% ; save the content of the clipboard
	Clipboard = %ClipTemp%
	if selection <> 
		Run, http://www.google.com.my/search?q=%selection%
	else
		Run, http://www.google.com.my
return


; open selected text(web link) in new tab
#ifWinActive, ahk_group Editor2
#Tab::
;MouseGetPos, , , t_WinID
;WinGetClass, t_WinClass, ahk_id %t_WinID%
;if ( (t_WinClass != "IEFrame") and ( t_WinClass != "MozillaUIWindowClass") )
;	return
	ClipTemp = %Clipboard%
	Clipboard := ""		; clear
		Send, ^c
		ClipWait, 0
		Send, ^t
		Sleep 200
		Send, ^v
		Send, {enter}
		Sleep 500
	Clipboard = %ClipTemp%
return
#ifWinActive

; capture full screen to desktop_PrtSc.jpg
#PrintScreen::
CaptureScreen(0, True, A_Desktop . "\desktop_PrtSc.jpg", 100)
return

; capture active window to desktop_PrtSc.jpg
^PrintScreen::
CaptureScreen(1, True, A_Desktop . "\desktop_PrtSc.jpg", 100)
return

; screen capture
^#p::
Send !{PrintScreen}
Run, mspaint.exe
WinWaitActive, untitled - Paint
    Send ^v
return


; powerful screen capture funtion
;    Ctrl + Shift + mouse drag capture to clipboard
;    Ctrl + Alt + mouse drag capture to desktop\screen.bmp(drag top to bottom) / desktop\screen.jpg(drag bottom to top)
^+LButton::
^!LButton::
;#persistent
CoordMode, Mouse, Screen
; CoordMode, Tooltip, Screen
MouseGetPos, scan_x_start, scan_y_start
; ToolTip, ., scan_x_start, scan_y_start
; WinSet, Transparent, 100, ahk_class tooltips_class32

Gui, Destroy ; destroy gesture gui
Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound
WinSet, Transparent, 80
Gui, Color, Fuchsia

GetKeyState, PrtSc_AltState, Alt, P
While, (GetKeyState("LButton", "p"))
{
  MouseGetPos, scan_x, scan_y
  Send {control up}
	if ( scan_x > scan_x_start )
	{
		scan_w := scan_x - scan_x_start
		box_x := scan_x_start
	}
	else
	{
		scan_w := scan_x_start  - scan_x
		box_x := scan_x
	}
	if ( scan_y > scan_y_start )
	{
		scan_h := scan_y - scan_y_start
		box_y := scan_y_start
	}
	else
	{
		scan_h := scan_y_start  - scan_y
		box_y := scan_y
	}
  Gui, Show, x%box_x% y%box_y% w%scan_w% h%scan_h%
	; WinMove, ahk_class tooltips_class32, , %box_x%, %box_y%, %scan_w%, %scan_h%
  ; GetKeyState, state, LButton, P
	; if state=u
	; {
	; 	tooltip
	; 	break
	; }
  Sleep, 50
}
; #############################

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
MouseGetPos, scan_x_end, scan_y_end
Gui, Destroy

if ( scan_x_start > scan_x_end )
{
	temp 		 := scan_x_start
	scan_x_start := scan_x_end
	scan_x_end	 := temp
}
if ( scan_y_start > scan_y_end )
{
	temp 		 := scan_y_start
	scan_y_start := scan_y_end
	scan_y_end	 := temp
	savetofile := A_Desktop . "\screen.jpg"
	tipmsg := "save to screen.jpg ..."
}
else
{
	savetofile := A_Desktop . "\screen.bmp"
	tipmsg := "save to screen.bmp ..."
}

if ( PrtSc_AltState != "D" )
{
	savetofile := 0
	tipmsg := "print Screen done ..."
}	

square_box = %scan_x_start%, %scan_y_start%, %scan_x_end%, %scan_y_end%
Sleep, 100 ; if omitted, GUI sometimes stays in picture
CaptureScreen(square_box, False, savetofile, 100)

TrayTip, , %tipmsg%, , 1
sleep, 500
TrayTip
gosub, gesture_setup ; restore gui for gesture
return 




; capture2text OCR
;    Win + alt then mouse drag capture to clipboard
#!LButton::
CoordMode, Mouse, Screen
; CoordMode, Tooltip, Screen
MouseGetPos, scan_x_start, scan_y_start
; ToolTip, ., scan_x_start, scan_y_start
; WinSet, Transparent, 100, ahk_class tooltips_class32

Gui, Destroy ; destroy gesture gui
Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound
WinSet, Transparent, 80
Gui, Color, Green

GetKeyState, PrtSc_AltState, Alt, P
While, (GetKeyState("LButton", "p"))
{
  MouseGetPos, scan_x, scan_y
  Send {control up}
	if ( scan_x > scan_x_start )
	{
		scan_w := scan_x - scan_x_start
		box_x := scan_x_start
	}
	else
	{
		scan_w := scan_x_start  - scan_x
		box_x := scan_x
	}
	if ( scan_y > scan_y_start )
	{
		scan_h := scan_y - scan_y_start
		box_y := scan_y_start
	}
	else
	{
		scan_h := scan_y_start  - scan_y
		box_y := scan_y
	}
  Gui, Show, x%box_x% y%box_y% w%scan_w% h%scan_h%
	; WinMove, ahk_class tooltips_class32, , %box_x%, %box_y%, %scan_w%, %scan_h%
  ; GetKeyState, state, LButton, P
	; if state=u
	; {
	; 	tooltip
	; 	break
	; }
  Sleep, 50
}
; #############################

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
MouseGetPos, scan_x_end, scan_y_end
Gui, Destroy

if ( scan_x_start > scan_x_end )
{
	temp 		 := scan_x_start
	scan_x_start := scan_x_end
	scan_x_end	 := temp
}

if ( PrtSc_AltState != "D" )
{
	savetofile := 0
	tipmsg := "Capture2Text done ..."
}	

square_box = %scan_x_start%, %scan_y_start%, %scan_x_end%, %scan_y_end%
Sleep, 100 ; if omitted, GUI sometimes stays in picture


; CaptureScreen(square_box, False, savetofile, 100)
RunWait, %A_ScriptDir%\..\Capture2Text\Capture2Text.exe -s "%scan_x_start% %scan_y_start% %scan_x_end% %scan_y_end%" --clipboard

TrayTip, , %tipmsg%, , 1
sleep, 500
TrayTip
gosub, gesture_setup ; restore gui for gesture
return 



; move window between left and right monitor, active window will be used

#right::
WinGet, mm, MinMax, A
Gosub, MoveToNextMonitor
if(mm = 0)
    WinRestore, A
return

#left::
WinGet, mm, MinMax, A
Gosub, MoveToNextMonitorLeft
if(mm = 0)
    WinRestore, A
return

; minize / maximize window, active window will be used

; maximize / restore toggle
#up::
MouseGetPos,,, cur_WinID
WinGetClass, cur_WinClass, ahk_id %cur_WinID%
if ( (cur_WinClass = "Progman") or (cur_WinClass = "WorkerW") )
	return
WinGet, mm, MinMax, A
if (mm = 1)
{
	WinRestore, A
	return
}
WinMaximize, A
SYS_ToolTipText = Window Maximize
Gosub, SYS_ToolTipFeedbackShow
return

#down::
MouseGetPos,,, cur_WinID
WinGetClass, cur_WinClass, ahk_id %cur_WinID%
if ( (cur_WinClass = "Progman") or (cur_WinClass = "WorkerW") )
	return
WinMinimize, A
SYS_ToolTipText = Window Minimize
Gosub, SYS_ToolTipFeedbackShow
return

; place window at right/left/top/down side within monitor, active window will be used

;placewindow
#Space::
span2monitor:
	GoSub, mmove_check	
	; WinGetPos, x, y, w, h, A
	; ; Determine which monitor contains the center of the window.
	; ms := GetMonitorAt(x+w/2, y+h/2)
	; WinRestore, A
	; SysGet, ma, MonitorWorkArea, %ms%	; monitor work areas (excludes taskbar-reserved space.)

	if (ms==2)
		WinMove, A,, m_offset, maTop, (maRight-maLeft)*2, (maBottom-maTop)
	else
		WinMove, A,, maLeft-(maRight-maLeft), maTop, (maRight-maLeft)*2, (maBottom-maTop)
Return

#!right::
	GoSub, mmove_check

	if(mmode = 0){
		WinMove, A,, (maRight-maLeft)/2+m_offset, maTop, (maRight-maLeft)/2, (maBottom-maTop)
	}else if(mmode = 1){
		WinMove, A,, maLeft, maTop, (maRight-maLeft)/2, (maBottom-maTop)
	}else if(mmode = 2){
		WinMove, A,, maLeft, maTop, (maRight-maLeft), (maBottom-maTop)
	}else if(mmode = 3){
		WinMove, A,, m_offset, maTop, (maRight-maLeft)*2, (maBottom-maTop)
	}

	;WinMove, A,, A_ScreenWidth/2, 0, A_ScreenWidth/2, A_ScreenHeight-10
return

#!left::
	GoSub, mmove_check

	if(mmode = 0){
		WinMove, A,, maLeft, maTop, (maRight-maLeft)/2, (maBottom-maTop)
	}else if(mmode = 1){
		WinMove, A,, (maRight-maLeft)/2+m_offset, maTop, (maRight-maLeft)/2, (maBottom-maTop)
	}else if(mmode = 2){
		WinMove, A,, maLeft, maTop, (maRight-maLeft), (maBottom-maTop)
	}else if(mmode = 3){
		WinMove, A,, maLeft-(maRight-maLeft), maTop, (maRight-maLeft)*2, (maBottom-maTop)
	}

	;WinMove, A,, 0, 0, A_ScreenWidth/2, A_ScreenHeight-10
return

#!up::
	GoSub, mmove_check

	if(mmode = 0){
		WinMove, A,, maLeft, maTop, (maRight-maLeft), (maBottom-maTop)/2
	}else if(mmode = 1){
		WinMove, A,, maLeft, maTop, (maRight-maLeft)/2, (maBottom-maTop)/2
	}else if(mmode = 2){
		WinMove, A,, (maRight-maLeft)/2+m_offset, maTop, (maRight-maLeft)/2, (maBottom-maTop)/2
	}
	;WinMove, A,, 0, 0, A_ScreenWidth, A_ScreenHeight/2-10
return

#!down::
	GoSub, mmove_check

	if(mmode = 0){
		WinMove, A,, maLeft, (maBottom+maTop)/2, (maRight-maLeft), (maBottom-maTop)/2
	}else if(mmode = 1){
		WinMove, A,, maLeft, (maBottom+maTop)/2, (maRight-maLeft)/2, (maBottom-maTop)/2
	}else if(mmode = 2){
		WinMove, A,, (maRight-maLeft)/2+m_offset, (maBottom+maTop)/2, (maRight-maLeft)/2, (maBottom-maTop)/2
	}
	;WinMove, A,, 0, A_ScreenHeight/2-10, A_ScreenWidth,  A_ScreenHeight/2-20
return

mmove_check:
	If ((A_PriorHotKey = A_ThisHotKey) and ((mc == 2 and mmode < 2) or (mc == 3 and mmode < 3)))
		mmode++
	else
		mmode=0
	WinGetPos, x, y, w, h, A
	; Determine which monitor contains the center of the window.
	ms := GetMonitorAt(x+w/2, y+h/2)

	WinRestore, A
	SysGet, ma, MonitorWorkArea, %ms%	; monitor work areas (excludes taskbar-reserved space.)

	if(ms=2){
		if(maLeft>0){		; 2nd monitor at Right side
			m_offset = %A_ScreenWidth%
		}else{				; 2nd monitor at Left side
			m_offset = %maLeft%
		}
	}else{
		m_offset = 0
}
return

; Get the index of the monitor containing the specified x and y co-ordinates.
GetMonitorAt(x, y, default = 1)
{
	global mc		; made global
	SysGet, mc, MonitorCount

	; Iterate through all monitors.
	Loop, %mc%
	{   ; Check if the window is on this monitor.
		SysGet, Mon, Monitor, %A_Index%
		if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
			return A_Index
	}
	return default
}


MoveToNextMonitor:
	WinGetPos, x, y, w, h, A
    ; Determine which monitor contains the center of the window.
    ms := GetMonitorAt(x+w/2, y+h/2)
	
	; This may happen if someone tries it with only one screen
	if (mc = 1)
		return
	
	if (mc==2) {
		; Determine which monitor to move to.
		if ( ms = 1 )
			md := 2
		else
			md := 1
	}else if (mc == 3){
		; Determine which monitor to move to.
		if ( ms = 1 )
			md := 2
		else if ( ms ==2 )
			md := 3
		else
			md := 1
	}
		
	; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    SysGet, md, MonitorWorkArea, %md%
    msw := msRight - msLeft, msh := msBottom - msTop
    mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
	
	w *= (mdw/msw)
    h *= (mdh/msh)
	
	SetWinDelay, -1
	; Move window, using resolution difference to scale co-ordinates.
	WinRestore, A
    ; WinMaximize, A 
	WinMove, A,, mdLeft + (x-msLeft)*(mdw/msw), mdTop + (y-msTop)*(mdh/msh), w, h
	WinMaximize, A
return

MoveToNextMonitorLeft:
	WinGetPos, x, y, w, h, A
    ; Determine which monitor contains the center of the window.
    ms := GetMonitorAt(x+w/2, y+h/2)
	
	; This may happen if someone tries it with only one screen
	if (mc = 1)
		return
	
	if (mc==2) {
		; Determine which monitor to move to.
		if ( ms = 1 )
			md := 2
		else
			md := 1
	}else if (mc == 3){
		; Determine which monitor to move to.
		if ( ms = 1 )
			md := 3
		else if ( ms == 3 )
			md := 2
		else
			md := 1
	}
		
	; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    SysGet, md, MonitorWorkArea, %md%
    msw := msRight - msLeft, msh := msBottom - msTop
    mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
	
	w *= (mdw/msw)
    h *= (mdh/msh)
	
	SetWinDelay, -1
	; Move window, using resolution difference to scale co-ordinates.
	WinRestore, A
    ; WinMaximize, A 
	WinMove, A,, mdLeft + (x-msLeft)*(mdw/msw), mdTop + (y-msTop)*(mdh/msh), w, h
	WinMaximize, A
return

; #############################################################################################
