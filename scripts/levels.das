options indenting = 2
require math
require common


let shared
  DEF_LEVEL = "normal"


struct StdMuls
  base : float
  mul : float
  max : float


struct UnitMuls
  start : int
  max : int
  end : int
  maxChance : int


def mkMuls(vBase, vMul, vMax)
  return [[ StdMuls base = float(vBase), mul = float(vMul), max = float(vMax) ]]


def mkUnitMuls(uStart, uMax, uEnd, uMaxChance : int)
  return [[ UnitMuls start = uStart, max = uMax, end = uEnd, maxChance = uMaxChance ]]


def mkRaiseArray(list : array<float>; div, minV, maxV : float)
  var res : array<float2>
  for v in list
    push(res, float2(max(minV, v - div), min(maxV, v + div)))
  return <- res


struct Level
  id : string
  speed : StdMuls = mkMuls(20, 1, 100)
  enemies : StdMuls = mkMuls(6, 0.5, 20)
  raiseSpeed : array<float2> <- mkRaiseArray([{ auto[] 0.95; 0.7; 0.95; 0.5; 0.8; 0.9; 0.7; 0.5; 0.9 }], 0.05, 0.48, 0.95)
  lastRaiseIndex : int
  uTypes : table<string; UnitMuls> <- {{
    "square" => mkUnitMuls(0, 5, 20, 100);
    "triangle" => mkUnitMuls(1, 7, 25, 100);
    "sinSquare" => mkUnitMuls(2, 10, -1, 200);
    "circle" => mkUnitMuls(3, 12, -1, 200)
  }}


def initLevels(var list : table<string; Level>)
  for id, level in keys(list), values(list)
    level.id = id
  return <- list


let
  levels <- initLevels({{
    "easy" => [[ Level()
      speed <- mkMuls(15, 0.2, 100)
    ]];

    "normal" => Level();

    "hard" => [[ Level()
      speed <- mkMuls(25, 1, 100),
      enemies <- mkMuls(6, 0.8, 25)
    ]]
  }})


var
  curLevel : Level
  
   
def setLevel(levelId)
  find(levels, levelId) <| $(level)
    if level != null
      curLevel := *level


def countValue(v : StdMuls; power : int)
  return min(v.base + v.mul * float(power), v.max)


def countValueInt(v : StdMuls; power : int)
  return int(min(v.base + v.mul * float(power), v.max))


def countValue(v : UnitMuls; power : int)
  if power < v.start
    return 0.0
  if power <= v.max
    return float(power - v.start + 1) / float(v.max - v.start + 1)
  if v.end < v.max
    return float(v.maxChance)
  if power < v.end
    return float(v.end - power + 1) / float(v.end - v.max + 1)
  return 0.0


def powerToSpeed(power : int)
  return sh(countValue(curLevel.speed, power))


def getLevelEnemiesCount(power : int)
  return countValueInt(curLevel.enemies, power)


def getSpawnEnemyType(power : int)
  var chances : table<string; float>
  var sum = 0.0
  for uType, muls in keys(curLevel.uTypes), values(curLevel.uTypes)
    let c = countValue(muls, power)
    if c <= 0.0
      continue
    chances[uType] = c
    sum += c

  if sum == 0.0
    return ""

  sum *= rand()
  for uType, c in keys(chances), values(chances)
    sum -= c
    if sum < 0.0
      return uType
  return ""
