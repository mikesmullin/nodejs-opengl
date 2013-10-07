util = require 'util'
glfw = require 'node-glfw'
log = console.log

version = glfw.GetVersion()
log "glfw " + version.major + "." + version.minor + "." + version.rev

# Initialize GLFW
unless glfw.Init()
  log "Failed to initialize GLFW"
  process.exit -1

# Open OpenGL window
glfw.OpenWindowHint glfw.OPENGL_MAJOR_VERSION, 3
glfw.OpenWindowHint glfw.OPENGL_MINOR_VERSION, 2
# r,g,b,a bits
# depth, stencil bits
unless glfw.OpenWindow 640, 480, 0, 0, 0, 0, 0, 0, glfw.WINDOW
  log "Failed to open GLFW window"
  glfw.Terminate()
  process.exit -1
glfw.SetWindowTitle "Node.JS OpenGL - Woot!"

# testing events
glfw.events.on "keydown", (evt) ->
  log "[keydown] " + util.inspect(evt)

glfw.events.on "mousemove", (evt) ->
  log "[mousemove] " + evt.x + ", " + evt.y

glfw.events.on "mousewheel", (evt) ->
  log "[mousewheel] " + evt.position

glfw.events.on "resize", (evt) ->
  log "[resize] " + evt.width + ", " + evt.height

glVersion = glfw.GetGLVersion() # can only be called after window creation!
log "gl " + glVersion.major + "." + glVersion.minor + "." + glVersion.rev

# Enable sticky keys
glfw.Enable glfw.STICKY_KEYS

# Enable vertical sync (on cards that support it)
glfw.SwapInterval 0 #1
# 0 for vsync off
start = glfw.GetTime()
loop
  # Get time and mouse position
  end = glfw.GetTime()
  delta = end - start
  start = end

  log('time: '+(delta*1000)+'ms');
  mouse = glfw.GetMousePos()

  #log("mouse: "+mouse.x+', '+mouse.y);

  # Get window size (may be different than the requested size)
  wsize = glfw.GetWindowSize()

  #log("window size: "+wsize.width+', '+wsize.height);

  # Swap buffers
  glfw.SwapBuffers()
  break unless not glfw.GetKey(glfw.KEY_ESC) and glfw.GetWindowParam(glfw.OPENED)

# Close OpenGL window and terminate GLFW
glfw.Terminate()
process.exit 0
