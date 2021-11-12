options indenting = 2
require daslib/media
require math


var
  shMul = 1.0
  sSize : float2
  seed : int4

let shared
  c60 = cos(60.0 * PI / 180.0)
  s60 = sin(60.0 * PI / 180.0)


def initSizes()
  sSize = float2(float(get_screen_width()), float(get_screen_height()))
  shMul = 0.01 * min(3.0 / 4.0 * float(get_screen_width()), float(get_screen_height()))


def mkPoint(relX, relY : float)
  return float2(relX * float(get_screen_width()), relY * float(get_screen_height()))


def sh(x : float)
  return x * shMul


def log(text : string)
  print("{text}\n")


def rand_int(from, to : int)
  if from >= to
    return from
  return random_int(seed) % (to - from)


def rand_int(variants : int)
  if variants <= 0
    return 0
  return random_int(seed) % variants


def rand()
  return random_float(seed)


def rand(v : float2)
  return v.x + rand() * (v.y - v.x)


def screenRand()
  return float2(rand() * sSize.x, rand() * sSize.y)


def toPositive(val, maxVal : float)
  var res = val % maxVal
  return res < 0.0 ? res + maxVal : res


def screenPoint(p : float2)
  return float2(toPositive(p.x, sSize.x), toPositive(p.y, sSize.y))


def screenLength(p1, p2 : float2)
  return min(length(screenPoint(p1) - screenPoint(p2)), length(screenPoint(p1 + 0.5 * sSize) - screenPoint(p2 + 0.5 * sSize)))


def rotate(p : float2; angle : float)
  let rad = angle * PI / 180.0
  let c = cos(rad)
  let s = sin(rad)
  return float2(c * p.x + s * p.y, c * p.y + s * p.x)


def rotateList(list : array<float2>; angle : float)
  var res : array<float2>
  for p in list
    push(res, rotate(p, angle))
  return <- res


def rotateList(list : array<float2>; angle : int)
  return <- rotateList(list, float(angle))


def moveList(list : array<float2>; offset : float2)
  var res : array<float2>
  for p in list
    push(res, p + offset)
  return <- res


def isInside(tgt, pos, size : float2)
  return tgt.x >= pos.x && tgt.x <= pos.x + size.x && tgt.y >= pos.y && tgt.y <= pos.y + size.y
