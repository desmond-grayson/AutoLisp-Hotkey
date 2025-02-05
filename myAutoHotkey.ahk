; ====================================================================================================
; =========                  =========================================================================
; =========   Introduction   =========================================================================
; =========                  =========================================================================
; ====================================================================================================

; Note: the author has chosen to write this script using AutoHotkey (AHK) version 1.1, not the newer version 2.
; AutoHotkey version 1.1 must be used to ensure compatibility. Please see the provided ReadMe for more details.

; This template is intended to be used as a framework to get started with AutoHotkey & AutoLisp for improved AutoCAD workflow.
; Each workflow is unique, as are the frequented commands for each industry. As such, only example commands are included here as proof-of-concept.
; The author assumes little-to-no prior knowledge of AHK, AutoLisp, or programming in general.
; In order to get a fresh mind up to speed quickly; effort has been made to explain syntax, document, and explain choices.

; HOW TO USE THIS TEMPLATE
; I would suggest skipping straight to the section labeled 'AutoCAD Hotkeys.' Read the section & experiemnt with the hotkeys.
; After, I would advise reading the 'Universal Hotkeys', 'Hotstrings', & 'Main GUI' sections.
; These will hopefully get you up to speed quickly. The remaining sections can be explored as needed for furthering your knowledge.










; ====================================================================================================
; =========                        ===================================================================
; =========   Configure Settings   ===================================================================
; =========                        ===================================================================
; ====================================================================================================
 

; These settings change the way we want our script to behave.
; Please read the AHK documentation for a full explaination of each command and modify freely to suit your preferences.
; Through my own experimentation, I've found most of the following settings help increase script speed which is why I've included them here.

#NoEnv                                  ; Prevents empty variables from being referenced, improves performance
#MaxHotkeysPerInterval 99000000         ; Max number of macros before script soft-stops
#HotkeyInterval 1000                    ; Interval(ms) before soft-stopping program
#KeyHistory 1                           ; Log length recent executions
#Warn                                   ; Enables error warnings at script start
#SingleInstance Force                   ; Disables 'Script Already Running' warning
#UseHook                                ; Disables recursive triggers
#HotkeyModifierTimeout 6                ; Attempts to kill stuck keys
ListLines Off                           ; Extension of KeyHistory, disabled for better speed
Process, Priority, , A                  ; Defines scripts system priority (A = above normal)
SetBatchLines, -1                       ; Speed of script (-1 for never sleep)
SetKeyDelay, -1, -1                     ; Set Delay between keystrokes (-1 = no delay)
SendMode Input                          ; SendInput=Speed, Input=Mouse Reliability
SetWorkingDir %A_ScriptDir%             ; Sets cd to folder containing script
Suspend On                              ; Script starts in suspended states
CoordMode, Pixel, Window                ; Image search coords relative to the window

; To enable the following commands, remove the ';' at the start of the line.
; They are included here as they may be welcomed by some users, but are too specific for a general user.

; SetNumLockState, AlwaysOn               ; Forces Numlock on, OS hotkey disables further functionality but allows the key to be used to fire specified macros
; SetScrollLockState, AlwaysOff           ; Similar to the above










; ====================================================================================================
; =========                      =====================================================================
; =========   Global Variables   =====================================================================
; =========                      =====================================================================
; ====================================================================================================


; These are variables which we will reuse later.

; Important note: by default the script is setup to start in a suspended state,
; Meaning no commands will trigger by default. If you instead wished for the script to start in an active state,
; change 'armed := 1' without quotes, and above in the 'Configure Settings' section, change 'Suspend On' to 'Suspend Off'
; The armed variable will be explained more in the following 'Main GUI' section.

gui_name := My AutoHotLisp GUI
armed := 0










; ====================================================================================================
; =========              =============================================================================
; =========   Main GUI   =============================================================================
; =========              =============================================================================
; ====================================================================================================


; This gives our GUI the 'AlwaysOnTop' & 'ToolWindow' properties
; Meaning it will 'float' above other windows and have a narrower top bar without minimize & maximize buttons
Gui Main: +AlwaysOnTop +ToolWindow

; This sets our default colors. See previous note in this section about the armed toggle.
Gui Main: Color, Blue, Black

; Sets the default font size to 12, color to white, & font to Consolas
Gui Main: Font, s12 cWhite, Consolas

; Creates seprate tabs for our GUI and sets 'Main' to default
Gui Main: Add, Tab3 w203 cWhite, Main||Doc|X

; Everything below the next line will appear in the 'Main' Tab of the GUI
Gui Main: Tab, Main

; Create a checkbox to control the 'Always on Top' status of the AHK GUI.
; This is 'Checked' by default, and that status is tracked by the variable 'floatIsOn'
; Clicking this box will cause the GoSub command 'Toggle_Float' to run which does as the name suggests.
; The text after the last comma controls the text displayed on the button.
Gui Main: Add, CheckBox, h20 Checked vfloatIsOn gToggle_Float,  Toggle Float

; Similar to the last, this will create a button which reloads this script.
; The script must be reloaded for any changed to take effect, making this a faster way of reloading than using the system tray.
Gui Main: Add, Button,   h20                    gReload_Gui,    Reload

