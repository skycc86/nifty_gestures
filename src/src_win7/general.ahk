
general_Init:	
	
; Create a group for easy identification of Browser windows
GroupAdd, Browser, ahk_class MozillaUIWindowClass
GroupAdd, Browser, ahk_class MozillaDropShadowWindowClass
GroupAdd, Browser, ahk_class IEFrame
GroupAdd, Browser, ahk_class Chrome_WidgetWin_0
GroupAdd, Browser, ahk_class Chrome_WidgetWin_1

; Create a group for easy identification of Text Editor windows
GroupAdd, Editor, ahk_class Notepad
GroupAdd, Editor, ahk_class Notepad2
GroupAdd, Editor, ahk_class Notepad++
GroupAdd, Editor, ahk_class OpusApp                 ; 1.22
GroupAdd, Editor, ahk_class PP12FrameClass          ; 1.22

; 1.21 , include browser for copy feature
GroupAdd, Editor2, ahk_class Notepad
GroupAdd, Editor2, ahk_class Notepad2
GroupAdd, Editor2, ahk_class Notepad++
GroupAdd, Editor2, ahk_class OpusApp
GroupAdd, Editor2, ahk_class PP12FrameClass
GroupAdd, Editor2, ahk_class XLMAIN
GroupAdd, Editor2, ahk_class PPTFrameClass
GroupAdd, Editor2, ahk_class MozillaUIWindowClass
GroupAdd, Editor2, ahk_class MozillaDropShadowWindowClass
GroupAdd, Editor2, ahk_class IEFrame
GroupAdd, Editor2, ahk_class Chrome_WidgetWin_0
GroupAdd, Editor2, ahk_class Chrome_WidgetWin_1


; Create a group for easy identification of BlackList Apps for certain features
GroupAdd, BlackListApp2, ahk_class rfb::win32::DesktopWindowClass	;VNC
GroupAdd, BlackListApp2, ahk_class vncviewer::DesktopWindow				;VNC
GroupAdd, BlackListApp2, ahk_class vwr::CDesktopWin       				;VNC
GroupAdd, BlackListApp2, ahk_class vwr::CSurfaceWin       				;VNC
GroupAdd, BlackListApp2, ahk_class TSSHELLWND	    			;Remote Desktop
GroupAdd, BlackListApp2, ahk_class TscShellContainerClass	    ;Remote Desktop (win7)
GroupAdd, BlackListApp2, ahk_class Progman         ; Desktop
GroupAdd, BlackListApp2, ahk_class WorkerW         ; Desktop
GroupAdd, BlackListApp2, ahk_class Shell_TrayWnd   ; Taskbar
GroupAdd, BlackListApp2, ahk_class DV2ControlHost  ; start menu

GroupAdd, BlackListCopy, ahk_class rfb::win32::DesktopWindowClass		;VNC
GroupAdd, BlackListCopy, ahk_class vncviewer::DesktopWindow				;VNC
GroupAdd, BlackListCopy, ahk_class vwr::CDesktopWin       				;VNC
GroupAdd, BlackListCopy, ahk_class vwr::CSurfaceWin       				;VNC
GroupAdd, BlackListCopy, ahk_class Progman         ; Desktop
GroupAdd, BlackListCopy, ahk_class WorkerW         ; Desktop
GroupAdd, BlackListCopy, ahk_class Shell_TrayWnd   ; Taskbar
GroupAdd, BlackListCopy, ahk_class DV2ControlHost  ; start menu
GroupAdd, BlackListCopy, ahk_class CabinetWClass
GroupAdd, BlackListCopy, ahk_class ExploreWClass
GroupAdd, BlackListCopy, ahk_class TSSHELLWND	    			;Remote Desktop
GroupAdd, BlackListCopy, ahk_class TscShellContainerClass	    ;Remote Desktop (win7)

