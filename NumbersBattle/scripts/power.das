options indenting = 2
require math
require daslib/media


let
  letters = "abcdefghijklmnopqrstuvwxyz"


struct Power
  value : float
  power : int //power of 1000


def normalize(var p)
  while p.value > 1000.0
    p.value *= 0.001
    p.power += 1
  while p.value < 1.0
    p.value *= 1000.0
    p.power -= 1


def sumTo(var p1; p2)
  if p1.power == p2.power
    p1.value += p2.value
  elif p1.power > p2.power
    if p1.power - p2.power == 1
      p1.value += p2.value * 0.001
  elif p2.power > p1.power
    if p2.power - p1.power == 1
      p1.value = p2.value + p1.value * 0.001
    else
      p1.value = p2.value
    p1.power = p2.power

  normalize(p1)


def isBigger(p1, p2)
  return p1.power == p2.power ? p1.value > p2.value : p1.power > p2.power


def clearPower(var p)
  p.value = 0.0
  p.power = 0


def copy(var p1 : Power; p2)
  p1.power = p2.power
  p1.value = p2.value


def get_power_letter(totalPower : int)
  var res : string
  var power = totalPower
  let total = length(letters)
  while power > 0
    power--
    let idx = power % total
    res = "{slice(letters, idx, idx + 1)}{res}"
    power = power / total
  return res


def get_power_text(p)
  var intPart = int(p.value)
  var fracPart = intPart > 20 ? 0 : int(p.value * 10.0) - intPart * 10
  let letter = get_power_letter(p.power)
  return fracPart > 0 ? "{intPart}.{fracPart}{letter}" : "{intPart}{letter}"
