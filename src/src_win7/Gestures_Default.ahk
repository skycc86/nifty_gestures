
; move to general.ahk
; DefaultGestures:    ; Init section for default gestures.
; return

Default_L:
    SetTitleMatchMode, RegEx
    if WinActive("ahk_group ^Explorer$")
        Send !{Left}
	else if WinActive("ahk_group Browser")
		Send, ^+{Tab}		; ^{PgDn}
	else if WinActive("ahk_class AcrobatSDIWindow")
		Send, {Left}
	else if WinActive("ahk_class OpusApp")
		Send, ^{PgUp}
	else if WinActive("- (Microsoft )?Visual C\+\+")
        Send ^-
    else if WinActive("ahk_class ^#32770$") && G_ControlExist("SHELLDLL_DefView1")
        ; Possibly a File dialog, so try sending "Back" command.
        SendMessage, 0x111, 0xA00B ; WM_COMMAND, ID
	else
        Send {Browser_Back}
    return
	
Default_R:
    SetTitleMatchMode, RegEx
    if WinActive("ahk_group ^Explorer$")
        Send !{Right}
	else if WinActive("ahk_group Browser")
		Send, ^{Tab}		; ^{PgUp}
	else if WinActive("ahk_class AcrobatSDIWindow")
		Send, {Right}
	else if WinActive("ahk_class OpusApp")
		Send, ^{PgDn}
    else if WinActive("- (Microsoft )?Visual C\+\+")
        Send ^+-
    else
        Send {Browser_Forward}
    return

; Close Application (or Firefox tab) - down, then right, then Down
; Default_D_R_D:
Default_DR:
    ifWinActive, ahk_group CloseBlacklist
        return

    ; close previously minimized window for good
    if m_ClosingWindow
        gosub gdCheckCloseApp

    ; remember ID of window
    m_ClosingWindow := WinActive("A")

    if m_ClosingWindow
    {
        WinMinimize ; deactivate the window, reactivating next window down in the z-order
        WinHide ; hide window
        ; give 5 second delay before actually closing
        SetTimer, gdCloseApp, 5000
        ; allow the Escape key to cancel (and show the window again)
        Hotkey, Escape, gdCancelCloseApp, On
        SYS_ToolTipText = Window Close in 5 Sec
	      Gosub, SYS_ToolTipFeedbackShow
    }
return



gdCloseApp:
    ; disable timer and cancel hotkey
    SetTimer, gdCloseApp, Off
    Hotkey, Escape, gdCancelCloseApp, Off

gdCheckCloseApp:
    if m_ClosingWindow
    {
        DetectHiddenWindows, Off
        ; don't close the window if it is visible
        ; (for example, user may have pressed a hotkey causing the m_ClosingWindow to be shown before it closes)
        if (! WinExist("ahk_id " m_ClosingWindow))
        {
            DetectHiddenWindows, On
            WinClose, ahk_id %m_ClosingWindow%
            DetectHiddenWindows, Off
        }
        m_ClosingWindow := 0
    }
return

; Press Escape within 5 seconds to cancel "Close App"
gdCancelCloseApp:
    ; disable timer and hotkey
    SetTimer, gdCloseApp, Off
    Hotkey, Escape, gdCancelCloseApp, Off

    ; show the window again
    WinShow, ahk_id %m_ClosingWindow%
    WinActivate, ahk_id %m_ClosingWindow%
    m_ClosingWindow := 0

    ; play a sound
    SoundPlay, *-1
return


; Reload the Script.
Default_R_D_L_U:
	if ( !A_IsCompiled )
	{
		Reload
		SYS_ToolTipText = Reload
		Gosub, SYS_ToolTipFeedbackShow
	}
return


; Edit script/config.
Default_D_L_U_R:
    ; Menu, EditFile, Add, Edit &Gestures.ahk         , TrayMenu_Edit
    ; Menu, EditFile, Add, Edit Gestures_&Default.ahk , TrayMenu_Edit
    ; Menu, EditFile, Add, Edit Gestures_&User.ahk    , TrayMenu_Edit
	Menu, EditFile, Add, Edit Gestures.ini    , TrayMenu_Edit
	Menu, EditFile, Add, Edit %SYS_ScriptNameNoExt%.ini , TrayMenu_Edit 
    Menu, EditFile, Show
    Menu, EditFile, Delete
return


; Default_L_D:    ; Minimize
Default_DL:
    G_MinimizeActiveWindow()
	SYS_ToolTipText = Window Minimize
	Gosub, SYS_ToolTipFeedbackShow
return
	
; Default_R_U:    ; Maximize
Default_UR:
    WinGet, mm, MinMax, A
    if mm
	{
        PostMessage, 0x112, 0xF120, , , A ; WM_SYSCOMMAND, SC_RESTORE		; WinRestore, A
		SYS_ToolTipText = Window Restore
	}else{
		PostMessage, 0x112, 0xF030, , , A ; WM_SYSCOMMAND, SC_MAXIMIZE
		SYS_ToolTipText = Window Maximize
	}
	Gosub, SYS_ToolTipFeedbackShow
