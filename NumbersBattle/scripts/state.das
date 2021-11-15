options indenting = 2
require power

let shared
  PLAYER_INDEX = 0
  UNIT_SIZE = 7.0
  PLAYER_SPEED_MUL = 3.0
  MIN_APPEAR_DIST_SIZE_MUL = 5.0
  DAMAGE_SIZE_MUL = 0.8
  DEATH_TIME = 0.5
  APPEAR_TIME = 1.0

  DEAD = "dead"
  APPEAR = ""
  READY = "ready"

  debugViewMode = false
  debugBigNumbers = false


struct PolyView
  poly : array<float2>
  textOffset : float2
  color : uint
  angle : float


struct Unit : Power
  id : int
  size : float
  pos : float2
  speed : float
  tgt : float2
  from : float2
  visual : string
  uType : string
  state : string
  stateTime : float
  view : PolyView


struct State
  units : table<int; Unit>
  lastUnitIndex : int
  lastGamePower : Power


var
  state : State


def isPlayerAlive()
  var res = false
  find(state.units, PLAYER_INDEX) <| $(unit)
    if unit != null
      res = unit.state != DEAD
  return res


def isPlayerExist()
  var res = false
  find(state.units, PLAYER_INDEX) <| $(unit)
    res = unit != null
  return res