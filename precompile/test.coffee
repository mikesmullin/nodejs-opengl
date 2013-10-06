#{ vec2, vec3, vec4, mat2, mat3, mat4, quat } = require 'gl-matrix'
{ vec3, mat4, quat4 } = require 'gl-matrix'
WebGL = require 'node-webgl'
Image = WebGL.Image
document = WebGL.document()
ATB = document.AntTweakBar
log = console.log

currentlyPressedKeys = {}
gl = undefined

shaderProgram = undefined
mvMatrix = mat4.create()
mvMatrixStack = []
pMatrix = mat4.create()
degToRad = (degrees) -> degrees * Math.PI / 180
cubeVertexPositionBuffer = undefined
cubeVertexNormalBuffer = undefined
cubeVerticesColorBuffer = undefined
cubeVertexIndexBuffer = undefined
lastTime = 0
fps = 0
twBar = undefined
xRot = 0
xSpeed = 5
yRot = 0
ySpeed = -5
z = -5.0

# TODO: next line doesn't work; compare test2.coffee example
document.setTitle "CoffeeScript Node.JS OpenGL Demo"

document.on "resize", (evt) ->
  document.createWindow evt.width, evt.height
  gl.viewportWidth = evt.width
  gl.viewportHeight = evt.height

  # make sure AntTweakBar is repositioned correctly and events correct
  ATB.WindowSize evt.width, evt.height
  return

document.on "keyup", (evt) ->
  currentlyPressedKeys[evt.keyCode] = false
  return

document.on "keydown", (evt) ->
  #console.log "[KEYDOWN] evt: ", evt
  currentlyPressedKeys[evt.keyCode] = true
  # handleKeys
  z -= 0.40  if currentlyPressedKeys[93] # ]
  z += 0.40  if currentlyPressedKeys[92] # \
  ySpeed -= 20  if currentlyPressedKeys[285] # Left cursor key
  ySpeed += 20  if currentlyPressedKeys[286] # Right cursor key
  xSpeed -= 20  if currentlyPressedKeys[283] # Up cursor key
  xSpeed += 20  if currentlyPressedKeys[284] # Down cursor key
  #console.log("speed: "+xSpeed+" "+ySpeed+" "+z);
  return

drawScene = ->
  gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
  gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
  mat4.perspective 45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix
  mat4.identity mvMatrix
  mat4.translate mvMatrix, [0.0, 0.0, z]
  mat4.rotate mvMatrix, degToRad(xRot), [1, 0, 0]
  mat4.rotate mvMatrix, degToRad(yRot), [0, 1, 0]
  gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
  gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
  gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA
  gl.enable gl.BLEND
  gl.disable gl.DEPTH_TEST
  gl.bindBuffer gl.ARRAY_BUFFER, cubeVerticesColorBuffer
  gl.vertexAttribPointer shaderProgram.vertexColorAttribute, 4, gl.FLOAT, false, 0, 0
  gl.enable gl.CULL_FACE
  gl.cullFace gl.FRONT
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
  setMatrixUniforms = ->
    gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
    gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
    return
  setMatrixUniforms()
  gl.drawElements gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
  gl.cullFace gl.BACK
  gl.drawElements gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0

  # cleanup GL state
  gl.bindBuffer gl.ARRAY_BUFFER, null
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null
  return

animate = (timeNow) ->
  return  unless timeNow # first time, timeNow may be undefined
  unless lastTime is 0
    elapsed = timeNow - lastTime
    fps = Math.round(1000 / elapsed)
    xRot += (xSpeed * elapsed) / 1000.0
    yRot += (ySpeed * elapsed) / 1000.0
  lastTime = timeNow
  return

drawATB = ->
  # disableProgram
  # Before calling AntTweakBar or any other library that could use programs,
  # one must make sure to disable the VertexAttribArray used by the current
  # program otherwise this may have some unpredictable consequences aka
  # wrong vertex attrib arrays being used by another program!
  gl.disableVertexAttribArray shaderProgram.vertexPositionAttribute
  gl.disableVertexAttribArray shaderProgram.vertexColorAttribute
  gl.useProgram null

  ATB.Draw()

  # enableProgram
  gl.useProgram shaderProgram
  gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
  gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
  return

webGLStart = ->
  canvas = document.createElement("cube-canvas")

  # -----------------
  log "init WebGL"
  try
    gl = canvas.getContext("experimental-webgl")
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
    throw "Could not initialize WebGL, sorry :-("
    process.exit -1

  # -----------------
  log "init GL shaders"
  getShader = (gl, id) ->
    shaders =
      "shader-fs": [
          "#ifdef GL_ES",
          "  precision mediump float;",
          "#endif",
          "varying vec4 vColor;",
          "void main(void) {",
          "    gl_FragColor = vColor;",
          "}"
      ].join("\n"),
      "shader-vs": [
        "attribute vec3 aVertexPosition;",
        "attribute vec4 aVertexColor;",
        "uniform mat4 uMVMatrix;",
        "uniform mat4 uPMatrix;",
        "varying vec4 vColor;",
        "void main(void) {",
        "    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);",
        "    vColor = aVertexColor;",
        "}"
      ].join("\n")

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
  return

webGLStart()
