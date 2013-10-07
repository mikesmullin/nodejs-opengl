log = console.log
Engine = require './Engine'
{ vec3, mat4, quat4 } = Engine.Matrix
engine = new Engine()
gl = engine.gl
gl.clearColor 0, 0, 0, 1
gl.enable gl.DEPTH_TEST

xRot = yRot = xSpeed = ySpeed = 0
cubeVertexPositionBuffer = undefined
cubeVertexNormalBuffer = undefined
cubeVerticesColorBuffer = undefined
cubeVertexIndexBuffer = undefined

pMatrix = mat4.create()
mvMatrix = mat4.create()
degToRad = (degrees) -> degrees * Math.PI / 180
engine.on 'tick', -> # draw
  @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
  @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
  mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, pMatrix
  mat4.identity mvMatrix
  mat4.translate mvMatrix, [0.0, 0.0, z]
  mat4.rotate mvMatrix, degToRad(xRot), [1, 0, 0]
  mat4.rotate mvMatrix, degToRad(yRot), [0, 1, 0]
  @gl.bindBuffer @gl.ARRAY_BUFFER, cubeVertexPositionBuffer
  @gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
  @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
  @gl.enable @gl.BLEND
  @gl.disable @gl.DEPTH_TEST
  @gl.bindBuffer @gl.ARRAY_BUFFER, cubeVerticesColorBuffer
  @gl.vertexAttribPointer shaderProgram.vertexColorAttribute, 4, @gl.FLOAT, false, 0, 0
  @gl.enable @gl.CULL_FACE
  @gl.cullFace @gl.FRONT
  @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
  setMatrixUniforms = ->
    @gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
    @gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
    return
  setMatrixUniforms()
  @gl.drawElements @gl.TRIANGLES, cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0
  @gl.cullFace @gl.BACK
  @gl.drawElements @gl.TRIANGLES, cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0

  # cleanup GL state
  @gl.bindBuffer @gl.ARRAY_BUFFER, null
  @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, null
  return

engine.on 'tick', (timeNow) -> # animate
  return unless timeNow # first time, timeNow may be undefined
  unless @lastTime is 0
    elapsed = timeNow - @lastTime
    @fps = Math.round(1000 / elapsed)
    xRot += (xSpeed * elapsed) / 1000.0
    yRot += (ySpeed * elapsed) / 1000.0
  lastTime = timeNow
  return

cubeVertexPositionBuffer = engine.newBuffer 3, 24, [
  -1.0, -1.0,  1.0,  1.0, -1.0,  1.0,  1.0,  1.0,  1.0, -1.0,  1.0,  1.0, # Front face
  -1.0, -1.0, -1.0, -1.0,  1.0, -1.0,  1.0,  1.0, -1.0,  1.0, -1.0, -1.0, # Back face
  -1.0,  1.0, -1.0, -1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0, -1.0, # Top face
  -1.0, -1.0, -1.0,  1.0, -1.0, -1.0,  1.0, -1.0,  1.0, -1.0, -1.0,  1.0, # Bottom face
   1.0, -1.0, -1.0,  1.0,  1.0, -1.0,  1.0,  1.0,  1.0,  1.0, -1.0,  1.0, # Right face
  -1.0, -1.0, -1.0, -1.0, -1.0,  1.0, -1.0 , 1.0,  1.0, -1.0,  1.0, -1.0  # Left face
]

cubeVertexNormalBuffer = engine.newBuffer 3, 24, [
   0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0, # Front face
   0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0, # Back face
   0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0, # Top face
   0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0, # Bottom face
   1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0,  1.0,  0.0,  0.0, # Right face
  -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0, -1.0,  0.0,  0.0  # Left face
]

_colors = [
  1.0, 1.0, 1.0, 0.5, # Front face: white
  1.0, 0.0, 0.0, 0.5, # Back face: red
  0.0, 1.0, 0.0, 0.5, # Top face: green
  0.0, 0.0, 1.0, 0.5, # Bottom face: blue
  1.0, 1.0, 0.0, 0.5, # Right face: yellow
  1.0, 0.0, 1.0, 0.5  # Left face: purple
]
colors = []; colors = colors.concat _colors.slice j*4, (j*4)+4 for i in [0...4] for j in [0...6]
cubeVerticesColorBuffer = engine.newBuffer undefined, undefined,
  arrayRepeat([ 1.0, 1.0, 1.0, 0.5 ], 4).concat # Front face: white
  arrayRepeat([ 1.0, 0.0, 0.0, 0.5 ], 4).concat # Back face: red
  arrayRepeat([ 0.0, 1.0, 0.0, 0.5 ], 4).concat # Top face: green
  arrayRepeat([ 0.0, 0.0, 1.0, 0.5 ], 4).concat # Bottom face: blue
  arrayRepeat([ 1.0, 1.0, 0.0, 0.5 ], 4).concat # Right face: yellow
  arrayRepeat([ 1.0, 0.0, 1.0, 0.5 ], 4)        # Left face: purple











engine.start()
