options indenting = 2
require daslib/media
require state
require unitDraws
require menu
require common


def draw_more_y(unitDraw, unit, pos, sSize, half)
  if pos.y + half > sSize.y
    invoke(*unitDraw, unit, float2(pos.x, pos.y - sSize.y))
  elif pos.y - half < 0.0
    invoke(*unitDraw, unit, float2(pos.x, sSize.y + pos.y))


[export]
def draw()
  enable_alpha_blend()
  for unit in values(state.units)
    let drawId = (unit.state == APPEAR ? "appear"
      : unit.state == DEAD ? "death"
      : key_exists(unitDraws, unit.uType) ? unit.uType
      : "default")
    find(unitDraws, drawId) <| $(unitDraw)
      if unitDraw == null
        log("Error: Not exist draw {drawId}!!!")
        return

      var pos = screenPoint(unit.pos)
      let half = 0.5 * unit.size
      invoke(*unitDraw, unit, pos)
      draw_more_y(unitDraw, unit, pos, sSize, half)

      if pos.x + half > sSize.x
        let pos2 = float2(pos.x - sSize.x, pos.y)
        invoke(*unitDraw, unit, pos2)
        draw_more_y(unitDraw, unit, pos2, sSize, half)
      elif pos.x - half < 0.0
        let pos2 = float2(sSize.x + pos.x, pos.y)
        invoke(*unitDraw, unit, pos2)
        draw_more_y(unitDraw, unit, pos2, sSize, half)

  drawMenu()