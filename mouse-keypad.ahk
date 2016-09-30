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
  tolerance := 0.25

  searchSpace := trimSearchSpace(searchSpace, initialSegment, tolerance, window)
  drawSelectionGrid(searchSpace)

  Loop {
    SetNumLockState, On
    Input, keyPressed, T3 L1, {NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadIns}{NumpadDel}{NumpadEnter}{NumpadMult},1,2,3,4,5,6,7,8,9,0
    SetNumLockState, Off

    If ErrorLevel = Timeout
    {
      Break
    }

    IfInString, ErrorLevel, EndKey:NumpadEnter
    {
      moveMouse(searchSpace)
      Break
    }
    else if keyPressed in 1,2,3,4,5,6,7,8,9
    {
      searchSpace := trimSearchSpace(searchSpace, keyPressed, tolerance, window)
      drawSelectionGrid(searchSpace)
    }
    else if keyPressed = 0
    {
      moveMouse(searchSpace)
      Click
      Break
    }
    else if keyPressed = .
    {
      moveMouse(searchSpace)
      Click Right
      Break
    }
    else if keyPressed = /
    {
      moveMouse(searchSpace)
      Click Middle
      Break
    }
    else if keyPressed = +
      Click WheelDown
    else if keyPressed = -
      Click WheelUp
    else
      Break
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

trimSearchSpace(searchSpace, segment, tolerance, window) {
  left := Floor(searchSpace.left + searchSpace.width / 3 * Mod(segment - 1, 3))
  top := Floor(searchSpace.top + searchSpace.height / 3 * Floor((9 - segment) / 3))
  width := Ceil(searchSpace.width / 3)
  height := Ceil(searchSpace.height / 3)

  left := left - Ceil(width * tolerance)
  width := width + Ceil(width * tolerance * 2)
  if left < 0
  {
    width := width + left
    left := 0
  }
  if left + width > window.right
  {
    width := window.right - left
  }

  top := top - Ceil(height * tolerance)
  height := height + Ceil(height * tolerance * 2)
  if top < 0
  {
    height := height + top
    top := 0
  }
  if top + height > window.bottom
  {
    height := window.bottom - top
  }

  return {left: left, top: top, width: width, height: height}
}
