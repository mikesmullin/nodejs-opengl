###
The job of the Engine should be:
* cross-platform DirectX or OpenGL integration
* cross-platform C-binding or Browser WebGL integration
* cross-platform Audio, KB, Mouse integration
* fast matrix math functions
###

WebGL = require 'node-webgl'
Matrix = require 'gl-matrix'
module.exports = class Engine
  Matrix: Matrix
  gl: null
  fps: 0
  currentlyPressedKeys: {}
  lastTime: 0

  constructor: ->
    document = WebGL.document()
    canvas = document.createElement 'cube-canvas' # TODO: rename to 'canvas'?
    @gl = canvas.getContext 'experimental-webgl' # TDOO: rename to another string?
    @gl.viewportWidth = canvas.width
    @gl.viewportHeight = canvas.height


