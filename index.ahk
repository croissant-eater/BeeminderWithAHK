#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
#SingleInstance, Force			; Ensures the script has only one single instance.
#Include %A_ScriptDir%\JSON.ahk ; Credit to cocobelgica for the library (https://github.com/cocobelgica/AutoHotkey-JSON)


FileRead jsonString, config.json
Data := JSON.Load(jsonString)
runBeeMinder := Data.beeminder
runPushNotifications := Data.pushover
playSounds := Data.playSounds
changeIcons := Data.changeIcons

dirPath := "G:\Work\Upwork\AHK_Kat\BeeMinder Timer\Beeminder with AHK\" ; Make sure to include the last \ in the path
mins := 0
secs := 0
state := "FOCUS"
paused := false


Gui, Add, Button, x6 y78 w51 h20 gRun default, Start
Gui, Add, Button, x63 y78 w51 h20 disabled gToggle, Stop
Gui, Add, Button, x120 y78 w51 h20 gPause, Pause
Gui, Font, cGreen s12 bold, verdana
Gui, Add, Edit, x55 y6 w90 h20 -E0x200 readonly, %state%
Gui, Font, cGreen s19 bold, verdana
Gui, Add, Edit, x34 y32 w108 h36 readonly center
Gui +ToolWindow +LastFound
GUI1 := WinExist()

Menu, Tray, NoStandard
Menu, Tray, Add, GUI Show/Hide, GuiShowHide
Menu, Tray, Add
Menu, Tray, Default, GUI Show/Hide
Menu, Tray, Click, 1
Menu, Tray, Standard
if(changeIcons) {
	Menu, Tray, Icon, %dirPath%\icons\yellow.ico
	iconStatus := "yellow"
}

Gui, Show, w180 x50 y50, Pomodoro
GuiControl,, edit2, 00:00
WinSet, AlwaysOnTop, On, a
return

Run:
if(changeIcons) {
	Menu, Tray, Icon, %dirPath%\icons\green.ico
	iconStatus := "green"
}
GuiControl, -disabled, Button2
FormatTime, timeatstart,, yyyyMMdd, HH:mm
SetTimer, Count, 1000
return

Count:
	if(!paused) {
		if(iconStatus != "red" && changeIcons) {
			Menu, Tray, Icon, %dirPath%\icons\green.ico
		}
		++secs
		if(secs=60) {
			++mins
			secs := 0
			if(mins<10)
				GuiControl,, edit2, 0%mins%:00
			else
				GuiControl,, edit2, %mins%:00
		}
		else if(secs<10) {
			if(mins<10)
				GuiControl,, edit2, 0%mins%:0%secs%
			else
				GuiControl,, edit2, %mins%:0%secs%
		}
		else {
			if(mins<10)
				GuiControl,, edit2, 0%mins%:%secs%
			else
				GuiControl,, edit2, %mins%:%secs%
		}
		if(secs = 5 and state = "FOCUS") {
			filename := dirPath . "status.txt"
			FileDelete, %filename% ; Delete status.txt to wipe it out

			if(changeIcons) {
				Menu, Tray, Icon, %dirPath%\icons\red.ico ; Set the Script's icon to Red
				iconStatus := "red"
			}


			if(playSounds) {
				SoundBeep, 200, 750 ; Plays a beep
			}

			secs := 0
			state := "BREAK"
			GuiControl,, edit1, %state% 

			FileAppend, break, %filename% ; Append the word "break" to status.txt
			Sleep, 1500
			if(runBeeMinder) {
				Run, %dirPath%beeminder.lnk 
			}
			
			if(runPushNotifications) {
				Run, %dirPath%pushover.lnk 
			}

			; Define the filename with the current date
			FormatTime, currentDate, , yyyyMMdd 
			filename := dirPath . "pomo\" . "pomo_" . currentDate . ".txt"
			FileRead, content, %dirPath%\pomo\pomo_%currentDate%.txt 
			content := (content + 1) 
			if(!content) { 
				content := 0
			}

			if FileExist(filename)
			{
				FileDelete, %filename%
				FileAppend, %content%, %filename%
			}
			else
			{
				FileAppend, %content%, %filename%
			}
		} else if(secs = 7 and state = "BREAK") {
			filename := dirPath . "status.txt"
			FileDelete, %filename% ; Delete status.txt to wipe it out

			if(changeIcons) {
				Menu, Tray, Icon, %dirPath%\icons\yellow.ico ; Set the Script's icon to Red
				iconStatus := "yellow"
			}


			if(playSounds) {
				SoundBeep, 700, 500 ; Plays a beep
			}

			FileAppend, work, %filename% ; Append the word "work" to status.txt
			Sleep, 1500
			if(runPushNotifications) {
				Run, %dirPath%pushover.lnk ; Runs Pushover's API request
			}

			SetTimer, Count, Off
			FormatTime, timeatstop,, yyyyMMdd, HH:mm
			mins := 0
			secs := 0
			if(state = "BREAK")
				state := "FOCUS"
			GuiControl, +disabled, Button2
			GuiControl,, edit1, %state%
			GuiControl,, edit2, 00:00
			Gui, Submit, NoHide
		}
	}
	Gui, Submit, NoHide
	if(paused) {
		if(changeIcons) {
			Menu, Tray, Icon, %dirPath%\icons\yellow.ico
			iconStatus := "yellow"
		}
	}
Return

Toggle:
if(changeIcons) {
	Menu, Tray, Icon, %dirPath%\icons\yellow.ico
	iconStatus := "yellow"
}
SetTimer, Count, Off
FormatTime, timeatstop,, yyyyMMdd, HH:mm
mins := 0
secs := 0
if(state = "BREAK")
	state := "FOCUS"
GuiControl, +disabled, Button2
GuiControl,, edit1, %state%
GuiControl,, edit2, 00:00
Gui, Submit, NoHide
Return

Pause:
paused := !paused
Return

GuiClose:
GuiShowHide:
  If GetKeyState("LShift")
     ExitApp

  If DllCall( "IsWindowVisible", UInt,GUI1 )
     Gui, Hide
  else
     Gui, Show
Return

+Esc::ExitApp ; Shift + Escape to ExitApp
