#{ vec2, vec3, vec4, mat2, mat3, mat4, quat } = require 'gl-matrix'
{ vec3, mat4, quat4 } = require 'gl-matrix'
WebGL = require 'node-webgl'
document = WebGL.document()
log = console.log
currentlyPressedKeys = {}
gl = undefined
shaderProgram = undefined
mvMatrix = mat4.create()
pMatrix = mat4.create()
degToRad = (degrees) -> degrees * Math.PI / 180
cubeVertexPositionBuffer = undefined
cubeVertexNormalBuffer = undefined
cubeVerticesColorBuffer = undefined
cubeVertexIndexBuffer = undefined
lastTime = 0
fps = 0
xRot = 0
xSpeed = 5
yRot = 0
ySpeed = -5
z = -5.0


document.on "resize", (evt) ->
  document.createWindow evt.width, evt.height
  gl.viewportWidth = evt.width
  gl.viewportHeight = evt.height
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
  gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
  gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
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

webGLStart = ->
  canvas = document.createElement("cube-canvas")
  document.setTitle "CoffeeScript Node.JS OpenGL Demo" # must occur after above

  # -----------------
  log "init WebGL"
  try
    gl = canvas.getContext("experimental-webgl")
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
    throw "Could not initialize WebGL, sorry :-("
    process.exit -1

  # load shaders
  shaderProgram = gl.createProgram()
  glob = require 'glob'
  files = glob.sync './shaders/*.c'
  shadersFound = false
  fs = require 'fs'
  for file in files
    src = fs.readFileSync file, encoding: 'utf8'
    shader = null
    if file.match /fragment/
      shader = gl.createShader gl.FRAGMENT_SHADER
    else if file.match /shader/
      shader = gl.createShader gl.VERTEX_SHADER
    if shader
      shadersFound = true
      gl.shaderSource shader, src
      gl.compileShader shader
      unless gl.getShaderParameter shader, gl.COMPILE_STATUS
        throw gl.getShaderInfoLog shader
      gl.attachShader shaderProgram, shader
  gl.linkProgram shaderProgram
  unless gl.getProgramParameter shaderProgram, gl.LINK_STATUS
    throw 'Could not initialize shaders. Error: ' + gl.getProgramInfoLog shaderProgram
  gl.useProgram shaderProgram
  shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram, 'aVertexPosition'
  gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
  shaderProgram.vertexColorAttribute = gl.getAttribLocation shaderProgram, 'aVertexColor'
  gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
  shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram, 'uPMatrix'
  shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram, 'uMVMatrix'

  # -----------------
  log "init GL buffers"

  engine = newBuffer: (type, unit, itemSize, itemCount, matrix) ->
    buf = gl.createBuffer()
    gl.bindBuffer gl[type], buf
    gl.bufferData gl[type], new unit(matrix), gl.STATIC_DRAW
    buf.itemSize = itemSize if itemSize
    buf.numItems = itemCount if itemCount
    return buf
  cubeVertexPositionBuffer = engine.newBuffer 'ARRAY_BUFFER', Float32Array, 3, 24, [
    -1.0, -1.0,  1.0,  1.0, -1.0,  1.0,  1.0,  1.0,  1.0, -1.0,  1.0,  1.0, # Front face
    -1.0, -1.0, -1.0, -1.0,  1.0, -1.0,  1.0,  1.0, -1.0,  1.0, -1.0, -1.0, # Back face
    -1.0,  1.0, -1.0, -1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0, -1.0, # Top face
    -1.0, -1.0, -1.0,  1.0, -1.0, -1.0,  1.0, -1.0,  1.0, -1.0, -1.0,  1.0, # Bottom face
     1.0, -1.0, -1.0,  1.0,  1.0, -1.0,  1.0,  1.0,  1.0,  1.0, -1.0,  1.0, # Right face
    -1.0, -1.0, -1.0, -1.0, -1.0,  1.0, -1.0 , 1.0,  1.0, -1.0,  1.0, -1.0  # Left face
  ]
  cubeVertexNormalBuffer = engine.newBuffer 'ARRAY_BUFFER', Float32Array, 3, 24, [
     0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0, # Front face
     0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0, # Back face
     0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0, # Top face
     0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0, # Bottom face
     1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0, # Right face
    -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0  # Left face
  ]
  cubeVerticesColorBuffer = engine.newBuffer 'ARRAY_BUFFER', Float32Array, null, null, [
    1.0, 1.0, 1.0, 0.5,  1.0, 1.0, 1.0, 0.5,  1.0, 1.0, 1.0, 0.5,  1.0, 1.0, 1.0, 0.5, # Front face: white
    1.0, 0.0, 0.0, 0.5,  1.0, 0.0, 0.0, 0.5,  1.0, 0.0, 0.0, 0.5,  1.0, 0.0, 0.0, 0.5, # Back face: red
    0.0, 1.0, 0.0, 0.5,  0.0, 1.0, 0.0, 0.5,  0.0, 1.0, 0.0, 0.5,  0.0, 1.0, 0.0, 0.5, # Top face: green
    0.0, 0.0, 1.0, 0.5,  0.0, 0.0, 1.0, 0.5,  0.0, 0.0, 1.0, 0.5,  0.0, 0.0, 1.0, 0.5, # Bottom face: blue
    1.0, 1.0, 0.0, 0.5,  1.0, 1.0, 0.0, 0.5,  1.0, 1.0, 0.0, 0.5,  1.0, 1.0, 0.0, 0.5, # Right face: yellow
    1.0, 0.0, 1.0, 0.5,  1.0, 0.0, 1.0, 0.5,  1.0, 0.0, 1.0, 0.5,  1.0, 0.0, 1.0, 0.5  # Left face: purple
  ]
  cubeVertexIndexBuffer = engine.newBuffer 'ELEMENT_ARRAY_BUFFER', Uint16Array, 1, 36, [
    0,  1,  2,    0,  2,  3,  # Front face
    4,  5,  6,    4,  6,  7,  # Back face
    8,  9,  10,   8,  10, 11, # Top face
    12, 13, 14,   12, 14, 15, # Bottom face
    16, 17, 18,   16, 18, 19, # Right face
    20, 21, 22,   20, 22, 23  # Left face
  ]

  #---------------
  gl.clearColor 0, 0, 0, 1
  gl.enable gl.DEPTH_TEST
  tick = (timeNow) ->
    drawScene timeNow
    animate timeNow
    gl.finish() # for timing
    document.requestAnimationFrame tick, 0
    return
  tick()
  return

webGLStart()
