#NoEnv
SetBatchLines, -1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

SetTimer, Timer1, 100
SetTimer, Timer2, 70

Timer1:
MouseGetPos, X, Y
FFToolTip.()
Sleep, -1
return

Timer2:
if (sX != X || sY != Y) {
ToolTip, %X% %Y%,
Sleep, -1
}
return
;-----------------------
*^x::ExitApp
;-----------------------

FFToolTip(Text:="", X:="", Y:="", WhichToolTip:=1) {
   static ID := [], sX:=X, sY:=Y, W, H, SavedText
        , PID := DllCall("GetCurrentProcessId")
        , _ := VarSetCapacity(Point, 8)
   if (Text = "") {  ; Hide the tooltip
      ToolTip, %Text%, X, Y, WhichToolTip
      ID[WhichToolTip] := WinExist("ahk_class tooltips_class32 ahk_pid " PID)
      WinGetPos, , , W, H, % "ahk_id " ID[WhichToolTip]
      SavedText := Text
   } else if (Text != SavedText) {  ; The tooltip text changed
      ToolTip, %Text%, X, Y, WhichToolTip
      WinGetPos, , , W, H, % "ahk_id " ID[WhichToolTip]
      SavedText := Text
   } else {  ; The tooltip is being repositioned
      if (Flag := X = "" || := Y = "") {
         DllCall("GetCursorPos", "Ptr", &Point, "Int")
         MouseX := NumGet(Point, 0, "Int")
         MouseY := NumGet(Point, 4, "Int")
      }
      ;
      ; Convert input coordinates to screen coordinates
      ;
	if (A_CoordModeToolTip = "Screen") {
         X := X = "" ? MouseX + 16 : X
         Y := Y = "" ? MouseY + 16 : Y
      }
      ;
      ; Deal with the bottom and right edges of the screen
      ;
      if Flag {
         X := X + W >= A_ScreenWidth  ? A_ScreenWidth  - W - 1 : X
         Y := Y + H >= A_ScreenHeight ? A_ScreenHeight - H - 1 : Y
         if (MouseX >= X && MouseX <= X + W && MouseY >= Y && MouseY <= Y + H)
            X := MouseX - W - 3, Y := MouseY - H - 3
      }
      ;
      ; If necessary, store the coordinates and move the tooltip window
      ;
      if (sX != X || sY != Y) {
	 sX:=X, sY:=Y
         DllCall("MoveWindow", "Ptr", ID[WhichToolTip], "Int", X, "Int", Y, "Int", W, "Int", H, "Int", false, "Int")
      }
   }
}