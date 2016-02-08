; --- import eclipse preferences ---
WinWait, ahk_class SWT_Window0
IfWinNotActive, ahk_class SWT_Window0, , WinActivate, ahk_class SWT_Window0
WinWaitActive, ahk_class SWT_Window0

Sleep, 2000
Send, {ALTDOWN}f{ALTUP}i

WinWait, Import, 
IfWinNotActive, Import, , WinActivate, Import, 
WinWaitActive, Import, 

Sleep, 2000
Send, preferences

; senden ALT-N um den button NEXT zu klicken.
; sonst kannst du einfach einmal mit ENTER bestätigen
; da der button sowieso den fokus bereits hat
Sleep, 2000
Send, {ENTER}

WinWait, Import Preferences, 
IfWinNotActive, Import Preferences, , WinActivate, Import Preferences, 
WinWaitActive, Import Preferences, 

Sleep, 2000
Send, eclipse-preferences.epf

Sleep, 2000
Send, {ENTER}

; --- import existing maven projects ---
WinWait, ahk_class SWT_Window0
IfWinNotActive, ahk_class SWT_Window0, , WinActivate, ahk_class SWT_Window0
WinWaitActive, ahk_class SWT_Window0

Sleep, 2000
Send, {ALTDOWN}f{ALTUP}i

WinWait, Import, 
IfWinNotActive, Import, , WinActivate, Import, 
WinWaitActive, Import, 

Sleep, 2000
Send, existing maven project

; senden ALT-N um den button NEXT zu klicken.
; sonst kannst du einfach einmal mit ENTER bestätigen
; da der button sowieso den fokus bereits hat
Sleep, 2000
Send, {ENTER}

WinWait, Import Maven Projects, 
IfWinNotActive, Import Maven Projects, , WinActivate, Import Maven Projects, 
WinWaitActive, Import Maven Projects, 

Sleep, 2000
Send, {ALTDOWN}r{ALTUP}%A_WorkingDir%

Sleep, 2000
Send, {ENTER}

; ist es besser selbst einmal mit ENTER bestätigen?
; naja, kann man machen ist ja auch nicht so schwer...
; funktioniert nicht wenn die zeit nicht ausreicht um projekte zu laden. also auskommentiert.
;Sleep, 2000
;Send, {ENTER}
