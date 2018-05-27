/*
  Lex' Mouse Gestures
  by Lexikos (Steve Gray)
*/

/*
 * Configuration Defaults:
 *      Override these in Gestures_User.ahk (in the "Gestures:" sub).
 */
 
/*
; clim75 changes
; activate window under mouse cursor so that drawing gesture take effect on mouse underneath window
; 20110812 - make gesture working for blacklist_apps if click and draw gesture start from caption
*/

 
Gestures_Init:
m_FirstDraw = 0
m_GestureKey = MButton  ; Gesture key.
m_GestureKey2 =         ; Alternate gesture key.
m_Interval = 20         ; How long to sleep between each iteration of the gesture-recognition loop.
m_LowThreshold = 25     ; Minimum distance to register as a gesture "stroke."
m_HighThreshold = 0     ; Maximum total gesture length. Exceeding this cancels the gesture.
m_Timeout = 500         ; Maximum time in milliseconds between the last mouse movement
                        ; and release of the gesture key/button.
m_InitialTimeout = 250  ; Maximum time in milliseconds that the mouse can remain in its initial
                        ; position before gesture-recognition is cancelled.
                        ; This makes it easier to click and drag with the gesture button.
m_ActiveTimeout = 0     ; Maximum time in milliseconds that the mouse can remain in any one
                        ; position before gesture-recognition is cancelled. 0 means forever.
m_ActiveTimeoutMode = 0 ; 0: cancel. 1: cancel & perform default action. 2: complete gesture.
m_DefaultOnTimeout = 0  ; If true, default action is performed whenever m_Timeout is applied.
m_Tolerance = 100       ; Maximum percent of deviance from "zone center" that will be tolerated.
                        ; If there are 4 zones, 100 percent = 45 degrees.
m_ZoneCount = 4         ; The number of zones.
m_InitialZoneCount = 8  ; If set, defines the number of zones allowed for the *first* stroke.
m_DisableDing = 1
m_GesturePrefix = Gesture   ; Default prefix for gesture variables/labels.
m_KeylessPrefix =           ; Prefix for keyless gestures, or blank to disable.
m_Delimiter = _

m_EnabledIcon = %A_ScriptDir%\gestures.ico
m_DisabledIcon = %A_ScriptDir%\nogestures.ico
; m_EnabledSound = %A_ScriptDir%\wurt_enabled.wav
; m_DisabledSound = %A_ScriptDir%\wurt_disabled.wav

m_PenWidth = 5            ; Width of the pen to draw trails with.
m_NodePenWidth = 3        ; Radius of "nodes" on the trails, indicating where each stroke begins.
m_PenColor = 00FF00       ; Colour of trails and nodes.

m_TrayIndicator = 1		; Set to 1 to enable, or blank to disable

; Read gesture definitions from Gestures.ini
G_LoadGestures( A_ScriptDir . "\Gestures.ini" )


/*
 * Basic global init
 */

; set in Main script
;#NoEnv
;#SingleInstance Force       ; Never allow more than one instance of this script.
CoordMode, Mouse, Screen    ; Let mouse commands use absolute/screen co-ordinates.
;SendMode Input              ; Set recommended send-mode.
;SetTitleMatchMode, 2        ; Match anywhere in window title.
;SetWorkingDir %A_ScriptDir% ; Set working directory to script's directory for consistency.
;SetBatchLines, -1           ; May improve responsiveness. Shouldn't negatively affect other
                            ; apps as the script sleeps every %m_Interval% ms while active.
/*
 * Set text labels to be used in other areas
 */

; Zone labels used when four zones are active:
c_Zone4_0 = R
c_Zone4_1 = D
c_Zone4_2 = L
c_Zone4_3 = U

; Zone labels used when eight zones are active:
c_Zone8_0 = R
c_Zone8_1 = DR
c_Zone8_2 = D
c_Zone8_3 = DL
c_Zone8_4 = L
c_Zone8_5 = UL
c_Zone8_6 = U
c_Zone8_7 = UR


