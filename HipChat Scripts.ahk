StatusChange(keysHC, keysTeams, pos3CX)		; The function that actually does the window switching and change of status
{
	winid := WinExist("A")					; Store ID of current active window

	if WinExist("HipChat")					; Check to make sure HipChat is running
	{
		WinActivate
		WinActivate 						; Not sure why this has to be sent twice, seems to be related to virtual desktops
		WinWaitActive, , , 1				; Make sure window got activated within 1 second
		If ErrorLevel 						; Run if window did not activate within timeout value
		{
			MsgBox, 8208, Error, HipChat Timed Out, cancelling
			return
		}
		; SendInput, ^{Tab}					; Switch room to clear selection
		; SendInput, ^+{Tab}					; Switch back to original room
		; Sleep, 250
		SendInput, ^a%keysHC%{Enter}		; Select all existing text and send command
	}

	if WinExist("ahk_exe teams.exe")		; Check to make sure Teams is running
	{
		WinActivate
		WinActivate 						; Not sure why this has to be sent twice, seems to be related to virtual desktops
		WinWaitActive, , , 1				; Make sure window got activated within 1 second
		If ErrorLevel 						; Run if window did not activate within timeout value
		{
			MsgBox, 8208, Error, Teams Timed Out, cancelling
			return
		}	
		SendInput, ^e
		SendInput, %keysTeams%
		Sleep, 250							; Seems to need a delay before sending enter
		SendInput, {Enter}
		Sleep, 250							; Seems to be more reliable with a delay before switching apps
	}

	if WinExist("ahk_exe 3CXWin8Phone.exe")		; Check to make sure Teams is running
	{
		WinActivate
		WinActivate 						; Not sure why this has to be sent twice, seems to be related to virtual desktops
		WinWaitActive, , , 1				; Make sure window got activated within 1 second
		If ErrorLevel 						; Run if window did not activate within timeout value
		{
			MsgBox, 8208, Error, 3CX Timed Out, cancelling
			return
		}	
		SendInput, {Esc}
		Click, 30,45						; Click on availability button
		Sleep, 20							; Seems to need to wait for the menu to be built, improves reliability
		Click, %pos3CX%						; Click on appropriate menu item based on coordinates below
	}

	WinActivate, ahk_id %winid%				; Switch back to original active window
}

#SingleInstance, force 						; Forces only one instance, allows to re-run script without reloading
CoordMode, Mouse, Client

; These are the measured coordinates on a 1920x1080 screen at 100% scaling, adjust as required
posAvail := "30,80"
posAway := "30,120"
posDND := "30,155"

^F1::
	StatusChange("/back", "/available", posAvail)
return

^F2::
	StatusChange("/dnd On Phone", "/dnd", posAway)
return

^F3::
	; Determine time %increment% minutes from now
	increment := 15 						; time to add to current time
	rounder := 5 							; what level to round UP to nearest
	var := ;								; initialize %var% as current time
	EnvAdd, var, %increment%, Minutes 		; current time plus increment
	; MsgBox %var%
	FormatTime, min, %var%, mm 				; grab minute part of time for rounding
	mod := Mod(min, rounder)				; grab remainder after dividing current mins by rounder
	; MsgBox %var% %mod%
	if mod
	{
		EnvSub, rounder, %mod%
		EnvAdd, var, %rounder%, Minutes
		; MsgBox %var%
	}
	FormatTime, var, %var%, h:mm 			; format for easy human digestion

	StatusChange("/away Back ~" var, "/brb", posAway)
return

^F4::
	StatusChange("/away PM Me", "/brb", posAway)
return

^F5::
	; Ask user for away input
	InputBox, var, Away Message, Message for Away Status?
	if ErrorLevel 		; Cancel script if "Cancel" is pressed 
	{
		return
	}

	StatusChange("/away " var, "/away", posAway)
return

^F6::
	; Ask user for dnd input
	InputBox, var, Do Not Disturb Message, Message for DND Status?
	if ErrorLevel 		; Cancel script if "Cancel" is pressed
	{
		return
	}
	
	StatusChange("/dnd " var, "/dnd", posDND)
return