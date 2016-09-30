; Scrolling
; ---------
; NumpadEnd (1)
; NumpadDown (2)
; NumpadPgDn (3)
; NumpadLeft (4)
; NumpadClear (5)
; NumpadRight (6)
; NumpadHome (7)
; NumpadUp (8)
; NumpadPgUp (9)
;
; Clicking
; --------
; NumpadIns (0) - Left click
; NumpadDel (.) - Right click
; NumpadEnter - Close without clicking
; NumpadAdd - Mouse scroll down
; NumpadSub - Mouse scroll up
; NumpadDiv - Middle click
; NumpadMult - Toggle next click (either left, right or middle)

MsgBox Start initialize

#SingleInstance,Force
SetWinDelay, 0
#MaxThreads 1

HotKey, NumpadEnd, startSelectingScreenSegmentWith1
HotKey, NumpadDown, startSelectingScreenSegmentWith2
HotKey, NumpadPgDn, startSelectingScreenSegmentWith3
HotKey, NumpadLeft, startSelectingScreenSegmentWith4
HotKey, NumpadClear, startSelectingScreenSegmentWith5
HotKey, NumpadRight, startSelectingScreenSegmentWith6
HotKey, NumpadHome, startSelectingScreenSegmentWith7
HotKey, NumpadUp, startSelectingScreenSegmentWith8
HotKey, NumpadPgUp, startSelectingScreenSegmentWith9

#If !GetKeyState("NumLock","T")
  NumpadIns::LButton
  NumpadDel::RButton
  NumpadEnter::Return
  NumpadAdd::WheelDown
  NumpadSub::WheelUp
  NumpadMult::Return ; for now - later, toggle
  NumpadDiv::MButton
#If

;/*Monitor:
;  MsgBox Monitoring
;  HotKey, NumpadEnd, On
;  HotKey, NumpadDown, On
;  HotKey, NumpadPgDn, On
;  HotKey, NumpadLeft, On
;  HotKey, NumpadClear, On
;  HotKey, NumpadRight, On
;  HotKey, NumpadHome, On
;  HotKey, NumpadUp, On
;  HotKey, NumpadPgUp, On
;
;  HotKey, NumpadIns, On
;  HotKey, NumpadDel, On
;  HotKey, NumpadEnter, On
;  HotKey, NumpadAdd, On
;  HotKey, NumpadSub, On
;  HotKey, NumpadMult, On
;  HotKey, NumpadDiv, On
;Return
;
;StopMonitoring:
;  HotKey, NumpadEnd, Off
;  HotKey, NumpadDown, Off
;  HotKey, NumpadPgDn, Off
;  HotKey, NumpadLeft, Off
;  HotKey, NumpadClear, Off
;  HotKey, NumpadRight, Off
;  HotKey, NumpadHome, Off
;  HotKey, NumpadUp, Off
;  HotKey, NumpadPgUp, Off
;
;  Hotkey, If, !GetKeyState("NumLock","T")
;    HotKey, NumpadIns, Off
;
;    HotKey, NumpadDel, Off
;    HotKey, NumpadEnter, Off
;    HotKey, NumpadAdd, Off
;    HotKey, NumpadSub, Off
;    HotKey, NumpadMult, Off
;    HotKey, NumpadDiv, Off
;
;Return*/
;
; Because I don't know AutoHotKey that well...
startSelectingScreenSegmentWith1:
  startSelectingScreenSegment(1)
Return
startSelectingScreenSegmentWith2:
  startSelectingScreenSegment(2)
Return
startSelectingScreenSegmentWith3:
  startSelectingScreenSegment(3)
Return
startSelectingScreenSegmentWith4:
  startSelectingScreenSegment(4)
Return
startSelectingScreenSegmentWith5:
  startSelectingScreenSegment(5)
Return
startSelectingScreenSegmentWith6:
  startSelectingScreenSegment(6)
Return
startSelectingScreenSegmentWith7:
  startSelectingScreenSegment(7)
Return
startSelectingScreenSegmentWith8:
  startSelectingScreenSegment(8)
Return
startSelectingScreenSegmentWith9:
  startSelectingScreenSegment(9)
Return

startSelectingScreenSegment(initialSegment) {
  CoordMode, Mouse, Screen
  SysGet, window, Monitor
  window := { bottom: windowBottom, right: windowRight }

  searchSpace := { left: 0, top: 0, width: windowRight, height: windowBottom }
  tolerance := 0.1666666

  searchSpace := trimSearchSpace(searchSpace, initialSegment, tolerance, window)
  drawSelectionGrid(searchSpace)

  Loop {
    SetNumLockState, On
    Input, keyPressed, T3 L1, {NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadIns}{NumpadDel}{NumpadEnter}{NumpadMult},1,2,3,4,5,6,7,8,9,0
    SetNumLockState, Off

    If ErrorLevel = Timeout
    {
      MsgBox Timed out
      Break
    }

    IfInString, ErrorLevel, EndKey:NumpadEnter
    {
      moveMouse(searchSpace)
      Break
    }
    else
      MsgBox %keyPressed%

    if keyPressed in 1,2,3,4,5,6,7,8,9
    {
      searchSpace := trimSearchSpace(searchSpace, keyPressed, tolerance, window)
      drawSelectionGrid(searchSpace)
    }
    ;process other keys
      ;break
    ;trimSearchSpace(searchSpace, segment, tolerance, window)
    ;drawSelectionGrid(searchSpace)
  }
  destroySelectionGrid()
}

moveMouse(searchSpace) {
  left := searchSpace.left + Floor(searchSpace.width / 2)
  top := searchSpace.top + Floor(searchSpace.height / 2)
  MouseMove, %left%, %top%
}

destroySelectionGrid() {
  Loop, 4 {
    i := A_Index - 1
    Gui, x%i%: Destroy
    Gui, y%i%: Destroy
  }
}

drawSelectionGrid(gridSpace) {
  Loop, 4 {
    i := A_Index - 1
    drawBox("x" . i, gridSpace.left + Ceil(i * gridSpace.width / 3), gridSpace.top, 1, gridSpace.height)
    drawBox("y" . i, gridSpace.left, gridSpace.top + Ceil(i * gridSpace.height / 3), gridSpace.width, 1)
  }
}

drawBox(guiName, left, top, width, height) {
  Gui, %guiName%: +ToolWindow -Caption +AlwaysOnTop +LastFound
  Gui, %guiName%: Color, 0000FF
  Gui, %guiName%: Show, x%left% y%top% w%width% h%height% NoActivate
}

trimSearchSpace(searchSpace, segment, tolerace, window) {
  left := Floor(searchSpace.left + searchSpace.width / 3 * Mod(segment - 1, 3))
  top := Floor(searchSpace.top + searchSpace.height / 3 * Floor((9 - segment) / 3))
  width := Ceil(searchSpace.width / 3)
  height := Ceil(searchSpace.height / 3)
  return {left: left, top: top, width: width, height: height}
}
