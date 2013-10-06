log = console.log
Engine = require './Engine'
engine = new Engine()
ATB = document.AntTweakBar

getShader = (gl, id) ->
  shader = undefined
  return null unless shaders.hasOwnProperty(id)
  str = shaders[id]
  if id.match(/-fs/)
    shader = gl.createShader(gl.FRAGMENT_SHADER)
  else if id.match(/-vs/)
    shader = gl.createShader(gl.VERTEX_SHADER)
  else
    return null
  gl.shaderSource shader, str
  gl.compileShader shader
  unless gl.getShaderParameter(shader, gl.COMPILE_STATUS)
    throw gl.getShaderInfoLog(shader)
    return null
  return shader
fragmentShader = getShader(gl, "shader-fs")
vertexShader = getShader(gl, "shader-vs")
shaderProgram = gl.createProgram()
gl.attachShader shaderProgram, vertexShader
gl.attachShader shaderProgram, fragmentShader
gl.linkProgram shaderProgram
throw "Could not initialise shaders. Error: " + gl.getProgramInfoLog(shaderProgram)  unless gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
gl.useProgram shaderProgram
shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition")
gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
shaderProgram.vertexColorAttribute = gl.getAttribLocation(shaderProgram, "aVertexColor")
gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix")
shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix")

# -----------------
log "init GL buffers"
vertices = [
  # Front face
  -1.0, -1.0,  1.0,
  1.0, -1.0,  1.0,
  1.0,  1.0,  1.0,
  -1.0,  1.0,  1.0,
  # Back face
  -1.0, -1.0, -1.0,
  -1.0,  1.0, -1.0,
  1.0,  1.0, -1.0,
  1.0, -1.0, -1.0,
  # Top face
  -1.0,  1.0, -1.0,
  -1.0,  1.0,  1.0,
  1.0,  1.0,  1.0,
  1.0,  1.0, -1.0,
  # Bottom face
  -1.0, -1.0, -1.0,
  1.0, -1.0, -1.0,
  1.0, -1.0,  1.0,
  -1.0, -1.0,  1.0,
  # Right face
  1.0, -1.0, -1.0,
  1.0,  1.0, -1.0,
  1.0,  1.0,  1.0,
  1.0, -1.0,  1.0,
  # Left face
  -1.0, -1.0, -1.0,
  -1.0, -1.0,  1.0,
  -1.0,  1.0,  1.0,
  -1.0,  1.0, -1.0
]
cubeVertexPositionBuffer = gl.createBuffer()
gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
cubeVertexPositionBuffer.itemSize = 3
cubeVertexPositionBuffer.numItems = 24
vertexNormals = [
  # Front face
  0.0,  0.0,  1.0,
  0.0,  0.0,  1.0,
  0.0,  0.0,  1.0,
  0.0,  0.0,  1.0,
  # Back face
  0.0,  0.0, -1.0,
  0.0,  0.0, -1.0,
  0.0,  0.0, -1.0,
  0.0,  0.0, -1.0,
  # Top face
  0.0,  1.0,  0.0,
  0.0,  1.0,  0.0,
  0.0,  1.0,  0.0,
  0.0,  1.0,  0.0,
  # Bottom face
  0.0, -1.0,  0.0,
  0.0, -1.0,  0.0,
  0.0, -1.0,  0.0,
  0.0, -1.0,  0.0,
  # Right face
  1.0,  0.0,  0.0,
  1.0,  0.0,  0.0,
  1.0,  0.0,  0.0,
  1.0,  0.0,  0.0,
  # Left face
  -1.0,  0.0,  0.0,
  -1.0,  0.0,  0.0,
  -1.0,  0.0,  0.0,
  -1.0,  0.0,  0.0
]
cubeVertexNormalBuffer = gl.createBuffer()
gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexNormalBuffer
gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertexNormals), gl.STATIC_DRAW
cubeVertexNormalBuffer.itemSize = 3
cubeVertexNormalBuffer.numItems = 24
colors = [
  [ 1.0, 1.0, 1.0, 0.5 ], # Front face: white
  [ 1.0, 0.0, 0.0, 0.5 ], # Back face: red
  [ 0.0, 1.0, 0.0, 0.5 ], # Top face: green
  [ 0.0, 0.0, 1.0, 0.5 ], # Bottom face: blue
  [ 1.0, 1.0, 0.0, 0.5 ], # Right face: yellow
  [ 1.0, 0.0, 1.0, 0.5 ]  # Left face: purple
]
generatedColors = []
j = 0
while j < 6
  c = colors[j]
  i = 0

  while i < 4
    generatedColors = generatedColors.concat(c)
    i++
  j++
