options indenting = 2
require daslib/media
require state
require common
require behaviours
require unitDraws
require levels
require power


def getSpawnPoint()
  var res = screenRand()
  find(state.units, PLAYER_INDEX) <| $(unit)
    if unit == null
      return
    var leftTries = 10
    while leftTries-- > 0 && screenLength(res, unit.pos) < MIN_APPEAR_DIST_SIZE_MUL * unit.size
      res = screenRand()

  return res


def addEnemyUnit(uType : string; value : float; power : int)
  log("AddUnit: uType = {uType}; value = {value}; power = {power}")
  var unit <- [[ Unit
    id = ++state.lastUnitIndex,
    value = value,
    power = power,
    pos = getSpawnPoint(),
    size = sh(UNIT_SIZE),
    speed = powerToSpeed(power),
    uType = uType
  ]]
  find(initUnitDraws, unit.uType) <| $(init)
    if init != null
      invoke(*init, unit)
  state.units[unit.id] <- unit


def spawnPlayer()
  state.units[PLAYER_INDEX] <- [[ Unit
    id = PLAYER_INDEX,
    value = 5.0,
    power = 0,
    pos = mkPoint(0.5, 0.5),
    size = sh(UNIT_SIZE),
    speed = powerToSpeed(0) * PLAYER_SPEED_MUL,
    uType = "player"
  ]]
  copy(state.lastGamePower, state.units[PLAYER_INDEX])


def getTotalUnitsPower()
  var res : Power
  for unit in values(state.units)
    if unit.state != DEAD
      sumTo(res, unit)
  return res


def spawnNewUnits()
  var allPower <- getTotalUnitsPower()
  var count = getLevelEnemiesCount(allPower.power) - length(state.units) + 1 //+ player
  if count <= 0
    return
  
  for i in range(0, count)
    var newPower := allPower
    newPower.value *= rand(curLevel.raiseSpeed[curLevel.lastRaiseIndex++ % length(curLevel.raiseSpeed)])
    if newPower.power == 0 || newPower.value >= 10.0
      newPower.value = floor(newPower.value)
    normalize(newPower)
    sumTo(allPower, newPower)
    let uType = getSpawnEnemyType(newPower.power)
    if uType == ""
      log("Error: !!!!!!!!!!!!!!!!!!!! No unit type to spawn at power {newPower.power} !!!!!!!!!!!!!!!!!!!!!!!!!!!")
      return
    addEnemyUnit(uType, newPower.value, newPower.power)


def debugAllTypes()
  let value = debugBigNumbers ? 999.0 : 3.0
  let power = debugBigNumbers ? 50 : 0
  for uType in keys(behaviours)
    if uType != "player"
      for i in range(0, 1)
        addEnemyUnit(uType, value, power)


def startNewGame()
  log("START NEW GAME")
  clear(state.units)
  spawnPlayer()
  spawnNewUnits()