/*
 * Load configuration
 */

; Run "auto-execute" sections of Gestures_Default.ahk and Gestures_User.ahk, in that order.
; Explicit labels are required in case the file contains only gesture definitions or hotkeys.

if IsLabel(ErrorLevel:="DefaultGestures")
    gosub %ErrorLevel%

if IsLabel(ErrorLevel:="Gestures")
    gosub %ErrorLevel%

	
/*
 * Initialize script - don't mess with this unless you know what you're doing
 */

; G_SetTrayIcon(true)         ; Set custom tray icon (also called by ToggleGestureSuspend).

; Hook "Suspend Hotkeys" messages to update the tray icon.
; Note: This has the odd side-effect of "disabling" the tray menu
;       if the script is paused from the tray menu.
OnMessage(0x111, "WM_COMMAND")

; no need gestures menu, using NiftyWindows menu
; GoSub, TrayMenu_Setup  ; gestures tray menu

; move to general.ahk
; Create a group for easy identification of Windows Explorer windows.
;GroupAdd, Explorer, ahk_class CabinetWClass
;GroupAdd, Explorer, ahk_class ExploreWClass

; Some code relies on m_InitialZoneCount being set.
if m_InitialZoneCount < 2
    m_InitialZoneCount := m_ZoneCount

; The following are relied on by the script and should not be changed:
c_PI := 3.141592653589793, c_Degrees := 180/c_PI

m_WaitForRelease := false   ; Are we waiting for the gesture key to be released? Not yet.
m_PassKeyUp := false        ; Should GestureKey_Up pass key-release to the active window? Not yet.
m_ClosingWindow := 0        ; We aren't about to close any window.

gosub, gesture_setup

; Register hotkeys.
Hotkey, *%m_GestureKey%, GestureKey_Down
; Hotkey, #%m_GestureKey%, ToggleGestureSuspend		; not needed
if m_GestureKey2 {
    Hotkey, %m_GestureKey2%, GestureKey_Down
    ; Hotkey, #%m_GestureKey2%, ToggleGestureSuspend		; not needed
}

; SoundPlay, %m_EnabledSound%

if m_KeylessPrefix {
    if !m_ActiveTimeout
        if m_Timeout
            m_ActiveTimeout := m_Timeout
        else
            m_ActiveTimeout := 1000
    SetTimer, GestureKeyless, %m_Interval%  ; Won't run while in the gesture recognition loop.
}

; declare globally in general.ahk
; m_DrawingMode := false

/*
 * END OF INIT SECTION
 */

return


/*
 * Scripted gestures
 */
 
; #Include %A_ScriptDir%              ; Set working directory for #Include.
#Include %A_ScriptDir%\Gestures_Default.ahk    ; Default gestures.
; #Include *i Gestures_User.ahk       ; User-defined gestures, etc.

gesture_setup:
  ; Set up the canvas for mouse-trails, if configured.
  if ( m_PenWidth and SYS_GestureEnable )
  {
      ; Set default trail colour or convert RRGGBB to 0xBBGGRR.
      if m_PenColor =
          m_PenColor := 0
      else
          m_PenColor := "0x" . SubStr(m_PenColor,5,2) . SubStr(m_PenColor,3,2) . SubStr(m_PenColor,1,2)
      m_PenColor &= 0xffffff
      ; Use any other colour as the trail-Gui background.
      m_TransColor := m_PenColor ? "000000" : "FFFFFF"

      ; Create the Gui if not already created, and set it as the Last Found Window.
      Gui, +LastFound
      ; Make the Gui background transparent.
      Gui, Color, %m_TransColor%
      WinSet, TransColor, %m_TransColor%
      ; Remove the caption and borders, and hide the Gui from the taskbar.
      Gui, -Caption +ToolWindow +AlwaysOnTop
      ; Get the HWND and HDC of the Last Found Window (the Gui).
      hw_canvas := WinExist()
      hdc_canvas := DllCall("GetDC", "uint", hw_canvas)
      if pen =
      {
        ; Create the pen, if not already created.
         pen := DllCall("CreatePen", "int", 0, "int", m_PenWidth, "uint", m_PenColor)
      }
      ; Select the pen and store a handle to the previously selected pen (common GDI practice).
      old_pen := DllCall("SelectObject", "uint", hdc_canvas, "uint", pen)
      
      if brush =
      {      
        ; Create a brush for erasing the Gui background.
        brush := DllCall("CreateSolidBrush", "uint", "0x" m_TransColor)
        brush2 := DllCall("CreateSolidBrush", "uint", m_PenColor)
      }
      old_brush := DllCall("SelectObject", "uint", hdc_canvas, "uint", brush2)
      
  }
