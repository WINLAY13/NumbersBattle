options indenting = 2
require math
require daslib/media
require state
require common
require power


let
  playerColor = 0xFF10A0FF
  appearColor = 0x80808080
  deathColor = 0x80800000

  squareColor = 0xFFFFFF00
  triangleColor = 0xFF00FF00  
  sinSquareColor = 0xFFFF8040
  circleColor = 0xFFA000A0


def drawUnitValue(unit : Unit; pos : float2; color : uint = 0xFF000000)
  let text = get_power_text(unit)
  set_font_size((length(text) > 4 ? 0.25 : 0.3) * unit.size)
  let resPos = pos - get_text_size(text) * 0.5
  text_out(resPos.x, resPos.y, text, color)


def drawDefault(unit : Unit; pos : float2)
  fill_circle(pos.x, pos.y, 0.5 * unit.size, circleColor)
  drawUnitValue(unit, pos)


def drawAppear(unit : Unit; pos : float2)
  let mul = min(unit.stateTime / APPEAR_TIME, 1.0)
  fill_circle(pos.x, pos.y, 0.5 * unit.size * mul, unit.uType == "circle" ? 0xFFFFFFFF : unit.id == PLAYER_INDEX ? playerColor : appearColor)


def drawDeath(unit : Unit; pos : float2)
  let mul = max(1.0 - unit.stateTime / DEATH_TIME, 0.0)
  fill_circle(pos.x, pos.y, 0.5 * unit.size * mul, deathColor)


def drawPlayer(unit : Unit; pos : float2)
  fill_circle(pos.x, pos.y, 0.5 * unit.size, playerColor)
  drawUnitValue(unit, pos + float2(0.0, -0.11 * unit.size))


def drawSquare(unit : Unit; pos : float2)
  fill_rect(pos.x - 0.5 * unit.size, pos.y - 0.5 * unit.size, unit.size, unit.size, squareColor)
  drawUnitValue(unit, pos)


def drawPoly(unit : Unit; pos : float2)
  if length(unit.view.poly) == 0
    drawDefault(unit, pos)
    return

  fill_convex_polygon(moveList(unit.view.poly, pos), unit.view.color)
  //polygon(moveList(unit.view.poly, pos), unit.view.color)
  drawUnitValue(unit, pos + unit.view.textOffset)


def initTriangle(var unit : Unit)
  let angle = float(rand_int(4) * 90)
  let halfX = 0.6 * unit.size //inc size 20% to fit texts
  let halfY = 0.6 * s60 * unit.size
  var triangle <- [{ auto[] float2(-halfX, halfY); float2(0.0, -halfY); float2(halfX, halfY) }]

  unit.view <- [[ PolyView
    color = triangleColor,
    angle = angle,
    poly <- angle == 0.0 ? triangle : rotateList(triangle, angle),
    textOffset = rotate(float2(0.0, 0.15 * unit.size), angle)
  ]]


def initSinSquare(var unit : Unit)
  let half = 0.5 * unit.size
  let hole = 0.4 * unit.size
  unit.view <- [[ PolyView
    color = sinSquareColor,
    poly <- [{ auto[]
      float2(0.0, 0.0); //hack to avoid render bug
      float2(-hole, 0.0); //hack to avoid render bug
      float2(-half, -half);
      float2(0.0, -hole);
      float2(half, -half);
      float2(hole, 0.0);
      float2(half, half);
      float2(0.0, hole);
      float2(-half, half);
      float2(-hole, 0.0)
    }]
  ]]


let shared
  unitDraws <- {{
    "default" => @@drawPoly;
    "appear" => @@drawAppear;
    "death" => @@drawDeath;
    "player" => @@drawPlayer;
    "square" => @@drawSquare
  }}

  initUnitDraws <- {{
    "triangle" => @@initTriangle;
    "sinSquare" => @@initSinSquare
  }}
