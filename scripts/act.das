options indenting = 2
require daslib/media
require state
require common
require behaviours
require spawn
require power
require menu
require levels


def kill(var victim, killer : Unit)
  sumTo(killer, victim)
  killer.speed = powerToSpeed(killer.power) * (killer.id == PLAYER_INDEX ? PLAYER_SPEED_MUL : 1.0)
  clearPower(victim)
  setState(victim, DEAD)

def battle(var unit1, unit2 : Unit)
  if isBigger(unit1, unit2)
    kill(unit2, unit1)
  else
    kill(unit1, unit2)


def actGame(dt)
  if menu.isActive && isPlayerAlive()
    return //game paused

  find_for_edit(state.units, PLAYER_INDEX) <| $(var playerUnit)
    if playerUnit != null
      playerUnit.tgt = get_mouse_position()

  var unitsToRemove : array<int>
  for idx, unit in keys(state.units), values(state.units)
    unit.stateTime += dt
    if unit.state == APPEAR
      if unit.stateTime < APPEAR_TIME
        continue
      setState(unit, READY)
    if unit.state == DEAD
      if unit.stateTime >= DEATH_TIME
        push(unitsToRemove, idx)
      continue
    find(behaviours, unit.uType) <| $(bhv)
      if bhv != null
        invoke(*bhv, unit, dt)

  for idx in unitsToRemove
    erase(state.units, idx)

  if length(unitsToRemove) > 0
    spawnNewUnits()

  if debugViewMode
    return

  //check fight
  find_for_edit(state.units, PLAYER_INDEX) <| $(var playerUnit)
    if playerUnit == null || playerUnit.state == DEAD
      return
    for idx, unit in keys(state.units), values(state.units)
      if idx == PLAYER_INDEX || unit.state == DEAD || unit.state == APPEAR
        continue

      if screenLength(playerUnit.pos, unit.pos) <= DAMAGE_SIZE_MUL * (playerUnit.size + unit.size)
        battle(*playerUnit, unit)
        if playerUnit.value > 0.0
          copy(state.lastGamePower, *playerUnit)


def processShortcuts()
  if get_key_up(VK_ESCAPE)
    if !menu.isActive || isPlayerAlive()
      menu.isActive = !menu.isActive
    //schedule_quit_game()


[export]
def act(dt: float)
  processShortcuts()
  actMenu(dt)
  actGame(dt)