return



/*
 * Tray menu subroutines
 */
 
/*
TrayMenu_Setup:
	; Set tooltip for tray icon.
Menu, Tray, Tip, Mouse Gestures
	; Setup custom tray menu.
Menu, Tray, NoStandard
Menu, Tray, Add, &Open      , TrayMenu_Open
Menu, Tray, Add, &Help      , TrayMenu_Help
Menu, Tray, Add
Menu, Tray, Add, &Reload    , TrayMenu_Reload
Menu, Tray, Add, &Suspend   , TrayMenu_Suspend
Menu, Tray, Add
Menu, Tray, Add, Edit &Gestures.ahk         , TrayMenu_Edit
Menu, Tray, Add, Edit Gestures_&Default.ahk , TrayMenu_Edit
Menu, Tray, Add, Edit Gestures_&User.ahk    , TrayMenu_Edit
Menu, Tray, Add
Menu, Tray, Add, E&xit      , TrayMenu_Exit
Menu, Tray, Default, &Open
return
 

TrayMenu_Open:
    DetectHiddenWindows, On
    Process, Exist
    PostMessage, 0x111, 65300,,, ahk_class AutoHotkey ahk_pid %ErrorLevel%
return
TrayMenu_Help:
    MsgBox, Sorry, feature not implemented!
return
TrayMenu_Reload:
    Reload
return
TrayMenu_Suspend:
    gosub ToggleGestureSuspend
return

TrayMenu_Exit:
ExitApp
*/

