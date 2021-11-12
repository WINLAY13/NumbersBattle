options indenting = 2
require daslib/media
require act
require common
require levels
require menu
require draw

// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code


[export]
def initialize
  set_window_title("Numbers battle")
  set_resolution(get_desktop_width() * 2 / 3, get_desktop_height() * 2 / 3)
  initSizes()
  initMenu()
  randomize_seed(seed)
  setLevel(DEF_LEVEL)
  return
