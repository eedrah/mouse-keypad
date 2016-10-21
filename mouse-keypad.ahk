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

global TOLERANCE := 0.2
global GRID_DEPTH := 1

#SingleInstance,Force
#MaxThreads 1
SetWinDelay, 0

NumpadEnd::
  f1() {
    startSelectingScreenSegment(1)
  }
NumpadDown::
  f2() {
    startSelectingScreenSegment(2)
  }
NumpadPgDn::
  f3() {
    startSelectingScreenSegment(3)
  }
NumpadLeft::
  f4() {
    startSelectingScreenSegment(4)
  }
NumpadClear::
  f5() {
    startSelectingScreenSegment(5)
  }
NumpadRight::
  f6() {
    startSelectingScreenSegment(6)
  }
NumpadHome::
  f7() {
    startSelectingScreenSegment(7)
  }
NumpadUp::
  f8() {
    startSelectingScreenSegment(8)
  }
NumpadPgUp::
  f9() {
    startSelectingScreenSegment(9)
  }

#If !GetKeyState("NumLock","T")
  NumpadIns::LButton
  NumpadDel::RButton
  NumpadEnter::Return
  NumpadAdd::WheelDown
  NumpadSub::WheelUp
  NumpadMult::Return ; for now - later, toggle
  NumpadDiv::MButton
#If

startSelectingScreenSegment(initialSegment) {
  CoordMode, Mouse, Screen
  SysGet, window, Monitor
  window := { bottom: windowBottom, right: windowRight }

  searchSpace := { left: 0, top: 0, width: windowRight, height: windowBottom }

  searchSpace := trimSearchSpace(searchSpace, initialSegment, TOLERANCE, window)
  drawSelectionGrid(searchSpace)

  Loop {
    SetNumLockState, On
    Input, keyPressed, T3 L1, {NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadIns}{NumpadDel}{NumpadEnter}{NumpadMult},1,2,3,4,5,6,7,8,9,0
    SetNumLockState, Off

    If ErrorLevel = Timeout
    {
      Break
    }
    else IfInString, ErrorLevel, EndKey:NumpadEnter
    {
      moveMouse(searchSpace)
      Break
    }
    else if keyPressed in 1,2,3,4,5,6,7,8,9
    {
      searchSpace := trimSearchSpace(searchSpace, keyPressed, TOLERANCE, window)
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
  destroyGrid(GRID_DEPTH, "GUI_0")
}

destroyGrid(depth, guiPrefix) {
  destroyGridLevel(guiPrefix)
  if depth > 0
  {
    Loop, 9 {
      destroyGrid(depth - 1, guiPrefix . "_" . A_Index)
    }
  }
}

destroyGridLevel(guiPrefix) {
  Loop, 4 {
    i := A_Index - 1
    Gui, %guiPrefix%x%i%: Destroy
    Gui, %guiPrefix%y%i%: Destroy
  }
}

drawSelectionGrid(gridSpace) {
  drawGrid(gridSpace, GRID_DEPTH, "GUI_0")
}

drawGrid(gridSpace, depth, guiPrefix) {
  drawGridLevel(gridSpace, depth, guiPrefix)
  if depth > 0
  {
    Loop, 9 {
      noBounds := { bottom: 99999999, right: 99999999 }
      trimmedGridSpace := trimSearchSpace(gridSpace, A_Index, TOLERANCE, noBounds)
      drawGrid(trimmedGridSpace, depth - 1, guiPrefix . "_" . A_Index)
    }
  }
}

drawGridLevel(gridSpace, depth, guiPrefix) {
  if (depth = GRID_DEPTH)
  {
    color := "FF0000"
  }
  else
  {
    color := "0000FF"
  }
  Loop, 4 {
    i := A_Index - 1
    if (depth != GRID_DEPTH && (i = 0 || i = 3))
    {
      continue
    }
    if (depth = GRID_DEPTH)
    {
      thickness := 3
    }
    else
    {
      thickness := 1
    }
    drawBox(guiPrefix . "x" . i, gridSpace.left + Ceil(i * gridSpace.width / 3), gridSpace.top, thickness, gridSpace.height, color)
    drawBox(guiPrefix . "y" . i, gridSpace.left, gridSpace.top + Ceil(i * gridSpace.height / 3), gridSpace.width, thickness, color)
  }
}

drawBox(guiName, left, top, width, height, color) {
  Gui, %guiName%: +ToolWindow -Caption +AlwaysOnTop +LastFound
  Gui, %guiName%: Color, %color%
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