cubeVerticesColorBuffer = gl.createBuffer()
gl.bindBuffer gl.ARRAY_BUFFER, cubeVerticesColorBuffer
gl.bufferData gl.ARRAY_BUFFER, new Float32Array(generatedColors), gl.STATIC_DRAW
cubeVertexIndices = [
  0, 1, 2,      0, 2, 3,    # Front face
  4, 5, 6,      4, 6, 7,    # Back face
  8, 9, 10,     8, 10, 11,  # Top face
  12, 13, 14,   12, 14, 15, # Bottom face
  16, 17, 18,   16, 18, 19, # Right face
  20, 21, 22,   20, 22, 23  # Left face
]
cubeVertexIndexBuffer = gl.createBuffer()
gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW
cubeVertexIndexBuffer.itemSize = 1
cubeVertexIndexBuffer.numItems = 36

#---------------
log "init AntTweakBar"
ATB.Init()
ATB.Define " GLOBAL help='This example shows how to integrate AntTweakBar with GLFW and OpenGL.' " # Message added to the help bar.
ATB.WindowSize canvas.width, canvas.height
twBar = new ATB.NewBar("Cube")
twBar.AddVar("z", ATB.TYPE_FLOAT,
  getter: (data) -> z
  setter: (val, data) -> z = val
, " label='z' min=-5 max=5 step=0.1 keyIncr=s keyDecr=S help='Eye distance' ")
twBar.AddVar("Orientation", ATB.TYPE_QUAT4F,
  getter: (data) ->
    a = degToRad(xRot) * 0.5
    b = degToRad(yRot) * 0.5
    x1 = Math.sin(a)
    y1 = 0
    z1 = 0
    w1 = Math.cos(a)
    x2 = 0
    y2 = Math.sin(b)
    z2 = 0
    w2 = Math.cos(b)
    return [w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
            w1 * y2 + y1 * w2 + z1 * x2 - x1 * z2,
            w1 * z2 + z1 * w2 + x1 * y2 - y1 * x2,
            w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2]
, " label=Orientation opened=true group=Rotation help='Orientation (degree)' ")

#twBar.AddVar("yRot", ATB.TYPE_FLOAT, {
#    getter: function(data){ return yRot; },
#  },
#  " label='yRot' precision=1 group=Rotation help='y rot (degree)' ");
twBar.AddVar("xSpeed", ATB.TYPE_FLOAT,
  getter: (data) -> xSpeed
  setter: (val, data) -> xSpeed = val
, " label='xSpeed' group=Rotation help='x speed' ")
twBar.AddVar("ySpeed", ATB.TYPE_FLOAT,
  getter: (data) -> ySpeed
  setter: (val, data) -> ySpeed = val
, " label='ySpeed' group=Rotation help='y speed' ")
twBar.AddSeparator "misc"
twBar.AddVar("fps", ATB.TYPE_INT32,
  getter: (data) -> fps
, " label='fps' help='frames per second' ")
#twBar.AddButton("toto",speedup,"dummy value"," label='misc' ");

#---------------
gl.clearColor 0, 0, 0, 1
gl.enable gl.DEPTH_TEST
tick = (timeNow) ->
  drawScene timeNow
  animate timeNow
  drawATB()
  gl.finish() # for timing
  document.requestAnimationFrame tick, 0
  return
tick()