TrayMenu_Edit:
    G_EditFile(A_ScriptDir "\" RegExReplace(A_ThisMenuItem,"^Edit |&"))
return

/*
 * Gesture recognition and hotkeys
 */

 /*
ToggleGestureSuspend:
    Suspend, Toggle
    G_SetTrayIcon(!A_IsSuspended)
    if A_IsSuspended {
        Menu, Tray, Check, &Suspend
        ; SoundPlay, %m_DisabledSound%
    } else {
        Menu, Tray, Uncheck, &Suspend
        ; SoundPlay, %m_EnabledSound%
    }
return
*/


^+space::
DrawingModeToggle:

if( m_DrawingMode ) {
	m_DrawingMode := false
	G_ExitGesture()
	SYS_ToolTipText = DrawingMode_Off
	Gosub, SYS_ToolTipFeedbackShow
}else{
	m_DrawingMode := true
	SYS_ToolTipText = DrawingMode_On
	Gosub, SYS_ToolTipFeedbackShow
}
return	

CancelGesture:
    Hotkey, *Escape, CancelGesture, Off
    m_ExitLoop := true
return

GestureKey_Up:
    Hotkey, %A_ThisHotkey%, Off
    MouseGetPos, m_EndX, m_EndY
	
    G_ExitGesture()
    if m_PassKeyUp
    {
        Send {Blind}{%m_LastGestureKey% Up}
        m_PassKeyUp := false
    }
return

GestureKey_Down:
	; activate window under mouse cursor
	CoordMode, Mouse, Relative	; set to relative
		MouseGetPos, , CGW_MouseY, Ges_WinID
	CoordMode, Mouse	; default to screen
	
	If ( !Ges_WinID )
		Return
	WinActivate, ahk_id %Ges_WinID%
	ROL_WinID = %Ges_WinID%		; for sub ROL_RollToggle usage
	
	SysGet, CGW_CaptionHeight, 4 ; SM_CYCAPTION
	SysGet, CGW_BorderHeight, 7 ; SM_CXDLGFRAME
	NGD_NotCaption := (CGW_MouseY > CGW_CaptionHeight + CGW_BorderHeight)
	
	; IfWinActive, ahk_group BlackListGesture
	if ( (WinActive("ahk_group BlackListGesture") and !m_DrawingMode) or !SYS_GestureEnable )
	{
		if m_LastGestureKey in LButton,MButton,RButton
		{
			if (NGD_NotCaption)
			{
				gosub nifty_%m_LastGestureKey%	; let main nifty script to handle it
				return
			}
		}
	}
	
    if m_WaitForRelease && m_LastGestureKey ; Key pressed while loop was running for the other key.
        return
    Thread, NoTimers  ; Disable keyless timer for the duration of this subroutine.
    
    m_LastGestureKey := A_ThisHotkey
    StringReplace, m_LastGestureKey, m_LastGestureKey, *
    Hotkey, *%m_LastGestureKey% Up, GestureKey_Up, On
    Hotkey, *Escape, CancelGesture, On
    if (%m_GesturePrefix%_WheelUp!="" || IsLabel(m_GesturePrefix "_WheelUp"))
        Hotkey, *WheelUp, GestureWheelUp, On
    if (%m_GesturePrefix%_WheelDown!="" || IsLabel(m_GesturePrefix "_WheelDown"))
        Hotkey, *WheelDown, GestureWheelDown, On

GestureKeyless:
    ; If the keyless timer started this thread, the gesture loop mustn't be active since
    ; a) the keyed entry-point above disables timers and b) no timer can execute its
    ; subroutine again until the previous instance returns.  We don't want to register
    ; any hotkeys since they wouldn't work intuitively with the keyless method.
    
    ; Increase interval between message checks so that any interruption will happen during
    ; 'Sleep' rather than at any random point.  Interruption happens if a keyless loop
    ; is running when the user presses a gesture key; when it happens, we want to recognize
    ; the "explicit" gesture and exit the keyless loop's thread as soon as it resumes.
    ; This must be done because of the use of global variables in the gesture loop.
    if A_ThisLabel=GestureKeyless
    {
        Critical % 100+m_Interval  ; Add m_Interval in case it is reasonably high/long.
        m_LastGestureKey := ""
    }
    
    m_WaitForRelease := true    ; Legacy naming: true while running the loop (even if its not really waiting for key-up).
    m_ExitLoop := false         ; Only overridden by scrolling/pressing Escape.
    m_ScrolledWheel := false    ;
    beginTimeout := A_TickCount
    startX := -1
    startY := -1
    totalDistance := 0
    lastZone := -1

    m_Gesture := ""
    m_GestureLength := 0

    ; get starting mouse position
    MouseGetPos, lastX, lastY

    ; record for later use
    m_EndX := m_StartX := lastX
    m_EndY := m_StartY := lastY
    
    if hdc_canvas && m_LastGestureKey
    {
        if !m_FirstDraw
        {
            SysGet, XVirtualScreen, 76
            SysGet, YVirtualScreen, 77
            SysGet, CXVirtualScreen, 78
            SysGet, CYVirtualScreen, 79
            ; Set origin to top-left of primary screen (since mouse co-ords are relative to this).
            DllCall("SetViewportOrgEx", "uint", hdc_canvas, "int", -XVirtualScreen, "int", -YVirtualScreen, "uint", 0)
            ; Show the trail canvas over the entire virtual screen (all monitors).
            Gui, Show, X-30000 Y-30000 W%CXVirtualScreen% H%CYVirtualScreen% NA
            ; Showing the Gui initially off-screen may help reduce "screen flash".
            Gui, Show, X%XVirtualScreen% Y%YVirtualScreen% NA
            m_FirstDraw=1
        }
        ; Set the initial position, where the first line will begin.
        DllCall("MoveToEx", "uint", hdc_canvas, "int", m_StartX, "int", m_StartY, "uint", 0)
    }
    m_linestart:=0
    Loop
    {
        ; Logic below requires that only keyless mode enables 'Critical'.
        if (A_ThisLabel="GestureKeyless" && m_wasCritical := A_IsCritical)
                Critical Off ; Allow interruption temporarily.
        
        ; wait for mouse to move
        Sleep, m_Interval
        
        GetKeyState, Ges_ShiftState, Shift, P
        while (m_DrawingMode && Ges_ShiftState = "D")
        {
          if (hdc_canvas && m_NodePenWidth && m_linestart=0)
          {
            m_linestart:=1
            DllCall( "Ellipse", "uint", hdc_canvas
                        , "int", m_StartX-m_NodePenWidth
                        , "int", m_StartY-m_NodePenWidth
                        , "int", m_StartX+m_NodePenWidth
                        , "int", m_StartY+m_NodePenWidth )
          }
          GetKeyState, Ges_ShiftState, Shift, P
          Sleep, m_Interval
        }
        
        if (A_ThisLabel="GestureKeyless" && m_wasCritical)
        {   ; If a gesture key was pressed, the globals this instance was using
            ; have probably been overwritten, so just break out of the loop.
            if m_LastGestureKey
                return
            Critical %m_wasCritical%
        }

        if m_ExitLoop
        {
            if m_ScrolledWheel
                KeyWait, %m_LastGestureKey%
            G_ExitGesture()
            return
        }

        if !m_WaitForRelease
        { ; use location mouse was released at
            x := m_EndX
            y := m_EndY
        }
        else ; get current mouse position
            MouseGetPos, x, y

        offsetX := x - lastX
        offsetY := y - lastY

        ; Check if mouse has moved.
        if (offsetX!=0 || offsetY!=0)
        {
            if hdc_canvas
            {
                if (m_linestart=1)
                {
                    m_linestart:=0
                    DllCall( "Ellipse", "uint", hdc_canvas
                                , "int", x-m_NodePenWidth
                                , "int", y-m_NodePenWidth
                                , "int", x+m_NodePenWidth
                                , "int", y+m_NodePenWidth )
                }
                ; Draw a line to the current mouse position, from the starting position or end of the previous line.
                DllCall("LineTo", "uint", hdc_canvas, "int", x, "int", y)
            }
            ; Calculate distance and angle from origin.
            ; Note origin changes only when a new stroke is detected, so distance will continue
            ; to increase while the mouse contiues to move in the same approximate direction.
            distance := Sqrt(offsetX*offsetX + offsetY*offsetY)

            if (distance > m_LowThreshold)
            {
                angle := G_GetAngle(offsetX, offsetY)

                lastX := x
                lastY := y
                
                ; Allow the initial stroke to be more or less specific than subsequent strokes,
                ; ensuring the initial stroke can be extended according to m_InitialZoneCount.
                if ( m_GestureLength = 0
                  || m_GestureLength = 1 && G_GetZone(angle, m_InitialZoneCount, m_Tolerance) = lastZone )
                     zoneCount := m_InitialZoneCount
                else zoneCount := m_ZoneCount
                
                zone := G_GetZone(angle, zoneCount, m_Tolerance)

                if zone =
                {
                    ; Error, or gesture stroke exceeded zone tolerance (m_Tolerance).
                    GoSub, GestureError		; tray icon indicator
					if !m_DisableDing
                        SoundPlay, *-1
                    G_ExitGesture()
                    return
                }
                
                if (lastZone != zone)
                {
                    if (hdc_canvas && m_NodePenWidth && !m_DrawingMode && lastZone != zone && lastZone != -1)
                        DllCall( "Ellipse", "uint", hdc_canvas
                                    , "int", lastZoneEndX-m_NodePenWidth
                                    , "int", lastZoneEndY-m_NodePenWidth
                                    , "int", lastZoneEndX+m_NodePenWidth
                                    , "int", lastZoneEndY+m_NodePenWidth )

                    ; Record length of this stroke.
                    totalDistance := distance

                    ; Remember zone index for subsequent iterations.
                    lastZone := zone
                    
                    ; Record this stroke.
                    m_Gesture .= m_Delimiter . zone
                    m_GestureLength += 1
                }
                else
                {
                    ; Extend length of this stroke.
                    totalDistance += distance
                }
                ; Reset timeout.
                beginTimeout := A_TickCount
                
                lastZoneEndX := x
                lastZoneEndY := y

                if (m_HighThreshold > 0 && totalDistance > m_HighThreshold)
                {
					; Gesture stroke exceeded maximum stroke length (m_HighThreshold).
					GoSub, GestureError		; tray icon indicator
                    if !m_DisableDing
                        SoundPlay, *-1
                    G_ExitGesture()
                    Sleep, 150
                    if !m_DisableDing
                        SoundPlay, *-1
                    return
                }
            }
        }

        timeout := m_Gesture="" ? m_InitialTimeout : m_ActiveTimeout
        
        if (timeout && A_TickCount-beginTimeout > timeout)
        {
            ; Timed out.
            if (m_Gesture!="" && (m_ActiveTimeoutMode=2 || !m_LastGestureKey))
            {
                ; Complete gesture. Circumvent m_Timeout.
                beginTimeout := A_TickCount
                m_WaitForRelease := false
                break
            }

			GoSub, GestureError		; tray icon indicator
            if !m_DisableDing && m_LastGestureKey
                SoundPlay, *-1		; *64
            ; G_ExitGesture attempts default function of gesture key if the first parameter is true.
            G_ExitGesture(m_Gesture="" || m_ActiveTimeoutMode=1)
            return
        }

        ; End loop when gesture key is released.
        if !m_WaitForRelease
            break
    }

    ; Cancel gesture if the mouse was immobile for too long after the last stroke.
    if (m_Timeout && A_TickCount-beginTimeout > m_Timeout)
    {
        ; Gesture timed out.
		GoSub, GestureError		; tray icon indicator
        if !m_DisableDing && m_LastGestureKey
            SoundPlay, *-1		; *64
        G_ExitGesture(m_DefaultOnTimeout && m_LastGestureKey)
        return
    }

    if m_Gesture !=
    {
        if !G_PerformAction(m_Gesture) && !m_DisableDing && m_LastGestureKey
            SoundPlay, *48
    }
    else
	{
		GoSub, GestureError		; tray icon indicator
        G_ExitGesture(true)
	}
    
