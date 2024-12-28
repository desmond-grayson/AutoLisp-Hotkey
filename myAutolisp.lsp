;;;;; Drawing Settings

; TODO: create a list of all enviornment variables
; TODO: provide a link for the documentation
; TODO: provide example scripts for...
;       inserting blocks
;       creating layers

; ====================================================================================================
; =========                  =========================================================================
; =========   Introduction   =========================================================================
; =========                  =========================================================================
; ====================================================================================================


;  





; ====================================================================================================
; =========                           ================================================================
; =========   Enviornment Variables   ================================================================
; =========                           ================================================================
; ====================================================================================================


; Every time this file is loaded, the following commands will run.
; In the first example, inside AutoCAD we could run the same command by typing 'gridmode' followed by '0'

(setvar "gridmode" 0)         ; disables background grid
(setvar "acadlspasdoc" 0)     ; controls how ACAD will load the lisp file

; ====================================================================================================
; =========                   ========================================================================
; =========   LISP Commands   ========================================================================
; =========                   ========================================================================
; ====================================================================================================


; We'll start simple & work our way into more complex examples.
; Let's make a command that will reorientate our viewpoint to a top-down view.
; The entire command must be contained within parenthesis.
; Inside pass 'defun c:' this tells the script that we are defining a command.
; Next is the name of the command, 'vwt'. This is what you will type inside AutoCAD to trigger the command.
; Begin a newline and create new parenthesis. The first thing we type is the function name 'command'.
; Command will trigger commands within AutoCAD. The first command we send is "-view",
; After "-view" is sent, we send "_top". 

(defun c:vwt ()
  (command "-view" "_top")
) ; this final parenthesis closes off the 'defun' statement & signals that the vwt command is finished being described.


; Here is an example of running multiple instructions within a single command.
; The commands will execute in order from top to bottom.
; First we will set the system variable 'filletrad' to 2, then trigger the fillet command.

(defun c:f2 () ; apply a 2 unit wide fillet
  (setvar "filletrad" 2)
  (command "fillet")
)


; Introducing the pause & "" commands
; For this example, we want to create a default leader with two points. We want the command to wait for the user to input where the points of the leader should go.
; When 'pause' is used without quotes, the instructions wait for user input.
; After both points are input, the qleader will normally ask us to select a next point. Since we are done selecting points, we can use an empty double quote "" instruct the command to continue.
; This is the equivilant of pressing enter / space in AutoCAD during a running command.

(defun c:2q () ; create a 2-point qleader with placeholder text
  (command "qleader" pause pause "" "This is my text" "this is a new line" "you can also write new lines\nlike this" "")
)


; Introducing variables and user input.
; Consider the following commands, the first two will arbitrarily set the system variable on or off.
; Sometimes this is useful, but it may be more useful to be able to toggle this command without necessarily knowing what it's currently set to.
; For this example we'll create a variable with setq. The logic of this is (setq variableName variableValue)
; Here, the variable name is dbfStatus & it's value is (getvar "dimtfill") [in other words, dbfStatus is equal to the current value of dimtfill]
; Since dimtfill can only be a 1 or 0, we can do some math to switch it.
; The final command be read as setting 'dimtfill' to the absolute value of dbfStatus minus 1.

(defun c:dbfOn () ; set dimension backfill on
  (setvar "dimtfill" 1) ; 
)

(defun c:dbfOff () ; set dimension backfill off
  (setvar "dimtfill" 0)
)

(defun c:dbf () ; toggle dimension backfill
  (setq dbfStatus (getvar "dimtfill"))
  (setvar "dimtfill" (abs (- dbfStatus 1)))
)

; For the sake of example, a nested method of writting the above command without using variables
; 
(defun c:dbf ()
  (setvar "dimtfill" (abs (- (getvar "dimtfill") 1)))
)

; Introducing command-s and user prompts
; command-s is a faster version of command. One drawback, however, is that it cannot pause for user input.
; Assume you have a command which you want to execute quickly but also wish to have user input for.
; We can get the user input as a variable and use that variable as an arguement in the -s commands.

(defun c:cct () ; copy current tab, set it's name, and move to it
  (setq title (getstring "Enter new tab's name"))
  (command-s "layout" "copy" "" title)
  (command-s "layout" "set" title)
)


; Here is an example with several instructions using the concepts we've learned so far.

(defun c:copyLine ()
  (command "-layer" "m" "blue hidden" "c" 150 "blue hidden" "lt" "hidden"     "blue hidden" "")
  (command "-layer" "m" "red solid"   "c" 10  "red solid"   "lt" "continuous" "red solid"   "")
  (command-s "-layer" "set" "blue hidden" "")
  (command "line" pause pause "")
  (command-s "-layer" "set" "red solid" "") 
  (command-s "copy" "last" "" "0,0" "0,3")
  (command "qleader" pause pause "" "Two lines 3 units apart" "and a leader" "both on different layers" "")
)

; Introducing functions


