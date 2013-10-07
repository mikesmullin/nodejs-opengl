###
The job of the Engine should be:
* cross-platform DirectX or OpenGL integration
* cross-platform C-binding or Browser WebGL integration
* cross-platform Audio, KB, Mouse integration
* fast matrix math functions
###

fs = require 'fs'
path = require 'path'
WebGL = require 'node-webgl'
Matrix = require 'gl-matrix'
module.exports = class Engine
  @Matrix: Matrix
  gl: null
  document: null
  lastTime: 0
  fps: 0
  currentlyPressedKeys: {}

  constructor: ->
    @document = WebGL.document()
    canvas = document.createElement 'cube-canvas' # TODO: rename to 'canvas'?
    @gl = canvas.getContext 'experimental-webgl' # TODO: rename to another string?
    @gl.viewportWidth = canvas.width
    @gl.viewportHeight = canvas.height
    @document.setTitle "CoffeeScript Node.JS OpenGL Demo"
    @_bindKeys()
    @_attachShaders()
    # TODO: bind keys
    # TODO: start draw loop?
    return

  # event emitter
  _eventCbs: {}
  on: (event, cb) -> @_eventCbs[event] ?= []; @eventCbs[event].push cb
  emit: (event) -> cb.call this for cb in @_eventCbs[event]

  start: -> # TODO: if this stays small just merge with tick()
    @tick()
    return

  tick: (timeNow) ->
    emit 'tick'
    @gl.finish() # for timing
    @document.requestAnimationFrame @tick, 0
    return

  _bindKeys: ->
    @document.on 'resize', (e) =>
      @document.createWindow e.width, e.height
      @gl.viewportWidth = e.width
      @gl.viewportHeight = e.height
      return

    @document.on 'keyup', (e) =>
      delete @currentlyPressedKeys[e.keyCode]
      return

    @document.on 'keydown', (e) =>
      #console.log '[KEYDOWN] event: ', e
      @currentlyPressedKeys[e.keyCode] = true
      @emit 'keydown'
    return

  _attachShaders: ->
    shaderProgram = @gl.createProgram()
    glob '../shaders/*.c', sync: true, (err, files) =>
      for file in files
        src = fs.readFileSync file, 'utf8'
        shader = null
        if file.match /fragment/
          shader = @gl.createShader @gl.FRAGMENT_SHADER
        else if file.match /shader/
          shader = @gl.createShader @gl.VERTEX_SHADER
        if shader
          @gl.shaderSource shader, src
          @gl.compileShader shader
          if @gl.getShaderParameter shader, @gl.COMPILE_STATUS
            @gl.attachShader shaderProgram, shader
          else
            throw @gl.getShaderInfoLog shader
    @gl.linkProgram shaderProgram
    unless @gl.getProgramParameter shaderProgram, @gl.LINK_STATUS
      throw 'Could not initialize shaders. Error: ' + @gl.getProgramInfoLog shaderProgram
    @gl.useProgram shaderProgram
    shaderProgram.vertexPositionAttribute = @gl.getAttribLocation shaderProgram, 'aVertexPosition'
    @gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
    shaderProgram.vertexColorAttribute = @gl.getAttribLocation shaderProgram, 'aVertexColor'
    @gl.enableVertexAttribArray shaderProgram.vertexColorAttribute
    shaderProgram.pMatrixUniform = @gl.getUniformLocation shaderProgram, 'uPMatrix'
    shaderProgram.mvMatrixUniform = @gl.getUniformLocation shaderProgram, 'uMVMatrix'
    return

  _setupBuffers: ->
  newBuffer: (itemSize, itemCount, matrix) ->
    buf = @gl.createBuffer()
    @gl.bindBuffer gl.ARRAY_BUFFER, buf
    @gl.bufferData gl.ARRAY_BUFFER, new Float32Array(matrix), @gl.STATIC_DRAW
    buf.itemSize = itemSize
    buf.numItems = itemCount
    return buf

    colors = [
      [ 1.0, 1.0, 1.0, 0.5 ], # Front face: white
      [ 1.0, 0.0, 0.0, 0.5 ], # Back face: red
      [ 0.0, 1.0, 0.0, 0.5 ], # Top face: green
      [ 0.0, 0.0, 1.0, 0.5 ], # Bottom face: blue
      [ 1.0, 1.0, 0.0, 0.5 ], # Right face: yellow
      [ 1.0, 0.0, 1.0, 0.5 ]  # Left face: purple
    ]
    generatedColors = []
    j = 0; while ++j <= 6
      c = colors[j]
      i = 0; while ++i <= 4
        generatedColors = generatedColors.concat(c)
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
