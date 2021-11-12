options indenting = 2
require daslib/media
require math
require state
require common


let
  IDLE_TIME = 0.5
  SIN_LINEAR_TIME = 0.3
  SIN_PERIOD = 1.0
  SIN_OFFSET = 1.0


def setState(var unit : Unit; state : string)
  if unit.state != state
    unit.state = state
    unit.stateTime = 0.0


def move(var unit : Unit; dt : float)
  if unit.speed == 0.0
    return true

  var offset = unit.tgt - unit.pos
  var moveDist = unit.speed * dt
  var dist = length(offset)
  if dist < moveDist
    unit.pos = unit.tgt
    return true

  unit.pos = unit.pos + offset * (moveDist / dist)
  return false


def moveSin(var unit : Unit; dt : float)
  if unit.speed == 0.0
    return true

  let totalOffset = unit.tgt - unit.from
  let totalDist = length(totalOffset)
  let movePart = unit.stateTime * unit.speed / totalDist
  if movePart >= 1.0
    unit.pos = unit.tgt
    return true

  let periods = int(totalDist / unit.speed / SIN_PERIOD)
  if periods <= 0
    unit.pos = unit.from + (unit.tgt - unit.from) * movePart
    return false


  let periodDist = totalDist / float(periods)
  let angle = ((movePart * float(periods)) % 1.0) * 2.0 * PI
  let sinOffset = normalize(totalOffset) * SIN_OFFSET * unit.size
  unit.pos = unit.from + (unit.tgt - unit.from) * movePart + float2(sinOffset.y * sin(angle), sinOffset.x * sin(angle))
  return false


def moveAround(var unit : Unit; dt : float)
  if unit.stateTime == 0.0
    unit.tgt = (unit.tgt + unit.from) / 2.0 //center of move, to get to real tgt

  let dir = unit.tgt - unit.from
  let radius = length(dir)
  let startAngle = (dir.x > 0.0 ? 0.0
    : dir.x < 0.0 ? PI
    : dir.y > 0.0 ? 0.5 * PI
    : -0.5 * PI)
  let angle = startAngle + unit.stateTime * unit.speed / radius
  unit.pos = unit.tgt - float2(cos(angle), sin(angle)) * radius

  return false


def playerMove(var unit : Unit; dt : float)
  move(unit, dt)


def moveLines(var unit : Unit; dt : float; getList : block<():array<float2>>; moveImpl : function<(var unit : Unit; dt : float):bool> = @@move)
  if unit.state == READY
    setState(unit, "idle")
    unit.stateTime = IDLE_TIME

  if unit.state == "idle"
    if unit.stateTime < IDLE_TIME
      return
    setState(unit, "move")
    let list <- invoke(getList)
    var idx = rand_int(0, length(list))
    let dir = list[idx]
    unit.tgt = unit.pos + dir * rand()
    unit.from = unit.pos

  if unit.state == "move" && invoke(moveImpl, unit, dt)
    setState(unit, "idle")


def moveLines(var unit : Unit; dt : float; moveImpl : function<(var unit : Unit; dt : float):bool> = @@move; getList : block<():array<float2>>)
  moveLines(unit, dt, getList, moveImpl)

def moveSquare(var unit : Unit; dt : float)
  moveLines(unit, dt) <| $()
    return <- [{ auto[] float2(sSize.x, 0.0); float2(-sSize.x, 0.0); float2(0.0, sSize.y); float2(0.0, -sSize.y) }]


def moveTriangle(var unit : Unit; dt : float)
  moveLines(unit, dt) <| $()
    let dist = sh(100.0)
    var triangle <- [{ auto[] float2(0.0, -dist); float2(-dist * s60, dist * c60); float2(dist * s60, dist * c60) }]
    return <- unit.view.angle == 0.0 ? triangle : rotateList(triangle, unit.view.angle)


def moveSinSquare(var unit : Unit; dt : float)
  moveLines(unit, dt, @@moveSin) <| $()
    return <- [{ auto[] float2(sSize.x, 0.0); float2(-sSize.x, 0.0); float2(0.0, sSize.y); float2(0.0, -sSize.y) }]


def moveCircle(var unit : Unit; dt : float)
  moveLines(unit, dt, @@moveAround) <| $()
    return <- [{ auto[] float2(sSize.x, 0.0); float2(-sSize.x, 0.0); float2(0.0, sSize.y); float2(0.0, -sSize.y) }]


let shared
  behaviours <- {{
    "player" => @@playerMove;
    "square" => @@moveSquare;
    "triangle" => @@moveTriangle;
    "sinSquare" => @@moveSinSquare;
    "circle" => @@moveCircle
  }}
