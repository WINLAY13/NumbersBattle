options indenting = 2
require daslib/media
require state
require common
require levels
require spawn
require power


let
  BTN_HEIGHT = 6.0
  BTN_WIDTH = 40.0
  BTN_FONT_SIZE = 3.0
  BTN_GAP = 1.0
  BTN_START = 40.0
  RESULT_START = 30.0

  COLOR_NORMAL = 0xFFA0A0A0
  COLOR_HOVERED = 0xFFFFFFFF
  COLOR_PUSHED = 0x80A0A0FF
  COLOR_BG = 0x80000000


struct Button
  text : string
  pos : float2
  size : float2


struct MenuState
  isActive : bool = !debugViewMode
  buttons : table<string; Button>
  pushed : string
  hovered : string
  resultPos : float2
  isMlbPushed : bool


var
  menu <- MenuState()


def mkButton(idx, text)
  return <- [[ Button
    text = text,
    size = float2(shMul * BTN_WIDTH, shMul * BTN_HEIGHT),
    pos = float2(0.5 * (float(get_screen_width()) - shMul * BTN_WIDTH),
      shMul * (BTN_START + float(idx) * (BTN_HEIGHT + BTN_GAP)))
  ]]


def initMenu()
  menu.buttons <- {{
    "continue" => mkButton(0, "Continue");
    "easy" => mkButton(1, "New Game: Easy");
    "normal" => mkButton(2, "New Game: Normal");
    "hard" => mkButton(3, "New Game: Hard")
  }}
  menu.resultPos = float2(0.5 * float(get_screen_width()), shMul * RESULT_START)


def isBtnVisible(id : string)
  return id != "continue" || isPlayerAlive()


def onBtnClick(id : string)
  if !isBtnVisible(id)
    return

  if id == "continue"
    menu.isActive = false
    return

  find(levels, id) <| $(level)
    if level != null
      curLevel := *level
      startNewGame()
      menu.isActive = false


def updateMouseClick()
  let newVal = get_mouse_button(MB_LEFT)
  if newVal == menu.isMlbPushed
    return
  menu.isMlbPushed = newVal
  if menu.isMlbPushed
    menu.pushed = menu.hovered
  else
    if menu.pushed == menu.hovered
      onBtnClick(menu.pushed)
    menu.pushed = ""


def actMenu(dt)
  if !menu.isActive
    if isPlayerExist()
      return
    if debugViewMode
      spawnPlayer()
      debugAllTypes()
    else
      menu.isActive = true

  menu.hovered = ""
  let mPos = get_mouse_position()
  for id, btn in keys(menu.buttons), values(menu.buttons)
    if isBtnVisible(id) && isInside(mPos, btn.pos, btn.size)
      menu.hovered = id
      break
  updateMouseClick()


def drawMenu()
  if !menu.isActive
    return

  set_font_size(shMul * BTN_FONT_SIZE)
  if !isPlayerExist() && state.lastGamePower.value > 0.0
    let text = "Your size last battle on {curLevel.id}: {get_power_text(state.lastGamePower)}"
    let pos = menu.resultPos - get_text_size(text) * 0.5
    text_out(pos.x, pos.y, text, COLOR_NORMAL)

  for id, btn in keys(menu.buttons), values(menu.buttons)
    if !isBtnVisible(id)
      continue
    var color = (id != menu.hovered ? COLOR_NORMAL
      : id == menu.pushed ? COLOR_PUSHED
      : COLOR_HOVERED)
    fill_rect(btn.pos.x, btn.pos.y, btn.size.x, btn.size.y, COLOR_BG)
    rect(btn.pos.x, btn.pos.y, btn.size.x, btn.size.y, color)
    let pos = btn.pos + btn.size * 0.5 - get_text_size(btn.text) * 0.5
    text_out(pos.x, pos.y, btn.text, color)