return

; skycc - modified
Default_R_L:
Default_L_R:
    GoSub, MoveToNextMonitor
return

; Default_L_D_U:
Default_DL_U:
; Default_U_L_D_U: ; <-- compensate for bad habit
    WinGet, mm, MinMax, A
    ;if ((lastMinTime+2000 > A_TickCount && WinExist("ahk_id " lastMinID))   ; undo recent minimize
	if (WinExist("ahk_id " lastMinID)   ; undo recent minimize
        OR (mm && WinActive("A"))                                           ; active window is minimized or maximized, restore it
        OR WinExist(G_GetLastMinimizedWindow()))                            ; restore "top-most" minimized window
    {
        ; PostMessage, WM_SYSCOMMAND, SC_RESTORE  ; -- restores the window, playing relevant "Restore" sound
        PostMessage, 0x112, 0xF120
        lastMinTime = 0
        lastMinID = 0
    }
return

Default_R_L_R_L:
Default_L_R_L_R:
    WinActive("A")
    WinGet, mm, MinMax
    if mm
        SendMessage, 0x112, 0xF120 ; WM_SYSCOMMAND, SC_RESTORE
    PostMessage, 0x112, 0xF010 ; WM_SYSCOMMAND, SC_MOVE
    Send {Left}{Right}
    return
	

; *** modified some of the default gestures
;;;;;;;;;; new default ;;;;;;;;;;

; n
Default_U_R_D:
	; SetTitleMatchMode, RegEx
	if WinActive("ahk_group Explorer")
		send {AppsKey}wf
	else if WinActive("ahk_group Browser")
		Send ^t
	else
		Send ^n
return

; n reversed
Default_U_L_D:
	; SetTitleMatchMode, RegEx
	if WinActive("ahk_group Explorer")
		send, !{Enter}	; send, {AppsKey}r
	else
		Send, {Enter}
return

; undo
Default_DL_R:
	Send, ^z
	SYS_ToolTipText = Undo
	Gosub, SYS_ToolTipFeedbackShow
return

	
; copy, cut, paste feature
Default_D_R_U_D:
	Send ^x
	SYS_ToolTipText = Cut
	Gosub, SYS_ToolTipFeedbackShow
return
	
Default_D_R_U:
	Send ^c
	SYS_ToolTipText = Copy
	Gosub, SYS_ToolTipFeedbackShow
return

Default_D_L_U:
	Send ^v
	SYS_ToolTipText = Paste
	Gosub, SYS_ToolTipFeedbackShow
return

; Delete, Shift delete
Default_U_R_D_L:
	Send {Del}
return

Default_R_U_L_D:
	Send +{Del}
return


; h
Default_D_U_R_D:
if WinActive("ahk_group Editor")
	Send ^{Home}
else
	Send {Home}
return

; h reversed
Default_U_L_D_U:
if WinActive("ahk_group Editor")
	Send ^{End}
else
	Send {End}
return


Default_L_R_L:
	Send, {Home}

Default_R_L_R:
	Send, {End}

; W
Default_D_R_U_D_R_U:
if WinExist("ahk_group Browser")
	WinActivate, ahk_group Browser
else
	Run, http://www.google.com.my
return


Default_U:
	if WinActive("ahk_group Explorer")
		Send, !{Up}		; Send, {BackSpace}
	else if WinActive("ahk_group Desktop")
		Send, #+m
	else
		Send {PgUp}
return

Default_D:
	if ( WinActive("ahk_group Explorer") or WinActive("ahk_group Desktop") )
		Send, {Launch_App1}		; Launch My Computer (usually)
	else
		Send {PgDn}
return


; open favourite
Default_L_D_R_U:
	Gosub, myFavourite
return


Default_D_U:
	Gosub, ROL_RollToggle
return

Default_D_U_R:
	Gosub, AOT_SetToggle
	Gosub, ROL_RollToggle
return

Default_U_D:
	Send, {F5}
return


Default_U_D_U_D:
	Send, {F11}
return

; show desktop
Default_U_D_U:
	Send, #d
return


Default_D_L:
if WinActive("ahk_group Browser")
	Send {Browser_Back}
return

Default_D_R:
if WinActive("ahk_group Browser")
	Send {Browser_Forward}
return

; Close MDI window
Default_L_U_R:
Default_UL:
	Send, ^w
return

Default_L_D_R:
	Send, !{F4}
return

; Media player
Default_U_L:
	Send, {Media_Prev}
return

Default_U_R:
	Send, {Media_Next}
return

Default_D_U_D:
	Send, {Media_Play_Pause}
return

Default_D_U_D_U:
	Send, {Media_Stop}
return

Default_U_L_R:
	Send, {Launch_Media}
return


Default_L_D_R_D_L:
	Send, ^s
return


; F1, F2, F3
Default_UR_D:
	Send, {F1}
return

Default_R_D_L_D_R:
	Send, {F2}
return

Default_R_D_L_R_D_L:
	Send, {F3}
return

Default_UL_D:
	Send, {Esc}
return

Default_R_L_D:
	Gosub, AOT_SetToggle
return