GroupAdd, BlackListPaste, ahk_class rfb::win32::DesktopWindowClass		;VNC
GroupAdd, BlackListPaste, ahk_class vncviewer::DesktopWindow				;VNC
GroupAdd, BlackListPaste, ahk_class vwr::CDesktopWin       				;VNC
GroupAdd, BlackListPaste, ahk_class vwr::CSurfaceWin       				;VNC
GroupAdd, BlackListPaste, ahk_class Shell_TrayWnd   ; Taskbar
GroupAdd, BlackListPaste, ahk_class DV2ControlHost  ; start menu
; GroupAdd, BlackListPaste, ahk_class TSSHELLWND	    			;Remote Desktop
; GroupAdd, BlackListPaste, ahk_class TscShellContainerClass	    ;Remote Desktop (win7)

GroupAdd, Desktop, ahk_class Progman         ; Desktop
GroupAdd, Desktop, ahk_class WorkerW         ; Desktop


GroupAdd, BlackListGesture, ahk_class rfb::win32::DesktopWindowClass	;VNC
GroupAdd, BlackListGesture, ahk_class vncviewer::DesktopWindow				;VNC
GroupAdd, BlackListGesture, ahk_class vwr::CDesktopWin       				  ;VNC
GroupAdd, BlackListGesture, ahk_class vwr::CSurfaceWin       				;VNC

GroupAdd, RemoteDesk, ahk_class TSSHELLWND	    			;Remote Desktop
GroupAdd, RemoteDesk, ahk_class TscShellContainerClass	    ;Remote Desktop (win7)

; Create a group for easy identification of Windows Explorer windows.
GroupAdd, Explorer, ahk_class CabinetWClass
GroupAdd, Explorer, ahk_class ExploreWClass

; Default_D_R never closes these windows:
GroupAdd, CloseBlacklist, ahk_class Progman         ; Desktop
GroupAdd, CloseBlacklist, ahk_class WorkerW         ; Desktop
GroupAdd, CloseBlacklist, ahk_class Shell_TrayWnd   ; Taskbar

m_DrawingMode := false

; return to main NiftyWindows
return

; [SYS] handles tooltips
; move from NiftyWindows.ahk

SYS_ToolTipShow:
	If ( SYS_ToolTipText )
	{
		If ( !SYS_ToolTipSeconds )
			SYS_ToolTipSeconds = 1
		SYS_ToolTipMillis := SYS_ToolTipSeconds * 1000
		CoordMode, Mouse, Screen
		CoordMode, ToolTip, Screen
		If ( !SYS_ToolTipX or !SYS_ToolTipY )
		{
			MouseGetPos, SYS_ToolTipX, SYS_ToolTipY
			SYS_ToolTipX += 16
			SYS_ToolTipY += 24
		}
		ToolTip, %SYS_ToolTipText%, %SYS_ToolTipX%, %SYS_ToolTipY%
		SetTimer, SYS_ToolTipHandler, %SYS_ToolTipMillis%
	}
	SYS_ToolTipText =
	SYS_ToolTipSeconds =
	SYS_ToolTipX =
	SYS_ToolTipY =
Return

SYS_ToolTipFeedbackShow:
	If ( SYS_ToolTipFeedback )
		Gosub, SYS_ToolTipShow
	; SYS_ToolTipText =
	; SYS_ToolTipSeconds =
	; SYS_ToolTipX =
	; SYS_ToolTipY =
Return

SYS_ToolTipHandler:
	SetTimer, SYS_ToolTipHandler, Off
	ToolTip
Return

hex2rgb(CR)
{
    H := InStr(CR, "0x") ? CR : (InStr(CR, "#") ? "0x" SubStr(CR, 2) : "0x" CR)
    return (H & 0xFF0000) >> 16 ", " (H & 0xFF00) >> 8 ", " (H & 0xFF)
}

hex2rgb_real(CR)
{
    SetFormat, float, 0.2
    H := "" . CR
    H := InStr(CR, "0x") ? CR : (InStr(CR, "#") ? "0x" SubStr(CR, 2) : "0x" CR)
    return ((H & 0xFF0000) >> 16)/255.0 ", " ((H & 0xFF00) >> 8)/255.0 ", " (H & 0xFF)/255.0
}