; Clicking this button will open a seprate GUI with various shortcuts within it. More on this later.
Gui Main: Add, Button,   h20 x+10               gOpen_UtilsGUI, Shortcuts

Gui Main: Tab, Doc
Gui Main: Add, Edit,r1 w50 varch_room_number gUpdate_Controls
Gui Main: Add, Edit,r1 w100 x+10 varch_room_name gUpdate_Controls
Gui Main: Add, Checkbox, xm+18 y75 h20 vCheckName1,Sec
Gui Main: Add, Checkbox, x+7 h20 Checked vCheckName0,Skip

Gui Main: Tab, X

; Finally, now that everything about our GUI is defined, we need to display it.
; We give it a name, in this case we are referencing the variable 'GuiName' defined in the previous section.
; To denote that we are using a variable, we wrap the variable name with %
Gui Main: Show, , %GuiName%
return

; The next command tells the script to terminate if the above GUI is ever closed.
; Without this, the script would continue to run in the background without the GUI.
; I feel the common user expectation would be for the script to terminate when the GUI is closed which is why it has been included here.
GuiClose:
	if (a_gui = "main")
		exitapp
	else
		gui destroy










; ====================================================================================================
; =========               ============================================================================
; =========   Functions   ============================================================================
; =========               ============================================================================
; ====================================================================================================


; Functions are snippits of code which can be reused later. 

winTitleActive(winTitle, waitSecs) {
; Repeatedly check if a specified window is currently focused. When combined with an if statement, can safely execute commands only once the intended window opens.
; winTitle: expects a str of the Window's name wrapped in double quotes "" (include ahk_class/exe/pid within quotes if not using the title)
; waitSecs: expects an int representing the length of time the function should wait for the window before returning False

; Example usage:
; if winTitleActive("Enhanced Attribute Editor", 2) {
;   Send,hello world
; }

; The function will check if Dynamic Block text entry form is active for two seconds.
; 'hello world' will only be typed if the window is open, otherwise those instructions will never be activated.

	timeout := (waitSecs * 1000)
	start_time := A_TickCount ; Get the current timestamp
	while (!WinActive(winTitle) && (A_TickCount - start_time) < timeout) {
		Sleep, 100
	}
	if (WinActive(winTitle)) {
		return True
	}
	else {
		return False
  }
}










; ====================================================================================================
; =========                    =======================================================================
; =========   GoSub Commands   =======================================================================
; =========                    =======================================================================
; ====================================================================================================


; GoSubs are a set of instructions to perform and can be referenced by GUI buttons & hotkeys.
; Unlike functions, GoSubs have a fixed set of instructions & cannot accept arguements.
; For this reason, it is generally advised to instead use a function when possible.
; The primary benefit of GoSubs can be triggered by the GUI's buttons & other controls while functions cannot.

Reload_GUI:
	Reload

; Controls always-on-top status of GUI
Toggle_Float:
	Gui Main: Submit, NoHide
	if (floatIsOn == 1)
		Gui Main: +AlwaysOnTop
	else
		Gui Main: -AlwaysOnTop
	return

; Dis/En-ables hotkeys & changes the GUI's background color to reflect status.
Toggle_Armed:
	if (armed = 0) {
		armed = 1
		Gui 1:Color,Red ; Armed color
	}
	else {
		armed = 0
		Gui 1:Color,Blue ; Disarmed color
	}
	return










; ====================================================================================================
; =========                     ======================================================================
; =========   AutoCAD Hotkeys   ======================================================================
; =========                     ======================================================================
; ====================================================================================================


; Any hotkeys written below the next line will only trigger if the named window is currently focused.
; Note: you will have to rename this depending on what version of AutoCAD you are using.
; Note: changing this to 'ahk_exe acad.exe' will ensure the hotkeys will work in any window generated by AutoCAD,
;       but in my experience, this behavior is undesirable and generates unintended effects which is why the window title is used instead.

#IfWinActive, Autodesk AutoCAD 2024

; Try the following hotkeys in an empty drawing in AutoCAD.
; MAKE SURE THE ABOVE LINE IS SET TO THE CORRECT VERSION & RELOAD AHK FROM THE GUI / SYSTEM TRAY IF YOU NEED TO CHANGE IT!
; ALSO MAKE SURE THAT THE GUI IS ARMED (Red) TO ENSURE THE HOTKEYS CAN TRIGGER, Press the Left Alt Key (by default) to toggle between armed & disarmed.
; open an empty drawing in autocad & try pressing the following commands to get the described results.

; press '1' on the numpad to activate the rectang command & draw a 2*2 square
Num1:: Send,{esc}rectang{enter}2{tab}2{enter}

; press '4' on the numpad to draw a 5*5 box & spawn a message box.
Num4::
  Send,{esc}rectang{enter}5{tab}5{enter}
  MsgBox,I just drew a 5*5 box!
  return

Num7::
  Suspend,Permit ; including this instruction will allow a hotkey to trigger even if the script is disarmed (but still running)
  MsgBox,This MsgBox will appear even if the script is disarmed, be careful!
  return

