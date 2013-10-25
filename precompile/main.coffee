alert = log = console.log
Engine = require './Engine'
{ vec3, mat4, quat4 } = Engine.Matrix
engine = new Engine()

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
xRot = 0.2; yRot = 0.1; xSpeed = 0.2; ySpeed = 0.2
z = -5.0

pMatrix = mat4.create()
mvMatrix = mat4.create()
degToRad = (degrees) -> degrees * Math.PI / 180
engine.on 'tick', -> # draw
  @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
  @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
  #mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, pMatrix
  #mat4.identity mvMatrix
  #mat4.translate mvMatrix, [0.0, 0.0, z]
  #mat4.rotate mvMatrix, degToRad(xRot), [1, 0, 0]
  #mat4.rotate mvMatrix, degToRad(yRot), [0, 1, 0]
  #@gl.bindBuffer @gl.ARRAY_BUFFER, cubeVertexPositionBuffer
  #@gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
  #@gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
  #@gl.enable @gl.BLEND
  #@gl.disable @gl.DEPTH_TEST
  #@gl.bindBuffer @gl.ARRAY_BUFFER, cubeVerticesColorBuffer
  #@gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, 4, @gl.FLOAT, false, 0, 0
  #@gl.enable @gl.CULL_FACE
  #@gl.cullFace @gl.FRONT
  #@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
  #@gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
  #@gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix
  #@gl.drawElements @gl.TRIANGLES, cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0
  #@gl.cullFace @gl.BACK
  #@gl.drawElements @gl.TRIANGLES, cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0



  # Initializes the vertex buffer and sets it as current one
  vbuffer = @gl.createBuffer()
  @gl.bindBuffer @gl.ARRAY_BUFFER, vbuffer

  # Puts vertices to buffer and links it to attribute variable 'ppos'
  vertices = new Float32Array([0.0, 0.5, -0.5, -0.5, 0.5, -0.5])
  @gl.bufferData @gl.ARRAY_BUFFER, vertices, @gl.STATIC_DRAW
  @gl.vertexAttribPointer @vattrib, 2, @gl.FLOAT, false, 0, 0

  # Draws the object
  @gl.drawArrays @gl.TRIANGLES, 0, 3
  @gl.flush()

  ## cleanup GL state
  #@gl.bindBuffer @gl.ARRAY_BUFFER, null
  #@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, null
  return

engine.gl.clearColor 0, 0, 0, 1
engine.gl.enable engine.gl.DEPTH_TEST
engine.start()