return

GestureWheelUp:
GestureWheelDown:
    m_ScrolledWheel := true
    m_ExitLoop := true
    G_PerformAction(m_Delimiter . SubStr(A_ThisLabel,8))
return

G_PerformAction(action_name)
{		
    local action, params, final_name
        , list := m_LastGestureKey ? m_GesturePrefix ",Default" : m_KeylessPrefix
		
	if ( m_DrawingMode ) {
		return true
	}
		
    Loop, Parse, list, `,
    {
        final_name = %A_LoopField%%action_name%
		
		subname := % %final_name%	; clim75 added - to be able to run subname in Gestures.ini

    if IsLabel(final_name)
        gosub %final_name%
		else if IsLabel(subname)  ; clim75 added
        gosub %subname%			  ; clim75 added
    else if RegExMatch(subname,"^run_(.*)",matchrun)
        Run, %matchrun1%
    else if subname !=
        Send %subname%
    else
        continue
        
		GoSub, GestureGood		; tray icon indicator
        return true
    }
	GoSub, GestureError		; tray icon indicator
    return false
}

G_ExitGesture(sendkey=false)
{
    local btn
    
    Hotkey, *Escape, CancelGesture, Off
    Hotkey, *WheelUp, GestureWheelUp, Off
    Hotkey, *WheelDown, GestureWheelDown, Off
    
    
    if (hdc_canvas && !m_DrawingMode )  ; Hide the mouse-trail canvas.
    {
        m_FirstDraw=0           ; 1.21
        ; Clear the canvas before hiding it. Otherwise, the next time the window is shown,
        ; the previous gesture can be shown for a brief moment before the window updates.
        VarSetCapacity(rect, 16, 0)
        , NumPut(CYVirtualScreen + YVirtualScreen, NumPut(CXVirtualScreen + XVirtualScreen
            , NumPut(YVirtualScreen, NumPut(XVirtualScreen, rect, 0))))
        , DllCall("FillRect", "uint", hdc_canvas, "int", &rect, "uint", brush)
        Gui, Hide
    }

    if !(sendkey && m_LastGestureKey && !m_DrawingMode)
    {
        m_WaitForRelease := false
        return
    }
        
    if m_LastGestureKey in LButton,MButton,RButton
    {
		if IsLabel "nifty_" . %m_LastGestureKey%
			gosub nifty_%m_LastGestureKey%
		else
		{
			; Try to leave mouse button functionality intact.
			StringLeft, btn, m_LastGestureKey, 1
			if m_WaitForRelease
				MouseGetPos, m_EndX, m_EndY
			; Move to point where gesture started, then press and hold button.
			MouseClick, %btn%, m_StartX, m_StartY,, 1, D
			; Move back into place. Release if button has been physically released.
			if m_WaitForRelease
				MouseMove, m_EndX, m_EndY
			else
				MouseClick, %btn%, m_EndX, m_EndY,,, U
		}
    }
    else
    {
        if m_WaitForRelease
            Send {Blind}{%m_LastGestureKey% Down}
        else
            Send {Blind}{%m_LastGestureKey%}
    }
    ; Pass through gesture button release to active window if applicable.
    m_PassKeyUp := m_WaitForRelease
    m_WaitForRelease := false

}

; Get angle (in degrees) of {x,y} relative to {0,0} -> {1,0}.
G_GetAngle(x, y)
{
    if (x != 0) {
        deg := ATan(y/x) * 57.295779513082323 ; deg := rad * 180/PI
        if x < 0
            return deg + 180
        else ; x > 0
            if y < 0
                return deg + 360
        ; x > 0 && y >= 0
        return deg
    } else ; x = 0
        if y > 0
            return 90.0
        else if y < 0
            return 270.0 ;-90
        ; else no return value.
}

; Get the zone of an angle
;  angle:       Angle in degrees, between 0.0 and 360.0 inclusive.
;  zoneCount:   Number of zones.
;  tolerance:   Allowed deviance from centre of zone.
;               If positive, specifies percentage of zone (between 1 and 100).
;               If negative, absolute value specifies tolerance in degrees.
G_GetZone(angle, zoneCount, tolerance)
{
    local degPerZone
    local zone

    if zoneCount < 2
        return ; ERROR.

    ; Calculate zone size.
    degPerZone := 360/zoneCount

    ; Calculate nearest zone integer.
    zone := Mod(Round(angle/degPerZone),zoneCount)

    ; Calculate tolerance.
    if tolerance < 0
        tolerance := Abs(tolerance)                 ; -n : must not exceed n degrees.
    else
        tolerance := degPerZone/2 * tolerance/100   ; n : must not exceed n percent.

    if (zone = 0 && angle > 180)
        angle -= 360

    ; Check if within tolerated distance from centre of zone.
    if (Abs(angle-(zone*degPerZone)) > tolerance)
        return

    ; Resolve to text form if available.
    if c_Zone%zoneCount%_%zone% !=
        return c_Zone%zoneCount%_%zone%

    return zone
}


/*
 * Tray icon maintenance
 */

G_SetTrayIcon(is_enabled)
{
    local icon := is_enabled ? m_EnabledIcon : m_DisabledIcon
    if icon !=
    {
        ifExist, %icon%
                Menu, Tray, Icon, %icon%,, 1
        else    Menu, Tray, Icon, *
        Menu, Tray, Icon
    }
    else
        Menu, Tray, NoIcon
    %m_OnUpdateIcon%(icon, is_enabled)
}

WM_COMMAND(wParam, lParam, msg, hwnd)
{
    static IsPaused, IsSuspended
    Critical
    id := wParam & 0xFFFF
    if id in 65305,65404,65306,65403
    {  ; "Suspend Hotkeys" or "Pause Script" - either A_IsPaused or A_IsSuspended is about to be toggled.
        if id in 65306,65403
            IsPaused := ! A_IsPaused
        else
            IsSuspended := ! A_IsSuspended
        G_SetTrayIcon(!(IsPaused or IsSuspended))
    }
}

/*
 * Helper functions
 */

G_EditFile(file)
{
    Run edit %file%,, UseErrorLevel
    if ErrorLevel = ERROR
        Run, notepad "%file%"
}

G_MinimizeActiveWindow()
{
    global
    lastMinTime := A_TickCount
    lastMinID   := WinExist("A")
    ; unlike WinMinimize, using WM_SYSCOMMAND, SC_MINIMIZE
    ; causes the system-wide "Minimize" sound to be played
    PostMessage, 0x112, 0xF020
}

G_GetLastMinimizedWindow()
{
    WinGet, w, List

    Loop %w%
    {
        wi := w%A_Index%
        WinGet, m, MinMax, ahk_id %wi%
        if m = -1 ; minimized
        {
            lastFound := wi
            break
        }
    }

    return "ahk_id " . (lastFound ? lastFound : 0)
}

G_ControlExist(Control, WinTitle="")
{
    ControlGet, temp, HWND, , %Control%, %WinTitle%
    return temp
}



; clim75 - added back ini read from older version
G_LoadGestures( filename )
{
    ; declaring one or more local variables forces newly created variables to be global in scope
    local line, varname
    ; declare a local array (0=array length, 1=first item)
    local lineParts0
    ; these must be explicitly declared local
    ; (as of AHK 1.0.46.10, StringSplit creates them as local variables either way
    ;  because lineParts0 is local, but references to 'lineParts1' in script refer
    ;  to GLOBAL variables...)
    local lineParts1, lineParts2

    Loop, Read, %filename%
    {
        ; ignore comments
        line:=RegExReplace(A_LoopReadLine, ";.*")
		
		; replace " = " with uncommon delimiter
        StringReplace, line, line, %A_Space%=%A_Space%, 
		; split the string into (hopefully) two parts: variable, keys to send
        StringSplit, lineParts, line, , %A_Space%%A_Tab%

		if ( lineParts0 == 0 )
            continue
		
        if ( lineParts0 == 2 )
        {
			if ( StrLen(lineParts1) > 0 )
            {
                ; allow underscores by removing them from comparison
                StringReplace, varname, lineParts1, _, , All
                ; check if variable name is alphanumeric
                if varname is alnum
                {
                    ; convert the key = value string to a variable
                    %lineParts1% := lineParts2
                }
            }
            else
            {
                MsgBox empty variable name on line %A_Index%
            }
        }
    }
}

RestoreIcon:
	SetTimer, RestoreIcon, off
	Menu, Tray, Icon, *
Return


GestureError:
if m_TrayIndicator && m_LastGestureKey
{
	ifExist, %m_DisabledIcon%
	{
	  Menu, TRAY, Icon, %m_DisabledIcon%
	  SetTimer, RestoreIcon, 1000
	}
}
Return

GestureGood:
if m_TrayIndicator
{
	ifExist, %m_EnabledIcon%
	{
	  Menu, TRAY, Icon, %m_EnabledIcon%
	  SetTimer, RestoreIcon, 1000
	}
}
Return