~Num8::MsgBox, Because this command started with a '~', the specified key will be sent like normal but the hotkey commands will also trigger.

Num9::
; For this hotkey, hover over a dynamic block with text input options before pressing the hotkey
	BlockInput, MouseMove                                  ; disables mouse to prevent accentially moving off position while the commands takes place
	Send,{Esc}_eattedit{enter}
	Send,{LButton}                                         ; sends a left mouse click
	BlockInput, MouseMoveOff                               ; renables mouse
  if winTitleActive("Enhanced Attribute Editor", 2) {    ; for details on 'winTitleActive', see the 'Functions' section
    ; Everything inside these {} braces will only trigger if AHK detects a window called "Enhanced Attribute Editor" is focused
    MsgBox, If you successsfully clicked into a dynamic block you will see this message.
  }
  else {
    ; Everything in these {} braces will only trigger if the "Enhanced Attribute Editor" was not opened within 2 secs
    MsgBox, The Enhanced Attribute Editor window didn't seem to open in time.
  }
  return

>+p::
  MsgBox, Press 'Right Shift' and 'p' to trigger this hotkey.
  MsgBox, Modifiers (shift, control, alt, & windows) can be added to hotkeys.
  MsgBox, Abrevitions are (shift +) (control ^) (alt !) (windows #)
  MsgBox, To denote the left or right hand modifier key use < or > before the modifier symbol.
  return

Esc & F1::
  MsgBox, To have a non-modifier combination of keys trigger a hotkey,
  MsgBox, Specify both keys and seperate them with '&'
  return

; Writting your own commands:
; Check the online AHK documentation for the names of the keys.
; Write your key name followed by two colons as above.

; 'Send,' will type out whatever is written afterwords.
;         for our purposes, it should be the name of the command or lisp which we want to trigger.
;         since 'esc' is wrapped in curly braces {}, the send command will interpret this as the name of the key to press instead of text.
;         Note, if possibly having something selected in autocad while running the command could cause errors, you should start the command with {esc} to ensure no selections are present.

; Notes on formatting hotkeys:
;   Notice that in the Num1 example, only one command (send) was used. This allowed everything to be written on one line.
;   When a command is written in the same line as the key, AHK interprets this as the ONLY command the hotkey will trigger.
;   In the example of Num4, Send and MsgBox were both used. This meant they could not be on the same line as the key.
;   When these commands were finished, we signalled to AHK that the hotkey's instructions were finished with 'return'











; ====================================================================================================
; =========                       ====================================================================
; =========   Universal Hotkeys   ====================================================================
; =========                       ====================================================================
; ====================================================================================================


; As before, any hotkeys written below the next line will only trigger in the specified window.
; Since no window is actually named, this means that the hotkeys will trigger in ANY window and can be used system-wide.

#IfWinActive

; armed key
LAlt::
  ; Note: the key we use to dis/arm the script must have Suspend,Permit enabled otherwise the script cannot be rearmed without reloading
  Suspend,Permit
  GoSub,Toggle_Armed
  return

Num1::MsgBox, hello world!

; Note that Num1 is used as a hotkey in the "AutoCAD" & "Universal" sections.
; In this example, the AutoCAD hotkey for Num1 will be the only one which triggers if AutoCAD is focused.
; Otherwise, the above Num1 hotkey will be default trigger in all other programs.










; ====================================================================================================
; =========                ===========================================================================
; =========   Hotstrings   ===========================================================================
; =========                ===========================================================================
; ====================================================================================================


; Hotstrings are similar to hotkeys. Instead of being triggered by a single key / key-combo, they are triggered whenever you type the defined text.
; This can be used to expand out abrevitions, auto-correct frequently misspelled words, our autofill in data.

; An example of correcting a spelling mistake:
; Whenever 'lazer ' is typed, this script will immediettly erase what was typed & replace it with 'laser'.
::lazer::
  Suspend,Permit
  Send,laser
  return

; Example: expanding out abbreviations
::HOA::
  Suspend,Permit
  Send,home owner's association
  return

; Example: Creating a quick way of typing longer forms of text.
; Note: it is strongly discouraged to use this as a method of inputting passwords. 
::me@::
  Suspend,Permit
  Send,myemail@company.com
  return

; Example: inputting symbols easily
::`tm::™
::`cr::©

; Example: inputting text mid-string
; In the below examples, a question mark is put in-between the leading colons.
; This enables the hotstrings to trigger even if there are preceeding letters before them.

:?:`deg::°
; For example, typing '36`deg' would become '36°'
; If the hotstring was written as '::`deg::°' instead, '36`deg' would not trigger the hotstring, but '36 `deg' would.

:?:`dia::Ø
:?:`e::é

; This example comes straight from the AutoHotkey documentation on hotstrings
:*:]d::  ; This hotstring replaces "]d" with the current date and time via the commands below.
  FormatTime, CurrentDateTime,, M/d/yyyy h:mm tt  ; It will look like 9/1/2005 3:53 PM
  SendInput %CurrentDateTime%
  return

