###
The job of the Engine should be:
* cross-platform DirectX or OpenGL integration
* cross-platform C-binding or Browser WebGL integration
* cross-platform Audio, KB, Mouse integration
* fast matrix math functions
###

fs = require 'fs'
path = require 'path'
glob = require 'glob'
WebGL = require 'node-webgl'
#Matrix = require 'gl-matrix'
Matrix = require './old-gl-matrix'
module.exports = class Engine
  @Matrix: Matrix
  gl: null
  document: null
  lastTime: 0
  fps: 0
  shaderProgram: null
  currentlyPressedKeys: {}

  constructor: ->
    @document = WebGL.document()
    canvas = @document.createElement 'canvas'
    @document.setTitle 'CoffeeScript Node.JS OpenGL Demo'
    @gl = canvas.getContext 'webgl'
    @gl.viewportWidth = canvas.width
    @gl.viewportHeight = canvas.height
    @_bindKeys()
    @_attachShaders()
    return

  # event emitter
  _eventCbs: {}
  on: (event, cb) -> @_eventCbs[event] ?= []; @_eventCbs[event].push cb
  emit: (event, args...) -> cb.apply @, args for cb in @_eventCbs[event] if @_eventCbs[event]

  start: -> # TODO: if this stays small just merge with tick()
    @tick()
    return

  tick: (timeNow) ->
    @emit 'tick', timeNow
    @gl.finish() # for timing
    @document.requestAnimationFrame @tick.bind(@), 0
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

    # Creates fragment shader (returns white color for any position)
    fshader = @gl.createShader(@gl.FRAGMENT_SHADER)
    @gl.shaderSource fshader, "void main(void) {gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);}"
    @gl.compileShader fshader
    alert "Error during fragment shader compilation:\n" + @gl.getShaderInfoLog(fshader)  unless @gl.getShaderParameter(fshader, @gl.COMPILE_STATUS)

    # Creates vertex shader (converts 2D point position to coordinates)
    vshader = @gl.createShader(@gl.VERTEX_SHADER)
    @gl.shaderSource vshader, "attribute vec2 ppos; void main(void) { gl_Position = vec4(ppos.x, ppos.y, 0.0, 1.0);}"
    @gl.compileShader vshader
    alert "Error during vertex shader compilation:\n" + @gl.getShaderInfoLog(vshader)  unless @gl.getShaderParameter(vshader, @gl.COMPILE_STATUS)

    # Creates program and links shaders to it
    program = @gl.createProgram()
    @gl.attachShader program, fshader
    @gl.attachShader program, vshader
    @gl.linkProgram program
    alert "Error during program linking:\n" + @gl.getProgramInfoLog(program)  unless @gl.getProgramParameter(program, @gl.LINK_STATUS)

    # Validates and uses program in the GL context
    @gl.validateProgram program
    alert "Error during program validation:\n" + @gl.getProgramInfoLog(program)  unless @gl.getProgramParameter(program, @gl.VALIDATE_STATUS)
    @gl.useProgram program

    # Gets address of the input 'attribute' of the vertex shader
    vattrib = @gl.getAttribLocation(program, "ppos")
    alert "Error during attribute address retrieval"  if vattrib is -1
    @gl.enableVertexAttribArray vattrib
    @shaderProgram = program
    @vattrib = vattrib

    #@shaderProgram = @gl.createProgram()
    #files = glob.sync './shaders/*.c'
    #return unless files
    #shadersFound = false
    #for file in files
    #  src = fs.readFileSync file, encoding: 'utf8'
    #  shader = null
    #  if file.match /fragment/
    #    shader = @gl.createShader @gl.FRAGMENT_SHADER
    #  else if file.match /shader/
    #    shader = @gl.createShader @gl.VERTEX_SHADER
    #  if shader
    #    shadersFound = true
    #    @gl.shaderSource shader, src
    #    @gl.compileShader shader
    #    unless @gl.getShaderParameter shader, @gl.COMPILE_STATUS
    #      throw @gl.getShaderInfoLog shader
    #    @gl.attachShader @shaderProgram, shader
    #return unless shadersFound
    #@gl.linkProgram @shaderProgram
    #unless @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS
    #  throw 'Could not initialize shaders. Error: ' + @gl.getProgramInfoLog @shaderProgram
    #@gl.useProgram @shaderProgram
    #@shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, 'aVertexPosition'
    #@gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute
    #@shaderProgram.vertexColorAttribute = @gl.getAttribLocation @shaderProgram, 'aVertexColor'
    #@gl.enableVertexAttribArray @shaderProgram.vertexColorAttribute
    #@shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, 'uPMatrix'
    #@shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, 'uMVMatrix'
    return

  newBuffer: (type, unit, itemSize, itemCount, matrix) ->
    buf = @gl.createBuffer()
    @gl.bindBuffer @gl[type], buf
    @gl.bufferData @gl[type], new unit(matrix), @gl.STATIC_DRAW
    buf.itemSize = itemSize if itemSize
    buf.numItems = itemCount if itemCount
    return buf
